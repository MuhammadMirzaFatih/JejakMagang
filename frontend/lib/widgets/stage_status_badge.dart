import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Badge visual untuk menampilkan Tahap Seleksi
class StageBadge extends StatelessWidget {
  final String tahap;

  const StageBadge({super.key, required this.tahap});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (tahap) {
      case 'kirim_berkas':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        label = 'Kirim Berkas';
        icon = Icons.upload_file_outlined;
        break;
      case 'tes':
        bg = const Color(0xFFF5F3FF);
        fg = const Color(0xFF7C3AED);
        label = 'Tes Seleksi';
        icon = Icons.assignment_outlined;
        break;
      case 'wawancara':
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFD97706);
        label = 'Wawancara';
        icon = Icons.record_voice_over_outlined;
        break;
      case 'hasil':
        bg = const Color(0xFFF0FDF4);
        fg = const Color(0xFF059669);
        label = 'Hasil Akhir';
        icon = Icons.flag_outlined;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        label = tahap;
        icon = Icons.info_outline;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? fg.withOpacity(0.2) : bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? AppTheme.primaryLight : fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge visual untuk menampilkan Status Akhir (Menunggu, Lolos, Ditolak)
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case 'lolos':
        bg = const Color(0xFFDCFCE7);
        fg = AppTheme.statusLolos;
        label = 'Lolos';
        icon = Icons.check_circle_outline;
        break;
      case 'ditolak':
        bg = const Color(0xFFFFE4E6);
        fg = AppTheme.statusDitolak;
        label = 'Ditolak';
        icon = Icons.cancel_outlined;
        break;
      case 'menunggu':
      default:
        bg = const Color(0xFFFEF3C7);
        fg = AppTheme.statusMenunggu;
        label = 'Menunggu';
        icon = Icons.hourglass_top_outlined;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? fg.withOpacity(0.2) : bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : fg,
            ),
          ),
        ],
      ),
    );
  }
}

