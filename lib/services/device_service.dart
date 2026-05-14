import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/device_model.dart';

class DeviceService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  String get _uid => _auth.currentUser!.uid;
  CollectionReference get _col =>
      _db.collection('users').doc(_uid).collection('devices');

  /// Stream en tiempo real de todos los dispositivos del usuario
  Stream<List<DeviceModel>> getDevicesStream() {
    return _col.orderBy('name').snapshots().map(
          (snap) => snap.docs.map(DeviceModel.fromFirestore).toList(),
        );
  }

  /// Solo dispositivos activos (para el dashboard)
  Stream<List<DeviceModel>> getActiveDevicesStream() {
    return _col
        .where('is_active', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map(DeviceModel.fromFirestore).toList());
  }

  /// Crear un nuevo dispositivo
  Future<void> addDevice(DeviceModel device) async {
    final id = device.deviceId.isEmpty ? _uuid.v4() : device.deviceId;
    await _col.doc(id).set(device.toFirestore());
  }

  /// Actualizar dispositivo existente
  Future<void> updateDevice(DeviceModel device) async {
    await _col.doc(device.deviceId).update(device.toFirestore());
  }

  /// Eliminar dispositivo
  Future<void> deleteDevice(String deviceId) async {
    await _col.doc(deviceId).delete();
  }

  /// Toggle activo / inactivo
  Future<void> toggleActive(String deviceId, bool isActive) async {
    await _col.doc(deviceId).update({
      'is_active': isActive,
      'updated_at': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Calcular kWh total mensual estimado de todos los dispositivos
  Future<double> getTotalMonthlyKwh() async {
    final snap = await _col.get();
    double total = 0;
    for (final doc in snap.docs) {
      final d = DeviceModel.fromFirestore(doc);
      total += d.monthlyKwh;
    }
    return total;
  }
}