import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/alert_model.dart';

class AlertService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  String get _uid => _auth.currentUser!.uid;
  CollectionReference get _col =>
      _db.collection('users').doc(_uid).collection('alerts');

  /// Stream de alertas en tiempo real (ordenadas por fecha desc)
  Stream<List<AlertModel>> getAlertsStream() {
    return _col
        .orderBy('triggered_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(AlertModel.fromFirestore).toList());
  }

  /// Número de alertas no leídas (para badge)
  Stream<int> getUnreadCountStream() {
    return _col
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.size);
  }

  /// Marcar alerta como leída
  Future<void> markAsRead(String alertId) async {
    await _col.doc(alertId).update({'is_read': true});
  }

  /// Marcar todas como leídas
  Future<void> markAllAsRead() async {
    final snap = await _col.where('is_read', isEqualTo: false).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'is_read': true});
    }
    await batch.commit();
  }

  /// Verificar consumo y crear alerta si supera el umbral
  Future<void> checkAndCreateAlert({
    required double currentMonthlyKwh,
    required double thresholdKwh,
  }) async {
    if (currentMonthlyKwh < thresholdKwh) return;

    // Verificar si ya existe una alerta activa del mismo tipo este mes
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final existing = await _col
        .where('type', isEqualTo: AlertType.thresholdExceeded.name)
        .where('triggered_at',
            isGreaterThan: Timestamp.fromDate(startOfMonth))
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return; // Ya existe

    final alert = AlertModel(
      alertId: _uuid.v4(),
      type: AlertType.thresholdExceeded,
      title: '⚡ Consumo elevado detectado',
      message:
          'Tu consumo mensual (${currentMonthlyKwh.toStringAsFixed(1)} kWh) '
          'superó el umbral de ${thresholdKwh.toStringAsFixed(0)} kWh.',
      severity: AlertSeverity.high,
      triggeredAt: now,
      thresholdKwh: thresholdKwh,
      actualKwh: currentMonthlyKwh,
    );

    await _col.doc(alert.alertId).set(alert.toFirestore());
  }

  /// Crear alerta de dispositivo inactivo
  Future<void> createDeviceInactiveAlert(String deviceId, String deviceName) async {
    final alert = AlertModel(
      alertId: _uuid.v4(),
      type: AlertType.deviceInactive,
      title: '🔌 Dispositivo inactivo',
      message: '"$deviceName" está activo pero sin variación de consumo en 24h.',
      severity: AlertSeverity.low,
      triggeredAt: DateTime.now(),
      deviceId: deviceId,
    );
    await _col.doc(alert.alertId).set(alert.toFirestore());
  }
}
