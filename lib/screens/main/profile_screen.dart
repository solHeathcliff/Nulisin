import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/article_repository.dart';


class ProfileScreen extends StatefulWidget {
  final bool openDraftTab;
  const ProfileScreen({super.key, this.openDraftTab = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _drafts = [
    _PrDraft('Masa Depan Pendidikan di Era AI', '14 Jun 2026'),
    _PrDraft('Mengapa Kita Butuh Silence: Catatan Introvert', '10 Jun 2026'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    ArticleRepository.instance.addListener(_updateState);
    // Auto-switch to Draft tab if requested
    if (widget.openDraftTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tabCtrl.animateTo(1);
      });
    }
  }

  @override
  void dispose() {
    ArticleRepository.instance.removeListener(_updateState);
    _tabCtrl.dispose();
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: AppColors.surfaceBright,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text('Profil', style: GoogleFonts.sourceSerif4(
                fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  onPressed: _confirmLogout,
                ),
              ),
            ],
          ),
        ],
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.sage,
                        child: Text('A',
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 36, fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      ),
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle,
                          border: Border.all(color: AppColors.background, width: 2),
                        ),
                        child: const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Amara Prasetya',
                      style: AppTextStyles.headlineLg),
                  const SizedBox(height: 4),
                  Text('Penulis & Esais',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Mencurahkan pikiran ke dalam kata-kata. Menulis tentang filsafat, budaya, dan kehidupan sehari-hari.',
                      style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats row
                  _StatItem(value: '24', label: 'Artikel'),
                  const SizedBox(height: 20),
                  // Edit profile button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/edit-profile'),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit Profil'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tabs
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.outline),
                        bottom: BorderSide(color: AppColors.outline),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabCtrl,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 2.5,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.secondary,
                      labelStyle: GoogleFonts.hankenGrotesk(
                          fontSize: 14, fontWeight: FontWeight.w600),
                      unselectedLabelStyle: GoogleFonts.hankenGrotesk(fontSize: 14),
                      tabs: const [
                        Tab(text: 'Cerita'),
                        Tab(text: 'Draft'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  // Cerita tab
                  ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: ArticleRepository.instance.articles
                        .where((a) => a.author == 'Amara Prasetya')
                        .length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (ctx, i) {
                      final myArticles = ArticleRepository.instance.articles
                          .where((a) => a.author == 'Amara Prasetya')
                          .toList();
                      final a = myArticles[i];
                      return _ProfileArticleCard(article: a);
                    },
                  ),
                  // Draft tab
                  ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _drafts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final d = _drafts[i];
                      return _DraftCard(draft: d);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceBright,
        title: Text('Keluar?', style: GoogleFonts.sourceSerif4(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 20)),
        content: Text('Apakah Anda yakin ingin keluar dari akun ini?', style: GoogleFonts.hankenGrotesk(fontSize: 15, color: AppColors.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.go('/');
    }
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        Text(value, style: AppTextStyles.headlineSm),
        Text(label, style: AppTextStyles.labelSm),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 28, color: AppColors.outline);
}

class _ProfileArticleCard extends StatelessWidget {
  final Article article;
  const _ProfileArticleCard({required this.article});
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 16 / 7,
              child: Image.network(article.image, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: AppColors.sage)),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.sage,
                            borderRadius: BorderRadius.circular(100)),
                        child: Text(article.category.toUpperCase(),
                            style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(article.title, style: AppTextStyles.headlineSm.copyWith(fontSize: 16),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Amara Prasetya', style: AppTextStyles.labelSm),
                      const SizedBox(width: 8),
                      Text('• ${article.publishDate} • ${article.readTime}', style: AppTextStyles.labelSm.copyWith(color: AppColors.secondary)),
                      const Spacer(),
                      const Icon(Icons.favorite, size: 14, color: AppColors.error),
                      const SizedBox(width: 4),
                      Text('1.2rb', style: AppTextStyles.labelSm),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  final _PrDraft draft;
  const _DraftCard({required this.draft});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.sage,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 20)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(draft.title, style: AppTextStyles.labelLg,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('Draft • ${draft.date}', style: AppTextStyles.labelSm),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.secondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PrDraft {
  final String title, date;
  const _PrDraft(this.title, this.date);
}
