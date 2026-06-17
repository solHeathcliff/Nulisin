import 'package:flutter/material.dart';
import '../core/theme.dart';

class ArticleCard extends StatefulWidget {
  final String imageUrl;
  final String category;
  final String title;
  final String? authorName;
  final String? readTime;
  final String? authorBadge;
  final String? publishDate;
  final bool isBookmarked;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  const ArticleCard({
    super.key,
    required this.imageUrl,
    required this.category,
    required this.title,
    this.authorName,
    this.readTime,
    this.authorBadge,
    this.publishDate,
    this.isBookmarked = false,
    this.isDark = false,
    this.onTap,
    this.onBookmarkTap,
  });

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
<<<<<<< HEAD
  late bool _bookmarked;
=======
  bool _bookmarked = false;
>>>>>>> Back-End

  @override
  void initState() {
    super.initState();
    _bookmarked = widget.isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDark) return _darkCard();
    return _lightCard();
  }

  Widget _lightCard() {
    return GestureDetector(
      onTap: widget.onTap,
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
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.sage,
                  child: const Center(
                    child: Icon(Icons.image_outlined, color: AppColors.secondary, size: 40),
                  ),
                ),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(color: AppColors.sage);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CategoryBadge(label: widget.category),
                      if (widget.readTime != null) ...[
                        const SizedBox(width: 6),
                        Text('• ${widget.readTime}', style: AppTextStyles.labelSm),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.title, style: AppTextStyles.headlineSm,
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  if (widget.authorName != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _AuthorAvatar(name: widget.authorName!),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.authorName!,
                                  style: AppTextStyles.labelLg),
                              if (widget.publishDate != null)
                                Text(widget.publishDate!,
                                    style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant))
                              else if (widget.authorBadge != null)
                                Text(widget.authorBadge!,
                                    style: AppTextStyles.labelSm),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _bookmarked = !_bookmarked);
                            widget.onBookmarkTap?.call();
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                              key: ValueKey(_bookmarked),
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _darkCard() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CategoryBadge(label: widget.category, isDark: true),
            const SizedBox(height: 12),
            Text(widget.title,
                style: AppTextStyles.headlineMd.copyWith(color: Colors.white),
                maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Baca sekarang',
                    style: AppTextStyles.labelLg.copyWith(color: Colors.white70)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, color: Colors.white70, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  final bool isDark;
  const _CategoryBadge({required this.label, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.15) : AppColors.sage,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSm.copyWith(
          color: isDark ? Colors.white70 : AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  final String name;
  const _AuthorAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.sage,
      child: Text(
        name[0].toUpperCase(),
        style: AppTextStyles.labelSm.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Compact horizontal card for bookmark/explore list
class ArticleListTile extends StatefulWidget {
  final String imageUrl;
  final String category;
  final String title;
  final String? authorName;
  final String? readTime;
  final String? publishDate;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  const ArticleListTile({
    super.key,
    required this.imageUrl,
    required this.category,
    required this.title,
    this.authorName,
    this.readTime,
    this.publishDate,
    this.isBookmarked = false,
    this.onTap,
    this.onBookmarkTap,
  });

  @override
  State<ArticleListTile> createState() => _ArticleListTileState();
}

class _ArticleListTileState extends State<ArticleListTile> {
<<<<<<< HEAD
  late bool _bookmarked;
=======
  bool _bookmarked = false;
>>>>>>> Back-End

  @override
  void initState() {
    super.initState();
    _bookmarked = widget.isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 90,
                height: 90,
                child: Image.network(widget.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: AppColors.sage,
                    child: const Icon(Icons.image_outlined, color: AppColors.secondary)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryBadge(label: widget.category),
                  const SizedBox(height: 6),
                  Text(widget.title, style: AppTextStyles.headlineSm.copyWith(fontSize: 15),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (widget.authorName != null)
                        Expanded(child: Text(widget.authorName!,
                            style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  if (widget.publishDate != null || widget.readTime != null)
                    Text('${widget.publishDate ?? ""} ${widget.publishDate != null && widget.readTime != null ? "•" : ""} ${widget.readTime ?? ""}'.trim(), 
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                setState(() => _bookmarked = !_bookmarked);
                widget.onBookmarkTap?.call();
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  key: ValueKey(_bookmarked),
                  color: AppColors.primary, size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
