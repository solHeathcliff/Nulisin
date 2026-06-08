import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/article_repository.dart';
import '../../widgets/article_card.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    ArticleRepository.instance.addListener(_updateState);
  }

  @override
  void dispose() {
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
      ),
    );
  }
}

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
