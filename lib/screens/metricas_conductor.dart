import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';

class MetricasConductor extends StatefulWidget {
  const MetricasConductor({super.key});

  @override
  State<MetricasConductor> createState() => _MetricasConductorState();
}

class _MetricasConductorState extends State<MetricasConductor>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  late TabController _tabController;

  // ── Datos de ejemplo ──────────────────────────────────────────────────────

  final List<double> _viajesSemana = [3, 5, 4, 7, 6, 2, 4];
  final List<double> _gananciasMes = [1200, 1800, 1500, 2200, 1900, 2500, 2100, 2800];
  final List<String> _diasSemana = ['L', 'M', 'Mi', 'J', 'V', 'S', 'D'];
  final List<String> _semanasMes = ['S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8'];

  final Map<String, double> _estadosViajes = {
    'Completados': 78,
    'Cancelados': 12,
    'En curso': 10,
  };

  final List<Color> _pieColors = [
    AppColors.primary,
    AppColors.error,
    AppColors.warning,
  ];

  TextStyle mBold({Color color = AppColors.textPrimary, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: const DriverBottomNav(selectedIndex: 2),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(
              isVoiceActive: _isListening,
              onVoiceTap: () => setState(() => _isListening = !_isListening),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Cards
                  _buildKpiRow(),
                  const SizedBox(height: 28),

                  // Viajes por día (bar chart)
                  _buildSectionTitle('Viajes por día', Icons.bar_chart_rounded),
                  const SizedBox(height: 14),
                  _buildBarChart(),
                  const SizedBox(height: 28),

                  // Ganancias (line chart)
                  _buildSectionTitle('Ganancias por semana', Icons.trending_up_rounded),
                  const SizedBox(height: 14),
                  _buildLineChart(),
                  const SizedBox(height: 28),

                  // Estado de viajes (pie chart)
                  _buildSectionTitle('Estado de viajes', Icons.pie_chart_rounded),
                  const SizedBox(height: 14),
                  _buildPieSection(),
                  const SizedBox(height: 28),

                  // Tabla resumen
                  _buildSectionTitle('Resumen del mes', Icons.table_chart_rounded),
                  const SizedBox(height: 14),
                  _buildResumenTable(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── KPI ───────────────────────────────────────────────────────────────────

  Widget _buildKpiRow() {
    final kpis = [
      {'label': 'Total viajes', 'value': '124', 'icon': Icons.directions_car_rounded, 'color': AppColors.primary},
      {'label': 'Km recorridos', 'value': '2,341', 'icon': Icons.route_rounded, 'color': AppColors.success},
      {'label': 'Calificación', 'value': '4.8 ★', 'icon': Icons.star_rounded, 'color': const Color(0xFFF59E0B)},
      {'label': 'Ganancias', 'value': '\$14,200', 'icon': Icons.payments_rounded, 'color': AppColors.primary},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.7,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, i) {
        final color = kpis[i]['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(kpis[i]['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(kpis[i]['label'] as String, style: mBold(color: AppColors.textSecondary, size: 10)),
                    const SizedBox(height: 2),
                    Text(kpis[i]['value'] as String, style: mBold(color: AppColors.textPrimary, size: 15)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── SECCIÓN TÍTULO ────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: mBold(size: 16)),
      ],
    );
  }

  // ── BAR CHART ─────────────────────────────────────────────────────────────

  Widget _buildBarChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: BarChart(
        BarChartData(
          maxY: 10,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.primary,
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                '${rod.toY.toInt()} viajes',
                GoogleFonts.montserrat(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: mBold(color: AppColors.textSecondary, size: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  _diasSemana[value.toInt()],
                  style: mBold(color: AppColors.textSecondary, size: 11),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(_viajesSemana.length, (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _viajesSemana[i],
                color: AppColors.primary,
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          )),
        ),
      ),
    );
  }

  // ── LINE CHART ────────────────────────────────────────────────────────────

  Widget _buildLineChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.primary,
              getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                '\$${s.y.toInt()}',
                GoogleFonts.montserrat(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w600),
              )).toList(),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, _) => Text(
                  '\$${value.toInt()}',
                  style: mBold(color: AppColors.textSecondary, size: 9),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  _semanasMes[value.toInt()],
                  style: mBold(color: AppColors.textSecondary, size: 11),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(_gananciasMes.length, (i) => FlSpot(i.toDouble(), _gananciasMes[i])),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: FlDotData(
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.white,
                  strokeColor: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PIE CHART ─────────────────────────────────────────────────────────────

  Widget _buildPieSection() {
    final entries = _estadosViajes.entries.toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 36,
                sections: List.generate(entries.length, (i) => PieChartSectionData(
                  value: entries[i].value,
                  color: _pieColors[i],
                  radius: 36,
                  title: '${entries[i].value.toInt()}%',
                  titleStyle: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                )),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(entries.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _pieColors[i],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entries[i].key, style: mBold(size: 12))),
                    Text('${entries[i].value.toInt()}%', style: mBold(color: AppColors.textSecondary, size: 12)),
                  ],
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }

  // ── TABLA RESUMEN ─────────────────────────────────────────────────────────

  Widget _buildResumenTable() {
    final rows = [
      ['Viajes completados', '97'],
      ['Viajes cancelados', '15'],
      ['Km promedio por viaje', '18.9 km'],
      ['Tiempo promedio', '32 min'],
      ['Ganancia promedio', '\$114.5'],
      ['Mejor día', 'Jueves'],
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(rows.length, (i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: i < rows.length - 1
                ? const Border(bottom: BorderSide(color: AppColors.border))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rows[i][0], style: mBold(color: AppColors.textSecondary, size: 13)),
              Text(rows[i][1], style: mBold(color: AppColors.primary, size: 13)),
            ],
          ),
        )),
      ),
    );
  }
}

// ── HEADER ────────────────────────────────────────────────────────────────────

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;

  _HeaderDelegate({required this.isVoiceActive, required this.onVoiceTap});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: maxExtent,
          width: double.infinity,
          color: AppColors.primaryLight,
          child: Center(
            child: Text(
              'Mis Métricas',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        Positioned(
          left: 10,
          bottom: 20,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        
      ],
    );
  }

  @override
  double get maxExtent => 80;
  @override
  double get minExtent => 80;
  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) => true;
}
