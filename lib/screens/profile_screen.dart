import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/alert_service.dart';
import '../services/dashboard_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  final _alertService = AlertService();
  final _dashboardService = DashboardService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<UserModel>(
        stream: _userService.getUserProfileStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C853)),
            );
          }
          final user = snap.data;
          final authUser = FirebaseAuth.instance.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── Avatar ──────────────────────────────────
                _buildAvatar(user, authUser, context),
                const SizedBox(height: 24),

                // ── Datos personales ─────────────────────────
                _buildSection(
                  'Datos personales',
                  [
                    _editableTile(
                      context,
                      label: 'Nombre',
                      value: user?.displayName ?? authUser?.displayName ?? 'Usuario',
                      icon: Icons.person_outline,
                      onEdit: (val) => _userService.updateDisplayName(val),
                    ),
                    Divider(color: Theme.of(context).colorScheme.outline.withOpacity(0.1), height: 1),
                    _readOnlyTile(
                      context,
                      label: 'Correo',
                      value: user?.email ?? authUser?.email ?? '—',
                      icon: Icons.email_outlined,
                    ),
                    Divider(color: Theme.of(context).colorScheme.outline.withOpacity(0.1), height: 1),
                    _editableTile(
                      context,
                      label: 'Teléfono',
                      value: user?.phone ?? '—',
                      icon: Icons.phone_outlined,
                      onEdit: (val) => _userService.updatePhone(val),
                    ),
                  ],
                  context,
                ),
                const SizedBox(height: 16),

                // ── Preferencias energéticas ─────────────────
                _buildSection(
                  'Preferencias energéticas',
                  [
                    _editableTile(
                      context,
                      label: 'Tarifa (COP/kWh)',
                      value: user?.tariffRateKwh.toStringAsFixed(1) ?? '362.5',
                      icon: Icons.monetization_on_outlined,
                      keyboardType: TextInputType.number,
                      onEdit: (val) => _userService.updatePreferences(
                        tariffRateKwh: double.tryParse(val),
                      ),
                    ),
                    Divider(color: Theme.of(context).colorScheme.outline.withOpacity(0.1), height: 1),
                    _editableTile(
                      context,
                      label: 'Umbral de alerta (kWh/mes)',
                      value: user?.alertThresholdKwh.toStringAsFixed(0) ?? '500',
                      icon: Icons.warning_amber_outlined,
                      keyboardType: TextInputType.number,
                      onEdit: (val) async {
                        final threshold = double.tryParse(val);
                        await _userService.updatePreferences(
                          alertThresholdKwh: threshold,
                        );
                        // Verificar si el consumo actual supera el nuevo umbral
                        if (threshold != null) {
                          final snap2 = await _dashboardService
                              .getDashboardSummaryStream()
                              .first;
                          final current = (snap2['monthly_kwh'] as num?)?.toDouble() ?? 0;
                          await _alertService.checkAndCreateAlert(
                            currentMonthlyKwh: current,
                            thresholdKwh: threshold,
                          );
                        }
                      },
                    ),
                  ],
                  context,
                ),
                const SizedBox(height: 16),

                // ── Configuración de la app ───────────────────
                _buildSection(
                  'Configuración',
                  [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_outlined,
                              color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Notificaciones in-app',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                          ),
                          Switch(
                            value: user?.notificationsEnabled ?? true,
                            onChanged: (val) => _userService.updatePreferences(
                              notificationsEnabled: val,
                            ),
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                  context,
                ),
                const SizedBox(height: 16),

                // ── Cuenta ────────────────────────────────────
                _buildSection(
                  'Cuenta',
                  [
                    ListTile(
                      leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                      title: Text(
                        'Miembro desde ${user != null ? DateFormat("MMM yyyy", 'es_ES').format(user.createdAt) : "—"}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                      ),
                      dense: true,
                    ),
                  ],
                  context,
                ),
                const SizedBox(height: 24),

                // ── Botón cerrar sesión ───────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmSignOut(context),
                    icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                    label: Text('Cerrar sesión',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(UserModel? user, User? authUser, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final name = user?.displayName ?? authUser?.displayName ?? 'U';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final email = user?.email ?? authUser?.email ?? '';

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(isDark ? 0.4 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: TextStyle(
              color: colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(isDark ? 0.3 : 0.1),
          width: 1,
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: colorScheme.outline.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _editableTile(
    BuildContext ctx, {
    required String label,
    required String value,
    required IconData icon,
    required Future<void> Function(String) onEdit,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(ctx);
    final colorScheme = theme.colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
      title: Text(label,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11)),
      subtitle: Text(value,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
      trailing: Icon(Icons.edit_outlined, color: colorScheme.onSurfaceVariant.withOpacity(0.5), size: 16),
      dense: true,
      onTap: () => _showEditDialog(ctx,
          label: label, initialValue: value, keyboardType: keyboardType, onSave: onEdit),
    );
  }

  Widget _readOnlyTile(
    BuildContext ctx, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(ctx);
    final colorScheme = theme.colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
      title: Text(label,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11)),
      subtitle: Text(value,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
      dense: true,
    );
  }

  Future<void> _showEditDialog(
    BuildContext ctx, {
    required String label,
    required String initialValue,
    required Future<void> Function(String) onSave,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final theme = Theme.of(ctx);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final ctrl = TextEditingController(text: initialValue == '—' ? '' : initialValue);
    await showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Editar $label',
            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          autofocus: true,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? colorScheme.surface : const Color(0xFFF1F3F4),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorScheme.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancelar', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () async {
              final val = ctrl.text.trim();
              if (val.isNotEmpty) {
                Navigator.pop(dialogCtx);
                await onSave(val);
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('$label actualizado', style: TextStyle(color: colorScheme.onSecondary)),
                    backgroundColor: colorScheme.secondary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                }
              }
            },
            child: Text('Guardar',
                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }

  Future<void> _confirmSignOut(BuildContext ctx) async {
    final theme = Theme.of(ctx);
    final colorScheme = theme.colorScheme;
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('¿Cerrar sesión?',
            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        content: Text('Se cerrará tu sesión actual.',
            style: TextStyle(color: colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text('Cancelar', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text('Cerrar sesión',
                style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      await _userService.signOut();
      Navigator.pushAndRemoveUntil(
        ctx,
        MaterialPageRoute(builder: (navCtx) => WelcomeScreen()),
        (route) => false,
      );
    }
  }
}
