import 'package:flutter_test/flutter_test.dart';
import 'package:gridwise/models/device_model.dart';

void main() {
  test('monthly kWh and monthly cost are calculated correctly', () {
    final device = DeviceModel(
      deviceId: 'd1',
      name: 'Aire',
      type: 'climate',
      powerWatts: 1200,
      location: 'Sala',
      dailyUsageHours: 4,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    expect(device.monthlyKwh, closeTo(144, 0.001));
    expect(device.monthlyCost(400), closeTo(57600, 0.001));
  });
}
