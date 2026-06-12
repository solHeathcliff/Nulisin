import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _profesiCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _isSaving = false;
  bool _isLoading = true;

  XFile? _avatarFile;
  Uint8List? _avatarWebBytes;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) return;
    final profile = await SupabaseService.instance.getProfile(userId);
    if (mounted && profile != null) {
      setState(() {
        _nameCtrl.text = profile.fullName;
        _profesiCtrl.text = profile.profession ?? '';
        _bioCtrl.text = profile.bio ?? '';
        _currentAvatarUrl = profile.avatarUrl;
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            _avatarFile = picked;
            _avatarWebBytes = bytes;
          });
        } else {
          setState(() {
            _avatarFile = picked;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking avatar: $e');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _profesiCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final userId = SupabaseService.instance.currentUser!.id;

      String? avatarUrl = _currentAvatarUrl;
      if (_avatarFile != null) {
        final uploadResult = await SupabaseService.instance.uploadAvatar(
          userId,
          kIsWeb ? _avatarWebBytes : File(_avatarFile!.path),
        );
        if (uploadResult != null) {
          avatarUrl = uploadResult;
        }
      }

      await SupabaseService.instance.upsertProfile(
        userId: userId,
        fullName: _nameCtrl.text.trim(),
        profession: _profesiCtrl.text.trim().isEmpty ? null : _profesiCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        avatarUrl: avatarUrl,
      );
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil berhasil diperbarui',
                style: GoogleFonts.hankenGrotesk(fontSize: 14)),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan. Coba lagi.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceBright,
        title: Text('Hapus Akun?', style: GoogleFonts.sourceSerif4(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 20)),
        content: Text('Apakah Anda yakin ingin menghapus akun ini secara permanen? Semua data dan artikel Anda akan hilang dan tidak dapat dipulihkan.', style: GoogleFonts.hankenGrotesk(fontSize: 15, color: AppColors.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await SupabaseService.instance.deleteCurrentUser();
        if (mounted) context.go('/');
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus akun: $e',
                  style: GoogleFonts.hankenGrotesk(fontSize: 14)),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBright,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Edit Profil',
            style: GoogleFonts.sourceSerif4(
                fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                  : Text('Simpan',
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar section
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.sage,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.outline, width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _avatarFile != null
                            ? (kIsWeb
                                ? Image.memory(_avatarWebBytes!, fit: BoxFit.cover)
                                : Image.file(File(_avatarFile!.path), fit: BoxFit.cover))
                            : (_currentAvatarUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: _currentAvatarUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2)),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  )
                                : Center(
                                    child: Text(
                                        _nameCtrl.text.isNotEmpty
                                            ? _nameCtrl.text[0].toUpperCase()
                                            : '?',
                                        style: GoogleFonts.sourceSerif4(
                                            fontSize: 40,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary)),
                                  )),
                      ),
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.background, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Ganti Foto',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Divider label
              _SectionLabel('Informasi Dasar'),
              const SizedBox(height: 16),

              // Name field
              _FieldLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.hankenGrotesk(fontSize: 15, color: AppColors.onSurface),
                decoration: const InputDecoration(
                  hintText: 'Masukkan nama lengkap',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nama tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Profesi field
              _FieldLabel('Profesi / Tagline'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _profesiCtrl,
                style: GoogleFonts.hankenGrotesk(fontSize: 15, color: AppColors.onSurface),
                decoration: const InputDecoration(
                  hintText: 'cth. Penulis & Esais',
                  prefixIcon: Icon(Icons.work_outline_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              // Bio field
              _FieldLabel('Bio'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioCtrl,
                maxLines: 4,
                maxLength: 200,
                style: GoogleFonts.hankenGrotesk(fontSize: 15, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Ceritakan sedikit tentang dirimu...',
                  alignLabelWithHint: true,
                  counterStyle: GoogleFonts.hankenGrotesk(
                      fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
                validator: (v) {
                  if (v != null && v.length > 200) {
                    return 'Bio tidak boleh lebih dari 200 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),



              // Save button (bottom)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan Perubahan'),
                ),
              ),
              const SizedBox(height: 16),
              // Delete Account button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _deleteAccount,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                  ),
                  child: const Text('Hapus Akun'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(text,
              style: GoogleFonts.hankenGrotesk(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  letterSpacing: 1.0, color: AppColors.onSurfaceVariant)),
          const SizedBox(width: 12),
          const Expanded(child: Divider(color: AppColors.outline)),
        ],
      );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.hankenGrotesk(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface));
}
