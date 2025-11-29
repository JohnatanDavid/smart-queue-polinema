import 'package:flutter/material.dart';
import '../../models/admin_model.dart';
import '../../models/loket_model.dart';
import '../../models/layanan_model.dart';
import '../../services/firebase_service.dart';
import 'single_poli_dashboard_screen.dart'; // File dashboard yang baru (lihat poin 2)

class LoketSelectionScreen extends StatelessWidget {
  final AdminModel admin;

  const LoketSelectionScreen({super.key, required this.admin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Loket Bertugas'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${admin.nama}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text('Silakan pilih loket tempat Anda bertugas hari ini:'),
            const SizedBox(height: 20),
            
            // List Loket dari Firebase
            Expanded(
              child: StreamBuilder<List<LoketModel>>(
                stream: FirebaseService.getLoketStream(), // Pastikan method ini ada di service Anda
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Tidak ada loket tersedia"));
                  }

                  final lokets = snapshot.data!;

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 kotak per baris
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: lokets.length,
                    itemBuilder: (context, index) {
                      final loket = lokets[index];
                      return _LoketCard(
                        loket: loket,
                        admin: admin,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoketCard extends StatelessWidget {
  final LoketModel loket;
  final AdminModel admin;

  const _LoketCard({required this.loket, required this.admin});

  @override
  Widget build(BuildContext context) {
    // Kita ambil info layanan untuk menampilkan nama poli (misal: "Poli Umum")
    return StreamBuilder<List<LayananModel>>(
      stream: FirebaseService.getLayananStream(),
      builder: (context, snapshot) {
        String namaLayanan = 'Memuat...';
        Color warnaKartu = Colors.blue.shade100;
        
        if (snapshot.hasData) {
          final layanan = snapshot.data!.firstWhere(
            (l) => l.id == loket.layananId,
            // PERBAIKAN DI SINI:
            orElse: () => LayananModel(
              id: 'unknown',
              nama: 'Layanan Tidak Dikenal',
              kode: '?',
              jamBuka: '00:00',      // Wajib diisi (required)
              jamTutup: '00:00',     // Wajib diisi (required)
              estimasiPerPasien: 0,  // Wajib diisi (required)
              aktif: false,          // Wajib diisi (required)
            ),
          );
          namaLayanan = layanan.nama;
          // Logika sederhana untuk warna pembeda
          if (layanan.nama.toLowerCase().contains('gigi')) {
             warnaKartu = Colors.green.shade100;
          }
        }

        return Card(
          color: warnaKartu,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              // NAVIGASI KE DASHBOARD TUNGGAL
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SinglePoliDashboardScreen(
                    admin: admin,
                    selectedLoketId: loket.id, // KITA KIRIM ID LOKET YANG DIPILIH
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.computer, size: 40, color: Colors.black54),
                  const SizedBox(height: 10),
                  Text(
                    loket.nama, // Misal: "Loket 1"
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    namaLayanan, // Misal: "Poli Umum"
                    style: TextStyle(color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}