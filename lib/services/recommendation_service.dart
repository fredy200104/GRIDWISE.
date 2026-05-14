import 'package:flutter/material.dart';
import '../models/device_model.dart';

class RecommendationService {
  List<Map<String, dynamic>> buildSmartTips({
    required double monthlyKwh,
    required double threshold,
    required List<DeviceModel> devices,
  }) {
    final tips = <Map<String, dynamic>>[];
    final highLoadDevices =
        devices.where((d) => d.monthlyKwh >= 80).toList()..sort((a, b) => b.monthlyKwh.compareTo(a.monthlyKwh));
    final standbyDevices = devices.where((d) => !d.isActive && d.powerWatts >= 100).toList();
    final monthProgress = threshold > 0 ? (monthlyKwh / threshold) : 0;

    if (monthProgress >= 1) {
      tips.add({
        'title': 'Consumo por encima del umbral',
        'desc':
            'Tu hogar ya supero el umbral mensual (${threshold.toStringAsFixed(0)} kWh). Programa uso escalonado de equipos de alto consumo.',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.redAccent,
      });
    } else if (monthProgress >= 0.8) {
      tips.add({
        'title': 'Consumo cercano al limite',
        'desc':
            'Vas en ${(monthProgress * 100).toStringAsFixed(0)}% del umbral. Reduce tiempos de lavadora, secadora y climatizacion en horas pico.',
        'icon': Icons.speed,
        'color': Colors.orange,
      });
    }

    if (highLoadDevices.isNotEmpty) {
      final top = highLoadDevices.first;
      tips.add({
        'title': 'Prioriza optimizar ${top.name}',
        'desc':
            'Este dispositivo aporta ~${top.monthlyKwh.toStringAsFixed(1)} kWh/mes. Bajar 1 hora diaria de uso reduce consumo mensual de forma notable.',
        'icon': Icons.bolt,
        'color': Colors.blue,
      });
    }

    if (standbyDevices.isNotEmpty) {
      tips.add({
        'title': 'Evita consumo fantasma',
        'desc':
            'Tienes ${standbyDevices.length} equipos con potencia alta en espera. Usa regletas con interruptor para cortar energia cuando no se usen.',
        'icon': Icons.power_off,
        'color': Colors.deepPurple,
      });
    }

    tips.addAll([
      {
        'title': 'Aprovecha luz natural',
        'desc': 'Mantener iluminacion natural durante el dia reduce entre 10% y 20% el consumo en iluminacion.',
        'icon': Icons.wb_sunny,
        'color': Colors.amber,
      },
      {
        'title': 'Usa modo eco',
        'desc': 'Activa modo ahorro en aire acondicionado y electrodomesticos para bajar picos de consumo nocturnos.',
        'icon': Icons.eco_outlined,
        'color': Colors.green,
      },
    ]);

    return tips;
  }
}
