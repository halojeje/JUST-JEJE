import React, { useState } from "react";
import { X, Globe, CheckCircle2, AlertCircle, RefreshCw, RotateCcw } from "lucide-react";
import { GoogleSyncConfig } from "../types";

interface SettingsModalProps {
  isOpen: boolean;
  onClose: () => void;
  config: GoogleSyncConfig;
  onSaveConfig: (config: GoogleSyncConfig) => void;
  onResetToDefaults: () => void;
}

export const SettingsModal: React.FC<SettingsModalProps> = ({
  isOpen,
  onClose,
  config,
  onSaveConfig,
  onResetToDefaults,
}) => {
  const [clientId, setClientId] = useState(config.clientId);
  const [autoSync, setAutoSync] = useState(config.autoSync);
  const [syncStatusMsg, setSyncStatusMsg] = useState("");

  if (!isOpen) return null;

  const handleSave = () => {
    onSaveConfig({
      ...config,
      clientId,
      autoSync,
    });
    setSyncStatusMsg("Pengaturan berhasil disimpan!");
    setTimeout(() => setSyncStatusMsg(""), 3000);
  };

  const handleSimulateGoogleConnect = () => {
    if (!clientId.trim()) {
      alert("Silakan masukkan Google OAuth Client ID terlebih dahulu untuk menghubungkan.");
      return;
    }
    // Simulate connection for UI readiness
    onSaveConfig({
      ...config,
      clientId,
      isConnected: true,
      userEmail: "user@gmail.com",
      lastSyncedAt: Date.now(),
    });
    setSyncStatusMsg("Berhasil terhubung dengan Google Tasks!");
  };

  const handleDisconnect = () => {
    onSaveConfig({
      ...config,
      isConnected: false,
      userEmail: undefined,
    });
    setSyncStatusMsg("Koneksi Google Tasks diputus.");
  };

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal-content settings-modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h3>Pengaturan Aplikasi</h3>
          <button className="modal-close-btn" onClick={onClose}>
            <X size={20} />
          </button>
        </div>

        <div className="modal-body settings-body">
          {/* Google Tasks Section */}
          <div className="settings-section">
            <div className="section-title-wrap">
              <Globe size={18} className="section-icon-blue" />
              <h4>Integrasi Google Tasks</h4>
            </div>
            <p className="section-desc">
              Sinkronkan tugas to-do secara otomatis dengan akun{" "}
              <a
                href="https://tasks.google.com/tasks/"
                target="_blank"
                rel="noreferrer"
                className="inline-link"
              >
                Google Tasks
              </a>
              . Tugas yang di-generate akan langsung muncul di Google Calendar dan HP Anda.
            </p>

            <div className="sync-status-box">
              {config.isConnected ? (
                <div className="status-badge connected">
                  <CheckCircle2 size={16} />
                  <span>Terhubung ({config.userEmail})</span>
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
                Dapat diperoleh gratis dari Google Cloud Console (APIs & Services {">"} Credentials).
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
          </div>

          {/* Data Management Section */}
          <div className="settings-section">
            <div className="section-title-wrap">
              <RefreshCw size={18} className="section-icon-blue" />
              <h4>Manajemen Data</h4>
            </div>
            <p className="section-desc">
              Kembalikan data ke setelan awal mockup jika ingin mencoba ulang dari awal.
            </p>
            <button
              className="btn-outline-danger"
              onClick={() => {
                if (window.confirm("Yakin ingin mereset data ke setelan awal mockup?")) {
                  onResetToDefaults();
                  onClose();
                }
              }}
            >
              <RotateCcw size={15} />
              <span>Reset ke Data Awal Mockup</span>
            </button>
          </div>

          {syncStatusMsg && (
            <div className="toast-inline success">
              {syncStatusMsg}
            </div>
          )}

          <div className="modal-actions">
            <button type="button" className="btn-modal-cancel" onClick={onClose}>
              Tutup
            </button>
            <button
              type="button"
              className="btn-modal-submit"
              onClick={handleSave}
            >
              Simpan Pengaturan
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
