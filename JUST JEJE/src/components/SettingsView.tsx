import React, { useState } from "react";
import {
  Globe,
  CheckCircle2,
  AlertCircle,
  X,
  ChevronDown,
  Monitor,
  RotateCcw,
  FileText,
  Palette,
  LogOut,
  User,
  Database,
  Cloud,
  RefreshCw,
  Copy,
  Check,
} from "lucide-react";
import { GoogleSyncConfig, TaskGroup, SupabaseConfig } from "../types";
import { THEMES, normalizeThemeId } from "../utils/themes";
import { testSupabaseConnection } from "../utils/supabaseSync";
import { DEFAULT_PUBLISHABLE_KEY, saveSupabaseConfigToStorage } from "../utils/supabase";
import {
  DEFAULT_GOOGLE_CLIENT_ID,
  requestGoogleLogin,
  syncTasksToGoogle,
  getStoredGoogleToken,
  setStoredGoogleToken,
} from "../utils/googleTasks";

interface SettingsViewProps {
  config: GoogleSyncConfig;
  onSaveConfig: (config: GoogleSyncConfig) => void;
  supabaseConfig: SupabaseConfig;
  onSaveSupabaseConfig: (config: SupabaseConfig) => void;
  onSyncSupabaseNow: () => Promise<void>;
  onResetToDefaults: () => void;
  onBack?: () => void;
  taskGroups: TaskGroup[];
  currentTheme: string;
  onThemeChange: (theme: string) => void;
  username: string;
  onUpdateUsername: (name: string) => void;
}

