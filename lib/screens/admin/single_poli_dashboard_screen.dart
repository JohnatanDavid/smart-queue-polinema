import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/admin_model.dart';
import '../../models/loket_model.dart';
import '../../models/layanan_model.dart';
import '../../models/antrian_model.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../role_selection_screen.dart';
import 'display_screen.dart';

class SinglePoliDashboardScreen extends StatefulWidget {
  final AdminModel admin;
  final String selectedLoketId;

  const SinglePoliDashboardScreen({
    super.key, required this.admin, required this.selectedLoketId
  });

  @override
  State<SinglePoliDashboardScreen> createState() =>_SinglePoliDashboardScreenState();
}

class _SinglePoliDashboardScreenState extends State<SinglePoliDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard ${widget.admin.nama}'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tv),
            tooltip: 'Buka Display',
            onPressed: () {
              _showDisplayOptions(context);
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: Column(
        children: [
          // Header Info Admin
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.admin.nama.substring(0, 1),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.admin.nama,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Admin Poli',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // CONTENT UTAMA: Langsung panggil _PoliPanel
          Expanded(
            child: _PoliPanel(
              loketId: widget.selectedLoketId, // Gunakan ID yang dikirim dari halaman sebelumnya
              backgroundColor: Colors.white,
              accentColor: Colors.blue, // Bisa dibuat dinamis berdasarkan jenis poli jika mau
            ),
          ),
        ],
      ),
    );
  }

  void _showDisplayOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Display Poli',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text('A', style: TextStyle(color: Colors.white)),
              ),
              title: const Text('Display Poli Umum'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DisplayScreen(layananId: 'poli_umum'),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Text('B', style: TextStyle(color: Colors.white)),
              ),
              title: const Text('Display Poli Gigi'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DisplayScreen(layananId: 'poli_gigi'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await AuthService.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
        (route) => false,
      );
    }
  }
}

// Widget untuk setiap panel poli
class _PoliPanel extends StatelessWidget {
  final String loketId;
  final Color backgroundColor;
  final Color accentColor;

