import 'package:flutter/material.dart';
import '../../models/admin_model.dart';
import '../../models/loket_model.dart';
import '../../models/layanan_model.dart';
import '../../models/antrian_model.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../role_selection_screen.dart';

class DashboardScreen extends StatefulWidget {
  final AdminModel admin;
  
  const DashboardScreen({
    super.key,
    required this.admin,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: StreamBuilder<LoketModel?>(
        stream: FirebaseService.getLoketByIdStream(widget.admin.loketId),
        builder: (context, loketSnapshot) {
          if (loketSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final loket = loketSnapshot.data;
          if (loket == null) {
            return const Center(
              child: Text('Loket tidak ditemukan'),
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
              
              return Column(
                children: [
                  // Header Card
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                    Text(
                                      loket.nama,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  layanan?.nama ?? 'Loading...',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Stats Card
                  if (layanan != null)
                    FutureBuilder<Map<String, int>>(
                      future: FirebaseService.getStatistikAntrian(layanan.id),
                      builder: (context, statsSnapshot) {
                        final stats = statsSnapshot.data ?? {
                          'total': 0,
                          'menunggu': 0,
                          'dipanggil': 0,
                          'selesai': 0,
                        };

                        return Container(
                          margin: const EdgeInsets.all(16),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Statistik Hari Ini',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _StatItem(
                                    label: 'Total',
                                    value: stats['total']!,
                                    color: Colors.blue,
                                    icon: Icons.people,
                                  ),
                                  _StatItem(
                                    label: 'Menunggu',
                                    value: stats['menunggu']!,
                                    color: Colors.orange,
                                    icon: Icons.hourglass_empty,
                                  ),
                                  _StatItem(
                                    label: 'Selesai',
                                    value: stats['selesai']!,
                                    color: Colors.green,
                                    icon: Icons.check_circle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  // Current Queue Card
                  if (layanan != null)
                    StreamBuilder<AntrianModel?>(
                      stream: FirebaseService.getAntrianDiLoketStream(
                        loket.id,
                        layanan.id,
                      ),
                      builder: (context, currentAntrianSnapshot) {
                        final currentAntrian = currentAntrianSnapshot.data;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(20),
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
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentAntrian?.nomorAntrian ?? '-',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: currentAntrian != null
                                      ? Colors.green.shade700
                                      : Colors.grey,
                                ),
                              ),
                              if (currentAntrian != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  currentAntrian.namaPasien,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  if (layanan != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _ActionButtons(
                        loket: loket,
                        layanan: layanan,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Queue List
                  if (layanan != null)
                    Expanded(
                      child: _QueueList(layananId: layanan.id),
                    ),
                ],
              );
            },
          );
        },
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

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final LoketModel loket;
  final LayananModel layanan;

  const _ActionButtons({
    required this.loket,
    required this.layanan,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AntrianModel?>(
      stream: FirebaseService.getAntrianDiLoketStream(loket.id, layanan.id),
      builder: (context, snapshot) {
        final currentAntrian = snapshot.data;
        final hasCurrentAntrian = currentAntrian != null;

        return Column(
          children: [
            // Panggil Berikutnya Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: hasCurrentAntrian ? null : () => _panggilBerikutnya(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      color: hasCurrentAntrian ? Colors.grey : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Panggil Berikutnya',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: hasCurrentAntrian ? Colors.grey : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Action Buttons Row
            if (hasCurrentAntrian)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _panggilUlang(context, currentAntrian),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Panggil Ulang'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selesai(context, currentAntrian),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Future<void> _panggilBerikutnya(BuildContext context) async {
    try {
      // Get next queue
      final antrianList = await FirebaseService.getAntrianMenungguStream(layanan.id).first;
      
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

      // Update status to dipanggil
      await FirebaseService.updateStatusAntrian(
        nomorAntrian: nextAntrian.nomorAntrian,
        layananId: layanan.id,
        status: StatusAntrian.dipanggil,
        loketId: loket.id,
      );

      // Update loket
      await FirebaseService.updateLoketAntrian(loket.id, nextAntrian.nomorAntrian);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Memanggil ${nextAntrian.nomorAntrian}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _panggilUlang(BuildContext context, AntrianModel antrian) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Memanggil ulang ${antrian.nomorAntrian}'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _selesai(BuildContext context, AntrianModel antrian) async {
    try {
      // Update status to selesai
      await FirebaseService.updateStatusAntrian(
        nomorAntrian: antrian.nomorAntrian,
        layananId: layanan.id,
        status: StatusAntrian.selesai,
      );

      // Clear loket
      await FirebaseService.updateLoketAntrian(loket.id, null);

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
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _QueueList extends StatelessWidget {
  final String layananId;

  const _QueueList({required this.layananId});

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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada antrian menunggu',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Antrian Menunggu (${menunggu.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: menunggu.length,
                itemBuilder: (context, index) {
                  final antrian = menunggu[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.shade100,
                        child: Text(
                          antrian.nomorUrut.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                      title: Text(
                        antrian.nomorAntrian,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(antrian.namaPasien),
                      trailing: Text(
                        Helpers.formatTime(
                          DateTime.fromMillisecondsSinceEpoch(antrian.waktuAmbil),
                        ),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}