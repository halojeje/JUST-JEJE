import 'package:flutter/material.dart';
import '../theme/app_themes.dart';

class AppHeader extends StatelessWidget {
  final String currentView; // 'dashboard' | 'generate' | 'settings'
  final VoidCallback onOpenSettings;
  final VoidCallback onNavigateGenerate;
  final VoidCallback onNavigateDashboard;
  final ThemeItem theme;

  const AppHeader({
    super.key,
    required this.currentView,
    required this.onOpenSettings,
    required this.onNavigateGenerate,
    required this.onNavigateDashboard,
    required this.theme,
  });

  Widget _buildSquareButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    Color? iconColor,
  }) {
    final color = iconColor ?? const Color(0xFF1E88E5);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
            ),
            child: Icon(icon, size: 21, color: color),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = "JUST JEJE";
    if (currentView == "generate") title = "Bank Idea";
    if (currentView == "settings") title = "Profil";

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Action
          if (currentView == "dashboard")
            _buildSquareButton(
              icon: Icons.settings_outlined,
              onTap: onOpenSettings,
              tooltip: "Pengaturan",
            )
          else if (currentView == "generate")
            _buildSquareButton(
              icon: Icons.chevron_left_rounded,
              onTap: onNavigateDashboard,
              tooltip: "Kembali ke Dashboard",
            )
          else
            const SizedBox(width: 42, height: 42),

          // Center Title
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppThemes.font(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: theme.textPrimary,
              ),
            ),
          ),

          // Right Action
          if (currentView == "dashboard")
            _buildSquareButton(
              icon: Icons.grid_view_rounded,
              onTap: onNavigateGenerate,
              tooltip: "Ke Halaman Generate",
            )
          else if (currentView == "settings")
            _buildSquareButton(
              icon: Icons.chevron_right_rounded,
              onTap: onNavigateDashboard,
              tooltip: "Kembali ke Dashboard",
            )
          else
            const SizedBox(width: 42, height: 42),
        ],
      ),
    );
  }
}
