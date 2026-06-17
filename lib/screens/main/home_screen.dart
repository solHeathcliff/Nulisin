import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/article_repository.dart';
import '../../widgets/article_card.dart';
=======
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';
>>>>>>> Back-End

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
<<<<<<< HEAD
  int _selectedCategory = 0;
  final _searchCtrl = TextEditingController();

  final _categories = [
    'Semua', 'Filsafat', 'Teknologi', 'Sastra', 'Esai', 'Sains', 'Budaya',
  ];
=======
  final _searchCtrl = TextEditingController();

  List<ArticleModel> _articles = [];
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  String _selectedCategoryName = 'Semua';
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMsg;
  int _offset = 0;
  static const int _pageSize = 10;
  bool _hasMore = true;
  RealtimeChannel? _realtimeChannel;
>>>>>>> Back-End

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _searchCtrl.addListener(() => setState(() {}));
    ArticleRepository.instance.addListener(_updateState);
=======
    _searchCtrl.addListener(_onSearch);
    _loadData();
    SupabaseService.instance.articleRefreshTrigger.addListener(_onArticleTriggerRefresh);
    _setupRealtimeListener();
  }

  void _setupRealtimeListener() {
    _realtimeChannel = Supabase.instance.client
        .channel('public:db_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'articles',
          callback: (payload) {
            if (mounted) {
              _loadArticles(refresh: true, silent: true);
              _loadCategories();
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'categories',
          callback: (payload) {
            if (mounted) {
              _loadCategories();
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reading_history',
          callback: (payload) {
            if (mounted) {
              _loadArticles(refresh: true, silent: true);
            }
          },
        );
    _realtimeChannel!.subscribe();
  }

  void _onArticleTriggerRefresh() {
    if (mounted) {
      _loadArticles(refresh: true, silent: true);
      _loadCategories();
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
    SupabaseService.instance.articleRefreshTrigger.removeListener(_onArticleTriggerRefresh);
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadProfile(), _loadCategories()]);
    await _loadArticles(refresh: true);
  }

  Future<void> _loadProfile() async {
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) return;
    await SupabaseService.instance.getProfile(userId);
  }

  Future<void> _loadCategories() async {
    final cats = await SupabaseService.instance.getCategories(onlyPublished: true);
    if (mounted) setState(() => _categories = cats);
  }

  Future<void> _loadArticles({bool refresh = false, bool silent = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = silent ? _articles.isEmpty : true;
        _offset = 0;
        _hasMore = true;
      });
    } else {
      if (_isLoadingMore || !_hasMore) return;
      setState(() => _isLoadingMore = true);
    }

    try {
      final result = await SupabaseService.instance.getHomeFeed(
        categoryId: _selectedCategoryId,
        limit: _pageSize,
        offset: _offset,
      );

      if (mounted) {
        setState(() {
          if (refresh) {
            _articles = result;
          } else {
            _articles.addAll(result);
          }
          _offset += result.length;
          _hasMore = result.length == _pageSize;
          _isLoading = false;
          _isLoadingMore = false;
          _errorMsg = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _errorMsg = 'Gagal memuat artikel. Tarik untuk refresh.';
        });
      }
    }
  }

  void _onSearch() {
    setState(() {});
  }

  void _selectCategory(String? id, String name) {
    setState(() {
      _selectedCategoryId = id;
      _selectedCategoryName = name;
    });
    _loadArticles(refresh: true);
  }

  List<ArticleModel> get _filteredArticles {
    final query = _searchCtrl.text.toLowerCase().trim();
    if (query.isEmpty) return _articles;
    return _articles.where((a) =>
        a.title.toLowerCase().contains(query) ||
        (a.author?.fullName.toLowerCase().contains(query) ?? false) ||
        a.categoryName.toLowerCase().contains(query)).toList();
  }

  String get _greetingText {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
>>>>>>> Back-End
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======
    final filtered = _filteredArticles;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _loadArticles(refresh: true),
        child: NestedScrollView(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ValueListenableBuilder<ProfileModel?>(
                        valueListenable: SupabaseService.instance.profileNotifier,
                        builder: (context, profile, _) {
                          final displayName = profile?.fullName.isNotEmpty == true
                              ? profile!.fullName.split(' ').first
                              : 'Penulis';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$_greetingText, $displayName 👋',
                                  style: AppTextStyles.labelLg.copyWith(
                                    color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text('Apa yang ingin kamu baca hari ini?',
                                  style: AppTextStyles.headlineSm),
                            ],
                          );
                        }
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
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _categories.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) {
                          final isAll = i == 0;
                          final label = isAll ? 'Semua' : _categories[i - 1].name;
                          final catId = isAll ? null : _categories[i - 1].id;
                          final isSelected = _selectedCategoryName == label;
                          return GestureDetector(
                            onTap: () => _selectCategory(catId, label),
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
                                label,
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
                      child: Text('Baru dibaca', style: AppTextStyles.headlineSm),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_errorMsg != null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              size: 48, color: AppColors.secondary),
                          const SizedBox(height: 16),
                          Text(_errorMsg!,
                              style: AppTextStyles.bodyMd
                                  .copyWith(color: AppColors.onSurfaceVariant),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _loadArticles(refresh: true),
                            child: const Text('Coba Lagi'),
>>>>>>> Back-End
                          ),
                        ],
                      ),
                    ),
                  ),
<<<<<<< HEAD
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
=======
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.article_outlined,
                              size: 48, color: AppColors.secondary),
                          const SizedBox(height: 16),
                          Text('Belum ada artikel di topik ini.',
                              style: AppTextStyles.bodyMd
                                  .copyWith(color: AppColors.onSurfaceVariant),
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
                        if (i == filtered.length) {
                          if (_isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: CircularProgressIndicator(
                                  color: AppColors.primary, strokeWidth: 2)),
                            );
                          }
                          if (_hasMore) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: OutlinedButton(
                                  onPressed: () => _loadArticles(),
                                  child: const Text('Muat Lebih Banyak'),
                                ),
                              ),
                            );
                          }
                          return const SizedBox(height: 24);
                        }
                        final a = filtered[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SupabaseArticleCard(
                            article: a,
                            onTap: () {
                              // Navigate to article detail
                              context.push('/article/${a.id}');
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
      ),
    );
  }
}

class SupabaseArticleCard extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback onTap;
  const SupabaseArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final author = article.author;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image with Bookmark overlay
            Stack(
              children: [
                if (article.coverImageUrl != null)
                  AspectRatio(
                    aspectRatio: 16 / 7,
                    child: CachedNetworkImage(
                      imageUrl: article.coverImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.sage),
                      errorWidget: (_, __, ___) => Container(color: AppColors.sage),
                    ),
                  )
                else
                  AspectRatio(
                    aspectRatio: 16 / 7,
                    child: Container(
                      color: AppColors.sage,
                      child: const Center(
                        child: Icon(Icons.article_outlined,
                            color: AppColors.primary, size: 40),
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
                        onTap: () {
                          SupabaseService.instance.toggleBookmark(article.id);
                        },
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
                  // Category chip
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
                  const SizedBox(height: 8),
                  // Title
                  Text(article.title,
                      style: AppTextStyles.headlineSm.copyWith(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  // Author row
                  Row(
                    children: [
                      // Avatar
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
>>>>>>> Back-End
              ),
            ),
          ],
        ),
      ),
    );
  }
}
