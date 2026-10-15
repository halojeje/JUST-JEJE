import React, { useState } from "react";
import { PoolItem } from "../types";
import { MoreVertical, Trash2, Edit2, SendHorizontal, Sparkles } from "lucide-react";

interface GenerateViewProps {
  poolItems: PoolItem[];
  onDeletePoolItem: (id: string) => void;
  onEditPoolItem: (id: string, newText: string) => void;
  onSendToDashboard: (text: string) => void;
  onOpenAddIdea: () => void;
  onRestoreDefaults: () => void;
}

export const GenerateView: React.FC<GenerateViewProps> = ({
  poolItems,
  onDeletePoolItem,
  onEditPoolItem,
  onSendToDashboard,
  onOpenAddIdea,
  onRestoreDefaults,
}) => {
  const [activeMenuId, setActiveMenuId] = useState<string | null>(null);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editText, setEditText] = useState("");

  const handleStartEdit = (item: PoolItem) => {
    setEditingId(item.id);
    setEditText(item.text);
    setActiveMenuId(null);
  };

  const handleSaveEdit = (id: string) => {
    if (editText.trim()) {
      onEditPoolItem(id, editText.trim());
    }
    setEditingId(null);
  };

  return (
    <div className="generate-view-container">
      <div className="pool-info-banner">
        <Sparkles size={16} className="sparkle-icon" />
        <span>
          Semua ide di bawah ini akan diacak saat Anda klik <strong>Generate</strong> di Dashboard!
        </span>
      </div>

      <div className="pool-list">
        {poolItems.length === 0 ? (
          <div className="pool-empty-card">
            <div className="empty-icon-wrap">🎲</div>
            <h3>Pool Ide Masih Kosong</h3>
            <p>
              Tambahkan ide aktivitas atau tugas agar sistem bisa mengacaknya untuk to-do harianmu.
            </p>
            <div className="empty-action-group">
              <button className="btn-primary-small" onClick={onOpenAddIdea}>
                + Tambah Ide Pertama
              </button>
              <button className="btn-secondary-small" onClick={onRestoreDefaults}>
                Muat Ide Contoh
              </button>
            </div>
          </div>
        ) : (
          poolItems.map((item) => (
            <div key={item.id} className="pool-item-card">
              {editingId === item.id ? (
                <div className="pool-inline-edit">
                  <input
                    type="text"
                    value={editText}
                    onChange={(e) => setEditText(e.target.value)}
                    onKeyDown={(e) => {
                      if (e.key === "Enter") handleSaveEdit(item.id);
                      if (e.key === "Escape") setEditingId(null);
                    }}
                    autoFocus
                    className="pool-inline-input"
                  />
                  <button
                    className="task-save-btn"
                    onClick={() => handleSaveEdit(item.id)}
                  >
                    Simpan
                  </button>
                </div>
              ) : (
                <div className="pool-item-content">
                  <span className="pool-item-text">{item.text}</span>
                  {item.category && (
                    <span className="pool-item-badge">{item.category}</span>
                  )}
                </div>
              )}

              {/* Three dots menu */}
              <div className="task-menu-wrapper">
                <button
                  className="icon-action-btn pool-menu-btn"
                  onClick={(e) => {
                    e.stopPropagation();
                    setActiveMenuId(activeMenuId === item.id ? null : item.id);
                  }}
                  title="Menu aksi"
                >
                  <MoreVertical size={18} />
                </button>

                {activeMenuId === item.id && (
                  <div
                    className="dropdown-menu"
                    onClick={(e) => e.stopPropagation()}
                  >
                    <button
                      className="dropdown-item"
                      onClick={() => {
                        onSendToDashboard(item.text);
                        setActiveMenuId(null);
                      }}
                    >
                      <SendHorizontal size={14} />
                      <span>Kirim ke To-Do Hari Ini</span>
                    </button>
                    <button
                      className="dropdown-item"
                      onClick={() => handleStartEdit(item)}
                    >
                      <Edit2 size={14} />
                      <span>Edit Teks</span>
                    </button>
                    <button
                      className="dropdown-item dropdown-item-danger"
                      onClick={() => {
                        onDeletePoolItem(item.id);
                        setActiveMenuId(null);
                      }}
                    >
                      <Trash2 size={14} />
                      <span>Hapus dari Pool</span>
                    </button>
                  </div>
                )}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};
