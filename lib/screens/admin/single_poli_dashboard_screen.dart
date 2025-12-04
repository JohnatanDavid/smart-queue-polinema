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
    super.key,
    required this.admin,
    required this.selectedLoketId,
  });

  @override
  State<SinglePoliDashboardScreen> createState() =>
      _SinglePoliDashboardScreenState();
}

class _SinglePoliDashboardScreenState extends State<SinglePoliDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.blue.withOpacity(0.4),
        centerTitle: true,
        toolbarHeight: 75,

        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.dashboard_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),

            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'Kelola antrian',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          // Tombol Display
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.tv_rounded, size: 22, color: Colors.white),
              tooltip: 'Buka Display',
              onPressed: () => _showDisplayOptions(context),
            ),
          ),

          // Tombol Logout
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                size: 22,
                color: Colors.white,
              ),
              tooltip: 'Logout',
              onPressed: _handleLogout,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // Header Info Admin dengan desain card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade50,
                    child: Text(
                      widget.admin.nama.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.admin.nama,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Admin Poli',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // CONTENT UTAMA
          Expanded(
            child: _PoliPanel(
              loketId: widget.selectedLoketId,
              backgroundColor: Colors.transparent,
              accentColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  void _showDisplayOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih Display Poli',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildDisplayOption(
              context,
              label: 'Display Poli Umum',
              icon: Icons.medical_services,
              color: Colors.blue,
              layananId: 'poli_umum',
            ),
            const SizedBox(height: 12),
            _buildDisplayOption(
              context,
              label: 'Display Poli Gigi',
              icon: Icons.health_and_safety,
              color: Colors.green,
              layananId: 'poli_gigi',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required String layananId,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DisplayScreen(layananId: layananId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red.shade700),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text('Yakin ingin keluar dari dashboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
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
            return Center(child: CircularProgressIndicator(color: accentColor));
          }

          final loket = loketSnapshot.data;
          if (loket == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loket tidak ditemukan',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
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
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    // Header Poli dengan desain modern
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withOpacity(0.1),
                            accentColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: accentColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              layanan?.kode ?? '?',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  layanan?.nama ?? 'Loading...',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      loket.nama,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Statistik dengan kartu modern
                          if (layanan != null)
                            FutureBuilder<Map<String, int>>(
                              future: FirebaseService.getStatistikAntrian(
                                layanan.id,
                              ),
                              builder: (context, statsSnapshot) {
                                final stats =
                                    statsSnapshot.data ??
                                    {'total': 0, 'menunggu': 0, 'selesai': 0};

                                return Row(
                                  children: [
                                    Expanded(
                                      child: _ModernStatCard(
                                        label: 'Total',
                                        value: stats['total']!,
                                        icon: Icons.people_outline,
                                        color: accentColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ModernStatCard(
                                        label: 'Menunggu',
                                        value: stats['menunggu']!,
                                        icon: Icons.hourglass_empty,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ModernStatCard(
                                        label: 'Selesai',
                                        value: stats['selesai']!,
                                        icon: Icons.check_circle_outline,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                          const SizedBox(height: 16),

                          // Sedang Dilayani dengan desain modern
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
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: currentAntrian != null
                                          ? [
                                              Colors.green.shade50,
                                              Colors.green.shade100,
                                            ]
                                          : [
                                              Colors.grey.shade50,
                                              Colors.grey.shade100,
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: currentAntrian != null
                                          ? Colors.green.shade300
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (currentAntrian != null
                                                    ? Colors.green
                                                    : Colors.grey)
                                                .withOpacity(0.1),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            currentAntrian != null
                                                ? Icons.medical_services
                                                : Icons.event_seat,
                                            size: 20,
                                            color: currentAntrian != null
                                                ? Colors.green.shade700
                                                : Colors.grey.shade500,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Sedang Dilayani',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: currentAntrian != null
                                                  ? Colors.green.shade700
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          currentAntrian?.nomorAntrian ?? '-',
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: currentAntrian != null
                                                ? Colors.green.shade700
                                                : Colors.grey.shade400,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                      if (currentAntrian != null) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.person,
                                                size: 16,
                                                color: Colors.green.shade700,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                currentAntrian.namaPasien,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                            ],
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

                          // Antrian Menunggu
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

class _ModernStatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _ModernStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  // Ganti bagian _ActionButtonsCompact Widget build method
  // Tombol akan selalu aktif/tidak blur

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
            // Tombol Panggil Berikutnya - SELALU AKTIF
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.accentColor, widget.accentColor],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _panggilBerikutnya(context), // SELALU AKTIF
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.skip_next, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Panggil Berikutnya',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (hasCurrentAntrian) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  // Tombol Panggil Ulang
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.accentColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () => _panggilUlang(context, currentAntrian),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.replay,
                              color: widget.accentColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Panggil Lagi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: widget.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol Selesai
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade600,
                            Colors.green.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _selesai(context, currentAntrian),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Selesai',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
