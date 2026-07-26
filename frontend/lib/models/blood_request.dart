/// A request for blood, as stored in Firestore and sent to the backend.
class BloodRequest {
  final String? id;
  final String fullName;
  final String bloodGroup;
  final String location;
  final String? phoneNumber;
  final String urgency; // 'Urgent' or 'Not Urgent'
  final String? note;

  const BloodRequest({
    this.id,
    required this.fullName,
    required this.bloodGroup,
    required this.location,
    this.phoneNumber,
    this.urgency = 'Not Urgent',
    this.note,
  });

  bool get isUrgent => urgency == 'Urgent';

  /// Shape written to `bloodRequests/{id}`. Delivery counters
  /// (`notifiedCount`, `notifiedAt`, …) are added by the backend.
  Map<String, dynamic> toFirestore() => {
    'fullName': fullName,
    'bloodGroup': bloodGroup,
    'location': location,
    'phoneNumber': phoneNumber,
    'urgency': urgency,
    'isUrgent': isUrgent,
    'note': note,
    'status': 'open',
  };

  Map<String, dynamic> toJson({String? requestId, String? requesterFcmToken}) => {
    if (requestId != null) 'requestId': requestId,
    'fullName': fullName,
    'bloodGroup': bloodGroup,
    'location': location,
    if (phoneNumber != null && phoneNumber!.isNotEmpty)
      'phoneNumber': phoneNumber,
    'urgency': urgency,
    if (note != null && note!.isNotEmpty) 'note': note,
    if (requesterFcmToken != null) 'requesterFcmToken': requesterFcmToken,
  };

  /// Builds a request out of an incoming FCM `data` payload, so a donor's
  /// device can show who is asking.
  factory BloodRequest.fromNotificationData(Map<String, dynamic> data) {
    String value(String key) => (data[key] ?? '').toString();
    return BloodRequest(
      id: value('requestId').isEmpty ? null : value('requestId'),
      fullName: value('fullName').isEmpty ? 'Someone' : value('fullName'),
      bloodGroup: value('bloodGroup'),
      location: value('location'),
      phoneNumber: value('phoneNumber').isEmpty ? null : value('phoneNumber'),
      urgency: value('urgency') == 'Urgent' ? 'Urgent' : 'Not Urgent',
      note: value('note').isEmpty ? null : value('note'),
    );
  }
}

/// The backend's answer to "how many people did my request reach?".
class BroadcastResult {
  /// Devices Firebase Cloud Messaging accepted the push for.
  final int notifiedCount;

  /// Registered users holding a push token (excluding the requester).
  final int totalRegisteredUsers;

  /// How many of those can actually donate to the requested blood group.
  final int compatibleDonorCount;

  /// Pushes FCM rejected — uninstalled app, stale token, …
  final int failedCount;

  final String requestId;
  final String message;
  final bool alreadyNotified;

  const BroadcastResult({
    required this.requestId,
    this.notifiedCount = 0,
    this.totalRegisteredUsers = 0,
    this.compatibleDonorCount = 0,
    this.failedCount = 0,
    this.alreadyNotified = false,
    this.message = '',
  });

  factory BroadcastResult.fromJson(Map<String, dynamic> json) {
    int intOf(String key) => (json[key] as num?)?.toInt() ?? 0;
    return BroadcastResult(
      requestId: (json['requestId'] ?? '').toString(),
      notifiedCount: intOf('notifiedCount'),
      totalRegisteredUsers: intOf('totalRegisteredUsers'),
      compatibleDonorCount: intOf('compatibleDonorCount'),
      failedCount: intOf('failedCount'),
      alreadyNotified: json['alreadyNotified'] == true,
      message: (json['message'] ?? '').toString(),
    );
  }
}
