import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/article_repository.dart';
import '../../widgets/article_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  final _searchCtrl = TextEditingController();

  final _categories = [
    'Semua', 'Filsafat', 'Teknologi', 'Sastra', 'Esai', 'Sains', 'Budaya',
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
    ArticleRepository.instance.addListener(_updateState);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    ArticleRepository.instance.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final repo = ArticleRepository.instance;
    final allArticles = repo.articles;

    // Filter by selected category
    var filtered = allArticles;
    if (_selectedCategory > 0) {
      final cat = _categories[_selectedCategory];
      filtered = filtered.where((a) => a.category.toLowerCase() == cat.toLowerCase()).toList();
    }

    // Filter by search query if any
    final query = _searchCtrl.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered.where((a) =>
          a.title.toLowerCase().contains(query) ||
          a.category.toLowerCase().contains(query) ||
          a.author.toLowerCase().contains(query)).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: AppColors.surfaceBright,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text('Nulisin',
                style: GoogleFonts.sourceSerif4(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppColors.primary, letterSpacing: -0.5)),

          ),
        ],
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Greeting
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selamat pagi, Amara 👋',
                            style: AppTextStyles.labelLg.copyWith(
                              color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text('Apa yang ingin kamu baca hari ini?',
                            style: AppTextStyles.headlineSm),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(Icons.search, color: AppColors.secondary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              style: AppTextStyles.bodyMd,
                              decoration: InputDecoration(
                                hintText: 'Cari artikel, penulis...',
                                hintStyle: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant),
                                border: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 36, height: 36,
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Category chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final isSelected = i == _selectedCategory;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.outline),
                            ),
                            child: Text(
                              _categories[i],
                              style: AppTextStyles.labelLg.copyWith(
                                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Baru Dibaca', style: AppTextStyles.headlineSm),
                        GestureDetector(
                          onTap: () {},
                          child: Text('Lihat semua',
                              style: AppTextStyles.labelLg.copyWith(
                                color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    if (i == filtered.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('Muat Lebih Banyak'),
                          ),
                        ),
                      );
                    }
                    final a = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ArticleCard(
                        imageUrl: a.image,
                        category: a.category,
                        title: a.title,
                        authorName: a.author,
                        authorBadge: a.badge,
                        publishDate: a.publishDate,
                        readTime: a.readTime,
                        isBookmarked: a.isBookmarked,
                        onTap: () {},
                        onBookmarkTap: () {
                          repo.toggleBookmark(a);
                        },
                      ),
                    );
                  },
                  childCount: filtered.length + 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
