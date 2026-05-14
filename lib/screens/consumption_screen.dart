import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/dashboard_service.dart';
import '../services/alert_service.dart';
import '../widgets/energy_card.dart';
import '../widgets/dashboard_skeleton.dart';
import 'package:intl/intl.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _dashboardService = DashboardService();
  final _alertService = AlertService();
  List<ConsumptionPoint> _chartData = [];
  bool _chartLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    // Cargar datos del gráfico Y summary EN PARALELO para reducir latencia.
    final results = await Future.wait([
      _dashboardService.getLast7DaysData(),
      _dashboardService.refreshDashboardSummary(),
    ]);

    final data    = results[0] as List<ConsumptionPoint>;
    final summary = results[1] as Map<String, dynamic>;

    if (mounted) {
      setState(() {
        _chartData    = data;
        _chartLoading = false;
      });
    }

    // Verificar umbral de alerta en segundo plano (fire-and-forget).
    _alertService.checkAndCreateAlert(
      currentMonthlyKwh: (summary['monthly_kwh']         as num?)?.toDouble() ?? 0,
      thresholdKwh:      (summary['alert_threshold_kwh'] as num?)?.toDouble() ?? 500,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firstName = (user?.displayName ?? 'Usuario').split(' ').first;

    return StreamBuilder<Map<String, dynamic>>(
      stream: _dashboardService.getDashboardSummaryStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const DashboardSkeleton();
        }

        final data = snap.data ?? {};
        final dailyKwh = (data['daily_kwh'] as num?)?.toDouble() ?? 0.0;
        final monthlyKwh = (data['monthly_kwh'] as num?)?.toDouble() ?? 0.0;
        final savingPct = (data['monthly_saving_pct'] as num?)?.toDouble() ?? 0.0;
        final costEstimate = (data['cost_estimate'] as num?)?.toDouble() ?? 0.0;
        final activeDevices = (data['active_devices'] as num?)?.toInt() ?? 0;
        final alertTriggered = data['alert_triggered'] ?? false;

        return RefreshIndicator(
          onRefresh: _loadChartData,
          color: const Color(0xFF00C853),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting ──────────────────────────────────
                _buildGreetingHeader(firstName, alertTriggered, context),
                const SizedBox(height: 24),

                // ── Cards de métricas ─────────────────────────
                _buildMetricsSection(dailyKwh, monthlyKwh, savingPct, costEstimate, activeDevices),
                const SizedBox(height: 28),

                // ── Gráfico de tendencia ──────────────────────
                _buildTrendSection(context),
                const SizedBox(height: 28),

                // ── Dispositivos activos ──────────────────────
                _buildQuickStats(monthlyKwh, activeDevices, context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreetingHeader(String firstName, bool alertTriggered, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Buenos días' : hour < 18 ? 'Buenas tardes' : 'Buenas noches';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.primary : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.8) : colorScheme.onPrimaryContainer.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                Text(
                  firstName,
                  style: TextStyle(
                    color: isDark ? Colors.white : colorScheme.onPrimaryContainer,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat("EEEE, d 'de' MMMM", 'es_ES').format(DateTime.now()),
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.6) : colorScheme.onPrimaryContainer.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (alertTriggered)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.error.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Consumo\nelevado',
                    style: TextStyle(color: colorScheme.error, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : colorScheme.onPrimaryContainer).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.energy_savings_leaf, color: isDark ? Colors.white : colorScheme.onPrimaryContainer, size: 28),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(double dailyKwh, double monthlyKwh,
      double savingPct, double costEstimate, int activeDevices) {
    final savingPositive = savingPct >= 0;
    final numberFormat = NumberFormat('#,##0', 'es_CO');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: EnergyCard(
                title: 'Consumo hoy',
                value: dailyKwh.toStringAsFixed(1),
                unit: 'kWh',
                icon: Icons.bolt,
                color: const Color(0xFF00BCD4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: EnergyCard(
                title: 'Ahorro mensual',
                value: savingPct.abs().toStringAsFixed(1),
                unit: '%',
                icon: savingPositive ? Icons.trending_down : Icons.trending_up,
                color: savingPositive ? const Color(0xFF00C853) : Colors.redAccent,
                subtitle: savingPositive ? 'Ahorro' : 'Aumento',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: EnergyCard(
                title: 'Consumo mensual',
                value: monthlyKwh.toStringAsFixed(1),
                unit: 'kWh',
                icon: Icons.electric_meter,
                color: const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: EnergyCard(
                title: 'Costo estimado hoy',
                value: '\$${numberFormat.format(costEstimate)}',
                unit: 'COP',
                icon: Icons.monetization_on_outlined,
                color: const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tendencia — últimos 7 días',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(isDark ? 0.3 : 0.2),
              width: 1,
            ),
          ),
          child: _chartLoading
              ? Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                )
              : LineChart(_buildLineChart(context)),
        ),
      ],
    );
  }

  LineChartData _buildLineChart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final spots = _chartData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.kwh);
    }).toList();

    final maxY = _chartData.isEmpty
        ? 30.0
        : _chartData.map((p) => p.kwh).reduce((a, b) => a > b ? a : b) + 5;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (_) => FlLine(
          color: colorScheme.outline.withOpacity(isDark ? 0.2 : 0.1),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (value, _) {
              if (value.toInt() >= _chartData.length) {
                return const SizedBox.shrink();
              }
              final date = _chartData[value.toInt()].date;
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  DateFormat('E', 'es_ES').format(date),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (_chartData.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: colorScheme.primary,
          barWidth: 2.5,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 3,
              color: colorScheme.primary,
              strokeWidth: 0,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.25),
                colorScheme.primary.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(double monthlyKwh, int activeDevices, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del mes',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _statRow(Icons.calendar_month, 'Consumo total del mes',
              '${monthlyKwh.toStringAsFixed(1)} kWh', const Color(0xFFFF9800), context),
          Divider(color: colorScheme.outline.withOpacity(0.2), height: 20),
          _statRow(Icons.devices_other, 'Dispositivos activos ahora',
              '$activeDevices dispositivos', const Color(0xFF00BCD4), context),
          Divider(color: colorScheme.outline.withOpacity(0.2), height: 20),
          _statRow(Icons.eco_outlined, 'CO₂ evitado estimado',
              '${(monthlyKwh * 0.185).toStringAsFixed(1)} kg', const Color(0xFF00C853), context),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value, Color iconColor, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
