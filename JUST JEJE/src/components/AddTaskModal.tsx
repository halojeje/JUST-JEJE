import React, { useState } from "react";
import { X, Plus, Sparkles } from "lucide-react";
import { PoolItem } from "../types";

interface AddTaskModalProps {
  isOpen: boolean;
  poolItems: PoolItem[];
  onClose: () => void;
  onAddTask: (text: string) => void;
  onAddListGroup: (title: string) => void;
}

export const AddTaskModal: React.FC<AddTaskModalProps> = ({
  isOpen,
  poolItems,
  onClose,
  onAddTask,
  onAddListGroup,
}) => {
  const [tab, setTab] = useState<"task" | "list">("task");
  const [taskText, setTaskText] = useState("");
  const [listTitle, setListTitle] = useState("");

  if (!isOpen) return null;

  const handleTaskSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!taskText.trim()) return;
    onAddTask(taskText.trim());
    setTaskText("");
    onClose();
  };

  const handleListSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!listTitle.trim()) return;
    onAddListGroup(listTitle.trim());
    setListTitle("");
    onClose();
  };

  const handlePickRandom = () => {
    if (poolItems.length === 0) return;
    const random = poolItems[Math.floor(Math.random() * poolItems.length)];
    setTaskText(random.text);
  };

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <div className="modal-tabs">
            <button
              className={`modal-tab ${tab === "task" ? "active" : ""}`}
              onClick={() => setTab("task")}
            >
              Tambah Tugas
            </button>
            <button
              className={`modal-tab ${tab === "list" ? "active" : ""}`}
              onClick={() => setTab("list")}
            >
              Buat List Baru
            </button>
          </div>
          <button className="modal-close-btn" onClick={onClose}>
            <X size={20} />
          </button>
        </div>

        {tab === "task" ? (
          <form onSubmit={handleTaskSubmit} className="modal-body">
            <label className="modal-label">Nama Tugas:</label>
            <input
              type="text"
              className="modal-input"
              placeholder="Ketik tugas baru..."
              value={taskText}
              onChange={(e) => setTaskText(e.target.value)}
              autoFocus
            />

            {poolItems.length > 0 && (
              <div className="modal-quick-pick">
                <button
                  type="button"
                  className="btn-random-pick-inline"
                  onClick={handlePickRandom}
                >
                  <Sparkles size={14} />
                  <span>Ambil ide acak dari pool</span>
                </button>
              </div>
            )}

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
                disabled={!taskText.trim()}
              >
                <Plus size={16} />
                <span>Tambahkan Tugas</span>
              </button>
            </div>
          </form>
        ) : (
          <form onSubmit={handleListSubmit} className="modal-body">
            <label className="modal-label">Judul List / Kategori Baru:</label>
            <input
              type="text"
              className="modal-input"
              placeholder="Contoh: Pekerjaan Kantor, Belanja, Wishlist..."
              value={listTitle}
              onChange={(e) => setListTitle(e.target.value)}
              autoFocus
            />

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
        )}
      </div>
    </div>
  );
};
