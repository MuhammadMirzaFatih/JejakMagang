import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/riwayat_tahap_model.dart';

/// Widget Garis Waktu (Timeline) yang menonjol sebagai ciri khas JejakMagang
class TimelineWidget extends StatelessWidget {
  final List<RiwayatTahapModel> riwayatList;

  const TimelineWidget({super.key, required this.riwayatList});

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      try {
        final dt = DateTime.parse(dateStr);
        return DateFormat('d MMMM yyyy').format(dt);
      } catch (_) {
        return dateStr;
      }
    }
  }

  IconData _getStageIcon(String tahap) {
    switch (tahap) {
      case 'kirim_berkas':
        return Icons.upload_file_rounded;
      case 'tes':
        return Icons.quiz_rounded;
      case 'wawancara':
        return Icons.record_voice_over_rounded;
      case 'hasil':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.circle;
    }
  }

  Color _getStageColor(String tahap) {
    switch (tahap) {
      case 'kirim_berkas':
        return const Color(0xFF2563EB);
      case 'tes':
        return const Color(0xFF7C3AED);
      case 'wawancara':
        return const Color(0xFFD97706);
      case 'hasil':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (riwayatList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text(
          'Belum ada riwayat garis waktu.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: riwayatList.length,
      itemBuilder: (context, index) {
        final item = riwayatList[index];
        final isLast = index == riwayatList.length - 1;
        final stageColor = _getStageColor(item.tahap);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Simpul Garis Waktu & Garis Penghubung
              Column(
                children: [
                  // Simpul Ikon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: stageColor.withOpacity(isDark ? 0.25 : 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: stageColor,
                        width: isLast ? 2.5 : 2,
                      ),
                      boxShadow: isLast
                          ? [
                              BoxShadow(
                                color: stageColor.withOpacity(0.35),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: Icon(
                      _getStageIcon(item.tahap),
                      size: 18,
                      color: stageColor,
                    ),
                  ),

                  // Garis Vertikal Penghubung
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2.5,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              stageColor.withOpacity(0.6),
                              _getStageColor(riwayatList[index + 1].tahap).withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Kolom Konten Riwayat
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLast
                          ? stageColor.withOpacity(0.5)
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      width: isLast ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.tahapLabel,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: stageColor,
                            ),
                          ),
                          if (isLast)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: stageColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Tahap Terkini',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: stageColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 13,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(item.tanggal),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (item.keterangan != null && item.keterangan!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.keterangan!,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
