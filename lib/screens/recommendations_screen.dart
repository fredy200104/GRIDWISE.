import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/dashboard_service.dart';
import '../services/device_service.dart';
import '../services/recommendation_service.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardService = DashboardService();
    final deviceService = DeviceService();
    final recommendationService = RecommendationService();
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<Map<String, dynamic>>(
      stream: dashboardService.getDashboardSummaryStream(),
      builder: (context, summarySnap) {
        final summary = summarySnap.data ?? {};
        final monthlyKwh = (summary['monthly_kwh'] as num?)?.toDouble() ?? 0;
        final alertThreshold = (summary['alert_threshold_kwh'] as num?)?.toDouble() ?? 500;

        return StreamBuilder<List<DeviceModel>>(
          stream: deviceService.getDevicesStream(),
          builder: (context, devicesSnap) {
            final devices = devicesSnap.data ?? const <DeviceModel>[];
            final tips = recommendationService.buildSmartTips(
              monthlyKwh: monthlyKwh,
              threshold: alertThreshold,
              devices: devices,
            );

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: tips.length,
              itemBuilder: (context, index) {
                final tip = tips[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: (tip['color'] as Color).withOpacity(0.15),
                      child: Icon(tip['icon'] as IconData, color: tip['color'] as Color),
                    ),
                    title: Text(
                      tip['title'] as String,
                      style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(tip['desc'] as String),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

}
