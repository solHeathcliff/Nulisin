import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/article_repository.dart';
=======
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';
>>>>>>> Back-End

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
<<<<<<< HEAD
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
=======
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<CategoryModel> _categories = [];
  List<ArticleModel> _articles = [];
  String? _selectedCategoryId;
  String _selectedCategoryName = 'Semua';

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  static const int _pageSize = 15;
  int _offset = 0;

  RealtimeChannel? _realtimeChannel;
>>>>>>> Back-End

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
<<<<<<< HEAD
    ArticleRepository.instance.addListener(_updateState);
=======
    _scrollCtrl.addListener(_onScroll);
    _loadData();
    SupabaseService.instance.articleRefreshTrigger.addListener(_onArticleTriggerRefresh);
    _setupRealtimeListener();
  }

  void _setupRealtimeListener() {
    _realtimeChannel = Supabase.instance.client
        .channel('public:explore_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'articles',
          callback: (payload) {
            if (mounted) _loadData(silent: true);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'categories',
          callback: (payload) {
            if (mounted) _loadData(silent: true);
          },
        );
    _realtimeChannel!.subscribe();
  }

  void _onArticleTriggerRefresh() {
    if (mounted) _loadData(silent: true);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
>>>>>>> Back-End
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
<<<<<<< HEAD
    ArticleRepository.instance.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
=======
    _scrollCtrl.dispose();
    SupabaseService.instance.articleRefreshTrigger.removeListener(_onArticleTriggerRefresh);
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
    }
    super.dispose();
  }

  // Full reload (pertama buka / ganti kategori / pull to refresh)
  Future<void> _loadData({bool silent = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = silent ? _articles.isEmpty : true;
      _offset = 0;
      _hasMore = true;
    });
    try {
      final cats = await SupabaseService.instance.getCategories(onlyPublished: true);
      final articles = await SupabaseService.instance.getDiscoverFeed(
        categoryId: _selectedCategoryId,
        limit: _pageSize,
        offset: 0,
      );
      if (mounted) {
        setState(() {
          _categories = cats;
          _articles = articles;
          _offset = articles.length;
          _hasMore = articles.length == _pageSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Load halaman berikutnya
  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _searchCtrl.text.isNotEmpty) return;
    setState(() => _isLoadingMore = true);
    try {
      final more = await SupabaseService.instance.getDiscoverFeed(
        categoryId: _selectedCategoryId,
        limit: _pageSize,
        offset: _offset,
      );
      if (mounted) {
        setState(() {
          _articles.addAll(more);
          _offset += more.length;
          _hasMore = more.length == _pageSize;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _selectCategory(String? id, String name) async {
    setState(() {
      _selectedCategoryId = id;
      _selectedCategoryName = name;
      _isLoading = true;
      _offset = 0;
      _hasMore = true;
    });
    try {
      final articles = await SupabaseService.instance.getDiscoverFeed(
        categoryId: id,
        limit: _pageSize,
        offset: 0,
      );
      if (mounted) {
        setState(() {
          _articles = articles;
          _offset = articles.length;
          _hasMore = articles.length == _pageSize;
          _isLoading = false;
        });
      }
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
>>>>>>> Back-End
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======
    final filtered = _filtered;
>>>>>>> Back-End

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
<<<<<<< HEAD
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
=======
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadData,
          child: CustomScrollView(
            controller: _scrollCtrl,
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
                    const SizedBox(height: 20),
                    // Category chips
                    if (_categories.isNotEmpty)
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _categories.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (ctx, i) {
                            final isAll = i == 0;
                            final label = isAll ? 'Semua' : _categories[i - 1].name;
                            final catId = isAll ? null : _categories[i - 1].id;
                            final isSelected = _selectedCategoryName == label;
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
                      child: Text('Sedang Tren 🔥',
                          style: AppTextStyles.headlineSm),
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
>>>>>>> Back-End
                        ],
                      ),
                    ),
                  ),
<<<<<<< HEAD
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
=======
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        // Item terakhir = loading indicator
                        if (i == filtered.length) {
                          if (_isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.primary, strokeWidth: 2),
                              ),
                            );
                          }
                          if (!_hasMore && filtered.length > _pageSize) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text('Semua artikel sudah ditampilkan.',
                                    style: AppTextStyles.labelSm),
                              ),
                            );
                          }
                          return const SizedBox(height: 24);
                        }
                        final a = filtered[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _TrendingCard(index: i + 1, article: a),
                        );
                      },
                      childCount: filtered.length + 1,
                    ),
                  ),
                ),
            ],
          ),
>>>>>>> Back-End
        ),
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final int index;
<<<<<<< HEAD
  final Article article;
=======
  final ArticleModel article;
>>>>>>> Back-End
  const _TrendingCard({required this.index, required this.article});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return GestureDetector(
      onTap: () {},
=======
    final author = article.author;
    return GestureDetector(
      onTap: () => context.push('/article/${article.id}'),
>>>>>>> Back-End
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
<<<<<<< HEAD
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
=======
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 7,
                  child: article.coverImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: article.coverImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: AppColors.sage),
                          errorWidget: (_, __, ___) => Container(color: AppColors.sage),
                        )
                      : Container(
                          color: AppColors.sage,
                          child: const Center(
                            child: Icon(Icons.article_outlined,
                                color: AppColors.primary, size: 40),
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('#$index',
                            style: AppTextStyles.labelLg.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: ValueListenableBuilder<Set<String>>(
                    valueListenable: SupabaseService.instance.bookmarkedIdsNotifier,
                    builder: (context, savedIds, _) {
                      final isSaved = savedIds.contains(article.id);
                      return GestureDetector(
                        onTap: () => SupabaseService.instance.toggleBookmark(article.id),
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.visibility_outlined,
                              size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text('${article.viewCount} kali dibaca',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              )),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(article.title,
                      style: AppTextStyles.headlineSm.copyWith(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.sage,
                        backgroundImage: author?.avatarUrl != null
                            ? CachedNetworkImageProvider(author!.avatarUrl!)
                            : null,
                        child: author?.avatarUrl == null
                            ? Text(
                                (author?.fullName.isNotEmpty == true
                                        ? author!.fullName[0]
                                        : '?')
                                    .toUpperCase(),
                                style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11))
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          author?.fullName ?? 'Anonim',
                          style: AppTextStyles.labelSm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${article.formattedDate} • ${article.readTimeEstimate}',
                        style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
>>>>>>> Back-End
          ],
        ),
      ),
    );
  }
}
