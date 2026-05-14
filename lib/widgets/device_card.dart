import 'package:flutter/material.dart';
import '../models/device_model.dart';

/// Card de dispositivo con toggle, consumo estimado, editar y eliminar
class DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggle;

  const DeviceCard({
    super.key,
    required this.device,
    this.onEdit,
    this.onDelete,
    this.onToggle,
  });

  IconData _resolveIcon(String key) {
    const map = {
      'ac_unit': Icons.ac_unit,
      'lightbulb': Icons.lightbulb,
      'kitchen': Icons.kitchen,
      'tv': Icons.tv,
      'ev_station': Icons.ev_station,
      'solar_power': Icons.solar_power,
    };
    return map[key] ?? Icons.devices;
  }

  Color _typeColor(String type) {
    const map = {
      'climate': Color(0xFF00BCD4),
      'lighting': Color(0xFFFFEB3B),
      'appliance': Color(0xFF4CAF50),
      'entertainment': Color(0xFFE91E63),
      'ev_charger': Color(0xFF9C27B0),
      'solar_panel': Color(0xFFFF9800),
    };
    return map[type] ?? const Color(0xFF607D8B);
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(device.type);
    final activeColor =
        device.isActive ? const Color(0xFF00C853) : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2336),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: device.isActive ? color.withOpacity(0.4) : Colors.white10,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_resolveIcon(device.iconKey), color: color, size: 24),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${device.powerWatts.toStringAsFixed(0)}W · ${device.dailyUsageHours.toStringAsFixed(1)}h/día · ${device.location}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Toggle
              Switch(
                value: device.isActive,
                onChanged: onToggle,
                activeColor: const Color(0xFF00C853),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Footer: consumo + acciones
          Row(
            children: [
              // Consumo mensual
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt, color: activeColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${device.monthlyKwh.toStringAsFixed(1)} kWh/mes',
                      style: TextStyle(
                        color: activeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Editar
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: Colors.white38,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              // Eliminar
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                color: Colors.redAccent.withOpacity(0.7),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
