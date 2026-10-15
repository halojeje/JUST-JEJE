import React, { useState } from "react";
import {
  ChevronRight,
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
} from "lucide-react";
import { GoogleSyncConfig, TaskGroup } from "../types";

interface SettingsViewProps {
  config: GoogleSyncConfig;
  onSaveConfig: (config: GoogleSyncConfig) => void;
  onResetToDefaults: () => void;
  onBack: () => void;
  taskGroups: TaskGroup[];
  currentTheme: string;
  onThemeChange: (theme: string) => void;
  username: string;
  onUpdateUsername: (name: string) => void;
}

export const SettingsView: React.FC<SettingsViewProps> = ({
  config,
  onSaveConfig,
  onResetToDefaults,
  onBack,
  taskGroups,
  currentTheme,
  onThemeChange,
  username,
  onUpdateUsername,
}) => {
  const [isGoogleModalOpen, setIsGoogleModalOpen] = useState(false);
  const [isDesktopModalOpen, setIsDesktopModalOpen] = useState(false);
  const [isEditingUsername, setIsEditingUsername] = useState(false);
  const [tempUsername, setTempUsername] = useState(username);

  // Google config state inside modal
  const [clientId, setClientId] = useState(config.clientId);
  const [autoSync, setAutoSync] = useState(config.autoSync);
  const [syncStatusMsg, setSyncStatusMsg] = useState("");

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

  const handleSimulateGoogleConnect = () => {
    if (!clientId.trim()) {
      alert("Silakan masukkan Google OAuth Client ID terlebih dahulu untuk menghubungkan.");
      return;
    }
    onSaveConfig({
      ...config,
      clientId,
      isConnected: true,
      userEmail: config.userEmail || "user@email.com",
      lastSyncedAt: Date.now(),
    });
    setSyncStatusMsg("Berhasil terhubung dengan Google Tasks!");
  };

  const handleDisconnect = () => {
    onSaveConfig({
      ...config,
      isConnected: false,
    });
    setSyncStatusMsg("Koneksi Google Tasks diputus.");
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
      "Apakah Anda yakin ingin LOGOUT?\n\nKoneksi Google Tasks akan diputus."
    );
    if (confirmLogout) {
      handleDisconnect();
      const resetConfirm = window.confirm("Apakah Anda juga ingin mereset data to-do ke setelan awal mockup?");
      if (resetConfirm) {
        onResetToDefaults();
      }
      alert("Anda telah berhasil logout.");
    }
  };

  return (
    <div className="settings-view-container">
      {/* Settings Top Header (Mockup: 'Profil' and chevron right '>' button) */}
      <div className="settings-header">
        <div className="settings-header-placeholder" />
        <h1 className="settings-title">Profil</h1>
        <button
          className="settings-exit-btn"
          onClick={onBack}
          title="Kembali ke Dashboard"
        >
          <ChevronRight size={22} />
        </button>
      </div>

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

      {/* 2. Synchronize to Desktop Card */}
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

      {/* 3. Synchronize to To Do Task Google Card */}
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

      {/* 4. Export to PDF Card */}
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

      {/* 5. Change Theme Card */}
      <div className="menu-card menu-card-theme">
        <div className="menu-card-left">
          <Palette size={18} className="menu-card-icon" />
          <span className="menu-card-text">Change Theme</span>
        </div>
        <div className="theme-select-wrapper">
          <select
            className="theme-dropdown"
            value={currentTheme}
            onChange={(e) => onThemeChange(e.target.value)}
          >
            <option value="Basic Baby Blue">Basic Baby Blue</option>
            <option value="Pastel Lavender">Pastel Lavender</option>
            <option value="Emerald Mint">Emerald Mint</option>
            <option value="Dark Mode">Dark Mode</option>
          </select>
          <ChevronDown size={16} className="theme-select-arrow" />
        </div>
      </div>

      {/* 6. LOGOUT Button (Full width black button) */}
      <button className="btn-logout" onClick={handleLogout}>
        <LogOut size={18} className="btn-logout-icon" />
        <span>LOGOUT</span>
      </button>

      {/* Sub-Modal: Google Tasks Synchronization Settings */}
      {isGoogleModalOpen && (
        <div className="modal-backdrop" onClick={() => setIsGoogleModalOpen(false)}>
          <div
            className="modal-content settings-modal-content"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="modal-header">
              <div className="modal-header-title">
                <Globe size={18} className="section-icon-blue" />
                <h3>Google Tasks Synchronization</h3>
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

                {config.isConnected ? (
                  <button
                    className="btn-danger-outline-small"
                    onClick={handleDisconnect}
                  >
                    Putus Koneksi
                  </button>
                ) : (
                  <button
                    className="btn-primary-small"
                    onClick={handleSimulateGoogleConnect}
                  >
                    Hubungkan Akun Google
                  </button>
                )}
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
                  Didapatkan dari Google Cloud Console (APIs & Services {">"} Credentials).
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
