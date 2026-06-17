import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD
import '../../core/theme.dart';
import '../../core/article_repository.dart';
import '../../widgets/article_card.dart';
=======
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';
import 'home_screen.dart';
>>>>>>> Back-End

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final _searchCtrl = TextEditingController();
<<<<<<< HEAD
  String _searchQuery = '';
=======
  final _scrollCtrl = ScrollController();

  bool _initialLoading = true;
  String? _selectedCategoryId;

  // Jumlah item yang saat ini ditampilkan (pagination lokal)
  static const int _pageSize = 15;
  int _displayCount = _pageSize;
>>>>>>> Back-End

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    ArticleRepository.instance.addListener(_updateState);
=======
    _searchCtrl.addListener(() => setState(() {}));
    _scrollCtrl.addListener(_onScroll);
    SupabaseService.instance.fetchBookmarks().then((_) {
      if (mounted) setState(() => _initialLoading = false);
    });
    // Reset display count saat data berubah (misal buka ulang tab)
    SupabaseService.instance.bookmarkedArticlesNotifier.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() => _displayCount = _pageSize);
  }

  void _onScroll() {
    final all = SupabaseService.instance.bookmarkedArticlesNotifier.value;
    final filtered = _getFiltered(all);

    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        _displayCount < filtered.length) {
      setState(() {
        _displayCount = (_displayCount + _pageSize).clamp(0, filtered.length);
      });
    }
  }

  List<ArticleModel> _getFiltered(List<ArticleModel> articles) {
    var list = articles;

    // Filter berdasarkan Kategori Chip
    if (_selectedCategoryId != null) {
      list = list.where((a) => a.categories.any((cat) => cat.id == _selectedCategoryId)).toList();
    }

    // Filter berdasarkan Search Query
    final q = _searchCtrl.text.toLowerCase().trim();
    if (q.isEmpty) return list;
    return list.where((a) =>
        a.title.toLowerCase().contains(q) ||
        (a.author?.fullName.toLowerCase().contains(q) ?? false) ||
        a.categoryName.toLowerCase().contains(q)).toList();
  }

  List<CategoryModel> _getBookmarkedCategories(List<ArticleModel> articles) {
    final seenIds = <String>{};
    final cats = <CategoryModel>[];
    for (final art in articles) {
      for (final cat in art.categories) {
        if (!seenIds.contains(cat.id)) {
          seenIds.add(cat.id);
          cats.add(cat);
        }
      }
    }
    cats.sort((a, b) => a.name.compareTo(b.name));
    return cats;
>>>>>>> Back-End
  }

  @override
  void dispose() {
<<<<<<< HEAD
    ArticleRepository.instance.removeListener(_updateState);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final repo = ArticleRepository.instance;
    final savedArticles = repo.articles.where((a) => a.isBookmarked).toList();
    final filteredArticles = _searchQuery.isEmpty
        ? savedArticles
        : savedArticles.where((a) =>
            a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            a.author.toLowerCase().contains(_searchQuery.toLowerCase())).toList();


    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surfaceBright,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text('Disimpan', style: GoogleFonts.sourceSerif4(
                fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
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
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: AppTextStyles.bodyMd,
                          decoration: InputDecoration(
                            hintText: 'Cari artikel tersimpan...',
                            hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
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
            ),
          ),
        ],
        body: _AllSaved(articles: filteredArticles),
=======
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    SupabaseService.instance.bookmarkedArticlesNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _initialLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : ValueListenableBuilder<List<ArticleModel>>(
                valueListenable:
                    SupabaseService.instance.bookmarkedArticlesNotifier,
                builder: (context, allArticles, _) {
                  final filtered = _getFiltered(allArticles);
                  final bookmarkCategories = _getBookmarkedCategories(allArticles);
                  final visible = filtered.take(_displayCount).toList();
                  final hasMore = _displayCount < filtered.length;

                  return CustomScrollView(
                    controller: _scrollCtrl,
                    slivers: [
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
                      if (allArticles.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              // Search bar (Desain sama persis seperti Jelajah)
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
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
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
                              const SizedBox(height: 16),
                              // Category chips (Desain sama persis seperti Jelajah)
                              SizedBox(
                                height: 36,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: bookmarkCategories.length + 1,
                                  separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                                  itemBuilder: (ctx, i) {
                                    final isAll = i == 0;
                                    final label = isAll ? 'Semua' : bookmarkCategories[i - 1].name;
                                    final isSelected = isAll
                                        ? _selectedCategoryId == null
                                        : _selectedCategoryId == bookmarkCategories[i - 1].id;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isAll) {
                                            _selectedCategoryId = null;
                                          } else {
                                            _selectedCategoryId = bookmarkCategories[i - 1].id;
                                          }
                                          _displayCount = _pageSize; // Reset display count saat filter berganti
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      if (allArticles.isEmpty)
                        SliverFillRemaining(
                          child: Center(
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
                                    'Tekan ikon bookmark pada artikel\ndi Beranda atau Jelajahi untuk menyimpannya.',
                                    style: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.onSurfaceVariant),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                                // Item terakhir = loading/footer indicator
                                if (i == visible.length) {
                                  if (hasMore) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 24),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            color: AppColors.primary, strokeWidth: 2),
                                      ),
                                    );
                                  }
                                  if (filtered.length > _pageSize) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 24),
                                      child: Center(
                                        child: Text(
                                          'Semua simpanan sudah ditampilkan.',
                                          style: AppTextStyles.labelSm,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox(height: 24);
                                }
                                final article = visible[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: SupabaseArticleCard(
                                    article: article,
                                    onTap: () => context.push('/article/${article.id}'),
                                  ),
                                );
                              },
                              childCount: visible.length + 1,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
>>>>>>> Back-End
      ),
    );
  }
}
<<<<<<< HEAD

class _AllSaved extends StatelessWidget {
  final List<Article> articles;
  const _AllSaved({required this.articles});

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border, size: 64, color: AppColors.outline),
            const SizedBox(height: 16),
            Text('Belum ada simpanan', style: AppTextStyles.headlineSm),
            const SizedBox(height: 8),
            Text('Mulai simpan artikel yang menarik\nuntuk dibaca nanti.',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: articles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final a = articles[i];
        return ArticleListTile(
          imageUrl: a.image,
          category: a.category,
          title: a.title,
          authorName: a.author,
          publishDate: a.publishDate,
          readTime: a.readTime,
          isBookmarked: a.isBookmarked,
          onTap: () {},
          onBookmarkTap: () {
            ArticleRepository.instance.toggleBookmark(a);
          },
        );
      },
    );
  }
}
=======
>>>>>>> Back-End
