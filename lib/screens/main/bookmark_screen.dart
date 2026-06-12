import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

// Catatan: Fitur bookmark tidak termasuk dalam scope MVP Nulisin (PRD v2.0).
// Halaman ini ditampilkan sebagai placeholder. Untuk mengimplementasikan,
// perlu menambahkan tabel 'bookmarks' di Supabase dan mengintegrasikan
// dengan supabase_service.dart.

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surfaceBright,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text('Disimpan',
                style: GoogleFonts.sourceSerif4(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
        ],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.sage,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.bookmark_outline,
                      size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                Text('Belum ada simpanan',
                    style: AppTextStyles.headlineSm),
                const SizedBox(height: 8),
                Text(
                  'Fitur simpan artikel akan segera hadir.\nTandai artikel favorit untuk dibaca nanti.',
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.sage,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('Segera Hadir',
                      style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
