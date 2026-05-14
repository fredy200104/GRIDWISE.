import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  String get uid => _auth.currentUser!.uid;

  DocumentReference get _userDoc => _db.collection('users').doc(uid);

  /// Stream del perfil del usuario en tiempo real
  Stream<UserModel> getUserProfileStream() {
    return _userDoc.snapshots().map((snap) {
      final data = snap.data() as Map<String, dynamic>? ?? {};
      return UserModel.fromFirestore(uid, data);
    });
  }

  /// Obtener perfil una sola vez
  Future<UserModel?> getUserProfile() async {
    final snap = await _userDoc.get();
    if (!snap.exists) return null;
    return UserModel.fromFirestore(uid, snap.data() as Map<String, dynamic>);
  }

  /// Actualizar nombre en Auth + Firestore
  Future<void> updateDisplayName(String name) async {
    await currentUser?.updateDisplayName(name);
    await _userDoc.update({
      'name': name,
      'last_updated': FieldValue.serverTimestamp(),
    });
  }

  /// Actualizar teléfono
  Future<void> updatePhone(String phone) async {
    await _userDoc.update({'phone': phone});
  }

  /// Actualizar preferencias energéticas
  Future<void> updatePreferences({
    double? tariffRateKwh,
    double? alertThresholdKwh,
    bool? notificationsEnabled,
    String? themeMode,
  }) async {
    final updates = <String, dynamic>{};
    if (tariffRateKwh != null) updates['tariff_rate_kwh'] = tariffRateKwh;
    if (alertThresholdKwh != null) updates['alert_threshold_kwh'] = alertThresholdKwh;
    if (notificationsEnabled != null) {
      updates['notifications_enabled'] = notificationsEnabled;
    }
    if (themeMode != null) updates['theme_mode'] = themeMode;
    if (updates.isNotEmpty) await _userDoc.update(updates);
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Asegurarse de que el documento del usuario tenga todos los campos esperados
  Future<void> ensureUserDocument() async {
    final snap = await _userDoc.get();
    if (!snap.exists) return;
    final data = snap.data() as Map<String, dynamic>;

    final updates = <String, dynamic>{};
    if (!data.containsKey('tariff_rate_kwh')) updates['tariff_rate_kwh'] = 362.5;
    if (!data.containsKey('alert_threshold_kwh')) {
      updates['alert_threshold_kwh'] = 500.0;
    }
    if (!data.containsKey('notifications_enabled')) {
      updates['notifications_enabled'] = true;
    }
    if (!data.containsKey('theme_mode')) updates['theme_mode'] = 'dark';

    if (updates.isNotEmpty) await _userDoc.update(updates);
  }
}
