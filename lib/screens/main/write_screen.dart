import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/article_repository.dart';

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _newTopicCtrl = TextEditingController();
  bool _isBold = false, _isItalic = false, _isQuote = false;
  DateTime? _selectedDate;
  String _selectedTopic = 'Filsafat';
  final List<String> _customTopics = [];

  String get _selectedDateStr {
    if (_selectedDate == null) return 'Sekarang';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = _selectedDate!.day.toString().padLeft(2, '0');
    final month = months[_selectedDate!.month - 1];
    final year = _selectedDate!.year;
    return '$day $month $year';
  }

  Future<void> _selectPublishDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _newTopicCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBright,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outline),
            ),
            child: const Icon(Icons.close, size: 18, color: AppColors.onSurface),
          ),
        ),
        title: Text('Artikel Baru', style: GoogleFonts.sourceSerif4(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              onPressed: _showPublishSheet,
              child: const Text('Terbitkan'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover image area
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outline, width: 1.5,
                            style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.sage,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.add_photo_alternate_outlined,
                                color: AppColors.primary, size: 26),
                          ),
                          const SizedBox(height: 12),
                          Text('Tambah Foto Sampul',
                              style: AppTextStyles.labelLg.copyWith(color: AppColors.primary)),
                          const SizedBox(height: 4),
                          Text('Disarankan 1600 × 840px',
                              style: AppTextStyles.labelSm),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Topic chip selection
                  GestureDetector(
                    onTap: _showTagSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.sage,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.tag_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            _selectedTopic.toUpperCase(),
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title input
                  TextField(
                    controller: _titleCtrl,
                    maxLines: null,
                    style: AppTextStyles.headlineLg.copyWith(fontSize: 26),
                    decoration: InputDecoration(
                      hintText: 'Judul artikel Anda...',
                      hintStyle: AppTextStyles.headlineLg.copyWith(
                          fontSize: 26, color: AppColors.outlineVariant),
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(height: 2, width: 48, color: AppColors.primary),
                  const SizedBox(height: 16),
                  // Author + date chip row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.sage,
                        child: Text('A', style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Text('Amara Prasetya', style: AppTextStyles.labelLg),
                      const SizedBox(width: 8),
                      Text('•', style: AppTextStyles.labelSm),
                      const SizedBox(width: 8),
                       GestureDetector(
                        onTap: _selectPublishDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedDateStr,
                                style: AppTextStyles.labelLg.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.calendar_month_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Reading time estimate
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.sage,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text('~1 mnt baca',
                            style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.primary, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.outline, height: 1),
                  const SizedBox(height: 20),
                  // Body input
                  TextField(
                    controller: _bodyCtrl,
                    maxLines: null,
                    minLines: 12,
                    style: AppTextStyles.bodyLg,
                    decoration: InputDecoration(
                      hintText: 'Mulailah dengan ide pertamamu...\n\nCeritakan sesuatu yang bermakna.',
                      hintStyle: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.outlineVariant, height: 1.7),
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // Formatting toolbar
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceBright,
              border: Border(top: BorderSide(color: AppColors.outline)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _FmtBtn(
                      icon: Icons.format_bold,
                      isActive: _isBold,
                      onTap: () => setState(() => _isBold = !_isBold),
                      tooltip: 'Bold',
                    ),
                    _FmtBtn(
                      icon: Icons.format_italic,
                      isActive: _isItalic,
                      onTap: () => setState(() => _isItalic = !_isItalic),
                      tooltip: 'Italic',
                    ),
                    _FmtBtn(
                      icon: Icons.format_quote_outlined,
                      isActive: _isQuote,
                      onTap: () => setState(() => _isQuote = !_isQuote),
                      tooltip: 'Kutipan',
                    ),
                    _FmtBtn(icon: Icons.format_list_bulleted, onTap: () {}, tooltip: 'List'),
                    _FmtBtn(icon: Icons.link_outlined, onTap: () {}, tooltip: 'Tautan'),
                    _FmtBtn(icon: Icons.image_outlined, onTap: () {}, tooltip: 'Gambar'),
                    const Spacer(),
                    _FmtBtn(icon: Icons.tag_outlined, onTap: _showTagSheet, tooltip: 'Topik'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPublishSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceBright,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: AppColors.outline,
                    borderRadius: BorderRadius.circular(100)))),
            const SizedBox(height: 20),
            Text('Siap Terbitkan?', style: AppTextStyles.headlineSm),
            const SizedBox(height: 8),
            Text('Pastikan artikelmu sudah siap dibaca oleh semua orang.',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context); // Close sheet

                  // Construct and add the article
                  final newArticle = Article(
                    image: 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/450',
                    category: _selectedTopic,
                    title: _titleCtrl.text.trim().isEmpty ? 'Artikel Tanpa Judul' : _titleCtrl.text.trim(),
                    author: 'Amara Prasetya',
                    badge: 'Penulis Pilihan',
                    publishDate: _selectedDateStr,
                    readTime: '5 mnt',
                    isBookmarked: false,
                  );
                  await ArticleRepository.instance.addArticle(newArticle);

                  if (mounted) {
                    context.go('/main');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Artikel berhasil diterbitkan!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.rocket_launch_outlined, size: 18),
                label: const Text('Terbitkan Sekarang'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // close sheet
                  Navigator.pop(context); // close write screen
                  context.go('/main', extra: {'tab': 4, 'draftTab': true});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Artikel disimpan sebagai draft!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Simpan sebagai Draft'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showTagSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final allTopics = [
              'Filsafat', 'Teknologi', 'Sastra', 'Esai', 'Sains',
              'Budaya', 'Sejarah', 'Kesehatan', ..._customTopics
            ];
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              builder: (_, ctrl) => Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBright,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(24),
                child: ListView(
                  controller: ctrl,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outline,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Tambahkan Topik', style: AppTextStyles.headlineSm),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newTopicCtrl,
                            style: AppTextStyles.bodyMd,
                            decoration: const InputDecoration(
                              hintText: 'Tulis topik baru...',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                          ),
                          onPressed: () {
                            final text = _newTopicCtrl.text.trim();
                            if (text.isNotEmpty) {
                              if (!allTopics.any((t) => t.toLowerCase() == text.toLowerCase())) {
                                _customTopics.add(text);
                              }
                              _selectedTopic = text;
                              _newTopicCtrl.clear();
                              Navigator.pop(ctx);
                              setState(() {});
                            }
                          },
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Pilih Topik Terpopuler', style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allTopics.map((t) {
                        final isChosen = _selectedTopic == t;
                        return GestureDetector(
                          onTap: () {
                            _selectedTopic = t;
                            Navigator.pop(ctx);
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isChosen ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: isChosen ? AppColors.primary : AppColors.outline),
                            ),
                            child: Text(
                              t,
                              style: AppTextStyles.labelLg.copyWith(
                                fontSize: 13,
                                color: isChosen ? Colors.white : AppColors.onSurface,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }
}



class _FmtBtn extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const _FmtBtn({
    required this.icon, required this.onTap, required this.tooltip,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36, height: 36,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20,
              color: isActive ? Colors.white : AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}
