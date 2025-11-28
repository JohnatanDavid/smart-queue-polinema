import 'package:flutter/material.dart';
import '../../models/layanan_model.dart';
import '../../models/antrian_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class DisplayScreen extends StatelessWidget {
  final String layananId;
  
  const DisplayScreen({
    super.key,
    required this.layananId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<LayananModel?>(
        stream: FirebaseService.getLayananStream().map((list) {
          return list.firstWhere(
            (l) => l.id == layananId,
            orElse: () => list.first,
          );
        }),
        builder: (context, layananSnapshot) {
          final layanan = layananSnapshot.data;
          
          return StreamBuilder<List<AntrianModel>>(
            stream: FirebaseService.getAntrianByLayananStream(layananId),
            builder: (context, antrianSnapshot) {
              final allAntrian = antrianSnapshot.data ?? [];
              
              // Antrian yang sedang dilayani
              final sedangDilayani = allAntrian
                  .where((a) => a.status == StatusAntrian.dipanggil)
                  .toList();
              
              // Antrian menunggu
              final menunggu = allAntrian
                  .where((a) => a.status == StatusAntrian.menunggu)
                  .toList();
              
              final currentAntrian = sedangDilayani.isNotEmpty ? sedangDilayani.first : null;
              final nextAntrian = menunggu.isNotEmpty ? menunggu.first : null;
              
              return Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.blue.shade500],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.local_hospital,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'POLIKLINIK POLINEMA',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            layanan?.nama ?? 'Loading...',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          // Sedang Dilayani
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: currentAntrian != null
                                    ? Colors.green.shade50
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: currentAntrian != null
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                  width: 4,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'SEDANG DILAYANI',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    currentAntrian?.nomorAntrian ?? '-',
                                    style: TextStyle(
                                      fontSize: 180,
                                      fontWeight: FontWeight.bold,
                                      color: currentAntrian != null
                                          ? Colors.green.shade700
                                          : Colors.grey,
                                      height: 1,
                                    ),
                                  ),
                                  if (currentAntrian != null) ...[
                                    const SizedBox(height: 16),
                                    Text(
                                      currentAntrian.namaPasien,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Persiapan & Total
                          Row(
                            children: [
                              // Persiapan
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.orange,
                                      width: 3,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'PERSIAPAN',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        nextAntrian?.nomorAntrian ?? '-',
                                        style: TextStyle(
                                          fontSize: 72,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 24),
                              
                              // Total Antrian
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 3,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'TOTAL ANTRIAN',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        allAntrian.length.toString(),
                                        style: TextStyle(
                                          fontSize: 72,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.shade200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Menunggu: ${menunggu.length}',
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          Helpers.formatTime(DateTime.now()),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}