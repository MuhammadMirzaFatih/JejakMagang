import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/lamaran_model.dart';
import 'priority_badge.dart';
import 'stage_status_badge.dart';

/// Kartu tampilan ringkas lamaran magang pada daftar utama
class ApplicationCard extends StatelessWidget {
  final LamaranModel lamaran;
  final VoidCallback onTap;
  final ValueChanged<bool>? onTogglePriority;

  const ApplicationCard({
    super.key,
    required this.lamaran,
    required this.onTap,
    this.onTogglePriority,
  });

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('d MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      try {
        final dt = DateTime.parse(dateStr);
        return DateFormat('d MMM yyyy').format(dt);
      } catch (_) {
        return dateStr;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris 1: Penanda Prioritas & Label Tahap
              Row(
                children: [
                  if (lamaran.isPrioritas) ...[
                    const PriorityBadge(),
                    const SizedBox(width: 8),
                  ],
                  if (lamaran.isOverdue) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.overdue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.overdue.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 13, color: AppTheme.overdue),
                          SizedBox(width: 4),
                          Text(
                            'Lewat Tenggat',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.overdue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  StageBadge(tahap: lamaran.tahap),
                  const SizedBox(width: 6),
                  StatusBadge(status: lamaran.status),
                ],
              ),
              const SizedBox(height: 12),

              // Baris 2: Nama Perusahaan & Posisi
              Text(
                lamaran.namaPerusahaan,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                lamaran.posisi,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),

              // Baris 3: Tanggal Lamar & Tenggat
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tenggat: ${_formatDate(lamaran.tenggat)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: lamaran.isOverdue
                          ? AppTheme.overdue
                          : (lamaran.isMendekatiTenggat ? AppTheme.statusMenunggu : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569))),
                    ),
                  ),
                  if (lamaran.status == 'menunggu' && !lamaran.isOverdue) ...[
                    const SizedBox(width: 6),
                    Text(
                      '(${lamaran.sisaHari} hari lagi)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: lamaran.isMendekatiTenggat ? AppTheme.statusMenunggu : AppTheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Baris 4: Progres Kelengkapan Berkas
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kelengkapan Berkas Persyaratan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '${lamaran.berkasSiap}/${lamaran.totalBerkas} (${lamaran.persentaseBerkas}%)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: lamaran.persentaseBerkas == 100
                              ? AppTheme.statusLolos
                              : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: lamaran.totalBerkas > 0 ? (lamaran.berkasSiap / lamaran.totalBerkas) : 0,
                      minHeight: 6,
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        lamaran.persentaseBerkas == 100 ? AppTheme.statusLolos : AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

