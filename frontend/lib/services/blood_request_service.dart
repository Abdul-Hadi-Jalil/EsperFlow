import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esperflow/config/api_config.dart';
import 'package:esperflow/models/blood_request.dart';
import 'package:esperflow/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Raised when a request could not be delivered. [savedToFirebase] tells the UI
/// whether the data survived, so the user is not asked to type it all again.
class BloodRequestException implements Exception {
  final String message;
  final String? requestId;
  final bool savedToFirebase;

  const BloodRequestException(
    this.message, {
    this.requestId,
    this.savedToFirebase = false,
  });

  @override
  String toString() => message;
}

/// Submitting a blood request: save it in Firestore, then ask the backend to
/// push it to every registered user and report how many were reached.
class BloodRequestService {
  const BloodRequestService._();

  static const String _collection = 'bloodRequests';

  static Future<BroadcastResult> submit(BloodRequest request) async {
    // The requester's own token: it is excluded from the broadcast so nobody is
    // notified about their own request.
    final requesterToken = await NotificationService.requestPermissionAndToken();

    final documentRef = await _saveToFirestore(request, requesterToken);
    return _broadcast(request, documentRef.id, requesterToken);
  }

  static Future<DocumentReference<Map<String, dynamic>>> _saveToFirestore(
    BloodRequest request,
    String? requesterToken,
  ) async {
    try {
      return await FirebaseFirestore.instance.collection(_collection).add({
        ...request.toFirestore(),
        'requesterFcmToken': requesterToken,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw BloodRequestException(
        'Could not save your request: ${e.message ?? e.code}',
      );
    }
  }

  /// Hands the saved request to the backend, which owns the Admin credentials
  /// needed to actually deliver a push.
  static Future<BroadcastResult> _broadcast(
    BloodRequest request,
    String requestId,
    String? requesterToken,
  ) async {
    try {
      final response = await http
          .post(
            ApiConfig.endpoint('/api/blood-requests'),
            headers: ApiConfig.headers,
            body: jsonEncode(
              request.toJson(
                requestId: requestId,
                requesterFcmToken: requesterToken,
              ),
            ),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BroadcastResult.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      throw BloodRequestException(
        _serverError(response),
        requestId: requestId,
        savedToFirebase: true,
      );
    } on BloodRequestException {
      rethrow;
    } on TimeoutException {
      throw BloodRequestException(
        'The server took too long to respond. Your request was saved and can '
        'be sent again.',
        requestId: requestId,
        savedToFirebase: true,
      );
    } on SocketException {
      throw BloodRequestException(
        'Could not reach the notification server (${ApiConfig.baseUrl}). Your '
        'request was saved, but donors have not been notified yet.',
        requestId: requestId,
        savedToFirebase: true,
      );
    } catch (e) {
      debugPrint('Broadcast failed: $e');
      throw BloodRequestException(
        'Your request was saved, but notifying donors failed. Please try again.',
        requestId: requestId,
        savedToFirebase: true,
      );
    }
  }

  static String _serverError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['detail'] != null) {
        final detail = decoded['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          // FastAPI validation errors.
          return detail
              .map((e) => (e is Map ? e['msg'] : e).toString())
              .join('\n');
        }
      }
    } catch (_) {
      // Fall through to the generic message below.
    }
    return 'The server rejected the request (HTTP ${response.statusCode}).';
  }

  /// Re-sends a request that was saved but never broadcast.
  static Future<BroadcastResult> resend(String requestId) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/blood-requests/$requestId/notify'),
          headers: ApiConfig.headers,
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BroadcastResult.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw BloodRequestException(
      _serverError(response),
      requestId: requestId,
      savedToFirebase: true,
    );
  }
}