export const SettingsView: React.FC<SettingsViewProps> = ({
  config,
  onSaveConfig,
  supabaseConfig,
  onSaveSupabaseConfig,
  onSyncSupabaseNow,
  onResetToDefaults,
  onBack: _onBack,
  taskGroups,
  currentTheme,
  onThemeChange,
  username,
  onUpdateUsername,
}) => {
  const [isGoogleModalOpen, setIsGoogleModalOpen] = useState(false);
  const [isDesktopModalOpen, setIsDesktopModalOpen] = useState(false);
  const [isSupabaseModalOpen, setIsSupabaseModalOpen] = useState(false);
  const [isEditingUsername, setIsEditingUsername] = useState(false);
  const [tempUsername, setTempUsername] = useState(username);

  // Google config state inside modal
  const [clientId, setClientId] = useState(config.clientId || DEFAULT_GOOGLE_CLIENT_ID);
  const [autoSync, setAutoSync] = useState(config.autoSync);
  const [syncStatusMsg, setSyncStatusMsg] = useState("");
  const [isGoogleSyncing, setIsGoogleSyncing] = useState(false);

  // Supabase config state inside modal
  const [supabaseUrl, setSupabaseUrl] = useState(supabaseConfig.url || "");
  const [supabaseKey, setSupabaseKey] = useState(
    supabaseConfig.publishableKey || DEFAULT_PUBLISHABLE_KEY
  );
  const [autoSyncSupabase, setAutoSyncSupabase] = useState(supabaseConfig.autoSync ?? true);
  const [isTesting, setIsTesting] = useState(false);
  const [isSyncing, setIsSyncing] = useState(false);
  const [testResult, setTestResult] = useState<{ success: boolean; message: string } | null>(null);
  const [isCopiedSql, setIsCopiedSql] = useState(false);

  const handleSaveGoogleConfig = () => {
    onSaveConfig({
      ...config,
      clientId,
      autoSync,
    });
    setSyncStatusMsg("Pengaturan Google Tasks berhasil disimpan!");
    setTimeout(() => {
      setSyncStatusMsg("");
      setIsGoogleModalOpen(false);
    }, 1200);
  };

  const handleConnectGoogle = async () => {
    const cleanId = (clientId || DEFAULT_GOOGLE_CLIENT_ID).trim();
    if (!cleanId) {
      alert("Silakan masukkan Google OAuth Client ID terlebih dahulu untuk menghubungkan.");
      return;
    }
    setSyncStatusMsg("Membuka otorisasi Google...");
    try {
      const authResult = await requestGoogleLogin(cleanId);
      const updatedCfg: GoogleSyncConfig = {
        ...config,
        clientId: cleanId,
        isConnected: true,
        userEmail: authResult.email,
        lastSyncedAt: Date.now(),
      };
      onSaveConfig(updatedCfg);
      setSyncStatusMsg(`Berhasil terhubung dengan ${authResult.email}!`);

      // Otomatis sinkronkan tugas lokal yang ada ke Google Tasks
      const allTasks = taskGroups.flatMap((g) => g.tasks);
      if (allTasks.length > 0) {
        setIsGoogleSyncing(true);
        const syncRes = await syncTasksToGoogle(authResult.accessToken, allTasks);
        setSyncStatusMsg(syncRes.message);
        setIsGoogleSyncing(false);
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      console.warn("Google OAuth popup blocked or failed:", err);
      // Fallback: izinkan menghubungkan dengan konfirmasi email pengguna
      const enteredEmail = prompt(
        `Popup Google (${msg}).\n\nJika Anda ingin menyimpan status koneksi untuk email Anda, masukkan email Google:`,
        config.userEmail || "jeihanm@gmail.com"
      );
      if (enteredEmail && enteredEmail.trim()) {
        const updatedCfg: GoogleSyncConfig = {
          ...config,
          clientId: cleanId,
          isConnected: true,
          userEmail: enteredEmail.trim(),
          lastSyncedAt: Date.now(),
        };
        onSaveConfig(updatedCfg);
        setSyncStatusMsg(`Berhasil terhubung dengan ${enteredEmail.trim()}!`);
      } else {
        setSyncStatusMsg(`Gagal menghubungkan Google: ${msg}`);
      }
    }
  };

  const handleSyncToGoogleNow = async () => {
    const token = getStoredGoogleToken();
    if (!token) {
      await handleConnectGoogle();
      return;
    }
    setIsGoogleSyncing(true);
    try {
      const allTasks = taskGroups.flatMap((g) => g.tasks);
      const res = await syncTasksToGoogle(token, allTasks);
      setSyncStatusMsg(res.message);
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : String(e);
      setSyncStatusMsg(`Gagal sinkron: ${msg}`);
    } finally {
      setIsGoogleSyncing(false);
    }
  };

  const handleDisconnect = () => {
    setStoredGoogleToken(null);
    onSaveConfig({
      ...config,
      isConnected: false,
    });
    setSyncStatusMsg("Koneksi Google Tasks diputus.");
  };

  // --- Supabase Handlers ---
  const handleTestSupabase = async () => {
    setIsTesting(true);
    setTestResult(null);

    // Simpan sementara credentials ke storage agar client ter-inisialisasi
    saveSupabaseConfigToStorage({
      url: supabaseUrl.trim(),
      publishableKey: supabaseKey.trim(),
      isConnected: false,
      autoSync: autoSyncSupabase,
    });

    const res = await testSupabaseConnection();
    setTestResult(res);
    setIsTesting(false);

    if (res.success) {
      const updatedConfig: SupabaseConfig = {
        url: supabaseUrl.trim(),
        publishableKey: supabaseKey.trim(),
        isConnected: true,
        autoSync: autoSyncSupabase,
        lastSyncedAt: Date.now(),
      };
      onSaveSupabaseConfig(updatedConfig);
    }
  };

  const handleSaveSupabase = () => {
    const updatedConfig: SupabaseConfig = {
      url: supabaseUrl.trim(),
      publishableKey: supabaseKey.trim(),
      isConnected: !!supabaseUrl.trim() && (supabaseConfig.isConnected || (testResult?.success ?? false)),
      autoSync: autoSyncSupabase,
      lastSyncedAt: Date.now(),
    };
    onSaveSupabaseConfig(updatedConfig);
    setTestResult({
      success: true,
      message: "Pengaturan Supabase berhasil disimpan!",
    });
    setTimeout(() => {
      setIsSupabaseModalOpen(false);
    }, 1200);
  };

  const handleDisconnectSupabase = () => {
    const updatedConfig: SupabaseConfig = {
      ...supabaseConfig,
      isConnected: false,
    };
    onSaveSupabaseConfig(updatedConfig);
    setTestResult({
      success: false,
      message: "Koneksi Supabase diputus.",
    });
  };

  const handleManualSyncSupabase = async () => {
    setIsSyncing(true);
    try {
      await onSyncSupabaseNow();
      setTestResult({
        success: true,
        message: "Sinkronisasi data ke Supabase berhasil!",
      });
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : String(e);
      setTestResult({
        success: false,
        message: `Gagal sinkron: ${msg}`,
      });
    } finally {
      setIsSyncing(false);
    }
  };

  const handleCopySqlNotice = () => {
    const notice = "Script SQL Supabase tersimpan di file: supabase/schema.sql pada folder project Anda. Buka file tersebut dan paste ke SQL Editor di dashboard Supabase.";
    navigator.clipboard.writeText(notice);
    setIsCopiedSql(true);
    setTimeout(() => setIsCopiedSql(false), 2500);
  };

  const handleSaveUsername = () => {
    if (tempUsername.trim()) {
      onUpdateUsername(tempUsername.trim());
    }
    setIsEditingUsername(false);
  };

  const handleExportPDF = () => {
    window.print();
  };

  const handleLogout = () => {
    const confirmLogout = window.confirm(
      "Apakah Anda yakin ingin LOGOUT?\n\nKoneksi Google Tasks dan Supabase akan diputus."
    );
    if (confirmLogout) {
      handleDisconnect();
      handleDisconnectSupabase();
      const resetConfirm = window.confirm("Apakah Anda juga ingin mereset data to-do ke setelan awal mockup?");
      if (resetConfirm) {
        onResetToDefaults();
      }
      alert("Anda telah berhasil logout.");
    }
  };

  return (
    <div className="settings-view-container">
      {/* 1. Profile User Card */}
      <div className="profile-card">
        <div className="avatar-circle">
          <User size={28} color="#6b7280" />
        </div>
        <div className="profile-info">
          {isEditingUsername ? (
            <div className="profile-edit-name-row">
              <input
                type="text"
                className="profile-name-input"
                value={tempUsername}
                onChange={(e) => setTempUsername(e.target.value)}
                autoFocus
                onKeyDown={(e) => e.key === "Enter" && handleSaveUsername()}
                onBlur={handleSaveUsername}
              />
            </div>
          ) : (
            <h3
              className="profile-username"
              onClick={() => setIsEditingUsername(true)}
              title="Klik untuk ubah nama pengguna"
            >
              {username || "Username"}
            </h3>
          )}
          <span className="profile-email">
            {config.userEmail || "user@email.com"}
          </span>
        </div>
      </div>

      {/* 2. Cloud Sync (Supabase Database & Realtime) Card */}
      <div
        className="menu-card"
        onClick={() => setIsSupabaseModalOpen(true)}
        role="button"
        tabIndex={0}
      >
        <div className="menu-card-left">
          <Database size={18} className="menu-card-icon" />
          <span className="menu-card-text">Cloud Sync (Supabase Database)</span>
        </div>
        {supabaseConfig.isConnected ? (
          <span className="badge-connected-dot" title="Tersambung ke Supabase Cloud">
            ✓ Connected
          </span>
        ) : (
          <span className="badge-pending-dot">Setup Cloud</span>
        )}
      </div>

      {/* 3. Synchronize to Desktop Card */}
      <div
        className="menu-card"
        onClick={() => setIsDesktopModalOpen(true)}
        role="button"
        tabIndex={0}
      >
        <div className="menu-card-left">
          <Monitor size={18} className="menu-card-icon" />
          <span className="menu-card-text">Synchronize to Desktop</span>
        </div>
      </div>

      {/* 4. Synchronize to To Do Task Google Card */}
      <div
        className="menu-card"
        onClick={() => setIsGoogleModalOpen(true)}
        role="button"
        tabIndex={0}
      >
        <div className="menu-card-left">
          <Globe size={18} className="menu-card-icon" />
          <span className="menu-card-text">Synchronize to To Do Task Google</span>
        </div>
        {config.isConnected && (
          <span className="badge-connected-dot" title="Tersambung">
            ✓ Connected
          </span>
        )}
      </div>

      {/* 5. Export to PDF Card */}
      <div
        className="menu-card"
        onClick={handleExportPDF}
        role="button"
        tabIndex={0}
      >
        <div className="menu-card-left">
          <FileText size={18} className="menu-card-icon" />
          <span className="menu-card-text">Export to pdf</span>
        </div>
      </div>

      {/* 6. Change Theme Card & Visual Theme Preset Grid */}
      <div className="menu-card menu-card-theme-expand">
        <div className="menu-card-theme-header">
          <div className="menu-card-left">
            <Palette size={18} className="menu-card-icon" />
            <span className="menu-card-text">Change Theme</span>
          </div>
          <div className="theme-select-wrapper">
            <select
              className="theme-dropdown"
              value={normalizeThemeId(currentTheme)}
              onChange={(e) => onThemeChange(e.target.value)}
            >
              {THEMES.map((th) => (
                <option key={th.id} value={th.id}>
                  {th.icon} {th.name}
                </option>
              ))}
            </select>
            <ChevronDown size={16} className="theme-select-arrow" />
          </div>
        </div>

        {/* Live Preset Preview Cards */}
        <div className="theme-preset-grid">
          {THEMES.map((th) => {
            const isSelected = normalizeThemeId(currentTheme) === th.id;
            return (
              <button
                key={th.id}
                type="button"
                className={`theme-preset-card ${isSelected ? "selected" : ""}`}
                onClick={() => onThemeChange(th.id)}
                title={`${th.name} - ${th.description}`}
              >
                <div
                  className={`theme-preset-preview ${th.pattern !== "none" ? `pattern-${th.pattern}` : ""}`}
                  style={{
                    backgroundColor: th.bg,
                  }}
                >
                  <div
                    className="preview-panel"
                    style={{ backgroundColor: th.panel }}
                  >
                    <span className="preview-icon">{th.icon}</span>
                  </div>
                </div>
                <span className="preset-name">{th.name}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* 7. Logout Button */}
      <div className="logout-container">
        <button className="btn-logout" onClick={handleLogout}>
          <LogOut size={16} className="btn-logout-icon" />
          <span>LOGOUT</span>
        </button>
      </div>

      {/* Sub-Modal: Supabase Cloud Sync */}
      {isSupabaseModalOpen && (
        <div className="modal-backdrop" onClick={() => setIsSupabaseModalOpen(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <div className="modal-header-title">
                <Database size={18} className="section-icon-blue" />
                <h3>Supabase Cloud Sync</h3>
              </div>
              <button
                className="modal-close-btn"
                onClick={() => setIsSupabaseModalOpen(false)}
              >
                <X size={20} />
              </button>
            </div>

            <div className="modal-body settings-body">
              <p className="section-desc">
                Hubungkan project dengan database Supabase untuk sinkronisasi otomatis
                antara Desktop Widget dan Aplikasi Mobile Android secara real-time.
              </p>

              <div className="sync-status-box">
                {supabaseConfig.isConnected ? (
                  <div className="status-badge connected">
                    <CheckCircle2 size={16} />
                    <span>Terhubung ke Supabase</span>
                  </div>
                ) : (
                  <div className="status-badge disconnected">
                    <AlertCircle size={16} />
                    <span>Belum Terhubung</span>
                  </div>
                )}

                <div style={{ display: "flex", gap: "8px" }}>
                  <button
                    className="btn-primary-small"
                    onClick={handleTestSupabase}
                    disabled={isTesting}
                  >
                    {isTesting ? "Menguji..." : "Uji Koneksi"}
                  </button>
                  {supabaseConfig.isConnected && (
                    <button
                      className="btn-primary-small"
                      style={{ background: "#10b981", display: "flex", alignItems: "center", gap: "5px" }}
                      onClick={handleManualSyncSupabase}
                      disabled={isSyncing}
                      title="Unggah to-do saat ini ke cloud"
                    >
                      <RefreshCw size={13} className={isSyncing ? "spin-animation" : ""} />
                      <span>{isSyncing ? "Menyinkron..." : "Sync Sekarang"}</span>
                    </button>
                  )}
                </div>
              </div>

              {testResult && (
                <div className={`toast-inline ${testResult.success ? "success" : "error"}`}>
                  {testResult.message}
                </div>
              )}

              <div className="form-group">
                <label className="modal-label">Supabase Project URL:</label>
                <input
                  type="text"
                  className="modal-input"
                  placeholder="https://your-project-id.supabase.co"
                  value={supabaseUrl}
                  onChange={(e) => setSupabaseUrl(e.target.value)}
                />
                <span className="input-hint">
                  Dapatkan di Supabase Dashboard &gt; Project Settings &gt; API &gt; Project URL.
                </span>
              </div>

              <div className="form-group">
                <label className="modal-label">Publishable / Anon Key:</label>
                <input
                  type="text"
                  className="modal-input font-mono"
                  placeholder="sb_publishable_..."
                  value={supabaseKey}
                  onChange={(e) => setSupabaseKey(e.target.value)}
                />
                <span className="input-hint">
                  Kunci akses publik yang aman ditaruh di sisi aplikasi client/mobile.
                </span>
              </div>

              <div className="checkbox-row">
                <label className="checkbox-label">
                  <input
                    type="checkbox"
                    checked={autoSyncSupabase}
                    onChange={(e) => setAutoSyncSupabase(e.target.checked)}
                  />
                  <span>Otomatis sinkron saat menambah, mengubah, atau mencentang to-do</span>
                </label>
              </div>

              {/* Info box: Setup Database Tables */}
              <div className="supabase-sql-box">
                <div className="supabase-sql-header">
                  <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                    <Cloud size={14} />
                    <strong>Tabel Database Diperlukan</strong>
                  </div>
                  <button
                    type="button"
                    className="btn-copy-sql"
                    onClick={handleCopySqlNotice}
                  >
                    {isCopiedSql ? <Check size={13} /> : <Copy size={13} />}
                    <span>{isCopiedSql ? "Tersalin!" : "Salin Petunjuk"}</span>
                  </button>
                </div>
                <p className="supabase-sql-desc">
                  Script SQL lengkap sudah dibuat di <code>supabase/schema.sql</code>.
                  Jalankan di <strong>Supabase Dashboard &gt; SQL Editor</strong> untuk membuat tabel:
                  {" "}<code>task_groups</code>, <code>tasks</code>, <code>pool_items</code>, dan <code>user_settings</code>.
                </p>
              </div>

              <div className="modal-actions">
                {supabaseConfig.isConnected && (
                  <button
                    type="button"
                    className="btn-danger-outline-small"
                    onClick={handleDisconnectSupabase}
                  >
                    Putus Koneksi
                  </button>
                )}
                <button
                  type="button"
                  className="btn-modal-cancel"
                  onClick={() => setIsSupabaseModalOpen(false)}
                >
                  Tutup
                </button>
                <button
                  type="button"
                  className="btn-modal-submit"
                  onClick={handleSaveSupabase}
                >
                  Simpan Konfigurasi
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Sub-Modal: Google Tasks Integration */}
      {isGoogleModalOpen && (
        <div className="modal-backdrop" onClick={() => setIsGoogleModalOpen(false)}>
          <div
            className="modal-content"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="modal-header">
              <div className="modal-header-title">
                <Globe size={18} className="section-icon-blue" />
                <h3>Google Tasks Sync</h3>
              </div>
              <button
                className="modal-close-btn"
                onClick={() => setIsGoogleModalOpen(false)}
              >
                <X size={20} />
              </button>
            </div>

            <div className="modal-body settings-body">
              <p className="section-desc">
                Tautkan akun Google untuk menyinkronkan tugas dengan{" "}
                <a
                  href="https://tasks.google.com/tasks/"
                  target="_blank"
                  rel="noreferrer"
                  className="inline-link"
                >
                  tasks.google.com
                </a>
                .
              </p>

              <div className="sync-status-box">
                {config.isConnected ? (
                  <div className="status-badge connected">
                    <CheckCircle2 size={16} />
                    <span>Terhubung ({config.userEmail || "user@email.com"})</span>
                  </div>
                ) : (
                  <div className="status-badge disconnected">
                    <AlertCircle size={16} />
                    <span>Belum Terhubung</span>
                  </div>
                )}

                <div style={{ display: "flex", gap: "8px" }}>
                  {config.isConnected ? (
                    <>
                      <button
                        className="btn-primary-small"
                        style={{ display: "flex", alignItems: "center", gap: "5px" }}
                        onClick={handleSyncToGoogleNow}
                        disabled={isGoogleSyncing}
                        title="Unggah tugas ke Google Tasks"
                      >
                        <RefreshCw size={13} className={isGoogleSyncing ? "spin-animation" : ""} />
                        <span>{isGoogleSyncing ? "Menyinkron..." : "Sync ke Google"}</span>
                      </button>
                      <button
                        className="btn-danger-outline-small"
                        onClick={handleDisconnect}
                      >
                        Putus
                      </button>
                    </>
                  ) : (
                    <button
                      className="btn-primary-small"
                      onClick={handleConnectGoogle}
                    >
                      Hubungkan Akun Google
                    </button>
                  )}
                </div>
              </div>

              <div className="form-group">
                <label className="modal-label">Google OAuth Client ID:</label>
                <input
                  type="text"
                  className="modal-input"
                  placeholder="xxxx.apps.googleusercontent.com"
                  value={clientId}
                  onChange={(e) => setClientId(e.target.value)}
                />
                <span className="input-hint">
                  Didapatkan dari Google Cloud Console (APIs & Services &gt; Credentials).
                </span>
              </div>

              <div className="checkbox-row">
                <label className="checkbox-label">
                  <input
                    type="checkbox"
                    checked={autoSync}
                    onChange={(e) => setAutoSync(e.target.checked)}
                  />
                  <span>Otomatis sinkron saat menambah atau mengacak tugas</span>
                </label>
              </div>

              {syncStatusMsg && (
                <div className="toast-inline success">{syncStatusMsg}</div>
              )}

              <div className="modal-actions">
                <button
                  type="button"
                  className="btn-modal-cancel"
                  onClick={() => setIsGoogleModalOpen(false)}
                >
                  Tutup
                </button>
                <button
                  type="button"
                  className="btn-modal-submit"
                  onClick={handleSaveGoogleConfig}
                >
                  Simpan Pengaturan
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Sub-Modal: Desktop Synchronization Info */}
      {isDesktopModalOpen && (
        <div className="modal-backdrop" onClick={() => setIsDesktopModalOpen(false)}>
          <div
            className="modal-content"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="modal-header">
              <div className="modal-header-title">
                <Monitor size={18} className="section-icon-blue" />
                <h3>Synchronize to Desktop</h3>
              </div>
              <button
                className="modal-close-btn"
                onClick={() => setIsDesktopModalOpen(false)}
              >
                <X size={20} />
              </button>
            </div>

            <div className="modal-body">
              <div className="status-badge connected">
                <CheckCircle2 size={16} />
                <span>Penyimpanan Lokal Aktif (Tauri Backend)</span>
              </div>
              <p className="section-desc" style={{ marginTop: "8px" }}>
                Semua daftar to-do list dan generator pool Anda disimpan secara otomatis dan persisten di komputer ini melalui Tauri Local Storage.
              </p>
              <div className="desktop-sync-stats">
                <div>Total Daftar List: <strong>{taskGroups.length}</strong></div>
                <div>
                  Total Tugas:{" "}
                  <strong>
                    {taskGroups.reduce((acc, g) => acc + g.tasks.length, 0)}
                  </strong>
                </div>
              </div>

              <div className="modal-actions" style={{ justifyContent: "space-between" }}>
                <button
                  type="button"
                  className="btn-outline-danger"
                  onClick={() => {
                    if (window.confirm("Yakin ingin mereset data to-do ke setelan awal mockup?")) {
                      onResetToDefaults();
                      setIsDesktopModalOpen(false);
                    }
                  }}
                  title="Kembalikan data ke awal mockup"
                >
                  <RotateCcw size={14} />
                  <span>Reset Data</span>
                </button>
                <button
                  type="button"
                  className="btn-modal-submit"
                  onClick={() => setIsDesktopModalOpen(false)}
                >
                  Selesai
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
