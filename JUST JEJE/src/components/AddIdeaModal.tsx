import React, { useState } from "react";
import { X, Sparkles } from "lucide-react";

interface AddIdeaModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAddIdea: (text: string, category?: string) => void;
}

const QUICK_CATEGORIES = ["Produktif", "Anabul & Santai", "Belajar", "Olahraga", "Tugas Rumah"];

export const AddIdeaModal: React.FC<AddIdeaModalProps> = ({
  isOpen,
  onClose,
  onAddIdea,
}) => {
  const [text, setText] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<string>("");

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!text.trim()) return;
    onAddIdea(text.trim(), selectedCategory || undefined);
    setText("");
    setSelectedCategory("");
    onClose();
  };

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <div className="modal-header-title">
            <Sparkles size={20} className="modal-icon-sparkle" />
            <h3>Tambah Ide ke Pool</h3>
          </div>
          <button className="modal-close-btn" onClick={onClose}>
            <X size={20} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="modal-body">
          <label className="modal-label">Ide Tugas / Aktivitas:</label>
          <input
            type="text"
            className="modal-input"
            placeholder="Contoh: Main sama anabul di cafe Kemang"
            value={text}
            onChange={(e) => setText(e.target.value)}
            autoFocus
          />

          <label className="modal-label">Kategori (Opsional):</label>
          <div className="category-chips">
            {QUICK_CATEGORIES.map((cat) => (
              <button
                type="button"
                key={cat}
                className={`category-chip ${selectedCategory === cat ? "active" : ""}`}
                onClick={() =>
                  setSelectedCategory(selectedCategory === cat ? "" : cat)
                }
              >
                {cat}
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
              disabled={!text.trim()}
            >
              Simpan ke Pool
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
