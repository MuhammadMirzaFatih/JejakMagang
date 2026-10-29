import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/lamaran_model.dart';
import '../../providers/lamaran_provider.dart';
import '../../widgets/custom_text_field.dart';

/// Layar Formulir Tambah dan Ubah Lamaran Magang
class LamaranFormScreen extends StatefulWidget {
  final int? lamaranId;

  const LamaranFormScreen({super.key, this.lamaranId});

  @override
  State<LamaranFormScreen> createState() => _LamaranFormScreenState();
}

class _LamaranFormScreenState extends State<LamaranFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _perusahaanCtrl = TextEditingController();
  final _posisiCtrl = TextEditingController();
  final _tglLamarCtrl = TextEditingController();
  final _tenggatCtrl = TextEditingController();
  final _tautanCtrl = TextEditingController();
  final _namaHrdCtrl = TextEditingController();
  final _emailHrdCtrl = TextEditingController();

  DateTime _selectedTglLamar = DateTime.now();
  DateTime _selectedTenggat = DateTime.now().add(const Duration(days: 14));
  bool _isPrioritas = false;
  String _tahap = 'kirim_berkas';
  bool _isEditing = false;
  bool _isInitialLoaded = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.lamaranId != null;

    final todayStr = DateFormat('yyyy-MM-dd').format(_selectedTglLamar);
    final tenggatStr = DateFormat('yyyy-MM-dd').format(_selectedTenggat);
    _tglLamarCtrl.text = todayStr;
    _tenggatCtrl.text = tenggatStr;

    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingData());
    }
  }

  void _loadExistingData() {
    final lamaranProvider = context.read<LamaranProvider>();
    final current = lamaranProvider.selectedLamaran;

    if (current != null && current.id == widget.lamaranId) {
      _populateFields(current);
    } else {
      lamaranProvider.fetchLamaranDetail(widget.lamaranId!).then((_) {
        if (mounted && lamaranProvider.selectedLamaran != null) {
          _populateFields(lamaranProvider.selectedLamaran!);
        }
      });
    }
  }

  void _populateFields(LamaranModel data) {
    setState(() {
      _perusahaanCtrl.text = data.namaPerusahaan;
      _posisiCtrl.text = data.posisi;
      _tglLamarCtrl.text = data.tanggalLamar;
      _tenggatCtrl.text = data.tenggat;
      _tautanCtrl.text = data.tautanLowongan ?? '';
      _namaHrdCtrl.text = data.namaKontakHrd ?? '';
      _emailHrdCtrl.text = data.emailKontakHrd ?? '';
      _isPrioritas = data.isPrioritas;
      _tahap = data.tahap;

      try {
        _selectedTglLamar = DateTime.parse(data.tanggalLamar);
        _selectedTenggat = DateTime.parse(data.tenggat);
      } catch (_) {}

      _isInitialLoaded = true;
    });
  }

  @override
  void dispose() {
    _perusahaanCtrl.dispose();
    _posisiCtrl.dispose();
    _tglLamarCtrl.dispose();
    _tenggatCtrl.dispose();
    _tautanCtrl.dispose();
    _namaHrdCtrl.dispose();
    _emailHrdCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isTglLamar}) async {
    final initialDate = isTglLamar ? _selectedTglLamar : _selectedTenggat;
    final firstDate = isTglLamar
        ? DateTime(2020)
        : _selectedTglLamar; // Tenggat tidak boleh sebelum tanggal lamar
    final lastDate = DateTime(2035);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isTglLamar ? 'PILIH TANGGAL LAMAR' : 'PILIH TANGGAL TENGGAT',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
    );

    if (picked != null) {
      setState(() {
        final formatted = DateFormat('yyyy-MM-dd').format(picked);
        if (isTglLamar) {
          _selectedTglLamar = picked;
          _tglLamarCtrl.text = formatted;
          // Sesuaikan tenggat jika sekarang lebih kecil dari tgl lamar
          if (_selectedTenggat.isBefore(picked)) {
            _selectedTenggat = picked.add(const Duration(days: 7));
            _tenggatCtrl.text = DateFormat('yyyy-MM-dd').format(_selectedTenggat);
          }
        } else {
          _selectedTenggat = picked;
          _tenggatCtrl.text = formatted;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi aturan tanggal: tenggat tidak boleh sebelum tanggal lamar
    if (_selectedTenggat.isBefore(_selectedTglLamar)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal tenggat tidak boleh sebelum tanggal lamar.'),
          backgroundColor: AppTheme.statusDitolak,
        ),
      );
      return;
    }

    final lamaranProvider = context.read<LamaranProvider>();

    final Map<String, dynamic> data = {
      'nama_perusahaan': _perusahaanCtrl.text.trim(),
      'posisi': _posisiCtrl.text.trim(),
      'tanggal_lamar': _tglLamarCtrl.text.trim(),
      'tenggat': _tenggatCtrl.text.trim(),
      'tautan_lowongan': _tautanCtrl.text.trim().isNotEmpty ? _tautanCtrl.text.trim() : null,
      'nama_kontak_hrd': _namaHrdCtrl.text.trim().isNotEmpty ? _namaHrdCtrl.text.trim() : null,
      'email_kontak_hrd': _emailHrdCtrl.text.trim().isNotEmpty ? _emailHrdCtrl.text.trim() : null,
      'is_prioritas': _isPrioritas,
    };

    bool success;
    if (_isEditing) {
      success = await lamaranProvider.updateLamaran(widget.lamaranId!, data);
    } else {
      data['tahap'] = _tahap;
      success = await lamaranProvider.createLamaran(data);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Data lamaran berhasil diperbarui.' : 'Lamaran berhasil ditambahkan.',
          ),
          backgroundColor: AppTheme.statusLolos,
        ),
      );
      context.pop();
    } else {
      final msg = lamaranProvider.errorMessage ?? 'Gagal menyimpan data lamaran.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppTheme.statusDitolak,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lamaranProvider = context.watch<LamaranProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Ubah Data Lamaran' : 'Tambah Lamaran Baru'),
      ),
      body: (_isEditing && !_isInitialLoaded && lamaranProvider.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Bagian 1: Informasi Lowongan ---
                    Text(
                      'Informasi Pokok Magang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Nama Perusahaan
                    CustomTextField(
                      controller: _perusahaanCtrl,
                      label: 'Nama Perusahaan *',
                      hint: 'Contoh: PT Bank Central Asia Tbk',
                      prefixIcon: Icons.business_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Nama perusahaan wajib diisi.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Posisi Magang
                    CustomTextField(
                      controller: _posisiCtrl,
                      label: 'Posisi / Jabatan Magang *',
                      hint: 'Contoh: Mobile Developer Intern',
                      prefixIcon: Icons.work_outline_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Posisi magang wajib diisi.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Baris Tanggal Lamar & Tenggat
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _tglLamarCtrl,
                            label: 'Tanggal Lamar *',
                            hint: 'YYYY-MM-DD',
                            prefixIcon: Icons.calendar_today_rounded,
                            readOnly: true,
                            onTap: () => _pickDate(isTglLamar: true),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Wajib diisi.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _tenggatCtrl,
                            label: 'Tenggat Waktu *',
                            hint: 'YYYY-MM-DD',
                            prefixIcon: Icons.event_available_rounded,
                            readOnly: true,
                            onTap: () => _pickDate(isTglLamar: false),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Wajib diisi.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Tautan Lowongan
                    CustomTextField(
                      controller: _tautanCtrl,
                      label: 'Tautan Info Lowongan (Opsional)',
                      hint: 'https://career.perusahaan.com/jobs/...',
                      prefixIcon: Icons.link_rounded,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 24),

                    // --- Bagian 2: Kontak Rekrutmen / HRD ---
                    Text(
                      'Kontak Rekrutmen / HRD (Opsional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: _namaHrdCtrl,
                      label: 'Nama Kontak HRD',
                      hint: 'Contoh: Ibu Sarah Wijaya',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: _emailHrdCtrl,
                      label: 'Email Kontak HRD',
                      hint: 'recruitment@perusahaan.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(val.trim())) {
                            return 'Format email tidak valid.';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- Bagian 3: Prioritas Impian ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isPrioritas
                              ? AppTheme.priority
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Icon(
                          Icons.star_rounded,
                          color: _isPrioritas ? AppTheme.priority : Colors.grey,
                        ),
                        title: const Text(
                          'Tandai Sebagai Prioritas (Impian)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Lamaran prioritas akan selalu ditampilkan di urutan paling atas.',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _isPrioritas,
                        activeThumbColor: AppTheme.priority,
                        onChanged: (val) {
                          setState(() {
                            _isPrioritas = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol Simpan
                    ElevatedButton(
                      onPressed: lamaranProvider.isLoading ? null : _handleSave,
                      child: lamaranProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(_isEditing ? 'Simpan Perubahan' : 'Tambahkan Lamaran'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