  const _PoliPanel({
    required this.loketId,
    required this.backgroundColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: StreamBuilder<LoketModel?>(
        stream: FirebaseService.getLoketByIdStream(loketId),
        builder: (context, loketSnapshot) {
          if (loketSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final loket = loketSnapshot.data;
          if (loket == null) {
            return const Center(child: Text('Loket tidak ditemukan'));
          }

          return StreamBuilder<LayananModel?>(
            stream: FirebaseService.getLayananStream().map((list) {
              return list.firstWhere(
                (l) => l.id == loket.layananId,
                orElse: () => list.first,
              );
            }),
            builder: (context, layananSnapshot) {
              final layanan = layananSnapshot.data;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Header Poli
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        border: Border(
                          bottom: BorderSide(color: accentColor, width: 3),
                        ),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: accentColor,
                            child: Text(
                              layanan?.kode ?? '?',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            layanan?.nama ?? 'Loading...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          Text(
                            loket.nama,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Statistik
                          if (layanan != null)
                            FutureBuilder<Map<String, int>>(
                              future: FirebaseService.getStatistikAntrian(
                                layanan.id,
                              ),
                              builder: (context, statsSnapshot) {
                                final stats =
                                    statsSnapshot.data ??
                                    {'total': 0, 'menunggu': 0, 'selesai': 0};

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _MiniStatItem(
                                        label: 'Total',
                                        value: stats['total']!,
                                        color: accentColor,
                                      ),
                                      _MiniStatItem(
                                        label: 'Menunggu',
                                        value: stats['menunggu']!,
                                        color: Colors.orange,
                                      ),
                                      _MiniStatItem(
                                        label: 'Selesai',
                                        value: stats['selesai']!,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                          const SizedBox(height: 16),

                          // Sedang Dilayani
                          if (layanan != null)
                            StreamBuilder<AntrianModel?>(
                              stream: FirebaseService.getAntrianDiLoketStream(
                                loket.id,
                                layanan.id,
                              ),
                              builder: (context, currentAntrianSnapshot) {
                                final currentAntrian =
                                    currentAntrianSnapshot.data;

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: currentAntrian != null
                                        ? Colors.green.shade50
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: currentAntrian != null
                                          ? Colors.green
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Sedang Dilayani',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        currentAntrian?.nomorAntrian ?? '-',
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: currentAntrian != null
                                              ? Colors.green.shade700
                                              : Colors.grey,
                                        ),
                                      ),
                                      if (currentAntrian != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          currentAntrian.namaPasien,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),

                          const SizedBox(height: 16),

                          // Tombol Aksi
                          if (layanan != null)
                            _ActionButtonsCompact(
                              loket: loket,
                              layanan: layanan,
                              accentColor: accentColor,
                            ),

                          const SizedBox(height: 16),

                          // Antrian Menunggu (Compact)
                          if (layanan != null)
                            _CompactQueueList(
                              layananId: layanan.id,
                              accentColor: accentColor,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MiniStatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MiniStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _ActionButtonsCompact extends StatefulWidget {
  final LoketModel loket;
  final LayananModel layanan;
  final Color accentColor;

  const _ActionButtonsCompact({
    required this.loket,
    required this.layanan,
    required this.accentColor,
  });

  @override
  State<_ActionButtonsCompact> createState() => _ActionButtonsCompactState();
}

class _ActionButtonsCompactState extends State<_ActionButtonsCompact> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("id-ID"); // Bahasa Indonesia
    await flutterTts.setSpeechRate(0.85); // Kecepatan bicara lebih natural
    await flutterTts.setVolume(1.0); // Volume maksimal
    await flutterTts.setPitch(1.0); // Nada suara normal
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AntrianModel?>(
      stream: FirebaseService.getAntrianDiLoketStream(
        widget.loket.id,
        widget.layanan.id,
      ),
      builder: (context, snapshot) {
        final currentAntrian = snapshot.data;
        final hasCurrentAntrian = currentAntrian != null;

        return Column(
          children: [
            // Panggil Berikutnya
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasCurrentAntrian
                    ? null
                    : () => _panggilBerikutnya(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      color: hasCurrentAntrian ? Colors.grey : Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Panggil Berikutnya',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: hasCurrentAntrian ? Colors.grey : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (hasCurrentAntrian) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _panggilUlang(context, currentAntrian),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Ulang',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selesai(context, currentAntrian),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _panggilBerikutnya(BuildContext context) async {
    try {
      final antrianList = await FirebaseService.getAntrianMenungguStream(
        widget.layanan.id,
      ).first;

      if (antrianList.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada antrian menunggu'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final nextAntrian = antrianList.first;

      await FirebaseService.updateStatusAntrian(
        nomorAntrian: nextAntrian.nomorAntrian,
        layananId: widget.layanan.id,
        status: StatusAntrian.dipanggil,
        loketId: widget.loket.id,
      );

      await FirebaseService.updateLoketAntrian(
        widget.loket.id,
        nextAntrian.nomorAntrian,
      );

      // Panggil dengan suara
      String announcement =
          "Nomor antrian ${nextAntrian.nomorAntrian}, "
          "atas nama ${nextAntrian.namaPasien}, "
          "silakan menuju ${widget.layanan.nama}";

      await _speak(announcement);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Memanggil ${nextAntrian.nomorAntrian}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _panggilUlang(BuildContext context, AntrianModel antrian) async {
    // Panggil ulang dengan suara
    String announcement =
        "Nomor antrian ${antrian.nomorAntrian}, "
        "atas nama ${antrian.namaPasien}, "
        "silakan menuju ${widget.layanan.nama}";

    await _speak(announcement);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Memanggil ulang ${antrian.nomorAntrian}'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _selesai(BuildContext context, AntrianModel antrian) async {
    try {
      await FirebaseService.updateStatusAntrian(
        nomorAntrian: antrian.nomorAntrian,
        layananId: widget.layanan.id,
        status: StatusAntrian.selesai,
      );

      await FirebaseService.updateLoketAntrian(widget.loket.id, null);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Antrian selesai dilayani'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _CompactQueueList extends StatelessWidget {
  final String layananId;
  final Color accentColor;

  const _CompactQueueList({required this.layananId, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AntrianModel>>(
      stream: FirebaseService.getAntrianByLayananStream(layananId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final antrianList = snapshot.data ?? [];
        final menunggu = antrianList
            .where((a) => a.status == StatusAntrian.menunggu)
            .toList();

        if (menunggu.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Tidak ada antrian',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Antrian Menunggu (${menunggu.length})',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...menunggu
                .take(5)
                .map(
                  (antrian) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: accentColor.withOpacity(0.2),
                          child: Text(
                            antrian.nomorUrut.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                antrian.nomorAntrian,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                antrian.namaPasien,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Helpers.formatTime(
                            DateTime.fromMillisecondsSinceEpoch(
                              antrian.waktuAmbil,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}
