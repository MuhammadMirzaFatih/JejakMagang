import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lamaran_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/application_card.dart';
import '../../widgets/empty_state_widget.dart';

/// Layar Daftar Seluruh Lamaran Magang
class LamaranListScreen extends StatefulWidget {
  const LamaranListScreen({super.key});

  @override
  State<LamaranListScreen> createState() => _LamaranListScreenState();
}

class _LamaranListScreenState extends State<LamaranListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LamaranProvider>().fetchLamaranList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, String>> _stageFilters = [
    {'key': 'semua', 'label': 'Semua'},
    {'key': 'kirim_berkas', 'label': 'Kirim Berkas'},
    {'key': 'tes', 'label': 'Tes'},
    {'key': 'wawancara', 'label': 'Wawancara'},
    {'key': 'hasil', 'label': 'Hasil'},
  ];

  @override
  Widget build(BuildContext context) {
    final lamaranProvider = context.watch<LamaranProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Cari perusahaan atau posisi...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintStyle: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: (val) {
                  lamaranProvider.setSearchQuery(val);
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('JejakMagang'),
                  if (authProvider.currentUser != null)
                    Text(
                      'Halo, ${authProvider.currentUser!.nama}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                ],
              ),
        actions: [
          // Tombol Cari
          IconButton(
            tooltip: _isSearching ? 'Tutup Pencarian' : 'Cari Lamaran',
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  lamaranProvider.setSearchQuery('');
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          // Tombol Statistik
          IconButton(
            tooltip: 'Ringkasan Statistik',
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => context.push('/statistik'),
          ),
          // Tombol Mode Gelap/Terang
          IconButton(
            tooltip: themeProvider.isDarkMode ? 'Beralih ke Mode Terang' : 'Beralih ke Mode Gelap',
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          // Tombol Pengaturan
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => lamaranProvider.fetchLamaranList(),
        child: Column(
          children: [
            // Filter Baris Tahap Seleksi
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _stageFilters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _stageFilters[index];
                  final isSelected = lamaranProvider.filterTahap == filter['key'];

                  return ChoiceChip(
                    label: Text(filter['label']!),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF334155)),
                    ),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.primary
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        lamaranProvider.setFilterTahap(filter['key']!);
                      }
                    },
                  );
                },
              ),
            ),

            // Konten Daftar / Kondisi Memuat / Galat / Kosong
            Expanded(
              child: Builder(
                builder: (context) {
                  if (lamaranProvider.isLoading && lamaranProvider.lamaranList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (lamaranProvider.errorMessage != null && lamaranProvider.lamaranList.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.wifi_off_rounded,
                      title: 'Gagal Memuat Data',
                      message: lamaranProvider.errorMessage!,
                      buttonText: 'Coba Lagi',
                      onButtonPressed: () => lamaranProvider.fetchLamaranList(),
                    );
                  }

                  if (lamaranProvider.lamaranList.isEmpty) {
                    final isFilterActive = lamaranProvider.filterTahap != 'semua' ||
                        lamaranProvider.searchQuery.isNotEmpty;

                    return EmptyStateWidget(
                      icon: isFilterActive ? Icons.filter_alt_off_rounded : Icons.post_add_rounded,
                      title: isFilterActive ? 'Tidak Ada Hasil' : 'Belum Ada Lamaran',
                      message: isFilterActive
                          ? 'Tidak ditemukan lamaran dengan kriteria filter tersebut. Coba pilih filter lain.'
                          : 'Mulai perjalanan magang impian Anda dengan mencatat lamaran pertama!',
                      buttonText: isFilterActive ? 'Reset Filter' : 'Tambah Lamaran Baru',
                      onButtonPressed: () {
                        if (isFilterActive) {
                          _searchController.clear();
                          lamaranProvider.clearFilters();
                        } else {
                          context.push('/lamaran/create');
                        }
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: lamaranProvider.lamaranList.length,
                    itemBuilder: (context, index) {
                      final lamaran = lamaranProvider.lamaranList[index];
                      return ApplicationCard(
                        lamaran: lamaran,
                        onTap: () => context.push('/lamaran/${lamaran.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/lamaran/create'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Lamaran', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
