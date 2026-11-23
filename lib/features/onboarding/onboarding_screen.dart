import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/dot_grid_painter.dart';
import '../../shared/widgets/beforth_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DotGridBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _isLastPage = index == 2;
                    });
                  },
                  children: [
                    _buildPage1(),
                    _buildPage2(),
                    _buildPage3(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: 3,
                      effect: const ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: AppTheme.primaryBlue,
                        dotColor: AppTheme.borderDivider,
                      ),
                    ),
                    if (!_isLastPage)
                      BeforthButton(
                        label: "NEXT",
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      )
                    else
                      BeforthButton(
                        label: "GET STARTED",
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('seen_onboarding', true);
                          if (context.mounted) context.go('/');
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 160,
            width: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: AppTheme.borderDivider, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: 120, color: AppTheme.borderDivider, margin: const EdgeInsets.only(bottom: 8)),
                  Container(height: 12, width: 80, color: AppTheme.borderDivider.withValues(alpha: 0.5), margin: const EdgeInsets.only(bottom: 24)),
                  Container(height: 8, width: 160, color: AppTheme.borderDivider.withValues(alpha: 0.3), margin: const EdgeInsets.only(bottom: 6)),
                  Container(height: 8, width: 140, color: AppTheme.borderDivider.withValues(alpha: 0.3)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text("CARDSNAP", style: GoogleFonts.plusJakartaSans(fontSize: 48, color: AppTheme.navy, letterSpacing: 2.0)),
          const SizedBox(height: 16),
          Text(
            "Scan. Save. Connect.",
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w300, color: AppTheme.stone),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_rounded, size: 80, color: AppTheme.primaryBlue),
          const SizedBox(height: 48),
          Text("Point and scan", style: GoogleFonts.plusJakartaSans(fontSize: 32, color: AppTheme.navy, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Text(
            "CardSnap reads business cards in seconds — even messy ones.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppTheme.stone, height: 1.5),
          ),
          const SizedBox(height: 32),
          BeforthButton(
            label: "Allow Camera Access",
            onPressed: () async {
              await Permission.camera.request();
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 80, color: AppTheme.warning),
          const SizedBox(height: 48),
          Text("Boost accuracy with AI", style: GoogleFonts.plusJakartaSans(fontSize: 32, color: AppTheme.navy, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Text(
            "Add an AI API key for near-perfect parsing on complex cards. Supports OpenAI, Grok, Gemini, and any compatible provider. Totally optional — the app works great offline too.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppTheme.stone, height: 1.5),
          ),
        ],
      ),
    );
  }
}
