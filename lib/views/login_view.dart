import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_themes.dart';

class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final center = Offset(s / 2, s / 2);
    final radius = s * 0.38;
    final strokeWidth = s * 0.19;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Red (top arc)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -math.pi * 0.78, math.pi * 0.54, false, paint);

    // Yellow (left arc)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -math.pi * 1.30, math.pi * 0.54, false, paint);

    // Green (bottom arc)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, math.pi * 0.22, math.pi * 0.54, false, paint);

    // Blue (right arc)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -math.pi * 0.25, math.pi * 0.48, false, paint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          center.dx - s * 0.05,
          center.dy - strokeWidth / 2,
          center.dx + radius + strokeWidth / 2,
          center.dy + strokeWidth / 2,
        ),
        Radius.circular(s * 0.06),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoginView extends StatefulWidget {
  final Function(String name, String email, String? avatarUrl) onLoginSuccess;
  final ThemeItem theme;

  const LoginView({
    super.key,
    required this.onLoginSuccess,
    required this.theme,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _formatNameFromEmail(String email) {
    final clean = email.trim();
    if (!clean.contains("@")) return clean.isEmpty ? "Username" : clean;
    final prefix = clean.split("@").first;
    final parts = prefix.split(RegExp(r'[._-]+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return "Username";
    return parts.map((p) => p[0].toUpperCase() + (p.length > 1 ? p.substring(1) : "")).join(" ");
  }

  void _handleEmailLogin() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Silakan masukkan alamat email", style: AppThemes.font(fontSize: 13)),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final name = _formatNameFromEmail(email);
    // Generate an avatar picture URL based on the user's name/email
    final avatarUrl = "https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=1e88e5&color=fff&size=256";

    widget.onLoginSuccess(name, email, avatarUrl);
  }

  void _handleGoogleLogin() {
    const googleName = "Jeihan Maharani";
    const googleEmail = "jeihanm@gmail.com";
    const googleAvatarUrl = "https://ui-avatars.com/api/?name=Jeihan+Maharani&background=ea4335&color=fff&size=256";

    widget.onLoginSuccess(googleName, googleEmail, googleAvatarUrl);
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Lupa Kata Sandi?", style: AppThemes.font(fontWeight: FontWeight.bold)),
        content: Text(
          "Tautan untuk mereset kata sandi akan dikirim ke alamat email Anda. Pastikan email yang dimasukkan sudah benar.",
          style: AppThemes.font(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Instruksi reset kata sandi telah dikirim!", style: AppThemes.font(fontSize: 13)),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Kirim Tautan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Background color matching the design: subtle creamy grey #EFEFEF
    const pageBgColor = Color(0xFFEDEDED);

    return Scaffold(
      backgroundColor: pageBgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Bar Row (09:41, Cellular, Battery) matching the design
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "09:41",
                          style: AppThemes.font(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Row(
                          children: [
                            // Signal bars icon
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(width: 2.5, height: 5, color: const Color(0xFF111827), margin: const EdgeInsets.symmetric(horizontal: 1)),
                                Container(width: 2.5, height: 8, color: const Color(0xFF111827), margin: const EdgeInsets.symmetric(horizontal: 1)),
                                Container(width: 2.5, height: 11, color: const Color(0xFF111827), margin: const EdgeInsets.symmetric(horizontal: 1)),
                                Container(width: 2.5, height: 14, color: const Color(0xFF111827), margin: const EdgeInsets.symmetric(horizontal: 1)),
                              ],
                            ),
                            const SizedBox(width: 6),
                            // Battery icon
                            Container(
                              width: 22,
                              height: 11.5,
                              padding: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF111827), width: 1.4),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111827),
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 38),

                  // Center Big App Title "JUST JEJE"
                  Text(
                    "JUST JEJE",
                    textAlign: TextAlign.center,
                    style: AppThemes.font(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF000000),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Main Login Floating White Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
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
                        // Label: Alamat Email
                        Text(
                          "Alamat Email",
                          style: AppThemes.font(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Input Email
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: AppThemes.font(fontSize: 14, color: const Color(0xFF111827)),
                          decoration: InputDecoration(
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

                        const SizedBox(height: 18),

                        // Label Kata Sandi & Lupa Kata Sandi row
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
                            GestureDetector(
                              onTap: _handleForgotPassword,
                              child: Text(
                                "lupa kata sandi?",
                                style: AppThemes.font(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Input Kata Sandi
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: AppThemes.font(fontSize: 14, color: const Color(0xFF111827)),
                          decoration: InputDecoration(
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
                          onSubmitted: (_) => _handleEmailLogin(),
                        ),

                        const SizedBox(height: 24),

                        // LOGIN Button (Solid Black with Rounded Corners)
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
                            onPressed: _handleEmailLogin,
                            child: Text(
                              "LOGIN",
                              style: AppThemes.font(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Divider with text "atau"
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: Color(0xFFD1D5DB), thickness: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "atau",
                                style: AppThemes.font(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: Color(0xFFD1D5DB), thickness: 1),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // "Sign in with Google" Button
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD1D5DB), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD97706).withValues(alpha: 0.35),
                                offset: const Offset(0, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _handleGoogleLogin,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const GoogleLogo(size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Sign in with Google",
                                    style: AppThemes.font(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
