import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();

  List<CategoryModel> _categories = [];
  List<ArticleModel> _articles = [];
  String? _selectedCategoryId;
  String _selectedCategoryName = 'Semua';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
    _loadData();
    SupabaseService.instance.articleRefreshTrigger.addListener(_onArticleTriggerRefresh);
  }

  void _onArticleTriggerRefresh() {
    if (mounted) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    SupabaseService.instance.articleRefreshTrigger.removeListener(_onArticleTriggerRefresh);
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final cats = await SupabaseService.instance.getCategories();
      final articles = await SupabaseService.instance.getDiscoverFeed(
        categoryId: _selectedCategoryId,
        limit: 30,
      );
      if (mounted) {
        setState(() {
          _categories = cats;
          _articles = articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectCategory(String? id, String name) async {
    setState(() {
      _selectedCategoryId = id;
      _selectedCategoryName = name;
      _isLoading = true;
    });
    try {
      final articles = await SupabaseService.instance.getDiscoverFeed(
        categoryId: id,
        limit: 30,
      );
      if (mounted) setState(() { _articles = articles; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ArticleModel> get _filtered {
    final q = _searchCtrl.text.toLowerCase().trim();
    if (q.isEmpty) return _articles;
    return _articles.where((a) =>
        a.title.toLowerCase().contains(q) ||
        (a.author?.fullName.toLowerCase().contains(q) ?? false) ||
        a.categoryName.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.surfaceBright,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Text('Jelajahi',
                    style: GoogleFonts.sourceSerif4(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
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
                            const Icon(Icons.search,
                                color: AppColors.secondary, size: 20),
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
                    // Category chips
                    if (_categories.isNotEmpty)
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _categories.length + 1,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 10),
                          itemBuilder: (ctx, i) {
                            final isAll = i == 0;
                            final label =
                                isAll ? 'Semua' : _categories[i - 1].name;
                            final catId =
                                isAll ? null : _categories[i - 1].id;
                            final isSelected =
                                _selectedCategoryName == label;
                            return GestureDetector(
                              onTap: () => _selectCategory(catId, label),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.outline,
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(label,
                                    style: AppTextStyles.labelLg.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.onSurface,
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
                          Text('Sedang Tren 🔥',
                              style: AppTextStyles.headlineSm),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary)),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off_rounded,
                              size: 48, color: AppColors.secondary),
                          const SizedBox(height: 12),
                          Text('Tidak ada artikel ditemukan.',
                              style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                )
              else
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
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final int index;
  final ArticleModel article;
  const _TrendingCard({required this.index, required this.article});

  @override
  Widget build(BuildContext context) {
    final author = article.author;
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.sage,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(article.categoryName.toUpperCase(),
                        style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 6),
                  Text(article.title,
                      style: AppTextStyles.headlineSm.copyWith(fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(author?.fullName ?? 'Anonim',
                      style: AppTextStyles.labelSm
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                      '${article.formattedDate} • ${article.readTimeEstimate}',
                      style: AppTextStyles.labelSm
                          .copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: article.coverImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: article.coverImageUrl!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(width: 64, height: 64, color: AppColors.sage),
                      errorWidget: (_, __, ___) =>
                          Container(width: 64, height: 64, color: AppColors.sage),
                    )
                  : Container(
                      width: 64,
                      height: 64,
                      color: AppColors.sage,
                      child: const Icon(Icons.article_outlined,
                          color: AppColors.primary, size: 28),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
