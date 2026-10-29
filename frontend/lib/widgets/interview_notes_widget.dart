import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/wawancara_model.dart';
import 'custom_text_field.dart';

/// Widget catatan persiapan wawancara dengan fitur Tambah, Ubah, dan Hapus
class InterviewNotesWidget extends StatelessWidget {
  final int lamaranId;
  final List<WawancaraModel> notes;
  final Function(String pertanyaan, String? jawaban, String? halDipelajari) onAdd;
  final Function(int noteId, String pertanyaan, String? jawaban, String? halDipelajari) onUpdate;
  final Function(int noteId) onDelete;

  const InterviewNotesWidget({
    super.key,
    required this.lamaranId,
    required this.notes,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  void _showNoteDialog(BuildContext context, {WawancaraModel? existingNote}) {
    final pertanyaanCtrl = TextEditingController(text: existingNote?.pertanyaan ?? '');
    final jawabanCtrl = TextEditingController(text: existingNote?.jawaban ?? '');
    final halDipelajariCtrl = TextEditingController(text: existingNote?.halDipelajari ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: formKey,
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
                    Text(
                      existingNote == null
                          ? 'Tambah Catatan Wawancara'
                          : 'Ubah Catatan Wawancara',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: pertanyaanCtrl,
                      label: 'Pertanyaan Wawancara *',
                      hint: 'Contoh: Ceritakan proyek tersulit yang pernah Anda buat!',
                      prefixIcon: Icons.help_outline_rounded,
                      maxLines: 2,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Pertanyaan wawancara wajib diisi.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: jawabanCtrl,
                      label: 'Jawaban yang Disiapkan',
                      hint: 'Poin-poin penting atau alur jawaban Anda...',
                      prefixIcon: Icons.question_answer_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: halDipelajariCtrl,
                      label: 'Hal yang Perlu Dipelajari',
                      hint: 'Contoh: Metode STAR, arsitektur microservices, riset profil tim...',
                      prefixIcon: Icons.lightbulb_outline_rounded,
                      maxLines: 2,
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
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                if (existingNote == null) {
                                  onAdd(
                                    pertanyaanCtrl.text.trim(),
                                    jawabanCtrl.text.trim().isNotEmpty ? jawabanCtrl.text.trim() : null,
                                    halDipelajariCtrl.text.trim().isNotEmpty ? halDipelajariCtrl.text.trim() : null,
                                  );
                                } else {
                                  onUpdate(
                                    existingNote.id,
                                    pertanyaanCtrl.text.trim(),
                                    jawabanCtrl.text.trim().isNotEmpty ? jawabanCtrl.text.trim() : null,
                                    halDipelajariCtrl.text.trim().isNotEmpty ? halDipelajariCtrl.text.trim() : null,
                                  );
                                }
                                Navigator.pop(ctx);
                              }
                            },
                            child: Text(existingNote == null ? 'Simpan' : 'Perbarui'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, int noteId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan Wawancara'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan persiapan wawancara ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusDitolak),
            onPressed: () {
              Navigator.pop(ctx);
              onDelete(noteId);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Persiapan Wawancara',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showNoteDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (notes.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.contact_support_outlined,
                    size: 36,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada catatan persiapan wawancara.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tulis pertanyaan yang diprediksi untuk berlatih.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            )
          else
            ...notes.map((note) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pertanyaan & Aksi
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.help_outline_rounded,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note.pertanyaan,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onSelected: (val) {
                            if (val == 'edit') {
                              _showNoteDialog(context, existingNote: note);
                            } else if (val == 'delete') {
                              _showDeleteConfirm(context, note.id);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Text('Ubah'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 16, color: AppTheme.statusDitolak),
                                  SizedBox(width: 8),
                                  Text('Hapus', style: TextStyle(color: AppTheme.statusDitolak)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Jawaban
                    if (note.jawaban != null && note.jawaban!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jawaban yang Disiapkan:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.statusLolos,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note.jawaban!,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Hal yang dipelajari
                    if (note.halDipelajari != null && note.halDipelajari!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 16,
                            color: AppTheme.priority,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Pelajari: ${note.halDipelajari!}',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

