import 'package:flutter_test/flutter_test.dart';
import 'package:gridwise/models/device_model.dart';
import 'package:gridwise/services/recommendation_service.dart';

void main() {
  test('integration style flow: devices -> summary -> recommendations', () {
    final devices = [
      DeviceModel(
        deviceId: 'ac1',
        name: 'Aire acondicionado',
        type: 'climate',
        powerWatts: 1400,
        location: 'Sala',
        isActive: true,
        dailyUsageHours: 5,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
      DeviceModel(
        deviceId: 'wm1',
        name: 'Lavadora',
        type: 'appliance',
        powerWatts: 700,
        location: 'Patio',
        isActive: false,
        dailyUsageHours: 1.5,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    ];

    final monthlyKwh = devices.fold<double>(0, (sum, d) => sum + d.monthlyKwh);
    final tips = RecommendationService().buildSmartTips(
      monthlyKwh: monthlyKwh,
      threshold: 300,
      devices: devices,
    );

    expect(monthlyKwh, greaterThan(0));
    expect(tips, isNotEmpty);
  });
}
