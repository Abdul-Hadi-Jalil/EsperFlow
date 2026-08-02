import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esperflow/config/api_config.dart';
import 'package:esperflow/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Raised when a donor registration could not be saved.
class DonorRegistrationException implements Exception {
  final String message;

  const DonorRegistrationException(this.message);

  @override
  String toString() => message;
}

/// Outcome of registering, so the UI can say what actually happened.
class DonorRegistration {
  final String donorId;

  /// False when the user denied notification permission — they are registered
  /// but the backend has no way to reach them.
  final bool canReceiveRequests;

  /// True when an existing registration for this device was updated rather
  /// than a duplicate created.
  final bool updatedExisting;

  const DonorRegistration({
    required this.donorId,
    required this.canReceiveRequests,
    required this.updatedExisting,
  });
}

/// Registering as a blood donor.
///
/// This is the only place an FCM token is stored, so the `donors` collection
/// defines who a blood request broadcast can reach — see the backend's
/// `fetch_audience()`.
class DonorService {
  const DonorService._();

  static const String _collection = 'donors';

  /// Survives app updates and token rotation (but not an uninstall, which
  /// clears both this and the FCM registration).
  static const String _donorIdKey = 'esperflow.donorId';

  static CollectionReference<Map<String, dynamic>> get _donors =>
      FirebaseFirestore.instance.collection(_collection);

  static Future<DonorRegistration> register({
    required String fullName,
    required String bloodGroup,
    String? location,
    String? phoneNumber,
    String? availability,
    bool allowCalls = true,
    bool activeDonorStatus = true,
  }) async {
    final token = await _liveToken();

    try {
      final existing = await _existingDoc(token);
      final isUpdate = existing != null;
      final doc = existing ?? _donors.doc(const Uuid().v4());

      await doc.set({
        'fullName': fullName,
        'location': location ?? '',
        'phoneNumber': phoneNumber ?? '',
        'availability': availability ?? '',
        'bloodGroup': bloodGroup,
        'allowCalls': allowCalls,
        'activeDonorStatus': activeDonorStatus,
        'fcmToken': token,
        if (!isUpdate) 'registeredAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _rememberDonorId(doc.id);

      return DonorRegistration(
        donorId: doc.id,
        canReceiveRequests: token != null,
        updatedExisting: isUpdate,
      );
    } on FirebaseException catch (e) {
      throw DonorRegistrationException(
        'Could not save your registration: ${e.message ?? e.code}',
      );
    }
  }

  /// Re-attaches the current FCM token to this device's registration.
  ///
  /// Call on every app start. Tokens rotate, and the backend deletes any token
  /// FCM rejects — without this, a donor whose token changed once would stay
  /// silently unreachable for good, because the token was the only thing
  /// linking the device to its document.
  static Future<void> syncToken() async {
    final donorId = await savedDonorId();
    if (donorId == null) return;

    try {
      final doc = _donors.doc(donorId);
      final snapshot = await doc.get();
      // Registration deleted server-side: leave it deleted, do not resurrect.
      if (!snapshot.exists) return;

      final data = snapshot.data() ?? {};
      final storedToken = data['fcmToken'] as String?;
      var token = NotificationService.token;

      // The backend deletes any token FCM rejects and stamps
      // tokenInvalidatedAt. If that happened, the token this device is holding
      // is dead — writing it back would just get it pruned again, so force the
      // SDK to mint a new one first.
      if (storedToken == null && data['tokenInvalidatedAt'] != null) {
        debugPrint('Stored token was rejected by FCM; rotating this device\'s token');
        token = await NotificationService.rotateToken() ?? token;
      }

      if (token == null || storedToken == token) return;

      await doc.update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Re-attached an FCM token to donor $donorId');
    } catch (e) {
      debugPrint('Could not sync the donor token: $e');
    }
  }

  /// A token FCM will actually deliver to.
  ///
  /// A device can hold a token the server has already retired — after an
  /// uninstall, Android Auto Backup restores the old registration into the
  /// app's preferences, so `getToken()` keeps returning a value that FCM
  /// answers `NotRegistered` for. Only the server can tell the difference, so
  /// ask it, and rotate the token if ours is dead.
  ///
  /// Best effort: if the backend cannot be reached the current token is used
  /// anyway — registering with a possibly-dead token beats not registering.
  static Future<String?> _liveToken() async {
    final token = await NotificationService.requestPermissionAndToken();
    if (token == null) return null;

    final verdict = await _verifyWithBackend(token);
    if (verdict != false) return token; // valid, or could not check

    debugPrint('FCM rejected this device\'s token; rotating before registering');
    return await NotificationService.rotateToken() ?? token;
  }

  /// True/false from the backend, or null when the check could not run.
  static Future<bool?> _verifyWithBackend(String token) async {
    try {
      final response = await http
          .post(
            ApiConfig.endpoint('/api/donors/verify-token'),
            headers: ApiConfig.headers,
            body: jsonEncode({'token': token}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;
      return (jsonDecode(response.body) as Map<String, dynamic>)['valid'] == true;
    } catch (e) {
      debugPrint('Could not verify the FCM token with the backend: $e');
      return null;
    }
  }

  /// This device's donor document id, if it has ever registered.
  static Future<String?> savedDonorId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_donorIdKey);
    } catch (e) {
      debugPrint('Could not read the saved donor id: $e');
      return null;
    }
  }

  static Future<void> _rememberDonorId(String donorId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_donorIdKey, donorId);
    } catch (e) {
      debugPrint('Could not persist the donor id: $e');
    }
  }

  /// Finds this device's existing registration so re-submitting updates it
  /// instead of piling up duplicates.
  ///
  /// The locally saved id is authoritative — it still works after the backend
  /// has pruned a dead token. The token lookup is the fallback for a device
  /// that registered before this id was being stored.
  static Future<DocumentReference<Map<String, dynamic>>?> _existingDoc(
    String? token,
  ) async {
    final donorId = await savedDonorId();
    if (donorId != null) {
      final doc = _donors.doc(donorId);
      if ((await doc.get()).exists) return doc;
    }

    if (token == null) return null;
    final matches = await _donors
        .where('fcmToken', isEqualTo: token)
        .limit(1)
        .get();
    return matches.docs.isEmpty ? null : matches.docs.first.reference;
  }
}
