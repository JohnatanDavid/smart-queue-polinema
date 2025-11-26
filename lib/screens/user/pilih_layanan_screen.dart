import 'package:flutter/material.dart';
import '../../models/layanan_model.dart';
import '../../models/antrian_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import 'tiket_screen.dart';

class PilihLayananScreen extends StatelessWidget {
  const PilihLayananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Layanan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<LayananModel>>(
        stream: FirebaseService.getLayananStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            );
          }

          final layananList = snapshot.data ?? [];

          if (layananList.isEmpty) {
            return const Center(
              child: Text('Tidak ada layanan tersedia'),
            );
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade50,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header Info
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.local_hospital,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Poliklinik POLINEMA',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pilih layanan yang Anda butuhkan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Layanan Cards
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: layananList.length,
                      itemBuilder: (context, index) {
                        final layanan = layananList[index];
                        final isOpen = Helpers.isJamOperasional(
                          layanan.jamBuka,
                          layanan.jamTutup,
                        );

                        return _LayananCard(
                          layanan: layanan,
                          isOpen: isOpen,
                          onTap: () => _showInputNamaDialog(context, layanan, isOpen),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showInputNamaDialog(
    BuildContext context,
    LayananModel layanan,
    bool isOpen,
  ) {
    if (!isOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${layanan.nama} tutup. Jam buka: ${layanan.jamBuka} - ${layanan.jamTutup}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Input Nama Pasien'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan nama Anda untuk mengambil nomor antrian di ${layanan.nama}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Contoh: Budi Santoso',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (value.trim().length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext);
                _handleAmbilNomor(context, layanan, nameController.text.trim());
              }
            },
            child: const Text('Ambil Nomor'),
          ),
        ],
      ),
    );
  }

  void _handleAmbilNomor(
    BuildContext context,
    LayananModel layanan,
    String namaPasien,
  ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Cek apakah user sudah punya antrian aktif
      final existingAntrian = await FirebaseService.cekAntrianAktif(
        layananId: layanan.id,
        namaPasien: namaPasien,
      );

      if (existingAntrian != null && context.mounted) {
        // User sudah punya antrian aktif
        Navigator.pop(context); // Close loading
        
        // Show dialog info
        final shouldView = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Antrian Sudah Ada'),
            content: Text(
              'Anda sudah memiliki antrian aktif dengan nomor ${existingAntrian.nomorAntrian}.\n\nSilakan tunggu antrian Anda dipanggil.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tutup'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Lihat Tiket'),
              ),
            ],
          ),
        );

        if (shouldView == true && context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TiketScreen(
                antrian: existingAntrian,
                layanan: layanan,
              ),
            ),
          );
        }
        return;
      }

      // Ambil nomor antrian baru
      final antrian = await FirebaseService.ambilNomorAntrian(
        layananId: layanan.id,
        namaPasien: namaPasien,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading

        // Navigate to ticket screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TiketScreen(
              antrian: antrian,
              layanan: layanan,
            ),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil nomor: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _LayananCard extends StatelessWidget {
  final LayananModel layanan;
  final bool isOpen;
  final VoidCallback onTap;

  const _LayananCard({
    required this.layanan,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.blue.shade50 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      layanan.kode,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isOpen ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        layanan.nama,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${layanan.jamBuka} - ${layanan.jamTutup}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '~${layanan.estimasiPerPasien} menit/pasien',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOpen ? 'BUKA' : 'TUTUP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isOpen ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}