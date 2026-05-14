import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertSeverity { low, medium, high }

enum AlertType { thresholdExceeded, deviceInactive, hourlySpike, tariffPeak }

class AlertModel {
  final String alertId;
  final AlertType type;
  final String title;
  final String message;
  final AlertSeverity severity;
  final bool isRead;
  final DateTime triggeredAt;
  final double? thresholdKwh;
  final double? actualKwh;
  final String? deviceId;

  AlertModel({
    required this.alertId,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    this.isRead = false,
    required this.triggeredAt,
    this.thresholdKwh,
    this.actualKwh,
    this.deviceId,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AlertModel(
      alertId: doc.id,
      type: _parseType(d['type']),
      title: d['title'] ?? 'Alerta',
      message: d['message'] ?? '',
      severity: _parseSeverity(d['severity']),
      isRead: d['is_read'] ?? false,
      triggeredAt: d['triggered_at'] is Timestamp
          ? (d['triggered_at'] as Timestamp).toDate()
          : DateTime.now(),
      thresholdKwh: (d['threshold_kwh'] as num?)?.toDouble(),
      actualKwh: (d['actual_kwh'] as num?)?.toDouble(),
      deviceId: d['device_id'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'type': type.name,
        'title': title,
        'message': message,
        'severity': severity.name,
        'is_read': isRead,
        'triggered_at': Timestamp.fromDate(triggeredAt),
        'threshold_kwh': thresholdKwh,
        'actual_kwh': actualKwh,
        'device_id': deviceId,
      };

  static AlertType _parseType(String? v) {
    return AlertType.values.firstWhere(
      (e) => e.name == v,
      orElse: () => AlertType.thresholdExceeded,
    );
  }

  static AlertSeverity _parseSeverity(String? v) {
    return AlertSeverity.values.firstWhere(
      (e) => e.name == v,
      orElse: () => AlertSeverity.medium,
    );
  }
}
