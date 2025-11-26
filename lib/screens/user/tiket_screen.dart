import 'package:flutter/material.dart';
import '../../models/antrian_model.dart';
import '../../models/layanan_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../role_selection_screen.dart';

class TiketScreen extends StatelessWidget {
  final AntrianModel antrian;
  final LayananModel layanan;

  const TiketScreen({
    super.key,
    required this.antrian,
    required this.layanan,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Confirm before going back
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Keluar'),
            content: const Text('Yakin ingin keluar? Nomor antrian Anda akan tetap aktif.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Keluar'),
              ),
            ],
          ),
        );
        return result ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.blue.shade700,
        appBar: AppBar(
          title: const Text('Nomor Antrian Anda'),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
          ),
        ),
        body: StreamBuilder<AntrianModel?>(
          stream: FirebaseService.getAntrianByNomorStream(
            antrian.nomorAntrian,
            layanan.id,
          ),
          builder: (context, snapshot) {
            final currentAntrian = snapshot.data ?? antrian;

            return StreamBuilder<List<AntrianModel>>(
              stream: FirebaseService.getAntrianByLayananStream(layanan.id),
              builder: (context, allAntrianSnapshot) {
                final allAntrian = allAntrianSnapshot.data ?? [];
                
                // Hitung sisa antrian
                final sisaAntrian = allAntrian.where((a) {
                  return a.nomorUrut < currentAntrian.nomorUrut &&
                      a.status == StatusAntrian.menunggu;
                }).length;

                // Estimasi waktu tunggu
                final estimasiMenit = Helpers.hitungEstimasiWaktu(
                  sisaAntrian,
                  layanan.estimasiPerPasien,
                );

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Info Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.local_hospital,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Poliklinik POLINEMA',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                layanan.nama,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Main Ticket Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(currentAntrian.status),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getStatusText(currentAntrian.status),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Nomor Antrian (BIG)
                              const Text(
                                'Nomor Antrian',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentAntrian.nomorAntrian,
                                style: AppTextStyles.nomorAntrian,
                              ),

                              const SizedBox(height: 30),

                              // Divider
                              Divider(color: Colors.grey.shade300),

                              const SizedBox(height: 20),

                              // Info Grid
                              Row(
                                children: [
                                  Expanded(
                                    child: _InfoItem(
                                      icon: Icons.people_outline,
                                      label: 'Sisa Antrian',
                                      value: sisaAntrian.toString(),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 50,
                                    color: Colors.grey.shade300,
                                  ),
                                  Expanded(
                                    child: _InfoItem(
                                      icon: Icons.tag,
                                      label: 'Peserta Dilayani',
                                      value: _getCurrentServing(allAntrian),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Estimasi Waktu
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.blue.shade700,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Estimasi Waktu Tunggu',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            Helpers.formatEstimasiWaktu(estimasiMenit),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Detail Info
                              _DetailRow(
                                label: 'Nama Pasien',
                                value: currentAntrian.namaPasien,
                              ),
                              _DetailRow(
                                label: 'Poli',
                                value: layanan.nama,
                              ),
                              _DetailRow(
                                label: 'Tanggal Kunjungan',
                                value: Helpers.formatDateForDisplay(
                                  DateTime.fromMillisecondsSinceEpoch(currentAntrian.waktuAmbil),
                                ),
                              ),
                              _DetailRow(
                                label: 'Waktu Pengambilan',
                                value: Helpers.formatTime(
                                  DateTime.fromMillisecondsSinceEpoch(currentAntrian.waktuAmbil),
                                ),
                              ),
                              _DetailRow(
                                label: 'Jam Operasional',
                                value: '${layanan.jamBuka} - ${layanan.jamTutup}',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Cancel Button
                        if (currentAntrian.status == StatusAntrian.menunggu)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _showCancelDialog(context, currentAntrian),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Batalkan Antrian',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case StatusAntrian.menunggu:
        return Colors.orange;
      case StatusAntrian.dipanggil:
        return Colors.green;
      case StatusAntrian.selesai:
        return Colors.blue;
      case StatusAntrian.batal:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case StatusAntrian.menunggu:
        return 'MENUNGGU';
      case StatusAntrian.dipanggil:
        return 'SEDANG DIPANGGIL';
      case StatusAntrian.selesai:
        return 'SELESAI';
      case StatusAntrian.batal:
        return 'DIBATALKAN';
      default:
        return status.toUpperCase();
    }
  }

  String _getCurrentServing(List<AntrianModel> allAntrian) {
    final serving = allAntrian.where((a) => a.status == StatusAntrian.dipanggil).toList();
    if (serving.isEmpty) return '-';
    return serving.first.nomorAntrian;
  }

  void _showCancelDialog(BuildContext context, AntrianModel antrian) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Antrian'),
        content: const Text('Yakin ingin membatalkan antrian Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              FirebaseService.updateStatusAntrian(
                nomorAntrian: antrian.nomorAntrian,
                layananId: layanan.id,
                status: StatusAntrian.batal,
              );
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}