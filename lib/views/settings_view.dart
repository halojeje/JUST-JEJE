import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/pdf_service.dart';
import '../theme/app_themes.dart';
import '../widgets/modals/google_modal.dart';
import '../widgets/modals/supabase_modal.dart';

class SettingsView extends StatefulWidget {
  final GoogleSyncConfig googleConfig;
  final Function(GoogleSyncConfig) onSaveGoogleConfig;
  final SupabaseConfig supabaseConfig;
  final Function(SupabaseConfig) onSaveSupabaseConfig;
  final Future<void> Function() onSyncSupabaseNow;
  final VoidCallback onResetToDefaults;
  final List<TaskGroup> taskGroups;
  final String currentThemeId;
  final Function(String) onThemeChange;
  final String username;
  final Function(String) onUpdateUsername;
  final ThemeItem theme;

  const SettingsView({
    super.key,
    required this.googleConfig,
    required this.onSaveGoogleConfig,
    required this.supabaseConfig,
    required this.onSaveSupabaseConfig,
    required this.onSyncSupabaseNow,
    required this.onResetToDefaults,
    required this.taskGroups,
    required this.currentThemeId,
    required this.onThemeChange,
    required this.username,
    required this.onUpdateUsername,
    required this.theme,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _isEditingUsername = false;
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
  }

  @override
  void didUpdateWidget(covariant SettingsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.username != widget.username && !_isEditingUsername) {
      _usernameController.text = widget.username;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _saveUsername() {
    final name = _usernameController.text.trim();
    if (name.isNotEmpty) {
      widget.onUpdateUsername(name);
    } else {
      _usernameController.text = widget.username;
    }
    setState(() => _isEditingUsername = false);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: widget.theme.panel,
        title: Text(
          "Konfirmasi Logout",
          style: AppThemes.font(fontWeight: FontWeight.bold, color: widget.theme.textPrimary),
        ),
        content: Text(
          "Apakah Anda yakin ingin LOGOUT?\n\nKoneksi Google Tasks dan Supabase akan diputus.",
          style: AppThemes.font(color: widget.theme.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Batal", style: AppThemes.font(color: widget.theme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // Disconnect
              widget.onSaveGoogleConfig(GoogleSyncConfig(
                clientId: widget.googleConfig.clientId,
                isConnected: false,
              ));
              widget.onSaveSupabaseConfig(SupabaseConfig(
                url: widget.supabaseConfig.url,
                publishableKey: widget.supabaseConfig.publishableKey,
                isConnected: false,
                autoSync: widget.supabaseConfig.autoSync,
              ));

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Anda telah berhasil logout.")),
              );
            },
            child: Text("Logout", style: AppThemes.font(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDesktopInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: widget.theme.panel,
        title: Row(
          children: [
            const Icon(Icons.desktop_windows_outlined, size: 22, color: Color(0xFF1E88E5)),
            const SizedBox(width: 8),
            Text("Synchronize to Desktop", style: AppThemes.font(fontWeight: FontWeight.bold, color: widget.theme.textPrimary)),
          ],
        ),
        content: Text(
          "Aplikasi Flutter JUST JEJE mendukung Desktop (Windows, macOS, Linux) dan Mobile (Android, iOS).\n\nSemua perubahan data disinkronkan secara real-time via Supabase Cloud Database ke seluruh perangkat Anda!",
          style: AppThemes.font(color: widget.theme.textSecondary, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.theme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Mengerti"),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.theme.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.theme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.theme.isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF1E88E5)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: AppThemes.font(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.theme.textPrimary,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeEmail = widget.googleConfig.userEmail ?? "user@email.com";
    final avatarLetter = (widget.username.isNotEmpty ? widget.username[0] : "U").toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Profile User Card
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: widget.theme.panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.theme.borderCard, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: widget.theme.isDark ? 0.25 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar Circle
                CircleAvatar(
                  radius: 28,
                  backgroundColor: widget.theme.primaryLight,
                  child: Text(
                    avatarLetter,
                    style: AppThemes.font(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: widget.theme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isEditingUsername)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _usernameController,
                                autofocus: true,
                                style: AppThemes.font(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: widget.theme.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onSubmitted: (_) => _saveUsername(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check, size: 20),
                              color: widget.theme.primary,
                              onPressed: _saveUsername,
                            ),
                          ],
                        )
                      else
                        InkWell(
                          onTap: () => setState(() => _isEditingUsername = true),
                          child: Row(
                            children: [
                              Text(
                                widget.username,
                                style: AppThemes.font(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: widget.theme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.edit_outlined, size: 15, color: widget.theme.textMuted),
                            ],
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        activeEmail,
                        style: AppThemes.font(
                          fontSize: 13,
                          color: widget.theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Cloud Sync (Supabase Database)
          _buildMenuCard(
            icon: Icons.cloud_sync_outlined,
            title: "Cloud Sync (Supabase Database)",
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.supabaseConfig.isConnected
                    ? const Color(0xFF10B981).withValues(alpha: 0.14)
                    : Colors.orange.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.supabaseConfig.isConnected ? "✓ Connected" : "Setup Cloud",
                style: AppThemes.font(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: widget.supabaseConfig.isConnected ? const Color(0xFF10B981) : Colors.orange.shade800,
                ),
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => SupabaseModal(
                  config: widget.supabaseConfig,
                  onSaveConfig: widget.onSaveSupabaseConfig,
                  onSyncNow: widget.onSyncSupabaseNow,
                  theme: widget.theme,
                ),
              );
            },
          ),

          // 3. Synchronize to Desktop
          _buildMenuCard(
            icon: Icons.desktop_windows_outlined,
            title: "Synchronize to Desktop",
            onTap: _showDesktopInfoDialog,
          ),

          // 4. Synchronize to To Do Task Google
          _buildMenuCard(
            icon: Icons.public,
            title: "Synchronize to To Do Task Google",
            trailing: widget.googleConfig.isConnected
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "✓ Connected",
                      style: AppThemes.font(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                    ),
                  )
                : null,
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => GoogleModal(
                  config: widget.googleConfig,
                  onSaveConfig: widget.onSaveGoogleConfig,
                  theme: widget.theme,
                ),
              );
            },
          ),

          // 5. Export to PDF
          _buildMenuCard(
            icon: Icons.picture_as_pdf_outlined,
            title: "Export to pdf",
            onTap: () async {
              await PdfService.exportToPdf(widget.taskGroups, widget.username);
            },
          ),

          // 6. Change Theme Card & Visual Preview Grid
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: widget.theme.panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.theme.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: widget.theme.isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.palette_outlined, size: 20, color: Color(0xFF1E88E5)),
                        const SizedBox(width: 12),
                        Text(
                          "Change Theme",
                          style: AppThemes.font(fontSize: 14, fontWeight: FontWeight.w600, color: widget.theme.textPrimary),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: AppThemes.normalizeThemeId(widget.currentThemeId),
                      dropdownColor: widget.theme.panel,
                      underline: const SizedBox.shrink(),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                      items: AppThemes.allThemes.map((th) {
                        return DropdownMenuItem<String>(
                          value: th.id,
                          child: Text("${th.icon} ${th.name}", style: AppThemes.font(fontSize: 13, color: widget.theme.textPrimary)),
                        );
                      }).toList(),
                      onChanged: (newId) {
                        if (newId != null) widget.onThemeChange(newId);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Theme Presets Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: AppThemes.allThemes.length,
                  itemBuilder: (context, index) {
                    final th = AppThemes.allThemes[index];
                    final isSelected = AppThemes.normalizeThemeId(widget.currentThemeId) == th.id;

                    return GestureDetector(
                      onTap: () => widget.onThemeChange(th.id),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: th.bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? widget.theme.primary : widget.theme.borderLight,
                                  width: isSelected ? 2.5 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: widget.theme.primary.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: th.panel,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(th.icon, style: const TextStyle(fontSize: 18)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            th.name,
                            style: AppThemes.font(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? widget.theme.primary : widget.theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 7. Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.theme.isDark ? const Color(0xFF374151) : const Color(0xFF1F2937),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout, size: 17),
              label: Text("LOGOUT", style: AppThemes.font(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8)),
              onPressed: _showLogoutDialog,
            ),
          ),
        ],
      ),
    );
  }
}
