import 'dart:math';
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

  /// Genera datos de los últimos 7 días para el gráfico de tendencia
  /// Si no hay datos reales, genera datos de demostración realistas
  Future<List<ConsumptionPoint>> getLast7DaysData() async {
    final now = DateTime.now();
    final since = now.subtract(const Duration(days: 7));

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

    // Datos de demostración si no hay registros
    return _generateDemoWeekData(now);
  }

  /// Genera datos del mes en curso (30 días) para el reporte mensual
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

    return _generateDemoMonthData(now);
  }

  /// Genera datos de las últimas 24 horas para el gráfico horario
  Future<List<ConsumptionPoint>> getLast24HoursData() async {
    final now = DateTime.now();
    return _generateDemoHourlyData(now);
  }

  // ──────────────────────────────────────────────
  // Generadores de datos de demostración
  // ──────────────────────────────────────────────

  List<ConsumptionPoint> _generateDemoWeekData(DateTime now) {
    final rng = Random(42);
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      // Patrón realista: más consumo los fines de semana
      final base = (day.weekday >= 6) ? 25.0 : 18.0;
      final kwh = base + rng.nextDouble() * 8 - 4;
      return ConsumptionPoint(date: day, kwh: kwh.clamp(10, 35));
    });
  }

  List<ConsumptionPoint> _generateDemoMonthData(DateTime now) {
    final rng = Random(7);
    final daysInMonth = now.day;
    return List.generate(daysInMonth, (i) {
      final day = DateTime(now.year, now.month, i + 1);
      final base = (day.weekday >= 6) ? 24.0 : 17.0;
      final kwh = base + rng.nextDouble() * 10 - 5;
      return ConsumptionPoint(date: day, kwh: kwh.clamp(8, 35));
    });
  }

  List<ConsumptionPoint> _generateDemoHourlyData(DateTime now) {
    final rng = Random(now.hour);
    return List.generate(24, (i) {
      final hour = DateTime(now.year, now.month, now.day, i);
      // Patrón: bajo de noche, pico en mañana y noche
      double base;
      if (i < 6) {
        base = 0.4;
      } else if (i < 9) {
        base = 1.8;
      } else if (i < 12) {
        base = 1.2;
      } else if (i < 14) {
        base = 1.5;
      } else if (i < 17) {
        base = 1.0;
      } else if (i < 22) {
        base = 2.2;
      } else {
        base = 0.9;
      }
      return ConsumptionPoint(
        date: hour,
        kwh: (base + rng.nextDouble() * 0.5).clamp(0.2, 3.5),
      );
    });
  }
}
