import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_theme.dart';
import '../services/combustible/combustible_service.dart';

class MetricasConductor extends StatefulWidget {
  const MetricasConductor({super.key});

  @override
  State<MetricasConductor> createState() => _MetricasConductorState();
}

class _MetricasConductorState extends State<MetricasConductor>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Datos demo ────────────────────────────────────────────────────────────
  final List<double> _viajesSemana = [3, 5, 4, 7, 6, 8, 2];
  final List<double> _gananciasMes = [420, 560, 390, 680, 510];
  final Map<String, double> _estadosViajes = {
    'Completados': 72,
    'Cancelados': 18,
    'En curso': 10,
  };
  final Map<String, dynamic> _kpis = {
    'total_viajes': 35,
    'km_totales': 412.5,
    'calificacion': 4.8,
    'ganancias_total': 2560.0,
  };
  final Map<String, dynamic> _resumen = {
    'viajes_completados': 28,
    'viajes_cancelados': 7,
    'km_promedio': 11.8,
    'tiempo_promedio_min': 24,
    'ganancia_promedio': 73.1,
    'mejor_dia': 'Sábado',
  };

  // ── Datos gasolina (desde backend) ───────────────────────────────────────
  Map<String, dynamic>? _nivelData;
  List<Map<String, dynamic>> _historialCargas = [];
  bool _cargandoCombustible = false;
  String? _errorCombustible;

  // ── Estáticos ─────────────────────────────────────────────────────────────
  final List<String> _diasSemana = ['L', 'M', 'Mi', 'J', 'V', 'S', 'D'];
  final List<String> _semanasMes = ['S1', 'S2', 'S3', 'S4', 'S5'];

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
    _cargarDatosCombustible();
  }

  Future<void> _cargarDatosCombustible() async {
    setState(() {
      _cargandoCombustible = true;
      _errorCombustible = null;
    });
    try {
      final kmActuales = (_kpis['km_totales'] as num).toDouble();
      final results = await Future.wait([
        CombustibleService.obtenerNivel(kmActuales),
        CombustibleService.obtenerHistorial(limite: 5),
      ]);
      if (!mounted) return;
      setState(() {
        _nivelData         = results[0] as Map<String, dynamic>;
        _historialCargas   = results[1] as List<Map<String, dynamic>>;
        _cargandoCombustible = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargandoCombustible = false;
        _errorCombustible    = 'Sin conexión al servidor';
      });
    }
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
            delegate: _HeaderDelegate(),
          ),
          SliverToBoxAdapter(
            child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildKpiRow(),
                            const SizedBox(height: 28),
                            _buildSectionTitle('Viajes por día', Icons.bar_chart_rounded),
                            const SizedBox(height: 14),
                            _buildBarChart(),
                            const SizedBox(height: 28),
                            _buildSectionTitle('Ganancias por semana', Icons.trending_up_rounded),
                            const SizedBox(height: 14),
                            _buildLineChart(),
                            const SizedBox(height: 28),
                            _buildSectionTitle('Estado de viajes', Icons.pie_chart_rounded),
                            const SizedBox(height: 14),
                            _buildPieSection(),
                            const SizedBox(height: 28),
                            _buildSectionTitle('Resumen del mes', Icons.table_chart_rounded),
                            const SizedBox(height: 14),
                            _buildResumenTable(),
                            const SizedBox(height: 28),
                            _buildSectionTitle('Control de gasolina', Icons.local_gas_station_rounded),
                            const SizedBox(height: 14),
                            _buildFuelSection(),
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
    final calificacion = _kpis['calificacion'];
    final kpis = [
      {'label': 'Total viajes', 'value': '${_kpis['total_viajes']}', 'icon': Icons.directions_car_rounded, 'color': AppColors.primary},
      {'label': 'Km recorridos', 'value': '${_kpis['km_totales']} km', 'icon': Icons.route_rounded, 'color': AppColors.success},
      {'label': 'Calificación', 'value': calificacion != null ? '$calificacion ★' : 'N/A', 'icon': Icons.star_rounded, 'color': const Color(0xFFF59E0B)},
      {'label': 'Ganancias', 'value': '\$${_kpis['ganancias_total']}', 'icon': Icons.payments_rounded, 'color': AppColors.primary},
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

  // ── CONTROL GASOLINA ──────────────────────────────────────────────────────

  Color _fuelColor(double nivel) {
    if (nivel > 0.5) return AppColors.success;
    if (nivel > 0.25) return const Color(0xFFF59E0B);
    return AppColors.error;
  }

  Widget _buildFuelSection() {
    if (_cargandoCombustible) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorCombustible != null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text(_errorCombustible!, style: mBold(color: AppColors.error, size: 13)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.refresh_rounded, color: AppColors.white, size: 18),
                label: Text('Reintentar', style: mBold(color: AppColors.white, size: 13)),
                onPressed: _cargarDatosCombustible,
              ),
            ),
          ],
        ),
      );
    }

    final sinRegistros = _nivelData == null ||
        (_nivelData!['sin_registros'] == true);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sinRegistros) ...[
            // ── Sin registros ─────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  const Icon(Icons.local_gas_station_outlined,
                      size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 10),
                  Text(
                    'Sin cargas registradas',
                    style: mBold(color: AppColors.textSecondary, size: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registra tu primera carga para ver el nivel estimado',
                    style: mBold(color: AppColors.textSecondary, size: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            // ── Indicador nivel ───────────────────────────────────────────
            Builder(builder: (_) {
              final nivel     = (_nivelData!['nivel'] as num).toDouble();
              final porcentaje = (_nivelData!['porcentaje'] as num).toStringAsFixed(1);
              final litros    = (_nivelData!['litros_actuales'] as num).toStringAsFixed(1);
              final capacidad = (_nivelData!['capacidad_tanque'] as num).toStringAsFixed(0);
              final color     = _fuelColor(nivel);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_gas_station_rounded, color: color, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Nivel estimado', style: mBold(color: AppColors.textSecondary, size: 12)),
                                Text('$litros / $capacidad L  ($porcentaje%)',
                                    style: mBold(color: color, size: 13)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: nivel,
                                minHeight: 14,
                                backgroundColor: color.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                            if (nivel <= 0.25)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded,
                                        color: AppColors.error, size: 14),
                                    const SizedBox(width: 4),
                                    Text('Nivel bajo — recarga pronto',
                                        style: mBold(color: AppColors.error, size: 11)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _buildFuelStat(
                          Icons.speed_rounded, 'Rendimiento',
                          '${(_nivelData!['rendimiento_kmL'] as num).toStringAsFixed(1)} km/L',
                          const Color(0xFFF59E0B))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildFuelStat(
                          Icons.route_rounded, 'Km desde carga',
                          '${(_nivelData!['km_desde_carga'] as num).toStringAsFixed(1)} km',
                          AppColors.primary)),
                    ],
                  ),
                ],
              );
            }),
          ],

          const Divider(height: 28, color: AppColors.border),

          // ── Botón registrar carga ─────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              icon: const Icon(Icons.add_rounded, color: AppColors.white, size: 18),
              label: Text('Registré gasolina',
                  style: mBold(color: AppColors.white, size: 14)),
              onPressed: _mostrarModalRegistrarCarga,
            ),
          ),

          // ── Historial ─────────────────────────────────────────────────────
          if (_historialCargas.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Últimas cargas', style: mBold(size: 14)),
            const SizedBox(height: 10),
            ..._historialCargas.map((c) => _buildHistorialItem(c)),
          ],
        ],
      ),
    );
  }

  Widget _buildFuelStat(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: mBold(color: AppColors.textSecondary, size: 10)),
                const SizedBox(height: 2),
                Text(value, style: mBold(color: AppColors.textPrimary, size: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialItem(Map<String, dynamic> carga) {
    final litros  = (carga['litros_en_tanque'] as num).toStringAsFixed(1);
    final costo   = (carga['costo'] as num).toStringAsFixed(0);
    final fecha   = (carga['fecha'] as String?) ?? '';
    final fechaCorta = fecha.length >= 10 ? fecha.substring(0, 10) : fecha;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_gas_station_rounded,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$litros L en tanque',
                style: mBold(size: 13)),
          ),
          Text('\$$costo', style: mBold(color: AppColors.success, size: 13)),
          const SizedBox(width: 12),
          Text(fechaCorta,
              style: mBold(color: AppColors.textSecondary, size: 11)),
        ],
      ),
    );
  }

  void _mostrarModalRegistrarCarga() {
    final ctrlLitros     = TextEditingController(text: '45');
    final ctrlCapacidad  = TextEditingController(
        text: _historialCargas.isNotEmpty
            ? (_historialCargas.first['capacidad_tanque'] as num).toStringAsFixed(0)
            : '50');
    final ctrlCosto      = TextEditingController();
    final ctrlRendimiento = TextEditingController(
        text: _historialCargas.isNotEmpty
            ? (_historialCargas.first['rendimiento_kmL'] as num).toStringAsFixed(1)
            : '10.0');
    final ctrlNotas      = TextEditingController();
    bool guardando       = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Handle ───────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Registrar carga de gasolina', style: mBold(size: 17)),
              const SizedBox(height: 20),

              // ── Campos ───────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: _modalField(
                    ctrl: ctrlLitros,
                    label: 'Litros en tanque después de cargar',
                    hint: 'ej. 45',
                    suffix: 'L',
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _modalField(
                    ctrl: ctrlCapacidad,
                    label: 'Capacidad total del tanque',
                    hint: 'ej. 50',
                    suffix: 'L',
                  )),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _modalField(
                    ctrl: ctrlCosto,
                    label: 'Costo pagado',
                    hint: 'ej. 600',
                    prefix: '\$',
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _modalField(
                    ctrl: ctrlRendimiento,
                    label: 'Rendimiento esperado',
                    hint: 'ej. 10.5',
                    suffix: 'km/L',
                  )),
                ],
              ),
              const SizedBox(height: 14),
              _modalField(
                ctrl: ctrlNotas,
                label: 'Notas (opcional)',
                hint: 'ej. Carga en gasolinera del centro',
              ),
              const SizedBox(height: 22),

              // ── Guardar ──────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: guardando
                      ? null
                      : () async {
                          final litros    = double.tryParse(ctrlLitros.text);
                          final capacidad = double.tryParse(ctrlCapacidad.text);
                          final costo     = double.tryParse(ctrlCosto.text);
                          final rend      = double.tryParse(ctrlRendimiento.text);

                          if (litros == null || capacidad == null ||
                              costo == null || rend == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Llena todos los campos requeridos')),
                            );
                            return;
                          }

                          setModal(() => guardando = true);
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            final kmActuales =
                                (_kpis['km_totales'] as num).toDouble();
                            await CombustibleService.registrarCarga(
                              litrosEnTanque: litros,
                              capacidadTanque: capacidad,
                              rendimientoKmL: rend,
                              costo: costo,
                              kmAlCargar: kmActuales,
                              notas: ctrlNotas.text.trim().isEmpty
                                  ? null
                                  : ctrlNotas.text.trim(),
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            await _cargarDatosCombustible();
                          } catch (e) {
                            setModal(() => guardando = false);
                            messenger.showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                  child: guardando
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.white))
                      : Text('Guardar carga',
                          style: mBold(color: AppColors.white, size: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modalField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    String? suffix,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: mBold(color: AppColors.textSecondary, size: 11)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            prefixText: prefix,
            hintStyle: GoogleFonts.montserrat(
                color: AppColors.textSecondary, fontSize: 13),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  // ── TABLA RESUMEN ─────────────────────────────────────────────────────────

  Widget _buildResumenTable() {
    final rows = [
      ['Viajes completados', '${_resumen['viajes_completados']}'],
      ['Viajes cancelados', '${_resumen['viajes_cancelados']}'],
      ['Km promedio por viaje', '${_resumen['km_promedio']} km'],
      ['Tiempo promedio', '${_resumen['tiempo_promedio_min']} min'],
      ['Ganancia promedio', '\$${_resumen['ganancia_promedio']}'],
      ['Mejor día', '${_resumen['mejor_dia']}'],
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
  _HeaderDelegate();

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
