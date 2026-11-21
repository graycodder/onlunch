import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/assets.dart';
import '../../../data/models/banner_model.dart';

class VideoBannerWidget extends StatelessWidget {
  final BannerModel? banner;

  const VideoBannerWidget({super.key, this.banner});

  void _openVideoPlayer(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Video Player',
        'Playing promotional video from OneLunch...',
        backgroundColor: Colors.white,
        colorText: AppColors.primaryGreen,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              AppAssets.videoBanner,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.darkGreen,
                child: const Icon(Icons.restaurant, color: Colors.white24, size: 64),
              ),
            ),

            // Soft dark gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.25),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Script text matching UI: "Delicious Lunch Just a Click Away!"
            Positioned(
              top: 18,
              left: 20,
              right: 20,
              child: Text(
                'Delicious Lunch\nJust a Click Away!',
                style: GoogleFonts.caveat(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                  shadows: const [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),

            // Center Circular Play Button
            Center(
              child: GestureDetector(
                onTap: () {
                  final url = banner?.videoUrl ?? 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
                  _openVideoPlayer(context, url);
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 34,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
