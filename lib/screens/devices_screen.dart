import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/device_service.dart';
import '../widgets/device_card.dart';
import 'add_device_screen.dart';
import 'edit_device_screen.dart';

class DevicesTab extends StatefulWidget {
  const DevicesTab({super.key});

  @override
  State<DevicesTab> createState() => _DevicesTabState();
}

class _DevicesTabState extends State<DevicesTab> {
  final _service = DeviceService();
  late Stream<List<DeviceModel>> _devicesStream;

  @override
  void initState() {
    super.initState();
    _devicesStream = _service.getDevicesStream();
  }

  Future<void> _confirmDelete(BuildContext ctx, DeviceModel device) async {
    final theme = Theme.of(ctx);
    final colorScheme = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Eliminar dispositivo',
            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro que deseas eliminar "${device.name}"?',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar',
                style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.deleteDevice(device.deviceId);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('${device.name} eliminado', style: TextStyle(color: colorScheme.onError)),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
        ),
        backgroundColor: colorScheme.primary,
        icon: Icon(Icons.add, color: isDark ? colorScheme.onSurface : Colors.white),
        label: Text('Agregar', style: TextStyle(color: isDark ? colorScheme.onSurface : Colors.white)),
      ),
      body: StreamBuilder<List<DeviceModel>>(
        stream: _devicesStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (snap.hasError) {
            debugPrint("Error loading devices: ${snap.error}");
            return Center(
              child: Text("Error: ${snap.error}", style: TextStyle(color: colorScheme.error)),
            );
          }

          final devices = snap.data ?? [];

          if (devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices_other,
                      size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Sin dispositivos registrados',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toca + para agregar tu primer dispositivo',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // Resumen en la parte superior
          final totalKwh = devices.fold<double>(0, (sum, d) => sum + d.monthlyKwh);
          final activeCount = devices.where((d) => d.isActive).length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      _summaryChip(
                        '${devices.length} dispositivos',
                        Icons.devices,
                        const Color(0xFF00BCD4),
                      ),
                      const SizedBox(width: 10),
                      _summaryChip(
                        '$activeCount activos',
                        Icons.power,
                        const Color(0xFF00C853),
                      ),
                      const Spacer(),
                      _summaryChip(
                        '${totalKwh.toStringAsFixed(0)} kWh/mes',
                        Icons.bolt,
                        const Color(0xFFFF9800),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final device = devices[i];
                      return DeviceCard(
                        device: device,
                        onToggle: (val) =>
                            _service.toggleActive(device.deviceId, val),
                        onEdit: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => EditDeviceScreen(device: device),
                          ),
                        ),
                        onDelete: () => _confirmDelete(ctx, device),
                      );
                    },
                    childCount: devices.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
