import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeItem {
  final String id;
  final String name;
  final String icon;
  final Color bg;
  final Color panel;
  final String pattern; // 'none' | 'grid' | 'check' | 'dot' | 'star' | 'spook'
  final Color patColor;
  final Color logo;
  final Color primary;
  final Color primaryHover;
  final Color primaryLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color borderLight;
  final Color borderCard;
  final bool isDark;
  final List<Color> covers;
  final String description;

  const ThemeItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.bg,
    required this.panel,
    required this.pattern,
    required this.patColor,
    required this.logo,
    required this.primary,
    required this.primaryHover,
    required this.primaryLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.borderLight,
    required this.borderCard,
    this.isDark = false,
    required this.covers,
    required this.description,
  });
}

class AppThemes {
  static const List<ThemeItem> allThemes = [
    // 1. Basic
    ThemeItem(
      id: "basic",
      name: "Basic",
      icon: "✏️",
      bg: Color(0xFFF1EFE9),
      panel: Color(0xFFFBFAF7),
      pattern: "none",
      patColor: Colors.transparent,
      logo: Color(0xFF4F5BD5),
      primary: Color(0xFF4F5BD5),
      primaryHover: Color(0xFF3E49BF),
      primaryLight: Color(0xFFECEEFD),
      textPrimary: Color(0xFF1F2328),
      textSecondary: Color(0xFF4B5563),
      textMuted: Color(0xFF7A7F87),
      borderLight: Color(0xFFE2DFD7),
      borderCard: Color(0xFFE2DFD7),
      covers: [
        Color(0xFF4F5BD5),
        Color(0xFFE0663C),
        Color(0xFF2F8F6B),
        Color(0xFFC2459A),
        Color(0xFF3A8EC9),
        Color(0xFFB8862B),
        Color(0xFF7A56C2),
        Color(0xFF52606D),
      ],
      description: "Tema standar dengan latar kertas hangat dan aksen biru elegan.",
    ),

    // 2. Neat
    ThemeItem(
      id: "neat",
      name: "Neat",
      icon: "●",
      bg: Color(0xFFEEEEEE),
      panel: Color(0xFFFAFAFA),
      pattern: "none",
      patColor: Colors.transparent,
      logo: Color(0xFF222222),
      primary: Color(0xFF222222),
      primaryHover: Color(0xFF000000),
      primaryLight: Color(0xFFE5E5E5),
      textPrimary: Color(0xFF1F2328),
      textSecondary: Color(0xFF4B5563),
      textMuted: Color(0xFF7A7F87),
      borderLight: Color(0xFFDEDEDE),
      borderCard: Color(0xFFDEDEDE),
      covers: [
        Color(0xFF1F1F1F),
        Color(0xFF3D3D3D),
        Color(0xFF5C5C5C),
        Color(0xFF7A7A7A),
        Color(0xFF2E2E2E),
        Color(0xFF4D4D4D),
        Color(0xFF6B6B6B),
        Color(0xFF878787),
      ],
      description: "Tampilan monokrom bersih, rapi, dan minimalis.",
    ),

    // 3. Cute
    ThemeItem(
      id: "cute",
      name: "Cute",
      icon: "🍰",
      bg: Color(0xFFFDF2F7),
      panel: Color(0xFFEEF6FF),
      pattern: "grid",
      patColor: Color(0xFFBCD7F5),
      logo: Color(0xFFFFAECB),
      primary: Color(0xFFEC4899),
      primaryHover: Color(0xFFDB2777),
      primaryLight: Color(0xFFFCE7F3),
      textPrimary: Color(0xFF374151),
      textSecondary: Color(0xFF4B5563),
      textMuted: Color(0xFF8B949E),
      borderLight: Color(0xFFFAD2E1),
      borderCard: Color(0xFFDBEAFE),
      covers: [
        Color(0xFFFFC8DD),
        Color(0xFFBDE0FE),
        Color(0xFFFFE9A8),
        Color(0xFFFFD1E8),
        Color(0xFFCFE6FF),
        Color(0xFFFFF1BD),
        Color(0xFFFFBFD6),
        Color(0xFFA9D4FB),
      ],
      description: "Warna pastel manis dengan motif kotak grid biru lembut.",
    ),

    // 4. Picnic
    ThemeItem(
      id: "picnic",
      name: "Picnic",
      icon: "🧺",
      bg: Color(0xFFFFF8DC),
      panel: Color(0xFFF1F9E8),
      pattern: "check",
      patColor: Color(0xFFF5A99E),
      logo: Color(0xFFF08A7E),
      primary: Color(0xFFF08A7E),
      primaryHover: Color(0xFFD97064),
      primaryLight: Color(0xFFFFEDEA),
      textPrimary: Color(0xFF2C3327),
      textSecondary: Color(0xFF515B49),
      textMuted: Color(0xFF7D8774),
      borderLight: Color(0xFFECD9B4),
      borderCard: Color(0xFFDDEBD2),
      covers: [
        Color(0xFFF0B860),
        Color(0xFFF08A7E),
        Color(0xFFA9D47A),
        Color(0xFFF6D36B),
        Color(0xFFEC9A9A),
        Color(0xFFC3E0A0),
        Color(0xFFF2CF6A),
        Color(0xFFF2B0B0),
      ],
      description: "Motif taplak meja piknik kotak-kotak hangat bernuansa ceria.",
    ),

    // 5. Mint Chocolate
    ThemeItem(
      id: "mint-chocolate",
      name: "Mint Chocolate",
      icon: "🍫",
      bg: Color(0xFFDFF3EC),
      panel: Color(0xFFF3FBF8),
      pattern: "dot",
      patColor: Color(0xFF7B5544),
      logo: Color(0xFF6B4433),
      primary: Color(0xFF3EB489),
      primaryHover: Color(0xFF2E9E7A),
      primaryLight: Color(0xFFD1FAE5),
      textPrimary: Color(0xFF26322B),
      textSecondary: Color(0xFF45564C),
      textMuted: Color(0xFF73857B),
      borderLight: Color(0xFFBCDFD3),
      borderCard: Color(0xFFCDEAE0),
      covers: [
        Color(0xFF5C3D2E),
        Color(0xFF3EB489),
        Color(0xFF8B5E3C),
        Color(0xFF7FD1B9),
        Color(0xFF4A2F24),
        Color(0xFF2E9E7A),
        Color(0xFFA47148),
        Color(0xFF98E0C8),
      ],
      description: "Kombinasi mint segar dengan polkadot butiran cokelat manis.",
    ),

    // 6. Dreamland
    ThemeItem(
      id: "dreamland",
      name: "Dreamland",
      icon: "⭐",
      bg: Color(0xFF151A30),
      panel: Color(0xFF1D2340),
      pattern: "star",
      patColor: Color(0xFF353D6E),
      logo: Color(0xFF9FA8FF),
      primary: Color(0xFF9FA8FF),
      primaryHover: Color(0xFFB4BCFF),
      primaryLight: Color(0x299FA8FF),
      textPrimary: Color(0xFFE4E7F5),
      textSecondary: Color(0xFF9AA1BF),
      textMuted: Color(0xFF6B7294),
      borderLight: Color(0xFF2E3456),
      borderCard: Color(0xFF2E3456),
      isDark: true,
      covers: [
        Color(0xFF3F51B5),
        Color(0xFF7E57C2),
        Color(0xFF00897B),
        Color(0xFF5C6BC0),
        Color(0xFFAD1457),
        Color(0xFF1E88E5),
        Color(0xFF6D4C41),
        Color(0xFF455A64),
      ],
      description: "Mode malam estetik bertabur bintang malam dan lavender lembut.",
    ),

    // 7. Halloween
    ThemeItem(
      id: "halloween",
      name: "Halloween",
      icon: "🎃",
      bg: Color(0xFF2B2238),
      panel: Color(0xFF211A2C),
      pattern: "spook",
      patColor: Color(0xFF4A3D60),
      logo: Color(0xFFFF8A1F),
      primary: Color(0xFFFF8A1F),
      primaryHover: Color(0xFFE6750E),
      primaryLight: Color(0x29FF8A1F),
      textPrimary: Color(0xFFF3E8F8),
      textSecondary: Color(0xFFBDAEC9),
      textMuted: Color(0xFF7E6D8C),
      borderLight: Color(0xFF47395C),
      borderCard: Color(0xFF3D2F50),
      isDark: true,
      covers: [
        Color(0xFFFF8A1F),
        Color(0xFF7B4FA0),
        Color(0xFF3D9A5C),
        Color(0xFFC8102E),
        Color(0xFFF2B632),
        Color(0xFF5A4A78),
        Color(0xFFE86A10),
        Color(0xFF8B1E3F),
      ],
      description: "Nuansa gelap misterius dengan siluet kelelawar dan labu oranye menyala.",
    ),
  ];

  static String normalizeThemeId(String? id) {
    if (id == null || id.isEmpty) return "basic";
    final t = id.toLowerCase().trim().replaceAll(RegExp(r'[\s_]+'), '-');
    if (t == "basic" || t.contains("baby-blue")) return "basic";
    if (t == "neat") return "neat";
    if (t == "cute") return "cute";
    if (t == "picnic") return "picnic";
    if (t == "mint-chocolate" || t.contains("mint") || t.contains("emerald")) {
      return "mint-chocolate";
    }
    if (t == "dreamland") return "dreamland";
    if (t == "halloween" || t.contains("dark")) return "halloween";
    return "basic";
  }

  static ThemeItem getThemeById(String? id) {
    final normalized = normalizeThemeId(id);
    return allThemes.firstWhere(
      (th) => th.id == normalized,
      orElse: () => allThemes[0],
    );
  }

  static TextStyle font({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      letterSpacing: letterSpacing,
    );
  }
}
