import React, { useState } from "react";
import { X, Plus, FolderPlus } from "lucide-react";

interface AddListModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAddListGroup: (title: string) => void;
}

const QUICK_SUGGESTIONS = [
  "Yang Harus Dikerjakan Hari ini!!",
  "Pekerjaan",
  "Pribadi",
  "Wishlist",
  "Belanja",
];

export const AddListModal: React.FC<AddListModalProps> = ({
  isOpen,
  onClose,
  onAddListGroup,
}) => {
  const [listTitle, setListTitle] = useState("");

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!listTitle.trim()) return;
    onAddListGroup(listTitle.trim());
    setListTitle("");
    onClose();
  };

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <div className="modal-header-title">
            <FolderPlus size={20} className="modal-icon-sparkle" />
            <h3>Buat List Baru</h3>
          </div>
          <button
            type="button"
            className="modal-close-btn"
            onClick={onClose}
            title="Tutup"
          >
            <X size={20} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="modal-body">
          <label className="modal-label">Judul List / Kategori Baru:</label>
          <input
            type="text"
            className="modal-input"
            placeholder="Contoh: Yang Harus Dikerjakan Hari ini!!..."
            value={listTitle}
            onChange={(e) => setListTitle(e.target.value)}
            autoFocus
          />

          <label className="modal-label">Saran Judul Cepat:</label>
          <div className="category-chips">
            {QUICK_SUGGESTIONS.map((suggestion) => (
              <button
                type="button"
                key={suggestion}
                className={`category-chip ${listTitle === suggestion ? "active" : ""}`}
                onClick={() => setListTitle(suggestion)}
              >
                {suggestion}
              </button>
            ))}
          </div>

          <div className="modal-actions">
            <button
              type="button"
              className="btn-modal-cancel"
              onClick={onClose}
            >
              Batal
            </button>
            <button
              type="submit"
              className="btn-modal-submit"
              disabled={!listTitle.trim()}
            >
              <Plus size={16} />
              <span>Buat List</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
