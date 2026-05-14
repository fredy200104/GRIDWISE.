import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/dashboard_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _service = DashboardService();

  List<ConsumptionPoint> _weekData = [];
  List<ConsumptionPoint> _monthData = [];
  List<ConsumptionPoint> _hourlyData = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _loading = true);
    final res = await Future.wait([
      _service.getLast24HoursData(),
      _service.getLast7DaysData(),
      _service.getCurrentMonthData(),
    ]);
    if (mounted) {
      setState(() {
        _hourlyData = res[0];
        _weekData = res[1];
        _monthData = res[2];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Theme.of(context).colorScheme.onPrimary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'Diario'),
                Tab(text: 'Semanal'),
                Tab(text: 'Mensual'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00C853)))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDailyTab(),
                      _buildWeeklyTab(),
                      _buildMonthlyTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Diario: LineChart de 24h ──────────────────────────────
  Widget _buildDailyTab() {
    return _buildTabContent(
      title: 'Consumo por hora (hoy)',
      totalKwh: _hourlyData.fold(0.0, (s, p) => s + p.kwh),
      pointCount: _hourlyData.length,
      chart: _buildLineChart(_hourlyData, formatLabel: (i) {
        if (i.toInt() % 4 != 0) return '';
        return '${i.toInt()}h';
      }),
      subtitle: 'Últimas 24 horas',
      icon: Icons.schedule,
    );
  }

  // ── Semanal: BarChart 7 días ──────────────────────────────
  Widget _buildWeeklyTab() {
    return _buildTabContent(
      title: 'Consumo por día (semana)',
      totalKwh: _weekData.fold(0.0, (s, p) => s + p.kwh),
      pointCount: _weekData.length,
      chart: _buildBarChart(_weekData, formatLabel: (i) {
        if (i.toInt() >= _weekData.length) return '';
        return DateFormat('E', 'es_ES').format(_weekData[i.toInt()].date);
      }),
      subtitle: 'Últimos 7 días',
      icon: Icons.calendar_view_week,
    );
  }

  // ── Mensual: BarChart días del mes ────────────────────────
  Widget _buildMonthlyTab() {
    return _buildTabContent(
      title: 'Consumo mensual',
      totalKwh: _monthData.fold(0.0, (s, p) => s + p.kwh),
      pointCount: _monthData.length,
      chart: _buildBarChart(_monthData, formatLabel: (i) {
        if (i.toInt() >= _monthData.length) return '';
        final d = _monthData[i.toInt()].date.day;
        return d % 5 == 1 ? '$d' : '';
      }),
      subtitle: DateFormat('MMMM yyyy', 'es_ES').format(DateTime.now()),
      icon: Icons.calendar_month,
    );
  }

  Widget _buildTabContent({
    required String title,
    required double totalKwh,
    required Widget chart,
    required String subtitle,
    required IconData icon,
    int pointCount = 1,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final avgKwh = totalKwh / (pointCount > 1 ? pointCount : 1);
    final numberFmt = NumberFormat('#,##0.0', 'es_CO');

    return RefreshIndicator(
      onRefresh: _loadAllData,
      color: colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? colorScheme.primary : colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: isDark ? Colors.white70 : colorScheme.onPrimaryContainer.withOpacity(0.7), size: 36),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subtitle,
                          style: TextStyle(
                              color: isDark ? Colors.white.withOpacity(0.7) : colorScheme.onPrimaryContainer.withOpacity(0.7),
                              fontSize: 12)),
                      Text(
                        '${numberFmt.format(totalKwh)} kWh total',
                        style: TextStyle(
                            color: isDark ? Colors.white : colorScheme.onPrimaryContainer,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Promedio: ${numberFmt.format(avgKwh)} kWh',
                        style:
                            TextStyle(color: isDark ? Colors.white.withOpacity(0.6) : colorScheme.onPrimaryContainer.withOpacity(0.6), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Chart title
            Text(title,
                style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            const SizedBox(height: 16),

            // Chart
            Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(4, 16, 16, 8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(isDark ? 0.3 : 0.1),
                  width: 1,
                ),
              ),
              child: chart,
            ),
            const SizedBox(height: 24),

            // Stats grid
            Row(
              children: [
                Expanded(
                    child: _statCard('Máximo',
                        _maxKwh(title).toStringAsFixed(2), 'kWh',
                        colorScheme.error)),
                const SizedBox(width: 12),
                Expanded(
                    child: _statCard('Mínimo',
                        _minKwh(title).toStringAsFixed(2), 'kWh',
                        colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _statCard('CO₂ evitado',
                        (totalKwh * 0.185).toStringAsFixed(1), 'kg',
                        colorScheme.secondary)),
                const SizedBox(width: 12),
                Expanded(
                    child: _statCard(
                        'Costo est.',
                        '\$${NumberFormat('#,##0', 'es_CO').format(totalKwh * 362.5)}',
                        'COP',
                        colorScheme.tertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _maxKwh(String title) {
    final data = title.contains('hora') ? _hourlyData : (title.contains('día') ? _weekData : _monthData);
    if (data.isEmpty) return 0;
    return data.map((p) => p.kwh).reduce((a, b) => a > b ? a : b);
  }

  double _minKwh(String title) {
    final data = title.contains('hora') ? _hourlyData : (title.contains('día') ? _weekData : _monthData);
    if (data.isEmpty) return 0;
    return data.map((p) => p.kwh).reduce((a, b) => a < b ? a : b);
  }

  Widget _statCard(String label, String value, String unit, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.8), fontSize: 11)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(unit,
              style: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.8), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<ConsumptionPoint> data,
      {required String Function(double) formatLabel}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (data.isEmpty) return Center(child: Text('Sin datos', style: TextStyle(color: colorScheme.onSurfaceVariant)));
    final maxY = data.map((p) => p.kwh).reduce((a, b) => a > b ? a : b) + 1;
    final spots = data.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.kwh))
        .toList();

    return LineChart(LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (_) => FlLine(color: colorScheme.outline.withOpacity(isDark ? 0.2 : 0.1), strokeWidth: 1)),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 26, interval: 1,
          getTitlesWidget: (v, _) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(formatLabel(v),
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10))),
        )),
      ),
      borderData: FlBorderData(show: false),
      minX: 0, maxX: (data.length - 1).toDouble(), minY: 0, maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots, isCurved: true, color: colorScheme.primary, barWidth: 2.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, gradient: LinearGradient(
            colors: [colorScheme.primary.withOpacity(0.25), Colors.transparent],
            begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        ),
      ],
    ));
  }

  Widget _buildBarChart(List<ConsumptionPoint> data,
      {required String Function(double) formatLabel}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (data.isEmpty) return Center(child: Text('Sin datos', style: TextStyle(color: colorScheme.onSurfaceVariant)));
    final maxY = data.map((p) => p.kwh).reduce((a, b) => a > b ? a : b) + 4;

    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 26,
          getTitlesWidget: (v, _) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(formatLabel(v),
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10))),
        )),
      ),
      gridData: FlGridData(
        show: true, drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (_) => FlLine(color: colorScheme.outline.withOpacity(isDark ? 0.2 : 0.1), strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      barGroups: data.asMap().entries.map((e) => BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.kwh,
            gradient: LinearGradient(
              colors: [colorScheme.primaryContainer, colorScheme.primary],
              begin: Alignment.bottomCenter, end: Alignment.topCenter),
            width: data.length > 15 ? 6 : 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      )).toList(),
    ));
  }
}
