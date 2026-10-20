import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_themes.dart';

class SupabaseModal extends StatefulWidget {
  final SupabaseConfig config;
  final Function(SupabaseConfig updated) onSaveConfig;
  final Future<void> Function() onSyncNow;
  final ThemeItem theme;

  const SupabaseModal({
    super.key,
    required this.config,
    required this.onSaveConfig,
    required this.onSyncNow,
    required this.theme,
  });

  @override
  State<SupabaseModal> createState() => _SupabaseModalState();
}

class _SupabaseModalState extends State<SupabaseModal> {
  late TextEditingController _urlController;
  late TextEditingController _keyController;
  late bool _autoSync;
  bool _isTesting = false;
  bool _isSyncing = false;
  SyncResult? _testResult;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.config.url);
    _keyController = TextEditingController(text: widget.config.publishableKey);
    _autoSync = widget.config.autoSync;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _handleTest() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final testCfg = SupabaseConfig(
      url: _urlController.text.trim(),
      publishableKey: _keyController.text.trim(),
      isConnected: false,
      autoSync: _autoSync,
    );

    final res = await SupabaseService.testConnection(testCfg);
    setState(() {
      _isTesting = false;
      _testResult = res;
    });

    if (res.success) {
      widget.onSaveConfig(SupabaseConfig(
        url: _urlController.text.trim(),
        publishableKey: _keyController.text.trim(),
        isConnected: true,
        autoSync: _autoSync,
        lastSyncedAt: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  Future<void> _handleManualSync() async {
    setState(() {
      _isSyncing = true;
    });
    try {
      await widget.onSyncNow();
      setState(() {
        _testResult = SyncResult(success: true, message: "Sinkronisasi data ke Supabase berhasil!");
      });
    } catch (e) {
      setState(() {
        _testResult = SyncResult(success: false, message: "Gagal sinkron: $e");
      });
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  void _handleSave() {
    final updated = SupabaseConfig(
      url: _urlController.text.trim(),
      publishableKey: _keyController.text.trim(),
      isConnected: _urlController.text.trim().isNotEmpty && (widget.config.isConnected || (_testResult?.success ?? false)),
      autoSync: _autoSync,
      lastSyncedAt: DateTime.now().millisecondsSinceEpoch,
    );
    widget.onSaveConfig(updated);
    Navigator.pop(context);
  }

  void _handleDisconnect() {
    final updated = SupabaseConfig(
      url: _urlController.text.trim(),
      publishableKey: _keyController.text.trim(),
      isConnected: false,
      autoSync: _autoSync,
    );
    widget.onSaveConfig(updated);
    setState(() {
      _testResult = SyncResult(success: false, message: "Koneksi Supabase diputus.");
    });
  }

  void _copySqlNotice() {
    Clipboard.setData(const ClipboardData(
      text: "Script SQL Supabase tersimpan di file: supabase/schema.sql pada folder project Anda. Buka file tersebut dan paste ke SQL Editor di dashboard Supabase.",
    ));
    setState(() => _isCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.config.isConnected;

    return Dialog(
      backgroundColor: widget.theme.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
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
                        const Icon(Icons.cloud_sync_outlined, size: 22, color: Color(0xFF1E88E5)),
                        const SizedBox(width: 8),
                        Text(
                          "Supabase Cloud Sync",
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
                  "Hubungkan project dengan database Supabase untuk sinkronisasi otomatis to-do list secara real-time.",
                  style: AppThemes.font(fontSize: 12.5, color: widget.theme.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 16),

                // Status Box
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
                            isConnected ? "Terhubung ke Supabase" : "Belum Terhubung",
                            style: AppThemes.font(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isConnected ? const Color(0xFF10B981) : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: _isTesting ? null : _handleTest,
                            child: Text(
                              _isTesting ? "Menguji..." : "Uji Koneksi",
                              style: AppThemes.font(fontSize: 11.5),
                            ),
                          ),
                          if (isConnected) ...[
                            const SizedBox(width: 6),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: _isSyncing ? null : _handleManualSync,
                              child: Text(
                                _isSyncing ? "Sync..." : "Sync Sekarang",
                                style: AppThemes.font(fontSize: 11.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                if (_testResult != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _testResult!.success
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _testResult!.message,
                      style: AppThemes.font(
                        fontSize: 12,
                        color: _testResult!.success ? const Color(0xFF047857) : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Form Fields
                Text(
                  "Supabase Project URL:",
                  style: AppThemes.font(fontSize: 12.5, fontWeight: FontWeight.w600, color: widget.theme.textSecondary),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _urlController,
                  style: AppThemes.font(fontSize: 13, color: widget.theme.textPrimary),
                  decoration: InputDecoration(
                    hintText: "https://your-project-id.supabase.co",
                    hintStyle: AppThemes.font(fontSize: 12.5, color: widget.theme.textMuted),
                    filled: true,
                    fillColor: widget.theme.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  "Publishable / Anon Key:",
                  style: AppThemes.font(fontSize: 12.5, fontWeight: FontWeight.w600, color: widget.theme.textSecondary),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _keyController,
                  style: AppThemes.font(fontSize: 12, color: widget.theme.textPrimary),
                  decoration: InputDecoration(
                    hintText: "sb_publishable_...",
                    hintStyle: AppThemes.font(fontSize: 12.5, color: widget.theme.textMuted),
                    filled: true,
                    fillColor: widget.theme.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 12),

                // Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _autoSync,
                      activeColor: widget.theme.primary,
                      onChanged: (val) => setState(() => _autoSync = val ?? true),
                    ),
                    Expanded(
                      child: Text(
                        "Otomatis sinkron saat menambah, mengubah, atau mencentang to-do",
                        style: AppThemes.font(fontSize: 12, color: widget.theme.textSecondary),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // SQL Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.theme.isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: widget.theme.isDark ? widget.theme.borderLight : const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.cloud_outlined, size: 16, color: Color(0xFF10B981)),
                              const SizedBox(width: 6),
                              Text(
                                "Tabel Database Diperlukan",
                                style: AppThemes.font(fontSize: 12, fontWeight: FontWeight.bold, color: widget.theme.textPrimary),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: _copySqlNotice,
                            child: Row(
                              children: [
                                Icon(_isCopied ? Icons.check : Icons.copy, size: 14, color: const Color(0xFF10B981)),
                                const SizedBox(width: 4),
                                Text(
                                  _isCopied ? "Tersalin!" : "Salin Petunjuk",
                                  style: AppThemes.font(fontSize: 11, color: const Color(0xFF10B981), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Tabel: task_groups, tasks, pool_items, dan user_settings.",
                        style: AppThemes.font(fontSize: 11.5, color: widget.theme.textSecondary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Modal Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isConnected)
                      TextButton(
                        onPressed: _handleDisconnect,
                        child: Text("Putus Koneksi", style: AppThemes.font(color: Colors.red.shade400, fontSize: 13)),
                      )
                    else
                      const SizedBox.shrink(),
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
        ),
      ),
    );
  }
}
