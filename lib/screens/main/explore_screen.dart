import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/article_repository.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedTopic = 0;
  final _searchCtrl = TextEditingController();

  final _defaultTopics = [
    'Semua',
    'Filsafat',
    'Teknologi',
    'Sastra',
    'Esai',
    'Sains',
    'Budaya',
    'Sejarah',
    'Kesehatan',
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

    // Collect all unique topics from articles
    final topics = List<String>.from(_defaultTopics);
    for (final a in allArticles) {
      final exists = topics.any((t) => t.toLowerCase() == a.category.toLowerCase());
      if (!exists) {
        topics.add(a.category);
      }
    }

    // Filter by selected topic chip
    var filtered = allArticles;
    if (_selectedTopic > 0 && _selectedTopic < topics.length) {
      final topicName = topics[_selectedTopic];
      filtered = filtered.where((a) => a.category.toLowerCase() == topicName.toLowerCase()).toList();
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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.surfaceBright,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text('Jelajahi', style: GoogleFonts.sourceSerif4(
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),

            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
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
                                hintText: 'Cari topik, penulis, artikel...',
                                hintStyle: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant),
                                border: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Topic chips
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: topics.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (ctx, i) {
                        final label = topics[i];
                        final isSelected = i == _selectedTopic;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTopic = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.outline,
                                width: 1.2,
                              ),
                            ),
                            child: Text(label,
                                style: AppTextStyles.labelLg.copyWith(
                                  color: isSelected ? Colors.white : AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                )),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sedang Tren 🔥', style: AppTextStyles.headlineSm),
                        Text('Lihat semua',
                            style: AppTextStyles.labelLg.copyWith(color: AppColors.primary)),
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
                    if (i >= filtered.length) return null;
                    final a = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _TrendingCard(index: i + 1, article: a),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final int index;
  final Article article;
  const _TrendingCard({required this.index, required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Text('$index',
                style: AppTextStyles.displayLg.copyWith(
                  fontSize: 28,
                  color: AppColors.outline,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.sage,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(article.category.toUpperCase(),
                        style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 6),
                  Text(article.title,
                      style: AppTextStyles.headlineSm.copyWith(fontSize: 15),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(article.author, style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('${article.publishDate} • ${article.readTime}',
                      style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(article.image, width: 64, height: 64, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                    width: 64, height: 64, color: AppColors.sage)),
            ),
          ],
        ),
      ),
    );
  }
}
