import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../services/alert_service.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AlertService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<AlertModel>>(
        stream: service.getAlertsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C853)),
            );
          }

          final alerts = snap.data ?? [];

          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: Colors.white.withOpacity(0.15)),
                  const SizedBox(height: 16),
                  Text('Sin alertas',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4), fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('¡Tu consumo está bajo control!',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.25), fontSize: 13)),
                ],
              ),
            );
          }

          final unread = alerts.where((a) => !a.isRead).length;

          return Column(
            children: [
              // Header con botón "marcar todas"
              if (unread > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$unread sin leer',
                          style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => service.markAllAsRead(),
                        child: const Text('Marcar todas como leídas',
                            style: TextStyle(
                                color: Color(0xFF00C853), fontSize: 12)),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  itemCount: alerts.length,
                  itemBuilder: (ctx, i) => _AlertCard(
                    alert: alerts[i],
                    onTap: () => service.markAsRead(alerts[i].alertId),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;

  const _AlertCard({required this.alert, this.onTap});

  Color get _severityColor {
    switch (alert.severity) {
      case AlertSeverity.high:
        return Colors.redAccent;
      case AlertSeverity.medium:
        return const Color(0xFFFF9800);
      case AlertSeverity.low:
        return const Color(0xFF00BCD4);
    }
  }

  IconData get _severityIcon {
    switch (alert.type) {
      case AlertType.thresholdExceeded:
        return Icons.electric_meter;
      case AlertType.deviceInactive:
        return Icons.power_off;
      case AlertType.hourlySpike:
        return Icons.trending_up;
      case AlertType.tariffPeak:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor;
    final isUnread = !alert.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread
              ? const Color(0xFF1E2336)
              : const Color(0xFF161926),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? color.withOpacity(0.4) : Colors.white10,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_severityIcon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: TextStyle(
                            color: isUnread ? Colors.white : Colors.white60,
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    alert.message,
                    style: TextStyle(
                      color: Colors.white.withOpacity(isUnread ? 0.6 : 0.35),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat("d MMM yyyy · HH:mm", 'es_ES')
                        .format(alert.triggeredAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
