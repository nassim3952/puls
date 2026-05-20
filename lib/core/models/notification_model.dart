enum NotificationType { alertPatient, system, admin }
enum NotificationSeverity { info, warning, critical }

class NotificationModel {
  final String id;
  final String hospitalId;
  final String? userId;
  final NotificationType type;
  final NotificationSeverity severity;
  final String title;
  final String? body;
  final bool isRead;
  final DateTime? readAt;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.hospitalId,
    this.userId,
    required this.type,
    required this.severity,
    required this.title,
    this.body,
    required this.isRead,
    this.readAt,
    required this.metadata,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      hospitalId: map['hospital_id'] as String,
      userId: map['user_id'] as String?,
      type: _parseType(map['type'] as String),
      severity: _parseSeverity(map['severity'] as String),
      title: map['title'] as String,
      body: map['body'] as String?,
      isRead: map['is_read'] as bool,
      readAt: map['read_at'] != null ? DateTime.parse(map['read_at']) : null,
      metadata: (map['metadata'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  static NotificationType _parseType(String v) => switch (v) {
    'alert_patient' => NotificationType.alertPatient,
    'admin' => NotificationType.admin,
    _ => NotificationType.system,
  };

  static NotificationSeverity _parseSeverity(String v) => switch (v) {
    'warning' => NotificationSeverity.warning,
    'critical' => NotificationSeverity.critical,
    _ => NotificationSeverity.info,
  };

  NotificationModel copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationModel(
      id: id,
      hospitalId: hospitalId,
      userId: userId,
      type: type,
      severity: severity,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      metadata: metadata,
      createdAt: createdAt,
    );
  }
}

// ── State ─────────────────────────────────────────────────────────────────────
class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
