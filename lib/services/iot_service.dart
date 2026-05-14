import 'dart:math';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class IotService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();
  final _rng = Random();
  static const _defaultBackendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  String get _uid => _auth.currentUser!.uid;
  CollectionReference<Map<String, dynamic>> get _devicesCol =>
      _db.collection('users').doc(_uid).collection('iot_devices');

  Stream<List<Map<String, dynamic>>> getDevicesStream() {
    return _devicesCol.orderBy('created_at', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  Future<Map<String, dynamic>> registerRealDevice({
    required String name,
    required String type,
    required String location,
    String? backendBaseUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final idToken = await user.getIdToken();
    final baseUrl = (backendBaseUrl ?? _defaultBackendBaseUrl).trim();
    final url = Uri.parse('$baseUrl/api/devices/register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'name': name,
        'type': type,
        'location': location,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('No se pudo registrar dispositivo real (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data;
  }

  Future<void> addSimulatedDevice({
    required String name,
    required String type,
  }) async {
    final now = DateTime.now();
    await _devicesCol.doc(_uuid.v4()).set({
      'name': name,
      'type': type,
      'is_connected': false,
      'mode': 'simulated',
      'last_seen_at': null,
      'last_power_watts': 0.0,
      'created_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
    });
  }

  Future<void> setConnection(String deviceId, bool isConnected) async {
    final now = DateTime.now();
    await _devicesCol.doc(deviceId).update({
      'is_connected': isConnected,
      'last_seen_at': isConnected ? Timestamp.fromDate(now) : null,
      'updated_at': Timestamp.fromDate(now),
    });
  }

  Future<void> removeDevice(String deviceId) async {
    await _devicesCol.doc(deviceId).delete();
  }

  Future<void> runSimulationStep() async {
    final snap = await _devicesCol.where('is_connected', isEqualTo: true).get();
    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    final now = DateTime.now();
    for (final doc in snap.docs) {
      final watts = 60 + _rng.nextInt(900) + _rng.nextDouble();
      batch.update(doc.reference, {
        'last_power_watts': watts,
        'last_seen_at': Timestamp.fromDate(now),
        'updated_at': Timestamp.fromDate(now),
      });
    }
    await batch.commit();
  }
}
