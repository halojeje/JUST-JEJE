import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_themes.dart';

class GoogleModal extends StatefulWidget {
  final GoogleSyncConfig config;
  final Function(GoogleSyncConfig updated) onSaveConfig;
  final ThemeItem theme;

  const GoogleModal({
    super.key,
    required this.config,
    required this.onSaveConfig,
    required this.theme,
  });

  @override
  State<GoogleModal> createState() => _GoogleModalState();
}

class _GoogleModalState extends State<GoogleModal> {
  late TextEditingController _clientIdController;
  late bool _autoSync;

  @override
  void initState() {
    super.initState();
    _clientIdController = TextEditingController(text: widget.config.clientId);
    _autoSync = widget.config.autoSync;
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final updated = GoogleSyncConfig(
      clientId: _clientIdController.text.trim(),
      isConnected: widget.config.isConnected,
      userEmail: widget.config.userEmail,
      userName: widget.config.userName,
      userPicture: widget.config.userPicture,
      autoSync: _autoSync,
      lastSyncedAt: widget.config.lastSyncedAt,
    );
    widget.onSaveConfig(updated);
    Navigator.pop(context);
  }

  void _handleToggleConnect() {
    final willConnect = !widget.config.isConnected;
    final updated = GoogleSyncConfig(
      clientId: _clientIdController.text.trim(),
      isConnected: willConnect,
      userEmail: willConnect ? (widget.config.userEmail ?? "user@gmail.com") : null,
      userName: willConnect ? (widget.config.userName ?? "Google User") : null,
      autoSync: _autoSync,
      lastSyncedAt: willConnect ? DateTime.now().millisecondsSinceEpoch : null,
    );
    widget.onSaveConfig(updated);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.config.isConnected;

    return Dialog(
      backgroundColor: widget.theme.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.public, size: 22, color: Color(0xFF1E88E5)),
                    const SizedBox(width: 8),
                    Text(
                      "Sinkronisasi Google Tasks",
                      style: AppThemes.font(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: widget.theme.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: widget.theme.textMuted,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              "Hubungkan dengan Google Tasks untuk menyinkronkan tugas to-do list harian Anda langsung ke akun Google.",
              style: AppThemes.font(fontSize: 12.5, color: widget.theme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Connected Badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.theme.isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.theme.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isConnected ? Icons.check_circle : Icons.error_outline,
                        size: 16,
                        color: isConnected ? const Color(0xFF10B981) : Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConnected ? "Terhubung (${widget.config.userEmail ?? 'Google'})" : "Belum Terhubung",
                        style: AppThemes.font(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isConnected ? const Color(0xFF10B981) : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      foregroundColor: isConnected ? Colors.red.shade400 : widget.theme.primary,
                      side: BorderSide(color: isConnected ? Colors.red.shade300 : widget.theme.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: _handleToggleConnect,
                    child: Text(
                      isConnected ? "Putus" : "Hubungkan",
                      style: AppThemes.font(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "Google OAuth Client ID:",
              style: AppThemes.font(fontSize: 12.5, fontWeight: FontWeight.w600, color: widget.theme.textSecondary),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _clientIdController,
              style: AppThemes.font(fontSize: 12, color: widget.theme.textPrimary),
              decoration: InputDecoration(
                hintText: "682229986383-...apps.googleusercontent.com",
                hintStyle: AppThemes.font(fontSize: 12, color: widget.theme.textMuted),
                filled: true,
                fillColor: widget.theme.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Checkbox(
                  value: _autoSync,
                  activeColor: widget.theme.primary,
                  onChanged: (val) => setState(() => _autoSync = val ?? false),
                ),
                Expanded(
                  child: Text(
                    "Otomatis sinkron ke Google Tasks saat tugas ditambah",
                    style: AppThemes.font(fontSize: 12, color: widget.theme.textSecondary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Batal", style: AppThemes.font(color: widget.theme.textMuted)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.theme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onPressed: _handleSave,
                  child: Text("Simpan Pengaturan", style: AppThemes.font(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
