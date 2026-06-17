<<<<<<< HEAD
=======
import 'dart:ui';
>>>>>>> Back-End
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
<<<<<<< HEAD
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  // Logo icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.edit_outlined, color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Nulisin',
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 40, fontWeight: FontWeight.w700,
                      color: AppColors.primary, letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ruang tenang untuk karya panjang Anda.\nTulis, bagikan, dan temukan cerita bermakna.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant, height: 1.6),
                  ),
                  const Spacer(flex: 2),
                  // Illustration area — subtle decorative cards
                  _IllustrationArea(),
                  const Spacer(flex: 2),
                  // CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Mulai Menulis'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah punya akun? ',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant)),
                      GestureDetector(
                        onTap: () => context.push('/login'),
                        child: Text('Masuk',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            )),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IllustrationArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back card
          Positioned(
            left: 0, top: 16,
            child: _MiniCard(
              icon: Icons.auto_stories_outlined,
              label: 'Filsafat',
              title: 'Stoikisme di Era Modern',
              color: AppColors.sage,
            ),
          ),
          // Front card
          Positioned(
            right: 0, top: 0,
            child: _MiniCard(
              icon: Icons.psychology_outlined,
              label: 'Teknologi',
              title: 'Masa Depan AI Eksplanatori',
              color: const Color(0xFFDCEDE5),
            ),
          ),
          // Center card
          _MiniCard(
            icon: Icons.landscape_outlined,
            label: 'Esai',
            title: 'Kembali ke Kesunyian',
            color: AppColors.cardBackground,
            hasBorder: true,
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final Color color;
  final bool hasBorder;

  const _MiniCard({
    required this.icon, required this.label,
    required this.title, required this.color,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: hasBorder ? Border.all(color: AppColors.outline) : null,
        boxShadow: hasBorder
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12, offset: const Offset(0, 4))]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(label,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary, fontSize: 10)),
          ),
          const SizedBox(height: 4),
          Text(title,
              style: AppTextStyles.headlineSm.copyWith(fontSize: 13),
              maxLines: 2, overflow: TextOverflow.ellipsis),
=======
      body: Stack(
        children: [
          // Ambient Glow Background (Top-Right)
          Positioned(
            top: -120,
            right: -120,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.07),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          // Ambient Glow Background (Bottom-Left)
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.04),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      // Enlarged Logo icon with Border and Shadow
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.outline,
                            width: 2.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            'assets/images/app_icon.jpeg',
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Brand Title
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Nulisin',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 44,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: -1,
                              ),
                            ),
                            TextSpan(
                              text: '.',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 44,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFDCEDE5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ruang tenang untuk karya panjang Anda.\nTulis, bagikan, dan temukan cerita bermakna.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      const Spacer(flex: 3),
                      // CTA Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push('/register'),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Mulai Menulis'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sudah punya akun? ',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              )),
                          GestureDetector(
                            onTap: () => context.push('/login'),
                            child: Text('Masuk',
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
                                )),
                          ),
                        ],
                      ),
                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
>>>>>>> Back-End
        ],
      ),
    );
  }
}
