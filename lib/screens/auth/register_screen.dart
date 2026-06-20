import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    String emailVal = _emailCtrl.text.trim();
    if (emailVal.isNotEmpty && !emailVal.contains('@')) {
      emailVal = '$emailVal@gmail.com';
      _emailCtrl.text = emailVal;
    }

    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMsg = null; });

    try {
      // Gunakan bagian depan email sebagai nama sementara
      final tempName = emailVal.split('@').first;
      await SupabaseService.instance.signUp(
        email: emailVal,
        password: _passCtrl.text,
        fullName: tempName,
      );
      if (mounted) context.push('/complete-profile');
    } catch (e) {
      setState(() => _errorMsg = SupabaseService.mapException(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/');
                          }
                        },
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: const Icon(Icons.arrow_back, size: 20),
                        ),
                      ),
                    const Expanded(
                      child: Center(
                        child: Text('Nulisin',
                          style: TextStyle(
                            fontFamily: 'SourceSerif4',
                            fontSize: 22, fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(width: 38),
                  ],
                ),
                const SizedBox(height: 40),
                Text('Buat Akun Anda', style: AppTextStyles.headlineLg),
                const SizedBox(height: 8),
                Text(
                  'Langkah pertama untuk memulai perjalanan menulis Anda.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 36),
                _FieldLabel('Email'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.bodyMd,
                  onChanged: (v) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'nama_pengguna',
                    suffixText: _emailCtrl.text.contains('@') ? null : '@gmail.com',
                    suffixStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    prefixIcon: const Icon(Icons.mail_outline, color: AppColors.secondary, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                    if (v.contains('@') && !v.contains('.')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _FieldLabel('Password'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  style: AppTextStyles.bodyMd,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.secondary, size: 20),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscurePass = !_obscurePass),
                      child: Icon(_obscurePass
                          ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.secondary, size: 20),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                    if (v.length < 8) return 'Password minimal 8 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _FieldLabel('Konfirmasi Password'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  style: AppTextStyles.bodyMd,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.secondary, size: 20),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      child: Icon(_obscureConfirm
                          ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.secondary, size: 20),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                    if (v != _passCtrl.text) return 'Password tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 36),
                if (_errorMsg != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_errorMsg!,
                              style: AppTextStyles.labelLg.copyWith(
                                  color: AppColors.error, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
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
                              Text('Lanjutkan'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sudah punya akun? ',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text('Masuk',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.primary, fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    ),);
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurface));
}
