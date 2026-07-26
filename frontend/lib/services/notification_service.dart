import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esperflow/models/blood_request.dart';
import 'package:esperflow/widgets/incoming_request_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Handles pushes that arrive while the app is terminated or in the background.
///
/// Must be a top-level function: Flutter spins up a separate isolate for it,
/// which is also why Firebase has to be initialised again here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background blood request: ${message.data['requestId']}');
  // The notification itself is drawn by the OS from the `notification` block
  // the backend sends, so there is nothing to display here.
}

/// The receiving half of Cloud Messaging: permission, token upkeep, and showing
/// an incoming blood request to the user.
///
/// The sending half lives in the FastAPI backend — a client can never be trusted
/// with the Admin credentials required to push to other devices.
class NotificationService {
  const NotificationService._();

  /// Lets us show a dialog from a push, where there is no `BuildContext`.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static String? _cachedToken;

  /// The FCM token of this device, if notifications were granted.
  static String? get token => _cachedToken;

  /// Wires up the listeners. Call once from `main()` after Firebase init.
  ///
  /// Never throws: losing notifications must not stop the app from starting.
  static Future<void> initialize() async {
    try {
      await _wireUp();
    } catch (e) {
      debugPrint('Notifications unavailable: $e');
    }
  }

  static Future<void> _wireUp() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // App in the foreground: the OS shows nothing on Android, so we do.
    FirebaseMessaging.onMessage.listen((message) {
      if (_isBloodRequest(message)) _showRequest(message);
    });

    // Notification tapped while the app sat in the background.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (_isBloodRequest(message)) _showRequest(message);
    });

    // Notification tapped while the app was terminated.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null && _isBloodRequest(initialMessage)) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showRequest(initialMessage),
      );
    }

    // Tokens rotate (reinstall, restore, cache clear). Keep Firestore current
    // or this device silently drops off the broadcast list.
    _messaging.onTokenRefresh.listen(_replaceStoredToken);

    // Pick up an already granted token without prompting.
    _cachedToken = await _messaging.getToken();
  }

  /// Asks for notification permission (if not already answered) and returns the
  /// device token. Returns null when the user declined.
  static Future<String?> requestPermissionAndToken() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!granted) return null;

      _cachedToken = await _messaging.getToken();
      return _cachedToken;
    } catch (e) {
      debugPrint('Could not obtain an FCM token: $e');
      return null;
    }
  }

  static bool _isBloodRequest(RemoteMessage message) =>
      message.data['type'] == 'blood_request';

  static void _showRequest(RemoteMessage message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (_) => IncomingRequestDialog(
        request: BloodRequest.fromNotificationData(message.data),
      ),
    );
  }

  /// Moves the token forward on every donor document that still holds the old
  /// one, so the backend keeps reaching this device.
  static Future<void> _replaceStoredToken(String newToken) async {
    final previousToken = _cachedToken;
    _cachedToken = newToken;
    if (previousToken == null || previousToken == newToken) return;

    try {
      final stale = await FirebaseFirestore.instance
          .collection('donors')
          .where('fcmToken', isEqualTo: previousToken)
          .get();

      for (final doc in stale.docs) {
        await doc.reference.update({'fcmToken': newToken});
      }
    } catch (e) {
      debugPrint('Could not refresh the stored FCM token: $e');
    }
  }
}
