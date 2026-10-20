import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';
import '../theme/app_themes.dart';

class RegisterView extends StatefulWidget {
  final Function(String name, String email, String? avatarUrl) onRegisterSuccess;
  final VoidCallback onNavigateLogin;
  final ThemeItem theme;

  const RegisterView({
    super.key,
    required this.onRegisterSuccess,
    required this.onNavigateLogin,
    required this.theme,
  });

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _recoveryController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _recoveryController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final recoveryHint = _recoveryController.text.trim();

    if (username.isEmpty) {
      _showError("Silakan masukkan username");
      return;
    }

    if (email.isEmpty) {
      _showError("Silakan masukkan alamat email");
      return;
    }

    // Password validation: minimum 6 digits
    if (password.length < 6) {
      _showError("Kata sandi harus minimal 6 digit!");
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await FirebaseAuthService.registerWithEmail(
      username: username,
      email: email,
      password: password,
      recoveryHint: recoveryHint,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      widget.onRegisterSuccess(
        result.name ?? username,
        result.email ?? email,
        result.avatarUrl,
      );
    } else {
      _showError(result.errorMessage ?? "Pendaftaran gagal. Silakan coba lagi.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppThemes.font(fontSize: 13, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pageBgColor = Color(0xFFEDEDED);

    return Scaffold(
      backgroundColor: pageBgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Center Big App Title "JUST JEJE" with Shadow
                  Text(
                    "JUST JEJE",
                    textAlign: TextAlign.center,
                    style: AppThemes.font(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF000000),
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Main Register Floating White Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tulisan REGISTER di dalam card dengan Shadow
                        Text(
                          "REGISTER",
                          textAlign: TextAlign.center,
                          style: AppThemes.font(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF111827),
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Form Username
                        Text(
                          "Username",
                          style: AppThemes.font(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.next,
                          style: AppThemes.font(fontSize: 14, color: const Color(0xFF111827)),
                          decoration: InputDecoration(
                            hintText: "yourname",
                            hintStyle: AppThemes.font(fontSize: 13.5, color: const Color(0xFF9CA3AF)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Form Email
                        Text(
                          "Alamat Email",
                          style: AppThemes.font(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: AppThemes.font(fontSize: 14, color: const Color(0xFF111827)),
                          decoration: InputDecoration(
                            hintText: "email@todolist.com",
                            hintStyle: AppThemes.font(fontSize: 13.5, color: const Color(0xFF9CA3AF)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Form Password (Minimal 6 digit)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Kata Sandi",
                              style: AppThemes.font(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              "harus 6 digit",
                              style: AppThemes.font(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          style: AppThemes.font(fontSize: 14, color: const Color(0xFF111827)),
                          decoration: InputDecoration(
                            hintText: "******",
                            hintStyle: AppThemes.font(fontSize: 14, color: const Color(0xFF9CA3AF), letterSpacing: 2.0),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 19,
                                color: const Color(0xFF9CA3AF),
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Form Forgot Password
                        Text(
                          "Forgot Password",
                          style: AppThemes.font(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _recoveryController,
                          textInputAction: TextInputAction.done,
                          style: AppThemes.font(fontSize: 14, color: const Color(0xFF111827)),
                          decoration: InputDecoration(
                            hintText: "Petunjuk pemulihan / recovery hint",
                            hintStyle: AppThemes.font(fontSize: 13, color: const Color(0xFF9CA3AF)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5),
                            ),
                          ),
                          onSubmitted: (_) => _handleRegister(),
                        ),

                        const SizedBox(height: 26),

                        // Button "REGISTER" warna hitam
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF000000),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isSubmitting ? null : _handleRegister,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "REGISTER",
                                    style: AppThemes.font(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Teks dibawah & di luar card: Already have an account? Login here
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          "Already have an account? ",
                          style: AppThemes.font(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onNavigateLogin,
                        child: Text(
                          "Login here",
                          style: AppThemes.font(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
