import 'package:flutter/material.dart';
import '../utils/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/slide1.png",
      "title": "Temukan Vendor Terbaik",
      "text": "Pilih dari ribuan vendor terpercaya untuk mewujudkan pernikahan impian Anda."
    },
    {
      "image": "assets/slide2.png",
      "title": "Pesan dengan Mudah",
      "text": "Bandingkan harga, lihat portofolio, dan langsung pesan dalam satu aplikasi."
    },
    {
      "image": "assets/slide3.png",
      "title": "Pantau Jadwal Acara",
      "text": "Atur semua kebutuhan dan pantau status pesanan tanpa perlu pusing."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) => _buildPageContent(
                  image: onboardingData[index]["image"]!,
                  title: onboardingData[index]["title"]!,
                  text: onboardingData[index]["text"]!,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingData.length,
                        (index) => _buildDot(index: index),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        if (_currentPage == onboardingData.length - 1) {
                          // Jika di halaman terakhir, masuk ke Login
                          Navigator.pushReplacementNamed(context, '/login');
                        } else {
                          // Geser ke halaman berikutnya
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                        }
                      },
                      child: Text(
                        _currentPage == onboardingData.length - 1 ? 'Mulai Sekarang' : 'Lanjut',
                        style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent({required String image, required String title, required String text}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Menampilkan gambar dari folder assets
          Image.asset(
            image,
            height: 250,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFFE56B8B) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}