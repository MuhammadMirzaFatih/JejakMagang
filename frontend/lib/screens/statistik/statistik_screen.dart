import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/statistik_model.dart';
import '../../providers/statistik_provider.dart';
import '../../widgets/stat_card.dart';

/// Layar Ringkasan Statistik Lamaran Magang dengan Grafik fl_chart
class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatistikProvider>().fetchStatistik();
    });
  }

  @override
  Widget build(BuildContext context) {
    final statProvider = context.watch<StatistikProvider>();
    final stats = statProvider.statistik;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Statistik'),
      ),
      body: statProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => statProvider.fetchStatistik(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grid Metrik Ringkasan
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.35,
                      children: [
                        StatCard(
                          title: 'Total Lamaran',
                          count: stats.totalLamaran,
                          icon: Icons.folder_copy_outlined,
                          color: AppTheme.primary,
                          subtitle: 'Seluruh lamaran terdaftar',
                        ),
                        StatCard(
                          title: 'Masih Menunggu',
                          count: stats.menunggu,
                          icon: Icons.hourglass_top_outlined,
                          color: AppTheme.statusMenunggu,
                          subtitle: 'Sedang dalam seleksi',
                        ),
                        StatCard(
                          title: 'Lolos Magang',
                          count: stats.lolos,
                          icon: Icons.check_circle_outline_rounded,
                          color: AppTheme.statusLolos,
                          subtitle: 'Hasil akhir lolos',
                        ),
                        StatCard(
                          title: 'Belum Lolos',
                          count: stats.ditolak,
                          icon: Icons.cancel_outlined,
                          color: AppTheme.statusDitolak,
                          subtitle: 'Hasil akhir ditolak',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Baris Metrik Tambahan: Prioritas & Lewat Tenggat
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Lamaran Impian',
                            count: stats.prioritas,
                            icon: Icons.star_rounded,
                            color: AppTheme.priority,
                            subtitle: 'Ditandai prioritas',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Lewat Tenggat',
                            count: stats.lewatTenggat,
                            icon: Icons.warning_amber_rounded,
                            color: AppTheme.overdue,
                            subtitle: 'Perlu tindak lanjut',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- GRAFIK 1: DIAGRAM LINGKARAN (PIE CHART) STATUS LAMARAN ---
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sebaran Status Lamaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Proporsi status menunggu, lolos, dan ditolak',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (stats.totalLamaran == 0)
                            Container(
                              height: 180,
                              alignment: Alignment.center,
                              child: const Text('Belum ada data lamaran untuk ditampilkan.'),
                            )
                          else
                            Column(
                              children: [
                                SizedBox(
                                  height: 200,
                                  child: PieChart(
                                    PieChartData(
                                      pieTouchData: PieTouchData(
                                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                          setState(() {
                                            if (!event.isInterestedForInteractions ||
                                                pieTouchResponse == null ||
                                                pieTouchResponse.touchedSection == null) {
                                              _touchedPieIndex = -1;
                                              return;
                                            }
                                            _touchedPieIndex = pieTouchResponse
                                                .touchedSection!.touchedSectionIndex;
                                          });
                                        },
                                      ),
                                      borderData: FlBorderData(show: false),
                                      sectionsSpace: 3,
                                      centerSpaceRadius: 40,
                                      sections: _buildPieSections(stats),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Legenda
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildLegendItem('Menunggu', stats.menunggu, AppTheme.statusMenunggu),
                                    _buildLegendItem('Lolos', stats.lolos, AppTheme.statusLolos),
                                    _buildLegendItem('Ditolak', stats.ditolak, AppTheme.statusDitolak),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- GRAFIK 2: DIAGRAM BATANG (BAR CHART) SEBARAN TAHAPAN SELEKSI ---
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Distribusi Tahapan Seleksi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Jumlah lamaran di tiap tahapan seleksi',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (stats.totalLamaran == 0)
                            Container(
                              height: 180,
                              alignment: Alignment.center,
                              child: const Text('Belum ada data tahapan.'),
                            )
                          else
                            SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: _getMaxBarValue(stats).toDouble() + 1,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipColor: (_) => isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
                                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                        final labels = ['Berkas', 'Tes', 'Wawancara', 'Hasil'];
                                        return BarTooltipItem(
                                          '${labels[group.x]}: ${rod.toY.toInt()}',
                                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        );
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          String label;
                                          switch (value.toInt()) {
                                            case 0:
                                              label = 'Berkas';
                                              break;
                                            case 1:
                                              label = 'Tes';
                                              break;
                                            case 2:
                                              label = 'Wawancara';
                                              break;
                                            case 3:
                                              label = 'Hasil';
                                              break;
                                            default:
                                              label = '';
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              label,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 1,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: [
                                    _buildBarGroup(0, stats.kirimBerkas, const Color(0xFF2563EB)),
                                    _buildBarGroup(1, stats.tes, const Color(0xFF7C3AED)),
                                    _buildBarGroup(2, stats.wawancara, const Color(0xFFD97706)),
                                    _buildBarGroup(3, stats.hasil, const Color(0xFF059669)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  List<PieChartSectionData> _buildPieSections(StatistikModel stats) {
    final total = stats.totalLamaran;
    if (total == 0) return [];

    final sections = <PieChartSectionData>[];

    if (stats.menunggu > 0) {
      final isTouched = _touchedPieIndex == 0;
      final pct = ((stats.menunggu / total) * 100).round();
      sections.add(
        PieChartSectionData(
          color: AppTheme.statusMenunggu,
          value: stats.menunggu.toDouble(),
          title: '$pct%',
          radius: isTouched ? 65 : 55,
          titleStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }

    if (stats.lolos > 0) {
      final isTouched = _touchedPieIndex == 1;
      final pct = ((stats.lolos / total) * 100).round();
      sections.add(
        PieChartSectionData(
          color: AppTheme.statusLolos,
          value: stats.lolos.toDouble(),
          title: '$pct%',
          radius: isTouched ? 65 : 55,
          titleStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }

    if (stats.ditolak > 0) {
      final isTouched = _touchedPieIndex == 2;
      final pct = ((stats.ditolak / total) * 100).round();
      sections.add(
        PieChartSectionData(
          color: AppTheme.statusDitolak,
          value: stats.ditolak.toDouble(),
          title: '$pct%',
          radius: isTouched ? 65 : 55,
          titleStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }

    return sections;
  }

  BarChartGroupData _buildBarGroup(int x, int y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          color: color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  int _getMaxBarValue(StatistikModel stats) {
    final list = [stats.kirimBerkas, stats.tes, stats.wawancara, stats.hasil];
    int max = 0;
    for (final v in list) {
      if (v > max) max = v;
    }
    return max < 4 ? 4 : max;
  }

  Widget _buildLegendItem(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$title ($count)',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
