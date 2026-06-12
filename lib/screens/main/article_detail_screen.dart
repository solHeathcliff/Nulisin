import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/gestures.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';
import 'write_screen.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String articleId;
  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  ArticleModel? _article;
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isSendingComment = false;
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadArticle() async {
    setState(() => _isLoading = true);
    try {
      final article = await SupabaseService.instance.getArticleById(widget.articleId);
      final comments = await SupabaseService.instance.getComments(widget.articleId);
      if (mounted) {
        setState(() {
          _article = article;
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    if (!SupabaseService.instance.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masuk terlebih dahulu untuk berkomentar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isSendingComment = true);
    try {
      final comment = await SupabaseService.instance.createComment(
        articleId: widget.articleId,
        content: text,
      );
      _commentCtrl.clear();
      if (mounted) {
        setState(() {
          _comments.add(comment);
          _isSendingComment = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSendingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_article == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Artikel tidak ditemukan.')),
      );
    }

    final article = _article!;
    final author = article.author;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Cover image app bar
                SliverAppBar(
                  expandedHeight: article.coverImageUrl != null ? 240 : 0,
                  pinned: true,
                  backgroundColor: AppColors.surfaceBright,
                  elevation: 0,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.onSurface, size: 20),
                    ),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  actions: [
                    if (article.authorId == SupabaseService.instance.currentUser?.id)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_outlined,
                                color: AppColors.onSurface, size: 20),
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => WriteScreen(editArticle: article),
                              ),
                            );
                            _loadArticle(); // Reload detail data when returning
                          },
                        ),
                      ),
                  ],
                  flexibleSpace: article.coverImageUrl != null
                      ? FlexibleSpaceBar(
                          background: CachedNetworkImage(
                            imageUrl: article.coverImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: AppColors.sage),
                            errorWidget: (_, __, ___) =>
                                Container(color: AppColors.sage),
                          ),
                        )
                      : null,
                ),
                // Article content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category chip
                        if (article.categories.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.sage,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              article.categoryName.toUpperCase(),
                              style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Title
                        Text(article.title,
                            style: GoogleFonts.newsreader(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                              height: 1.3,
                            )),
                        const SizedBox(height: 20),
                        // Author info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
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
                                      style: AppTextStyles.labelLg.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700))
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(author?.fullName ?? 'Anonim',
                                    style: AppTextStyles.labelLg.copyWith(
                                        fontWeight: FontWeight.w600)),
                                if (author?.profession?.isNotEmpty == true)
                                  Text(author!.profession!,
                                      style: AppTextStyles.labelSm.copyWith(
                                          color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(article.formattedDate,
                                    style: AppTextStyles.labelSm.copyWith(
                                        color: AppColors.onSurfaceVariant)),
                                Text(article.readTimeEstimate,
                                    style: AppTextStyles.labelSm.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.outline),
                        const SizedBox(height: 24),
                        // Content
                        MarkdownBody(
                          data: article.content,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            textAlign: WrapAlignment.spaceAround,
                            p: GoogleFonts.newsreader(
                              fontSize: 18,
                              height: 1.8,
                              color: AppColors.onSurface,
                            ),
                            h1: GoogleFonts.sourceSerif4(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                              color: AppColors.onSurface,
                            ),
                            h2: GoogleFonts.sourceSerif4(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                              color: AppColors.onSurface,
                            ),
                            h3: GoogleFonts.sourceSerif4(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                              color: AppColors.onSurface,
                            ),
                            em: GoogleFonts.newsreader(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              height: 1.8,
                              color: AppColors.onSurface,
                            ),
                            strong: GoogleFonts.newsreader(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.8,
                              color: AppColors.onSurface,
                            ),
                            blockquote: GoogleFonts.newsreader(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              height: 1.8,
                              color: AppColors.secondary,
                            ),
                            blockquoteDecoration: BoxDecoration(
                              border: const Border(
                                left: BorderSide(color: AppColors.primary, width: 4),
                              ),
                              color: AppColors.sage.withOpacity(0.2),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            listBullet: GoogleFonts.newsreader(
                              fontSize: 18,
                              color: AppColors.onSurface,
                            ),
                            listBulletPadding: const EdgeInsets.only(right: 8, top: 4),
                            a: GoogleFonts.hankenGrotesk(
                              fontSize: 18,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                            img: const TextStyle(fontSize: 18),
                          ),
                           imageBuilder: (uri, title, alt) {
                            final size = uri.fragment;
                            final cleanUrl = uri.replace(fragment: '').toString();

                            Widget imageWidget = ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: cleanUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  height: 200,
                                  color: AppColors.sage.withOpacity(0.3),
                                  child: const Center(
                                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  height: 150,
                                  color: AppColors.sage.withOpacity(0.3),
                                  child: const Center(
                                    child: Icon(Icons.broken_image_outlined, color: AppColors.secondary, size: 36),
                                  ),
                                ),
                              ),
                            );

                            if (size == 'small') {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: 0.5,
                                  child: imageWidget,
                                ),
                              );
                            } else if (size == 'wide') {
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  final double bleedWidth = constraints.maxWidth + 48;
                                  return Center(
                                    child: OverflowBox(
                                      minWidth: 0,
                                      maxWidth: bleedWidth,
                                      child: SizedBox(
                                        width: bleedWidth,
                                        child: imageWidget,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }

                            return SizedBox(
                              width: double.infinity,
                              child: imageWidget,
                            );
                          },
                        ),
                        const SizedBox(height: 48),
                        const Divider(color: AppColors.outline),
                        const SizedBox(height: 24),
                        // Comments section header
                        Row(
                          children: [
                            Text('Respons',
                                style: AppTextStyles.headlineSm),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.sage,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text('${_comments.length}',
                                  style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Comments list
                        if (_comments.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'Belum ada respons. Jadilah yang pertama!',
                                style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          ...(_comments.map((c) => _CommentCard(comment: c))),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Comment input bar
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceBright,
              border: Border(top: BorderSide(color: AppColors.outline)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      style: AppTextStyles.bodyMd,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: SupabaseService.instance.isLoggedIn
                            ? 'Tulis respons...'
                            : 'Masuk untuk berkomentar',
                        hintStyle: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.onSurfaceVariant),
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isSendingComment ? null : _sendComment,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: _isSendingComment
                          ? const Center(
                              child: SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              ),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final CommentModel comment;
  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    final author = comment.author;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
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
                        color: AppColors.primary, fontWeight: FontWeight.w700))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(author?.fullName ?? 'Anonim',
                        style: AppTextStyles.labelLg
                            .copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(comment.formattedTime,
                        style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: AppTextStyles.bodyMd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
