import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/berkas_model.dart';

/// Widget daftar centang kelengkapan berkas persyaratan
class DocumentChecklistWidget extends StatelessWidget {
  final List<BerkasModel> berkasList;
  final Function(int berkasId, bool sudahSiap) onToggle;

  const DocumentChecklistWidget({
    super.key,
    required this.berkasList,
    required this.onToggle,
  });

  IconData _getBerkasIcon(String nama) {
    final lower = nama.toLowerCase();
    if (lower.contains('cv')) return Icons.badge_outlined;
    if (lower.contains('surat')) return Icons.mail_outline;
    if (lower.contains('portofolio')) return Icons.folder_special_outlined;
    if (lower.contains('transkrip')) return Icons.school_outlined;
    return Icons.description_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final total = berkasList.length;
    final siap = berkasList.where((b) => b.sudahSiap).length;
    final persentase = total > 0 ? ((siap / total) * 100).round() : 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
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
          // Header & Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kelengkapan Berkas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: persentase == 100
                      ? AppTheme.statusLolos.withOpacity(0.15)
                      : AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$siap/$total Siap ($persentase%)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: persentase == 100 ? AppTheme.statusLolos : AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total > 0 ? (siap / total) : 0,
              minHeight: 8,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                persentase == 100 ? AppTheme.statusLolos : AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Daftar Centang Berkas
          ...berkasList.map((berkas) {
            return InkWell(
              onTap: () => onToggle(berkas.id, !berkas.sudahSiap),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      _getBerkasIcon(berkas.namaBerkas),
                      size: 20,
                      color: berkas.sudahSiap
                          ? AppTheme.statusLolos
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        berkas.namaBerkas,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: berkas.sudahSiap ? TextDecoration.lineThrough : null,
                          color: berkas.sudahSiap
                              ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
                              : (isDark ? Colors.white : const Color(0xFF0F172A)),
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 1.1,
                      child: Checkbox(
                        value: berkas.sudahSiap,
                        activeColor: AppTheme.statusLolos,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            onToggle(berkas.id, val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

