import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../services/alert_service.dart';
import '../services/user_service.dart';
import 'consumption_screen.dart';
import 'devices_screen.dart';
import 'reports_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';
import 'recommendations_screen.dart';
import 'iot_connect_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _alertService = AlertService();
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    // Diferir la inicialización del documento de usuario hasta después del
    // primer frame para no bloquear la navegación desde _AuthGate.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _userService.ensureUserDocument();
    });
  }

  final List<_TabItem> _tabs = [
    _TabItem(
      label: 'Dashboard',
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
    ),
    _TabItem(
      label: 'Dispositivos',
      icon: Icons.devices_outlined,
      activeIcon: Icons.devices,
    ),
    _TabItem(
      label: 'Reportes',
      icon: Icons.query_stats_outlined,
      activeIcon: Icons.query_stats,
    ),
    _TabItem(
      label: 'Alertas',
      icon: Icons.notifications_none_rounded,
      activeIcon: Icons.notifications_rounded,
    ),
    _TabItem(
      label: 'Recomendaciones',
      icon: Icons.tips_and_updates_outlined,
      activeIcon: Icons.tips_and_updates,
    ),
    _TabItem(
      label: 'IoT',
      icon: Icons.wifi_tethering_outlined,
      activeIcon: Icons.wifi_tethering,
    ),
    _TabItem(
      label: 'Asistente',
      icon: Icons.smart_toy_outlined,
      activeIcon: Icons.smart_toy,
    ),
    _TabItem(
      label: 'Perfil',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Los tabs del body
    final List<Widget> bodies = [
      const DashboardTab(),
      const DevicesTab(),
      const ReportsScreen(),
      const AlertsScreen(),
      const RecommendationsScreen(),
      const IoTConnectScreen(),
      const ChatScreen(),
      const ProfileScreen(),
    ];

    final List<String> titles = [
      'GridWise',
      'Dispositivos',
      'Reportes de consumo',
      'Alertas',
      'Recomendaciones',
      'Conexión IoT',
      'Asistente IA',
      'Mi perfil',
    ];

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.energy_savings_leaf, color: isDark ? const Color(0xFF00C853) : colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              titles[_selectedIndex],
              style: TextStyle(
                color: theme.appBarTheme.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          // Badge de alertas no leídas
          StreamBuilder<int>(
            stream: _alertService.getUnreadCountStream(),
            builder: (context, snap) {
              final count = snap.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, color: theme.appBarTheme.foregroundColor?.withOpacity(0.7)),
                    onPressed: () => setState(() => _selectedIndex = 3),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            count > 9 ? '9+' : '$count',
                            style: TextStyle(
                              color: colorScheme.onError,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: bodies,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1),
          ),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: colorScheme.outline.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isSelected = _selectedIndex == i;
                return _buildNavItem(tab, i, isSelected, theme);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_TabItem tab, int index, bool isSelected, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? tab.activeIcon : tab.icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: TextStyle(
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant.withOpacity(0.5),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  _TabItem({required this.label, required this.icon, required this.activeIcon});
}