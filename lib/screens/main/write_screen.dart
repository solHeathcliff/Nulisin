import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_quill/markdown_quill.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';

class WriteScreen extends StatefulWidget {
  final ArticleModel? editArticle;
  const WriteScreen({super.key, this.editArticle});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final _titleCtrl = TextEditingController();
  late final QuillController _controller;
  final _newTopicCtrl = TextEditingController();
  final _editorFocusNode = FocusNode();
  DateTime? _selectedDate;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  List<CategoryModel> _categories = [];
  bool _isPublishing = false;
  bool _isPreviewMode = false;

  XFile? _pickedImageFile;
  Uint8List? _webImageBytes;
  String? _existingCoverUrl;

  Future<void> _pickCoverImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            _pickedImageFile = picked;
            _webImageBytes = bytes;
          });
        } else {
          setState(() {
            _pickedImageFile = picked;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking cover image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

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

  @override
  void initState() {
    super.initState();
    _loadCategories();

    final content = widget.editArticle?.content ?? '';
    Delta delta;
    if (content.isNotEmpty) {
      try {
        delta = MarkdownToDelta(markdownDocument: md.Document(encodeHtml: false)).convert(content);
      } catch (e) {
        debugPrint('Error converting markdown to delta: $e');
        delta = Delta()..insert('$content\n');
      }
    } else {
      delta = Delta()..insert('\n');
    }

    _controller = QuillController(
      document: Document.fromDelta(delta),
      selection: const TextSelection.collapsed(offset: 0),
      config: const QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: false,
        ),
      ),
    );

    if (widget.editArticle != null) {
      _titleCtrl.text = widget.editArticle!.title;
      _existingCoverUrl = widget.editArticle!.coverImageUrl;
      _selectedDate = widget.editArticle!.createdAt;
    }
  }

  Future<void> _loadCategories() async {
    final cats = await SupabaseService.instance.getCategories();
    if (mounted && cats.isNotEmpty) {
      setState(() {
        _categories = cats;
        if (widget.editArticle != null) {
          final artCats = widget.editArticle!.categories;
          if (artCats.isNotEmpty) {
            _selectedCategoryId = artCats.first.id;
            _selectedCategoryName = artCats.first.name;
          }
        }
      });
    }
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
            colorScheme: const ColorScheme.light(
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
    _controller.dispose();
    _newTopicCtrl.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _toggleH1() {
    final currentAttributes = _controller.getSelectionStyle().attributes;
    final isH1 = currentAttributes['header']?.value == 1;
    _controller.formatSelection(isH1 ? Attribute.clone(Attribute.h1, null) : Attribute.h1);
  }

  void _toggleH2() {
    final currentAttributes = _controller.getSelectionStyle().attributes;
    final isH2 = currentAttributes['header']?.value == 2;
    _controller.formatSelection(isH2 ? Attribute.clone(Attribute.h2, null) : Attribute.h2);
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Artikel', style: GoogleFonts.sourceSerif4(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus artikel/draft ini secara permanen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.hankenGrotesk(color: AppColors.secondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: GoogleFonts.hankenGrotesk(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await SupabaseService.instance.deleteArticle(widget.editArticle!.id);
        if (mounted) {
          context.go('/main', extra: {'tab': 0}); // Redirect ke halaman Beranda/Home
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Artikel berhasil dihapus'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  String _getBodyMarkdown() {
    final delta = _controller.document.toDelta();
    return DeltaToMarkdown().convert(delta);
  }

  Future<void> _pickInlineImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        if (!mounted) return;
        final authorCtrl = TextEditingController();
        final linkCtrl = TextEditingController();

        String selectedSize = 'normal';
        final details = await showDialog<Map<String, String>>(
          context: context,
          builder: (ctx) => StatefulBuilder(
            builder: (ctx, setStateDialog) => AlertDialog(
              title: Text('Pengaturan Gambar', style: GoogleFonts.sourceSerif4(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: authorCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Fotografer / Kreator (Opsional)',
                        hintText: 'Misal: John Doe',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: linkCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Link Sumber Foto (Opsional)',
                        hintText: 'https://example.com/photo',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedSize,
                      decoration: const InputDecoration(
                        labelText: 'Ukuran Tampilan Gambar',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'small',
                          child: Text('Kecil (Inline / Kiri)'),
                        ),
                        DropdownMenuItem(
                          value: 'normal',
                          child: Text('Sedang (Lebar Kolom)'),
                        ),
                        DropdownMenuItem(
                          value: 'wide',
                          child: Text('Lebar (Out-bleed)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            selectedSize = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, {'author': '', 'link': '', 'size': 'normal'}),
                  child: Text('Lewati', style: GoogleFonts.hankenGrotesk(color: AppColors.secondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx, {
                      'author': authorCtrl.text.trim(),
                      'link': linkCtrl.text.trim(),
                      'size': selectedSize,
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Terapkan'),
                ),
              ],
            ),
          ),
        );

        if (!mounted) {
          authorCtrl.dispose();
          linkCtrl.dispose();
          return;
        }

        final author = details?['author'] ?? '';
        final link = details?['link'] ?? '';
        final size = details?['size'] ?? 'normal';
        
        authorCtrl.dispose();
        linkCtrl.dispose();

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  SizedBox(width: 16),
                  Text('Mengunggah gambar...'),
                ],
              ),
              duration: Duration(days: 1),
            ),
          );
        }
        
        final String? imageUrl;
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          if (!mounted) return;
          imageUrl = await SupabaseService.instance.uploadArticleImage(bytes);
        } else {
          imageUrl = await SupabaseService.instance.uploadArticleImage(File(picked.path));
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();

        if (imageUrl != null) {
          final index = _controller.selection.baseOffset;
          
          // Insert the image BlockEmbed with size format fragment
          final imageSource = '$imageUrl#$size';
          _controller.replaceText(
            index,
            0,
            BlockEmbed.image(imageSource),
            TextSelection.collapsed(offset: index + 1),
          );

          // Insert custom caption right below if provided
          if (author.isNotEmpty || link.isNotEmpty) {
            String caption = '\n';
            if (author.isNotEmpty && link.isNotEmpty) {
              caption += '[$author]($link)\n\n';
            } else if (author.isNotEmpty) {
              caption += '$author\n\n';
            } else {
              caption += '[$link]($link)\n\n';
            }
            _controller.document.insert(index + 1, caption);
            _controller.formatText(index + 2, caption.length - 2, Attribute.italic);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gambar berhasil disematkan!'), behavior: SnackBarBehavior.floating),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal mengunggah gambar.'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking inline image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _showPublishSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setSheet) => Container(
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
                  onPressed: _isPublishing ? null : () async {
                    setSheet(() => _isPublishing = true);
                    try {
                      final bodyText = _getBodyMarkdown();
                      final ArticleModel article;
                      if (widget.editArticle != null) {
                        article = await SupabaseService.instance.updateArticle(
                          articleId: widget.editArticle!.id,
                          title: _titleCtrl.text.trim().isEmpty
                              ? 'Artikel Tanpa Judul'
                              : _titleCtrl.text.trim(),
                          content: bodyText.trim().isEmpty ? '...' : bodyText.trim(),
                          isPublished: true,
                          clearCoverImage: _existingCoverUrl == null && _pickedImageFile == null,
                          categoryIds: _selectedCategoryId != null ? [_selectedCategoryId!] : [],
                        );
                      } else {
                        article = await SupabaseService.instance.createArticle(
                          title: _titleCtrl.text.trim().isEmpty
                              ? 'Artikel Tanpa Judul'
                              : _titleCtrl.text.trim(),
                          content: bodyText.trim().isEmpty ? '...' : bodyText.trim(),
                          isPublished: true,
                          categoryIds: _selectedCategoryId != null ? [_selectedCategoryId!] : [],
                        );
                      }

                      if (_pickedImageFile != null) {
                        final fileData = kIsWeb ? _webImageBytes : File(_pickedImageFile!.path);
                        final coverUrl = await SupabaseService.instance.uploadCoverImage(
                          article.id,
                          fileData,
                        );
                        if (coverUrl != null) {
                          await SupabaseService.instance.updateArticle(
                            articleId: article.id,
                            coverImageUrl: coverUrl,
                          );
                        }
                      }

                      if (context.mounted) {
                        Navigator.pop(context); // Tutup bottom sheet
                        Navigator.pop(context); // Tutup halaman menulis (WriteScreen)
                        context.go('/main', extra: {'tab': 4, 'draftTab': false}); // Redirect ke Profil cerita
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Artikel berhasil diterbitkan!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      setSheet(() => _isPublishing = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menerbitkan: $e'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  icon: _isPublishing
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.rocket_launch_outlined, size: 18),
                  label: const Text('Terbitkan Sekarang'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isPublishing ? null : () async {
                    setSheet(() => _isPublishing = true);
                    try {
                      final bodyText = _getBodyMarkdown();
                      final ArticleModel article;
                      if (widget.editArticle != null) {
                        article = await SupabaseService.instance.updateArticle(
                          articleId: widget.editArticle!.id,
                          title: _titleCtrl.text.trim().isEmpty
                              ? 'Draft Tanpa Judul'
                              : _titleCtrl.text.trim(),
                          content: bodyText.trim().isEmpty ? '...' : bodyText.trim(),
                          isPublished: false,
                          clearCoverImage: _existingCoverUrl == null && _pickedImageFile == null,
                          categoryIds: _selectedCategoryId != null ? [_selectedCategoryId!] : [],
                        );
                      } else {
                        article = await SupabaseService.instance.createArticle(
                          title: _titleCtrl.text.trim().isEmpty
                              ? 'Draft Tanpa Judul'
                              : _titleCtrl.text.trim(),
                          content: bodyText.trim().isEmpty ? '...' : bodyText.trim(),
                          isPublished: false,
                          categoryIds: _selectedCategoryId != null ? [_selectedCategoryId!] : [],
                        );
                      }

                      if (_pickedImageFile != null) {
                        final fileData = kIsWeb ? _webImageBytes : File(_pickedImageFile!.path);
                        final coverUrl = await SupabaseService.instance.uploadCoverImage(
                          article.id,
                          fileData,
                        );
                        if (coverUrl != null) {
                          await SupabaseService.instance.updateArticle(
                            articleId: article.id,
                            coverImageUrl: coverUrl,
                          );
                        }
                      }

                      if (context.mounted) {
                        Navigator.pop(context); // Tutup bottom sheet
                        Navigator.pop(context); // Tutup halaman menulis (WriteScreen)
                        context.go('/main', extra: {'tab': 4, 'draftTab': true}); // Redirect ke Profil draf
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Artikel disimpan sebagai draft!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      setSheet(() => _isPublishing = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menyimpan draft: $e'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Simpan sebagai Draft'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
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
        bool isCreating = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              maxChildSize: 0.9,
              builder: (_, ctrl) => Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBright,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outline,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Pilih Topik', style: AppTextStyles.headlineSm),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newTopicCtrl,
                            style: AppTextStyles.bodyLg,
                            decoration: InputDecoration(
                              hintText: 'Tambah topik baru...',
                              hintStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.outlineVariant),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: isCreating ? null : () async {
                            final text = _newTopicCtrl.text.trim();
                            if (text.isEmpty) return;
                            setSheetState(() => isCreating = true);
                            try {
                              final newCat = await SupabaseService.instance.createCategory(name: text);
                              await _loadCategories();
                              setState(() {
                                _selectedCategoryId = newCat.id;
                                _selectedCategoryName = newCat.name;
                              });
                              _newTopicCtrl.clear();
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Topik "$text" berhasil ditambahkan dan dipilih!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal menambah topik: $e'),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } finally {
                              setSheetState(() => isCreating = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isCreating
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.outline, height: 1),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _categories.isEmpty
                          ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                          : ListView(
                              controller: ctrl,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _categories.map((cat) {
                                    final isChosen = _selectedCategoryId == cat.id;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedCategoryId = cat.id;
                                          _selectedCategoryName = cat.name;
                                        });
                                        Navigator.pop(ctx);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isChosen ? AppColors.primary : AppColors.surface,
                                          borderRadius: BorderRadius.circular(100),
                                          border: Border.all(
                                              color: isChosen ? AppColors.primary : AppColors.outline),
                                        ),
                                        child: Text(
                                          cat.name,
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTextStyles.labelLg.copyWith(
                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          if (_pickedImageFile != null || _existingCoverUrl != null)
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: _pickedImageFile != null
                  ? (kIsWeb
                      ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                      : Image.file(File(_pickedImageFile!.path), fit: BoxFit.cover))
                  : CachedNetworkImage(
                      imageUrl: _existingCoverUrl!,
                      fit: BoxFit.cover,
                    ),
            ),
          // Category Chip
          if (_selectedCategoryName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sage,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                _selectedCategoryName!.toUpperCase(),
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Title
          Text(
            _titleCtrl.text.isEmpty ? 'Judul Artikel' : _titleCtrl.text,
            style: GoogleFonts.newsreader(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          // Author & Date Row
          ValueListenableBuilder<ProfileModel?>(
            valueListenable: SupabaseService.instance.profileNotifier,
            builder: (context, profile, _) {
              final name = profile?.fullName ?? 'Penulis';
              final avatarUrl = profile?.avatarUrl;
              final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.sage,
                    backgroundImage: avatarUrl != null
                        ? CachedNetworkImageProvider(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? Text(initial,
                            style: AppTextStyles.labelLg.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700))
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.w600)),
                      if (profile?.profession?.isNotEmpty == true)
                        Text(profile!.profession!,
                            style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_selectedDateStr,
                          style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant)),
                      Text('~1 mnt baca',
                          style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.outline),
          const SizedBox(height: 24),
          // Body content Markdown
          MarkdownBody(
            data: _getBodyMarkdown(),
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              textAlign: WrapAlignment.spaceAround,
              p: GoogleFonts.newsreader(
                fontSize: 18,
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
        ],
      ),
    );
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
        title: Text(widget.editArticle != null ? 'Edit Artikel' : 'Artikel Baru', style: GoogleFonts.sourceSerif4(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        actions: [
          if (widget.editArticle != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _confirmDelete,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              onPressed: _showPublishSheet,
              child: Text(widget.editArticle != null ? 'Simpan' : 'Terbitkan'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surfaceBright,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _buildTabButton(
                  title: 'Tulis',
                  isActive: !_isPreviewMode,
                  icon: Icons.edit_outlined,
                  onTap: () => setState(() => _isPreviewMode = false),
                ),
                const SizedBox(width: 8),
                _buildTabButton(
                  title: 'Pratinjau',
                  isActive: _isPreviewMode,
                  icon: Icons.visibility_outlined,
                  onTap: () => setState(() => _isPreviewMode = true),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outline),
          Expanded(
            child: _isPreviewMode
                ? _buildPreview()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cover image area
                        GestureDetector(
                          onTap: _pickCoverImage,
                          child: Container(
                            width: double.infinity,
                            height: 180,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.outline, width: 1.5,
                                  style: BorderStyle.solid),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _pickedImageFile != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      kIsWeb
                                          ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                                          : Image.file(File(_pickedImageFile!.path), fit: BoxFit.cover),
                                      Container(
                                        color: Colors.black.withOpacity(0.35),
                                      ),
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Ubah Foto Sampul',
                                                style: AppTextStyles.labelLg.copyWith(color: Colors.white, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _pickedImageFile = null;
                                              _webImageBytes = null;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : (_existingCoverUrl != null
                                    ? Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: _existingCoverUrl!,
                                            fit: BoxFit.cover,
                                          ),
                                          Container(
                                            color: Colors.black.withOpacity(0.35),
                                          ),
                                          Center(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.5),
                                                borderRadius: BorderRadius.circular(100),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Ubah Foto Sampul',
                                                    style: AppTextStyles.labelLg.copyWith(color: Colors.white, fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 12,
                                            right: 12,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _existingCoverUrl = null;
                                                });
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
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
                                      )),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Topic chip selection
                        GestureDetector(
                          onTap: _showTagSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _selectedCategoryName == null ? Colors.transparent : AppColors.sage,
                              borderRadius: BorderRadius.circular(100),
                              border: _selectedCategoryName == null
                                  ? Border.all(color: AppColors.primary)
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _selectedCategoryName == null ? Icons.add : Icons.tag_outlined,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  (_selectedCategoryName ?? 'Tambah Topik').toUpperCase(),
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
                            ValueListenableBuilder<ProfileModel?>(
                              valueListenable: SupabaseService.instance.profileNotifier,
                              builder: (context, profile, _) {
                                final name = profile?.fullName ?? 'Penulis';
                                final avatarUrl = profile?.avatarUrl;
                                final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.sage,
                                      backgroundImage: avatarUrl != null
                                          ? CachedNetworkImageProvider(avatarUrl)
                                          : null,
                                      child: avatarUrl == null
                                          ? Text(initial,
                                              style: AppTextStyles.labelSm.copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w700))
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(name, style: AppTextStyles.labelLg),
                                  ],
                                );
                              },
                            ),
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
                        // Body input with QuillEditor inside a styled writing pad card
                        GestureDetector(
                          onTap: () => _editorFocusNode.requestFocus(),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 300),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.outline,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: QuillEditor.basic(
                              controller: _controller,
                              focusNode: _editorFocusNode,
                              config: QuillEditorConfig(
                                placeholder: 'Mulailah dengan ide pertamamu... Tuliskan gagasan hebatmu.',
                                autoFocus: false,
                                expands: false,
                                padding: EdgeInsets.zero,
                                scrollable: false,
                                embedBuilders: kIsWeb 
                                    ? FlutterQuillEmbeds.editorWebBuilders() 
                                    : FlutterQuillEmbeds.editorBuilders(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
          ),
          // Formatting toolbar
          if (!_isPreviewMode)
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surfaceBright,
                border: Border(top: BorderSide(color: AppColors.outline)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: QuillSimpleToolbar(
                          controller: _controller,
                          config: QuillSimpleToolbarConfig(
                            showBoldButton: true,
                            showItalicButton: true,
                            showQuote: true,
                            showListBullets: true,
                            showLink: false,
                            showInlineCode: false,
                            // Turn off everything else to make it super clean and match standard styling
                            showUnderLineButton: false,
                            showStrikeThrough: false,
                            showColorButton: false,
                            showBackgroundColorButton: false,
                            showClearFormat: false,
                            showAlignmentButtons: false,
                            showHeaderStyle: false,
                            showListNumbers: false,
                            showListCheck: false,
                            showCodeBlock: false,
                            showIndent: false,
                            showDirection: false,
                            showSearchButton: false,
                            showSubscript: false,
                            showSuperscript: false,
                            showFontFamily: false,
                            showFontSize: false,
                            showUndo: false,
                            showRedo: false,
                            multiRowsDisplay: false,
                            showDividers: false,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Medium-style Large T & Small T buttons
                      ListenableBuilder(
                        listenable: _controller,
                        builder: (context, _) {
                          final currentAttributes = _controller.getSelectionStyle().attributes;
                          final isH1 = currentAttributes['header']?.value == 1;
                          final isH2 = currentAttributes['header']?.value == 2;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Tooltip(
                                message: 'Judul Besar',
                                child: InkWell(
                                  onTap: _toggleH1,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    child: Text(
                                      'T',
                                      style: GoogleFonts.sourceSerif4(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isH1 ? AppColors.primary : AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Tooltip(
                                message: 'Subjudul',
                                child: InkWell(
                                  onTap: _toggleH2,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    child: Text(
                                      'T',
                                      style: GoogleFonts.sourceSerif4(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isH2 ? AppColors.primary : AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      // Custom image button to upload to Supabase and insert as BlockEmbed.image
                      Tooltip(
                        message: 'Gambar',
                        child: InkWell(
                          onTap: _pickInlineImage,
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.image_outlined,
                              color: AppColors.onSurfaceVariant,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
