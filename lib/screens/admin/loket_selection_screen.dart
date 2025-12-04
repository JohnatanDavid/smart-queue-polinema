import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../models/admin_model.dart';
import '../../models/loket_model.dart';
import '../../models/layanan_model.dart';
import '../../services/firebase_service.dart';
import 'single_poli_dashboard_screen.dart';

class LoketSelectionScreen extends StatefulWidget {
  final AdminModel admin;

  const LoketSelectionScreen({super.key, required this.admin});

  @override
  State<LoketSelectionScreen> createState() => _LoketSelectionScreenState();
}

class _LoketSelectionScreenState extends State<LoketSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late PageController _quotePageController;
  int _currentQuoteIndex = 0;

  final List<String> _quotes = [
    "Senyum adalah pelayanan terbaik yang bisa kita berikan",
    "Kesabaran adalah kunci untuk memberikan layanan yang berkualitas",
    "Setiap pasien adalah prioritas, layani dengan sepenuh hati",
    "Keramahan Anda adalah obat pertama bagi pasien",
    "Pelayanan terbaik dimulai dari sikap positif kita",
    "Jadilah cahaya harapan bagi setiap pasien yang datang",
    "Empati adalah jembatan menuju pelayanan yang luar biasa",
    "Profesionalisme dimulai dari hal-hal kecil yang kita lakukan",
    "Setiap interaksi adalah kesempatan untuk membuat perbedaan",
    "Kepedulian Anda hari ini adalah kenangan pasien selamanya",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Initialize PageController untuk quote carousel
    _quotePageController = PageController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _quotePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade700, Colors.blue.shade500],
                  ),
                ),
                child: Stack(
                  children: [
                    // Animated Background Circles
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      top: 100,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    // Content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Hero(
                                  tag: 'admin_avatar',
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 32,
                                      backgroundColor: Colors.white,
                                      child: Text(
                                        widget.admin.nama[0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Selamat Datang,',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.admin.nama,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card - White Design
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 0, 179, 255),
                                  Color.fromARGB(255, 13, 109, 192),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pilih Loket 🏷️',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade900,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pilih loket tempat Anda bertugas hari ini',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section Title
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Loket Tersedia',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Loket Grid
                    StreamBuilder<List<LoketModel>>(
                      stream: FirebaseService.getLoketStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            height: 400,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 3,
                                      ),
                                    ),
                                    child: const SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Memuat loket...',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            height: 400,
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.computer_outlined,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Tidak ada loket tersedia',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Hubungi administrator untuk informasi lebih lanjut',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final lokets = snapshot.data!;

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: lokets.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _LoketCard(
                              loket: lokets[index],
                              admin: widget.admin,
                              index: index,
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // 💬 Motivational Quote Card dengan Manual Swipe
                    Container(
                      width: double.infinity,
                      height: 140, // 👈 Dikecilkan dari 180
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue.shade600, Colors.blue.shade400],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(
                              16,
                            ), // 👈 Dikecilkan dari 20
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(
                                    10,
                                  ), // 👈 Dikecilkan dari 12
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.format_quote_rounded,
                                    color: Colors.white,
                                    size: 22, // 👈 Dikecilkan dari 28
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ), // 👈 Dikecilkan dari 12
                                const Text(
                                  'Quote Hari Ini',
                                  style: TextStyle(
                                    fontSize: 14, // 👈 Dikecilkan dari 16
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.swipe_rounded,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 18, // 👈 Dikecilkan dari 20
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: PageView.builder(
                              controller: _quotePageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentQuoteIndex = index;
                                });
                              },
                              itemCount: _quotes.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _quotes[index],
                                      style: const TextStyle(
                                        fontSize: 13, // 👈 Dikecilkan dari 15
                                        color: Colors.white,
                                        height: 1.5, // 👈 Dikecilkan dari 1.6
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3, // 👈 Batasi jumlah baris
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Indicator dots
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 12,
                            ), // 👈 Dikecilkan dari 16
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _quotes.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3, // 👈 Dikecilkan dari 4
                                  ),
                                  width: _currentQuoteIndex == index
                                      ? 20
                                      : 6, // 👈 Dikecilkan dari 24:8
                                  height: 6, // 👈 Dikecilkan dari 8
                                  decoration: BoxDecoration(
                                    color: _currentQuoteIndex == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section Title untuk Card Lottie
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Semangat Hari Ini 🚀',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.emoji_emotions_rounded,
                          color: Colors.amber.shade600,
                          size: 26,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 🔥 CARD Pembungkus Lottie + Selamat Bekerja
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 250,
                            child: Lottie.network(
                              'https://lottie.host/b2f5646d-70f8-4f67-b7e7-ce23296229c8/zReykplI5p.json',
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'Selamat bekerja 👋',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Semoga tugas Anda hari ini berjalan lancar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 14),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoketCard extends StatefulWidget {
  final LoketModel loket;
  final AdminModel admin;
  final int index;

  const _LoketCard({
    required this.loket,
    required this.admin,
    required this.index,
  });

  @override
  State<_LoketCard> createState() => _LoketCardState();
}

class _LoketCardState extends State<_LoketCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  String _getBackgroundImage(String nama) {
    nama = nama.toLowerCase();
    if (nama.contains('gigi')) return 'assets/images/Loket2.png';
    if (nama.contains('umum')) return 'assets/images/Loket1.png';
    return 'assets/bg_default.jpg';
  }

  IconData _getIconByLayanan(String namaLayanan) {
    final nama = namaLayanan.toLowerCase();
    if (nama.contains('gigi')) return Icons.medical_services;
    if (nama.contains('umum')) return Icons.local_hospital;
    if (nama.contains('anak')) return Icons.child_care;
    if (nama.contains('mata')) return Icons.visibility;
    if (nama.contains('jantung')) return Icons.favorite;
    return Icons.local_hospital_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LayananModel>>(
      stream: FirebaseService.getLayananStream(),
      builder: (context, snapshot) {
        String namaLayanan = 'Memuat...';
        IconData iconLayanan = Icons.computer;

        if (snapshot.hasData) {
          final layanan = snapshot.data!.firstWhere(
            (l) => l.id == widget.loket.layananId,
            orElse: () => LayananModel(
              id: 'unknown',
              nama: 'Layanan Tidak Dikenal',
              kode: '?',
              jamBuka: '00:00',
              jamTutup: '00:00',
              estimasiPerPasien: 0,
              aktif: false,
            ),
          );
          namaLayanan = layanan.nama;
          iconLayanan = _getIconByLayanan(namaLayanan);
        }

        return Row(
          children: [
            // 👈 BAGIAN KIRI - Informasi Tambahan
            Expanded(
              flex: 2,
              child: Container(
                height: 280,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nomor Loket
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Loket ${widget.index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nama Layanan
                    Text(
                      namaLayanan,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Info Status - Dinamis berdasarkan widget.loket.status
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: widget.loket.status == 'aktif'
                                ? Colors.green.shade400
                                : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.loket.status == 'aktif'
                              ? 'Aktif'
                              : 'Tidak Aktif',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Divider
                    Divider(color: Colors.grey.shade200),
                    const SizedBox(height: 12),

                    // Info Tambahan
                    _buildInfoRow(
                      Icons.access_time_rounded,
                      'Buka',
                      '08:00 - 16:00',
                    ),
                    const SizedBox(height: 8),

                    // Info Pasien - Dinamis dari widget.loket.antrianSaatIni
                    _buildInfoRow(
                      Icons.people_outline_rounded,
                      'Pasien',
                      widget.loket.antrianSaatIni != null
                          ? 'No. ${widget.loket.antrianSaatIni}'
                          : 'Tidak ada antrian',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // 👉 BAGIAN KANAN - Card Loket (Ukuran sama seperti asli)
            Expanded(
              flex: 3,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onTapDown: (_) {
                    setState(() => _isPressed = true);
                    _scaleController.forward();
                  },
                  onTapUp: (_) {
                    setState(() => _isPressed = false);
                    _scaleController.reverse();
                  },
                  onTapCancel: () {
                    setState(() => _isPressed = false);
                    _scaleController.reverse();
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SinglePoliDashboardScreen(
                              admin: widget.admin,
                              selectedLoketId: widget.loket.id,
                            ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                  child: Container(
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: _isPressed ? 8 : 16,
                          offset: _isPressed
                              ? const Offset(0, 2)
                              : const Offset(0, 8),
                          spreadRadius: _isPressed ? 0 : 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_getBackgroundImage(namaLayanan)),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.15),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Background pattern
                            Positioned(
                              right: -40,
                              top: -40,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),
                            Positioned(
                              left: -20,
                              bottom: -20,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                            ),

                            // Status Badge - Dinamis berdasarkan widget.loket.status
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.loket.status == 'aktif'
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: widget.loket.status == 'aktif'
                                            ? Colors.white
                                            : Colors.grey.shade400,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.loket.status == 'aktif'
                                          ? 'Aktif'
                                          : 'Nonaktif',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Spacer(),

                                  // Icon with Glow Effect
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      iconLayanan,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Loket Number
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.0),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      widget.loket.nama,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Layanan Name
                                  Text(
                                    namaLayanan,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const Spacer(),

                                  // Action Button
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Pilih Loket',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method untuk info row
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
