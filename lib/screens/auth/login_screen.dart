import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../core/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
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
      await SupabaseService.instance.signIn(
        email: emailVal,
        password: _passCtrl.text,
      );
      if (mounted) context.go('/main');
    } on AuthException catch (e) {
      setState(() {
        _errorMsg = _mapAuthError(e.message);
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Terjadi kesalahan. Silakan coba lagi.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapAuthError(String msg) {
    if (msg.contains('Invalid login credentials')) return 'Email atau kata sandi salah.';
    if (msg.contains('Email not confirmed')) return 'Email belum dikonfirmasi. Cek inbox Anda.';
    if (msg.contains('Too many requests')) return 'Terlalu banyak percobaan. Tunggu sebentar.';
    return msg;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Top bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: const Icon(Icons.arrow_back, size: 20, color: AppColors.onSurface),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: _AppLogo(),
                      ),
                    ),
                    const SizedBox(width: 38),
                  ],
                ),
                const SizedBox(height: 40),
                // Header
                Text('Selamat Datang\nKembali', style: AppTextStyles.headlineLg),
                const SizedBox(height: 8),
                Text(
                  'Ruang tenang untuk karya panjang Anda.\nSilakan masuk untuk melanjutkan.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 36),
                // Email field
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
                // Password field
                _FieldLabel('Kata Sandi'),
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
                      child: Icon(
                        _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.secondary, size: 20,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Kata sandi tidak boleh kosong';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text('Lupa kata sandi?',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.onSurfaceVariant,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.outlineVariant,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
                if (_errorMsg != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                const SizedBox(height: 32),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Masuk'),
                  ),

                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Belum punya akun? ',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text('Daftar',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurface));
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();
  @override
  Widget build(BuildContext context) {
    return Text('Nulisin',
        style: GoogleFonts.sourceSerif4(
          fontSize: 22, fontWeight: FontWeight.w700,
          color: AppColors.primary, letterSpacing: -0.5));
  }
}
