import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';
import 'write_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool openDraftTab;
  const ProfileScreen({super.key, this.openDraftTab = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  List<ArticleModel> _myArticles = [];
  List<ArticleModel> _myDrafts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadData();
    if (widget.openDraftTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tabCtrl.animateTo(1);
      });
    }
    SupabaseService.instance.articleRefreshTrigger.addListener(_onArticleTriggerRefresh);
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.openDraftTab && !oldWidget.openDraftTab) {
      _tabCtrl.animateTo(1);
    }
  }

  void _onArticleTriggerRefresh() {
    if (mounted) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    SupabaseService.instance.articleRefreshTrigger.removeListener(_onArticleTriggerRefresh);
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = SupabaseService.instance.currentUser?.id;
      if (userId == null) return;
      final results = await Future.wait([
        SupabaseService.instance.getProfile(userId),
        SupabaseService.instance.getMyArticles(isPublished: true),
        SupabaseService.instance.getMyArticles(isPublished: false),
      ]);
      if (mounted) {
        setState(() {
          _myArticles = results[1] as List<ArticleModel>;
          _myDrafts = results[2] as List<ArticleModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadData,
              child: NestedScrollView(
                headerSliverBuilder: (ctx, _) => [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 0,
                    backgroundColor: AppColors.surfaceBright,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    title: Text('Profil',
                        style: GoogleFonts.sourceSerif4(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: const Icon(Icons.logout_rounded,
                              color: AppColors.error),
                          onPressed: _confirmLogout,
                        ),
                      ),
                    ],
                  ),
                ],
                body: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ValueListenableBuilder<ProfileModel?>(
                        valueListenable: SupabaseService.instance.profileNotifier,
                        builder: (context, profile, _) {
                          final name = profile?.fullName.isNotEmpty == true
                              ? profile!.fullName
                              : 'Penulis';
                          final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                          return Column(
                            children: [
                              const SizedBox(height: 24),
                              // Avatar
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 44,
                                    backgroundColor: AppColors.sage,
                                    backgroundImage: profile?.avatarUrl != null
                                        ? CachedNetworkImageProvider(profile!.avatarUrl!)
                                        : null,
                                    child: profile?.avatarUrl == null
                                        ? Text(initial,
                                            style: GoogleFonts.sourceSerif4(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary))
                                        : null,
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.background, width: 2),
                                    ),
                                    child: const Icon(Icons.verified_rounded,
                                        color: Colors.white, size: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(name, style: AppTextStyles.headlineLg),
                              if (profile?.profession?.isNotEmpty == true) ...[
                                const SizedBox(height: 4),
                                Text(profile!.profession!,
                                    style: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.onSurfaceVariant)),
                              ],
                              if (profile?.bio?.isNotEmpty == true) ...[
                                const SizedBox(height: 12),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    profile!.bio!,
                                    style: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        height: 1.5),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              // Stats
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _StatItem(
                                      value: _myArticles.length.toString(),
                                      label: 'Artikel'),
                                  const SizedBox(width: 32),
                                  _StatItem(
                                      value: _myDrafts.length.toString(),
                                      label: 'Draft'),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Edit profile button
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await context.push('/edit-profile');
                                      _loadData();
                                    },
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
                                  unselectedLabelStyle:
                                      GoogleFonts.hankenGrotesk(fontSize: 14),
                                  tabs: const [
                                    Tab(text: 'Cerita'),
                                    Tab(text: 'Draft'),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      ),
                    ),
                    SliverFillRemaining(
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [
                          // Published articles
                          _myArticles.isEmpty
                              ? _EmptyState(
                                  icon: Icons.article_outlined,
                                  message: 'Belum ada artikel yang diterbitkan.',
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(20),
                                  itemCount: _myArticles.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (ctx, i) =>
                                      _ProfileArticleCard(article: _myArticles[i]),
                                ),
                          // Draft articles
                          _myDrafts.isEmpty
                              ? _EmptyState(
                                  icon: Icons.description_outlined,
                                  message: 'Tidak ada draft tersimpan.',
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(20),
                                  itemCount: _myDrafts.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (ctx, i) =>
                                      _DraftCard(article: _myDrafts[i]),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceBright,
        title: Text('Keluar?',
            style: GoogleFonts.sourceSerif4(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 20)),
        content: Text('Apakah Anda yakin ingin keluar dari akun ini?',
            style: GoogleFonts.hankenGrotesk(
                fontSize: 15, color: AppColors.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.hankenGrotesk(
                    fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await SupabaseService.instance.signOut();
      if (mounted) context.go('/');
    }
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: AppTextStyles.headlineSm),
          Text(label, style: AppTextStyles.labelSm),
        ],
      );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.secondary),
              const SizedBox(height: 12),
              Text(message,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _ProfileArticleCard extends StatelessWidget {
  final ArticleModel article;
  const _ProfileArticleCard({required this.article});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/article/${article.id}'),
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
            if (article.coverImageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 7,
                child: CachedNetworkImage(
                  imageUrl: article.coverImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.sage),
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.sage),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 7,
                child: Container(
                  color: AppColors.sage,
                  child: const Center(
                    child: Icon(Icons.article_outlined,
                        color: AppColors.primary, size: 36),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.categories.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: article.categories.map((cat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.sage,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            cat.name.toUpperCase(),
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.sage,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text('UMUM',
                          style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  const SizedBox(height: 8),
                  Text(article.title,
                      style: AppTextStyles.headlineSm.copyWith(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                          '${article.formattedDate} • ${article.readTimeEstimate}',
                          style: AppTextStyles.labelSm
                              .copyWith(color: AppColors.secondary)),
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
  final ArticleModel article;
  const _DraftCard({required this.article});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => WriteScreen(editArticle: article),
          ),
        );
      },
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
            if (article.coverImageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 7,
                child: CachedNetworkImage(
                  imageUrl: article.coverImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.sage),
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.sage),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 7,
                child: Container(
                  color: AppColors.sage,
                  child: const Center(
                    child: Icon(Icons.description_outlined,
                        color: AppColors.primary, size: 36),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.categories.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: article.categories.map((cat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.sage,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            cat.name.toUpperCase(),
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.sage,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text('UMUM',
                          style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  const SizedBox(height: 8),
                  Text(article.title,
                      style: AppTextStyles.headlineSm.copyWith(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                          'Draft • ${article.readTimeEstimate}',
                          style: AppTextStyles.labelSm
                              .copyWith(color: AppColors.secondary)),
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
