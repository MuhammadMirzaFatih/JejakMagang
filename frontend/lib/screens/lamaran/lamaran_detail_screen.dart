import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/lamaran_model.dart';
import '../../providers/lamaran_provider.dart';
import '../../widgets/document_checklist_widget.dart';
import '../../widgets/interview_notes_widget.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/stage_status_badge.dart';
import '../../widgets/timeline_widget.dart';

/// Layar Detail Lamaran Magang Lengkap
class LamaranDetailScreen extends StatefulWidget {
  final int lamaranId;

  const LamaranDetailScreen({super.key, required this.lamaranId});

  @override
  State<LamaranDetailScreen> createState() => _LamaranDetailScreenState();
}

class _LamaranDetailScreenState extends State<LamaranDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LamaranProvider>().fetchLamaranDetail(widget.lamaranId);
    });
  }

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

  // Dialog Ubah Tahap Seleksi & Status
  void _showChangeStageDialog(BuildContext context, LamaranModel lamaran) {
    String selectedStage = lamaran.tahap;
    String selectedStatus = lamaran.status;
    final noteCtrl = TextEditingController();
    DateTime datePicked = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(dialogCtx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Text(
                        'Ubah Tahapan Seleksi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Pilih Tahap Seleksi Baru:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),

                      // Pilihan Tahap
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          {'key': 'kirim_berkas', 'label': 'Kirim Berkas'},
                          {'key': 'tes', 'label': 'Tes Seleksi'},
                          {'key': 'wawancara', 'label': 'Wawancara'},
                          {'key': 'hasil', 'label': 'Hasil Akhir'},
                        ].map((item) {
                          final isSel = selectedStage == item['key'];
                          return ChoiceChip(
                            label: Text(item['label']!),
                            selected: isSel,
                            selectedColor: AppTheme.primary,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  selectedStage = item['key']!;
                                  if (selectedStage != 'hasil') {
                                    selectedStatus = 'menunggu';
                                  } else if (selectedStatus == 'menunggu') {
                                    selectedStatus = 'lolos';
                                  }
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Pilihan Status jika Tahap Hasil
                      if (selectedStage == 'hasil') ...[
                        const Text(
                          'Keputusan Hasil Akhir *',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text('Lolos / Diterima', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                selected: selectedStatus == 'lolos',
                                selectedColor: AppTheme.statusLolos,
                                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                onSelected: (val) {
                                  if (val) setDialogState(() => selectedStatus = 'lolos');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ChoiceChip(
                                label: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cancel_outlined, size: 16, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text('Ditolak', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                selected: selectedStatus == 'ditolak',
                                selectedColor: AppTheme.statusDitolak,
                                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                onSelected: (val) {
                                  if (val) setDialogState(() => selectedStatus = 'ditolak');
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Catatan Perubahan Garis Waktu
                      const Text(
                        'Catatan Perubahan (Akan Dicatat di Garis Waktu):',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Menerima undangan tes teknis via email...',
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final tglFormatted = DateFormat('yyyy-MM-dd').format(datePicked);
                                final lamaranProvider = context.read<LamaranProvider>();
                                final scaffoldMessenger = ScaffoldMessenger.of(context);

                                final success = await lamaranProvider.updateTahap(
                                  lamaran.id,
                                  tahap: selectedStage,
                                  status: selectedStage == 'hasil' ? selectedStatus : 'menunggu',
                                  tanggal: tglFormatted,
                                  keterangan: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : null,
                                );

                                if (ctx.mounted) Navigator.pop(ctx);

                                if (mounted && success) {
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Tahapan seleksi berhasil diperbarui.'),
                                      backgroundColor: AppTheme.statusLolos,
                                    ),
                                  );
                                }
                              },
                              child: const Text('Simpan'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Dialog Catatan Evaluasi Hasil Akhir
  void _showEvaluationDialog(BuildContext context, LamaranModel lamaran) {
    final noteCtrl = TextEditingController(text: lamaran.catatanHasil ?? '');
    String currentStatus = lamaran.status == 'menunggu' ? 'lolos' : lamaran.status;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dCtx, setDState) {
            return AlertDialog(
              title: const Text('Catatan Hasil Akhir (Evaluasi)'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tulis alasan diterima, ditolak, atau poin refleksi diri sebagai bahan evaluasi untuk kesempatan magang berikutnya:',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Berhasil menjawab arsitektur Flutter. Perlu perkuat pemahaman database relasional...',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final lamaranProvider = context.read<LamaranProvider>();
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final success = await lamaranProvider.updateCatatanHasil(
                      lamaran.id,
                      catatanHasil: noteCtrl.text.trim(),
                      status: lamaran.tahap == 'hasil' ? currentStatus : null,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);

                    if (mounted && success) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Catatan evaluasi berhasil disimpan.'),
                          backgroundColor: AppTheme.statusLolos,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog Konfirmasi Hapus Lamaran
  void _showDeleteConfirm(BuildContext context, LamaranModel lamaran) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Lamaran Magang'),
        content: Text(
          'Apakah Anda yakin ingin menghapus seluruh data lamaran untuk ${lamaran.namaPerusahaan}? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusDitolak),
            onPressed: () async {
              Navigator.pop(ctx);
              final lamaranProvider = context.read<LamaranProvider>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final router = GoRouter.of(context);
              final success = await lamaranProvider.deleteLamaran(lamaran.id);

              if (mounted && success) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Lamaran berhasil dihapus.'),
                    backgroundColor: AppTheme.statusDitolak,
                  ),
                );
                router.pop();
              }
            },
            child: const Text('Hapus Permanen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final lamaranProvider = context.watch<LamaranProvider>();
    final lamaran = lamaranProvider.selectedLamaran;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (lamaranProvider.isLoading && lamaran == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Lamaran')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (lamaran == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Lamaran')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('Data lamaran tidak ditemukan.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Lamaran'),
        actions: [
          // Tombol Bintang Prioritas
          IconButton(
            tooltip: lamaran.isPrioritas ? 'Hapus Prioritas' : 'Tandai Prioritas',
            icon: Icon(
              lamaran.isPrioritas ? Icons.star_rounded : Icons.star_outline_rounded,
              color: lamaran.isPrioritas ? AppTheme.priority : null,
              size: 26,
            ),
            onPressed: () {
              lamaranProvider.togglePrioritas(lamaran.id, !lamaran.isPrioritas);
            },
          ),
          // Tombol Ubah Data Pokok
          IconButton(
            tooltip: 'Ubah Data Pokok',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/lamaran/${lamaran.id}/edit'),
          ),
          // Tombol Hapus Lamaran
          IconButton(
            tooltip: 'Hapus Lamaran',
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.statusDitolak),
            onPressed: () => _showDeleteConfirm(context, lamaran),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => lamaranProvider.fetchLamaranDetail(lamaran.id),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- KARTU UTAMA: Identitas Perusahaan & Posisi ---
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
                    const SizedBox(height: 14),

                    Text(
                      lamaran.namaPerusahaan,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lamaran.posisi,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),

                    // Detail Tanggal Lamar & Tenggat
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal Lamar',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(lamaran.tanggalLamar),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Batas Tenggat',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(lamaran.tenggat),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: lamaran.isOverdue ? AppTheme.overdue : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Tautan Lowongan & Kontak HRD jika ada
                    if (lamaran.tautanLowongan != null && lamaran.tautanLowongan!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => _launchUrl(lamaran.tautanLowongan!),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.link_rounded, size: 16, color: AppTheme.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  lamaran.tautanLowongan!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    if ((lamaran.namaKontakHrd != null && lamaran.namaKontakHrd!.isNotEmpty) ||
                        (lamaran.emailKontakHrd != null && lamaran.emailKontakHrd!.isNotEmpty)) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.person_pin_outlined, size: 16, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'HRD: ${lamaran.namaKontakHrd ?? "-"} ${lamaran.emailKontakHrd != null ? "(${lamaran.emailKontakHrd})" : ""}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Tombol Aksi Utama: Ubah Tahap Seleksi
                    ElevatedButton.icon(
                      onPressed: () => _showChangeStageDialog(context, lamaran),
                      icon: const Icon(Icons.timeline_rounded, size: 18),
                      label: const Text('Pindah Tahap Seleksi'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // --- BAGIAN CATATAN HASIL EVALUASI (Jika tahap hasil atau sudah ada catatan) ---
              if (lamaran.tahap == 'hasil' || (lamaran.catatanHasil != null && lamaran.catatanHasil!.isNotEmpty)) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: lamaran.status == 'lolos'
                        ? (isDark ? const Color(0xFF064E3B).withOpacity(0.4) : const Color(0xFFDCFCE7))
                        : (isDark ? const Color(0xFF881337).withOpacity(0.4) : const Color(0xFFFFE4E6)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: lamaran.status == 'lolos' ? AppTheme.statusLolos : AppTheme.statusDitolak,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                lamaran.status == 'lolos' ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                color: lamaran.status == 'lolos' ? AppTheme.statusLolos : AppTheme.statusDitolak,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Evaluasi Hasil: ${lamaran.statusLabel.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: lamaran.status == 'lolos' ? AppTheme.statusLolos : AppTheme.statusDitolak,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_note_rounded, size: 22),
                            onPressed: () => _showEvaluationDialog(context, lamaran),
                            tooltip: 'Ubah Evaluasi',
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lamaran.catatanHasil != null && lamaran.catatanHasil!.isNotEmpty
                            ? lamaran.catatanHasil!
                            : 'Belum ada catatan evaluasi. Klik ikon pensil untuk menulis catatan evaluasi.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                          fontStyle: lamaran.catatanHasil != null && lamaran.catatanHasil!.isNotEmpty
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // --- BAGIAN GARIS WAKTU (TIMELINE) - MENONJOL SEBAGAI CIRI KHAS ---
              Container(
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.route_rounded, size: 20, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Garis Waktu Seleksi',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Riwayat perjalanan tahapan lamaran magang',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TimelineWidget(riwayatList: lamaran.riwayat),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // --- BAGIAN DAFTAR CENTANG BERKAS PERSYARATAN ---
              DocumentChecklistWidget(
                berkasList: lamaran.berkas,
                onToggle: (berkasId, sudahSiap) {
                  lamaranProvider.toggleBerkas(lamaran.id, berkasId, sudahSiap);
                },
              ),
              const SizedBox(height: 18),

              // --- BAGIAN CATATAN PERSIAPAN WAWANCARA ---
              InterviewNotesWidget(
                lamaranId: lamaran.id,
                notes: lamaran.catatanWawancara,
                onAdd: (pertanyaan, jawaban, halDipelajari) {
                  lamaranProvider.addCatatanWawancara(
                    lamaran.id,
                    pertanyaan: pertanyaan,
                    jawaban: jawaban,
                    halDipelajari: halDipelajari,
                  );
                },
                onUpdate: (noteId, pertanyaan, jawaban, halDipelajari) {
                  lamaranProvider.updateCatatanWawancara(
                    lamaran.id,
                    noteId,
                    pertanyaan: pertanyaan,
                    jawaban: jawaban,
                    halDipelajari: halDipelajari,
                  );
                },
                onDelete: (noteId) {
                  lamaranProvider.deleteCatatanWawancara(lamaran.id, noteId);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
