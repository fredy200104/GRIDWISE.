import 'package:flutter_test/flutter_test.dart';
import 'package:gridwise/models/device_model.dart';
import 'package:gridwise/services/recommendation_service.dart';

DeviceModel _device({
  required String id,
  required String name,
  required double watts,
  required double hours,
  required bool active,
}) {
  return DeviceModel(
    deviceId: id,
    name: name,
    type: 'appliance',
    powerWatts: watts,
    location: 'Cocina',
    isActive: active,
    dailyUsageHours: hours,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  final service = RecommendationService();

  test('returns threshold warning when monthly usage exceeds threshold', () {
    final tips = service.buildSmartTips(
      monthlyKwh: 620,
      threshold: 500,
      devices: [_device(id: '1', name: 'Aire', watts: 1800, hours: 6, active: true)],
    );

    expect(tips.first['title'], contains('Consumo por encima del umbral'));
  });

  test('includes standby advice when high power devices are inactive', () {
    final tips = service.buildSmartTips(
      monthlyKwh: 200,
      threshold: 500,
      devices: [_device(id: '1', name: 'TV', watts: 150, hours: 3, active: false)],
    );

    final titles = tips.map((t) => t['title'] as String).toList();
    expect(titles.any((t) => t.contains('consumo fantasma') || t.contains('Evita consumo fantasma')), isTrue);
  });
}
