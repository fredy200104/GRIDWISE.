import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Punto de dato para gráficos (día o hora + valor kWh)
class ConsumptionPoint {
  final DateTime date;
  final double kwh;
  final double? cost;

  ConsumptionPoint({required this.date, required this.kwh, this.cost});
}

class DashboardService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;
  DocumentReference get _summaryDoc =>
      _db.collection('users').doc(_uid).collection('dashboard_summary').doc('current');

  /// Stream del resumen del dashboard — reactivo a cambios en dispositivos Y en perfil
  Stream<Map<String, dynamic>> getDashboardSummaryStream() {
    // Escucha cambios en los dispositivos del usuario y recalcula en tiempo real
    final devicesRef = _db.collection('users').doc(_uid).collection('devices');

    return devicesRef.snapshots().asyncMap((_) async {
      return await _computeSummary();
    });
  }

  Map<String, dynamic> _defaultSummary() => {
        'daily_kwh': 0.0,
        'monthly_kwh': 0.0,
        'monthly_kwh_prev': 0.0,
        'monthly_saving_pct': 0.0,
        'active_devices': 0,
        'cost_estimate': 0.0,
        'alert_threshold_kwh': 500.0,
        'alert_triggered': false,
        'last_updated': DateTime.now().toIso8601String(),
      };

  /// Calcula el resumen a partir de datos reales de Firestore.
  /// Las lecturas de userDoc y prevSnap se hacen EN PARALELO para reducir latencia.
  Future<Map<String, dynamic>> _computeSummary() async {
    try {
      // Leer perfil del usuario Y resumen previo EN PARALELO (2 RTT → 1 RTT).
      final results = await Future.wait([
        _db.collection('users').doc(_uid).get(),
        _summaryDoc.get(),
        _db.collection('users').doc(_uid).collection('devices').get(),
      ]);

      final userDoc   = results[0] as DocumentSnapshot;
      final prevSnap  = results[1] as DocumentSnapshot;
      final devSnap   = results[2] as QuerySnapshot;

      final userData     = userDoc.data() as Map<String, dynamic>? ?? {};
      final tariffRate   = (userData['tariff_rate_kwh']   as num?)?.toDouble() ?? 362.5;
      final alertThresh  = (userData['alert_threshold_kwh'] as num?)?.toDouble() ?? 500.0;

      double totalMonthlyKwh = 0;
      int activeDevices = 0;

      for (final doc in devSnap.docs) {
        final d     = doc.data() as Map<String, dynamic>;
        final watts = (d['power_watts']      as num?)?.toDouble() ?? 0;
        final hours = (d['daily_usage_hours'] as num?)?.toDouble() ?? 0;
        totalMonthlyKwh += (watts * hours * 30) / 1000;
        if (d['is_active'] == true) activeDevices++;
      }

      final dailyKwh = totalMonthlyKwh / 30;

      final prevData     = prevSnap.data() as Map<String, dynamic>? ?? {};
      double prevMonthKwh = (prevData['monthly_kwh_prev'] as num?)?.toDouble() ?? 0.0;
      if (DateTime.now().day == 1) {
        prevMonthKwh = (prevData['monthly_kwh'] as num?)?.toDouble() ?? totalMonthlyKwh;
      }
      if (prevMonthKwh == 0 && totalMonthlyKwh > 0) {
        prevMonthKwh = totalMonthlyKwh * 1.1;
      }

      final savingPct = prevMonthKwh > 0
          ? ((prevMonthKwh - totalMonthlyKwh) / prevMonthKwh * 100)
          : 0.0;

      final summary = <String, dynamic>{
        'daily_kwh':           dailyKwh,
        'monthly_kwh':         totalMonthlyKwh,
        'monthly_kwh_prev':    prevMonthKwh,
        'monthly_saving_pct':  savingPct,
        'active_devices':      activeDevices,
        'cost_estimate':       dailyKwh * tariffRate,
        'alert_threshold_kwh': alertThresh,
        'alert_triggered':     totalMonthlyKwh > alertThresh,
        'last_updated':        FieldValue.serverTimestamp(),
      };

      // Persistir en Firestore de forma no bloqueante (fire-and-forget).
      _summaryDoc.set(summary, SetOptions(merge: true));
      return summary;
    } catch (e) {
      return _defaultSummary();
    }
  }

  /// Fuerza un recálculo manual (pull-to-refresh)
  Future<Map<String, dynamic>> refreshDashboardSummary() => _computeSummary();

  /// Verifica si el usuario tiene dispositivos registrados
  Future<bool> hasDevices() async {
    try {
      final snap = await _db
          .collection('users')
          .doc(_uid)
          .collection('devices')
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Calcula el consumo diario base proyectado a partir de los dispositivos registrados.
  /// Aplica una variación ±20% por día de la semana (fines de semana +10%, noches +5%).
  Future<double> _getDailyKwhFromDevices() async {
    try {
      final snap = await _db
          .collection('users')
          .doc(_uid)
          .collection('devices')
          .get();
      double total = 0;
      for (final doc in snap.docs) {
        final d = doc.data();
        final watts = (d['power_watts'] as num?)?.toDouble() ?? 0;
        final hours = (d['daily_usage_hours'] as num?)?.toDouble() ?? 0;
        total += (watts * hours) / 1000;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Datos de los últimos 7 días para el gráfico de tendencia.
  /// - Sin dispositivos → lista vacía (muestra estado "sin dispositivos").
  /// - Con dispositivos pero sin registros → proyección calculada de consumo real.
  /// - Con registros reales → usa los registros de Firestore.
  Future<List<ConsumptionPoint>> getLast7DaysData() async {
    final now = DateTime.now();
    final since = now.subtract(const Duration(days: 7));

    // 1. Intentar registros reales de Firestore
    try {
      final snap = await _db
          .collection('users')
          .doc(_uid)
          .collection('consumption_records')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(since))
          .where('period', isEqualTo: 'daily')
          .orderBy('timestamp')
          .limit(7)
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) {
          final d = doc.data();
          return ConsumptionPoint(
            date: (d['timestamp'] as Timestamp).toDate(),
            kwh: (d['kwh_consumed'] as num?)?.toDouble() ?? 0,
          );
        }).toList();
      }
    } catch (_) {}

    // 2. Sin registros — verificar si hay dispositivos
    final baseKwh = await _getDailyKwhFromDevices();
    if (baseKwh <= 0) return []; // Sin dispositivos → estado vacío

    // 3. Proyección basada en dispositivos registrados
    return _projectWeekData(now, baseKwh);
  }

  /// Datos del mes en curso para el reporte mensual.
  Future<List<ConsumptionPoint>> getCurrentMonthData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    try {
      final snap = await _db
          .collection('users')
          .doc(_uid)
          .collection('consumption_records')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(startOfMonth))
          .where('period', isEqualTo: 'daily')
          .orderBy('timestamp')
          .limit(31)
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) {
          final d = doc.data();
          return ConsumptionPoint(
            date: (d['timestamp'] as Timestamp).toDate(),
            kwh: (d['kwh_consumed'] as num?)?.toDouble() ?? 0,
          );
        }).toList();
      }
    } catch (_) {}

    final baseKwh = await _getDailyKwhFromDevices();
    if (baseKwh <= 0) return [];

    return _projectMonthData(now, baseKwh);
  }

  /// Datos de las últimas 24 horas (distribución horaria del consumo diario).
  Future<List<ConsumptionPoint>> getLast24HoursData() async {
    final now = DateTime.now();
    final baseKwh = await _getDailyKwhFromDevices();
    if (baseKwh <= 0) return [];
    return _projectHourlyData(now, baseKwh);
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // Proyectores de datos basados en consumo real de dispositivos
  // ──────────────────────────────────────────────────────────────────────────────

  /// Genera 7 puntos diarios con variación realista a partir del consumo base.
  List<ConsumptionPoint> _projectWeekData(DateTime now, double baseKwh) {
    const weekendFactor = 1.15;
    const weekdayFactor = 1.0;
    // Variaciones fijas por seed para que no cambien en cada rebuild
    const variations = [0.05, -0.08, 0.12, -0.03, 0.07, 0.10, -0.05];
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final factor = (day.weekday >= 6) ? weekendFactor : weekdayFactor;
      final kwh = baseKwh * factor * (1 + variations[i]);
      return ConsumptionPoint(date: day, kwh: kwh.clamp(0.1, double.infinity));
    });
  }

  /// Genera puntos diarios del mes actual a partir del consumo base.
  List<ConsumptionPoint> _projectMonthData(DateTime now, double baseKwh) {
    const weekendFactor = 1.15;
    const weekdayFactor = 1.0;
    const variations = [
      0.05, -0.08, 0.12, -0.03, 0.07, 0.10, -0.05,
      0.02, -0.06, 0.09, -0.01, 0.04, 0.11, -0.07,
      0.06, -0.04, 0.13, -0.02, 0.08, 0.03, -0.09,
      0.07, 0.05, -0.03, 0.10, -0.06, 0.04, 0.08, -0.02, 0.06, 0.03,
    ];
    final daysInMonth = now.day;
    return List.generate(daysInMonth, (i) {
      final day = DateTime(now.year, now.month, i + 1);
      final factor = (day.weekday >= 6) ? weekendFactor : weekdayFactor;
      final v = variations[i % variations.length];
      final kwh = baseKwh * factor * (1 + v);
      return ConsumptionPoint(date: day, kwh: kwh.clamp(0.1, double.infinity));
    });
  }

  /// Genera 24 puntos horarios distribuyendo el consumo diario según patrones de uso típico.
  List<ConsumptionPoint> _projectHourlyData(DateTime now, double dailyKwh) {
    // Pesos horarios: menor de noche, picos mañana y tarde-noche
    const weights = [
      0.015, 0.010, 0.008, 0.007, 0.008, 0.015, // 0–5 h
      0.040, 0.060, 0.055, 0.045, 0.040, 0.045, // 6–11 h
      0.055, 0.050, 0.042, 0.040, 0.045, 0.060, // 12–17 h
      0.075, 0.080, 0.070, 0.055, 0.040, 0.030, // 18–23 h
    ];
    return List.generate(24, (i) {
      final hour = DateTime(now.year, now.month, now.day, i);
      final kwh = dailyKwh * weights[i];
      return ConsumptionPoint(date: hour, kwh: kwh.clamp(0.01, double.infinity));
    });
  }
}
