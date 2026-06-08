import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _profesiCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _profesiCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Progress indicator
                Row(
                  children: [
                    Expanded(child: Container(height: 3,
                        decoration: BoxDecoration(color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(width: 4),
                    Expanded(child: Container(height: 3,
                        decoration: BoxDecoration(color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(width: 4),
                    Expanded(child: Container(height: 3,
                        decoration: BoxDecoration(color: AppColors.outline,
                            borderRadius: BorderRadius.circular(2)))),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Langkah 2 dari 3', style: AppTextStyles.labelSm),
                ),
                const SizedBox(height: 32),
                Text('Lengkapi Profil Anda', style: AppTextStyles.headlineLg,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Mari mulai dengan perkenalan singkat untuk membangun ruang menulismu.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Avatar upload
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outline, width: 2),
                      ),
                      child: const Icon(Icons.person_outline,
                          color: AppColors.secondary, size: 44),
                    ),
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Unggah Foto',
                    style: AppTextStyles.labelLg.copyWith(color: AppColors.primary)),
                const SizedBox(height: 32),
                // Name field
                _buildField(
                  label: 'Nama Lengkap',
                  controller: _nameCtrl,
                  hint: 'Masukkan nama lengkap Anda',
                  icon: Icons.person_outline,
                  validator: (v) => (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 20),
                _buildField(
                  label: 'Profesi',
                  controller: _profesiCtrl,
                  hint: 'Penulis, Editor, dll.',
                  icon: Icons.work_outline,
                ),
                const SizedBox(height: 20),
                // Bio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bio Singkat', style: AppTextStyles.labelLg),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _bioCtrl,
                      maxLines: 4,
                      style: AppTextStyles.bodyMd,
                      decoration: const InputDecoration(
                        hintText: 'Ceritakan sedikit tentang diri Anda dan ketertarikan Anda dalam menulis...',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Selesai & Mulai Menulis'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLg),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: AppTextStyles.bodyMd,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
