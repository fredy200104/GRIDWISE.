import 'package:flutter_test/flutter_test.dart';
import 'package:gridwise/services/recommendation_service.dart';

void main() {
  test('smoke test for recommendation service', () {
    final tips = RecommendationService().buildSmartTips(
      monthlyKwh: 100,
      threshold: 500,
      devices: const [],
    );
    expect(tips, isNotEmpty);
  });
}
