import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String phone;
  final String? photoUrl;
  final double tariffRateKwh;
  final double alertThresholdKwh;
  final bool notificationsEnabled;
  final String themeMode;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.phone = '',
    this.photoUrl,
    this.tariffRateKwh = 362.5,
    this.alertThresholdKwh = 500.0,
    this.notificationsEnabled = true,
    this.themeMode = 'dark',
    required this.createdAt,
  });

  factory UserModel.fromFirestore(String uid, Map<String, dynamic> d) {
    return UserModel(
      uid: uid,
      displayName: d['name'] ?? d['display_name'] ?? 'Usuario',
      email: d['email'] ?? '',
      phone: d['phone'] ?? '',
      photoUrl: d['photoUrl'] ?? d['photo_url'],
      tariffRateKwh: (d['tariff_rate_kwh'] as num?)?.toDouble() ?? 362.5,
      alertThresholdKwh: (d['alert_threshold_kwh'] as num?)?.toDouble() ?? 500.0,
      notificationsEnabled: d['notifications_enabled'] ?? true,
      themeMode: d['theme_mode'] ?? 'dark',
      createdAt: d['createdAt'] is Timestamp
          ? (d['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': displayName,
        'email': email,
        'phone': phone,
        'photo_url': photoUrl,
        'tariff_rate_kwh': tariffRateKwh,
        'alert_threshold_kwh': alertThresholdKwh,
        'notifications_enabled': notificationsEnabled,
        'theme_mode': themeMode,
      };

  UserModel copyWith({
    String? displayName,
    String? phone,
    String? photoUrl,
    double? tariffRateKwh,
    double? alertThresholdKwh,
    bool? notificationsEnabled,
    String? themeMode,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      tariffRateKwh: tariffRateKwh ?? this.tariffRateKwh,
      alertThresholdKwh: alertThresholdKwh ?? this.alertThresholdKwh,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
      createdAt: createdAt,
    );
  }
}
