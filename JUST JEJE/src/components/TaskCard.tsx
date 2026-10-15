import React, { useState, useMemo } from "react";
import { Task, TaskGroup, PoolItem } from "../types";
import {
  Pencil,
  Check,
  MoreVertical,
  Trash2,
  BookmarkPlus,
  Edit2,
  SlidersHorizontal,
  X,
  Tag,
} from "lucide-react";
import confetti from "canvas-confetti";

interface TaskCardProps {
  group: TaskGroup;
  poolItems: PoolItem[];
  canDeleteGroup?: boolean;
  onDeleteGroup?: (groupId: string) => void;
  onUpdateGroupTitle: (groupId: string, newTitle: string) => void;
  onAddTask: (groupId: string, text: string) => void;
  onToggleTask: (groupId: string, taskId: string) => void;
  onDeleteTask: (groupId: string, taskId: string) => void;
  onEditTask: (groupId: string, taskId: string, newText: string) => void;
  onSaveToPool: (text: string) => void;
  onNavigateGenerate: () => void;
}

export const TaskCard: React.FC<TaskCardProps> = ({
  group,
  poolItems,
  canDeleteGroup = false,
  onDeleteGroup,
  onUpdateGroupTitle,
  onAddTask,
  onToggleTask,
  onDeleteTask,
  onEditTask,
  onSaveToPool,
  onNavigateGenerate,
}) => {
  const [isEditingTitle, setIsEditingTitle] = useState(false);
  const [titleInput, setTitleInput] = useState(group.title);
  const [inputText, setInputText] = useState("");
  const [isGenerating, setIsGenerating] = useState(false);
  const [activeMenuTaskId, setActiveMenuTaskId] = useState<string | null>(null);
  const [editingTaskId, setEditingTaskId] = useState<string | null>(null);
  const [editTaskText, setEditTaskText] = useState("");
  
  // Tag Filter State for Randomize Generator
  const [selectedTag, setSelectedTag] = useState<string | null>(null);
  const [isTagPickerOpen, setIsTagPickerOpen] = useState(false);

  // Extract unique tags/categories from pool items
  const availableTags = useMemo(() => {
    const tagsSet = new Set<string>();
    poolItems.forEach((item) => {
      if (item.category && item.category.trim()) {
        tagsSet.add(item.category.trim());
      }
    });
    return Array.from(tagsSet);
  }, [poolItems]);

  // Close tag picker on click outside
  React.useEffect(() => {
    if (!isTagPickerOpen) return;
    const handleOutsideClick = () => setIsTagPickerOpen(false);
    window.addEventListener("click", handleOutsideClick);
    return () => window.removeEventListener("click", handleOutsideClick);
  }, [isTagPickerOpen]);

  const handleTitleSubmit = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    if (titleInput.trim()) {
      onUpdateGroupTitle(group.id, titleInput.trim());
    } else {
      setTitleInput(group.title);
    }
    setIsEditingTitle(false);
  };

  const handleManualAdd = (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputText.trim()) return;
    onAddTask(group.id, inputText.trim());
    setInputText("");
  };

  const handleGenerateClick = () => {
    // If user has typed something, add the typed text
    if (inputText.trim()) {
      onAddTask(group.id, inputText.trim());
      setInputText("");
      return;
    }

    // Determine candidate pool based on selectedTag
    const candidatePool = selectedTag
      ? poolItems.filter((item) => item.category === selectedTag)
      : poolItems;

    // If pool is empty
    if (candidatePool.length === 0) {
      if (selectedTag) {
        alert(
          `Belum ada ide di kategori "${selectedTag}".\n\nSilakan pilih kategori lain atau buka page Generate untuk menambah ide di kategori ini!`
        );
      } else {
        const confirmNav = window.confirm(
          "Bank ide di page Generate masih kosong!\n\nMau buka page Generate untuk menambah ide tugas sekarang?"
        );
        if (confirmNav) {
          onNavigateGenerate();
        }
      }
      return;
    }

    setIsGenerating(true);

    // Fun slot-machine style fast shuffle effect through candidates
    let count = 0;
    const interval = setInterval(() => {
      const randomPreview = candidatePool[Math.floor(Math.random() * candidatePool.length)];
      setInputText(randomPreview.text);
      count++;

      if (count > 6) {
        clearInterval(interval);
        const finalItem = candidatePool[Math.floor(Math.random() * candidatePool.length)];
        setInputText("");
        onAddTask(group.id, finalItem.text);
        setIsGenerating(false);

        // Gentle celebratory burst
        try {
          confetti({
            particleCount: 25,
            spread: 45,
            origin: { y: 0.5 },
          });
        } catch {
          // ignore
        }
      }
    }, 60);
  };

  const handleToggle = (taskId: string, currentCompleted: boolean) => {
    onToggleTask(group.id, taskId);
    if (!currentCompleted) {
      // Small celebratory confetti when checking a task as completed!
      try {
        confetti({
          particleCount: 30,
          spread: 60,
          origin: { y: 0.6 },
        });
      } catch {
        // ignore
      }
    }
  };

  const handleStartEditTask = (task: Task) => {
    setEditingTaskId(task.id);
    setEditTaskText(task.text);
    setActiveMenuTaskId(null);
  };

  const handleSaveEditTask = (taskId: string) => {
    if (editTaskText.trim()) {
      onEditTask(group.id, taskId, editTaskText.trim());
    }
    setEditingTaskId(null);
  };

  return (
    <div className="task-card-container">
      {/* Card Header with Title and Edit Pencil */}
      <div className="task-card-header">
        {isEditingTitle ? (
          <form onSubmit={handleTitleSubmit} className="title-edit-form">
            <input
              type="text"
              className="title-edit-input"
              value={titleInput}
              onChange={(e) => setTitleInput(e.target.value)}
              autoFocus
              onBlur={() => handleTitleSubmit()}
            />
          </form>
        ) : (
          <div className="task-card-title-row">
            <div
              className="task-card-title-left"
              onClick={() => setIsEditingTitle(true)}
              title="Klik untuk ubah judul list"
            >
              <h2 className="task-card-title">{group.title}</h2>
              <button
                type="button"
                className="icon-action-btn edit-title-btn"
                title="Edit judul daftar"
                onClick={(e) => {
                  e.stopPropagation();
                  setIsEditingTitle(true);
                }}
              >
                <Pencil size={18} />
              </button>
            </div>

            {/* Opsi Hapus Card: Hanya muncul pada card ke-2 dan seterusnya */}
            {canDeleteGroup && (
              <button
                type="button"
                className="icon-action-btn delete-card-btn"
                onClick={(e) => {
                  e.stopPropagation();
                  if (onDeleteGroup) onDeleteGroup(group.id);
                }}
                title="Hapus list card ini"
              >
                <Trash2 size={17} />
              </button>
            )}
          </div>
        )}
      </div>

      {/* Task List Items */}
      <div className="task-list">
        {group.tasks.length === 0 ? (
          <div className="task-empty-state">
            <p>Belum ada tugas. Tulis manual di bawah atau klik <strong>Generate</strong>!</p>
          </div>
        ) : (
          group.tasks.map((task) => (
            <div
              key={task.id}
              className={`task-item-card ${task.completed ? "task-completed" : ""}`}
            >
              {/* Custom Square Checkbox */}
              <button
                type="button"
                className={`task-checkbox ${task.completed ? "checked" : ""}`}
                onClick={() => handleToggle(task.id, task.completed)}
                title={task.completed ? "Tandai belum selesai" : "Tandai selesai"}
              >
                {task.completed && <Check size={14} strokeWidth={3.5} color="#ffffff" />}
              </button>

              {/* Task Text / In-line edit */}
              {editingTaskId === task.id ? (
                <div className="task-inline-edit">
                  <input
                    type="text"
                    value={editTaskText}
                    onChange={(e) => setEditTaskText(e.target.value)}
                    onKeyDown={(e) => {
                      if (e.key === "Enter") handleSaveEditTask(task.id);
                      if (e.key === "Escape") setEditingTaskId(null);
                    }}
                    autoFocus
                    className="task-inline-input"
                  />
                  <button
                    className="task-save-btn"
                    onClick={() => handleSaveEditTask(task.id)}
                  >
                    Simpan
                  </button>
                </div>
              ) : (
                <span
                  className="task-text"
                  onClick={() => handleToggle(task.id, task.completed)}
                  title={task.text}
                >
                  {task.text}
                </span>
              )}

              {/* Three dots menu */}
              <div className="task-menu-wrapper">
                <button
                  className="icon-action-btn task-menu-btn"
                  onClick={(e) => {
                    e.stopPropagation();
                    setActiveMenuTaskId(activeMenuTaskId === task.id ? null : task.id);
                  }}
                  title="Menu aksi"
                >
                  <MoreVertical size={18} />
                </button>

                {activeMenuTaskId === task.id && (
                  <div
                    className="dropdown-menu"
                    onClick={(e) => e.stopPropagation()}
                  >
                    <button
                      className="dropdown-item"
                      onClick={() => handleStartEditTask(task)}
                    >
                      <Edit2 size={14} />
                      <span>Edit Teks</span>
                    </button>
                    <button
                      className="dropdown-item"
                      onClick={() => {
                        onSaveToPool(task.text);
                        setActiveMenuTaskId(null);
                      }}
                    >
                      <BookmarkPlus size={14} />
                      <span>Simpan ke Pool Generate</span>
                    </button>
                    <button
                      className="dropdown-item dropdown-item-danger"
                      onClick={() => {
                        onDeleteTask(group.id, task.id);
                        setActiveMenuTaskId(null);
                      }}
                    >
                      <Trash2 size={14} />
                      <span>Hapus</span>
                    </button>
                  </div>
                )}
              </div>
            </div>
          ))
        )}
      </div>

      {/* Active Tag Filter Indicator Pill (if a tag is selected) */}
      {selectedTag && (
        <div className="active-tag-pill">
          <Tag size={12} className="tag-pill-icon" />
          <span className="tag-pill-text">
            Kategori Acak: <strong>{selectedTag}</strong>
          </span>
          <button
            type="button"
            className="tag-pill-clear"
            onClick={() => setSelectedTag(null)}
            title="Reset ke Semua Tags"
          >
            <X size={12} />
          </button>
        </div>
      )}

      {/* Input Row with Input & Generate Actions Cluster */}
      <form onSubmit={handleManualAdd} className="task-input-card">
        <input
          type="text"
          className={`task-input-field ${isGenerating ? "generating" : ""}`}
          placeholder="Tulis atau pilih randomize"
          value={inputText}
          onChange={(e) => setInputText(e.target.value)}
          disabled={isGenerating}
        />

        <div className="generate-actions-cluster">
          {/* Small Option Button to Choose Tag Filter */}
          <div className="tag-filter-popover-wrapper">
            <button
              type="button"
              className={`btn-tag-option-small ${selectedTag ? "has-active-tag" : ""}`}
              onClick={(e) => {
                e.stopPropagation();
                setIsTagPickerOpen(!isTagPickerOpen);
              }}
              title={
                selectedTag
                  ? `Filter Tag Aktif: ${selectedTag} (Klik untuk ubah/semua)`
                  : "Filter Tags untuk Generate Acak"
              }
            >
              <SlidersHorizontal size={14} />
              {selectedTag && <span className="tag-active-dot" />}
            </button>

            {/* Dropdown Menu for Tags */}
            {isTagPickerOpen && (
              <div
                className="tag-dropdown-menu"
                onClick={(e) => e.stopPropagation()}
              >
                <div className="tag-dropdown-header">
                  <span>Pilih Tag Generate</span>
                </div>

                <button
                  type="button"
                  className={`tag-dropdown-item ${selectedTag === null ? "active" : ""}`}
                  onClick={() => {
                    setSelectedTag(null);
                    setIsTagPickerOpen(false);
                  }}
                >
                  <span className="tag-item-bullet">•</span>
                  <span className="tag-item-label">Semua Tags</span>
                  <span className="tag-item-count">({poolItems.length})</span>
                </button>

                {availableTags.map((tag) => {
                  const count = poolItems.filter((i) => i.category === tag).length;
                  return (
                    <button
                      type="button"
                      key={tag}
                      className={`tag-dropdown-item ${selectedTag === tag ? "active" : ""}`}
                      onClick={() => {
                        setSelectedTag(tag);
                        setIsTagPickerOpen(false);
                      }}
                    >
                      <span className="tag-item-bullet">•</span>
                      <span className="tag-item-label">{tag}</span>
                      <span className="tag-item-count">({count})</span>
                    </button>
                  );
                })}
              </div>
            )}
          </div>

          {/* Generate Button */}
          <button
            type="button"
            className="btn-generate-action"
            onClick={handleGenerateClick}
            disabled={isGenerating}
            title={
              selectedTag
                ? `Generate acak dari kategori "${selectedTag}"`
                : "Generate acak dari semua kategori"
            }
          >
            {isGenerating ? "Picking..." : "Generate"}
          </button>
        </div>
      </form>
    </div>
  );
};
