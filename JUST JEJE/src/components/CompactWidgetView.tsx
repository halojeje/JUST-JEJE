import React, { useState } from "react";
import { TaskGroup, PoolItem } from "../types";
import { Check, Plus, Sparkles, Trash2, ChevronDown } from "lucide-react";
import confetti from "canvas-confetti";

interface CompactWidgetViewProps {
  taskGroups: TaskGroup[];
  poolItems: PoolItem[];
  onAddTask: (groupId: string, text: string) => void;
  onToggleTask: (groupId: string, taskId: string) => void;
  onDeleteTask: (groupId: string, taskId: string) => void;
  onNavigateGenerate: () => void;
}

export const CompactWidgetView: React.FC<CompactWidgetViewProps> = ({
  taskGroups,
  poolItems,
  onAddTask,
  onToggleTask,
  onDeleteTask,
  onNavigateGenerate,
}) => {
  const [selectedGroupId, setSelectedGroupId] = useState<string>(
    taskGroups[0]?.id || ""
  );
  const [quickInput, setQuickInput] = useState("");
  const [isRolling, setIsRolling] = useState(false);

  // Active group
  const activeGroup =
    taskGroups.find((g) => g.id === selectedGroupId) || taskGroups[0];

  const totalTasks = activeGroup?.tasks.length || 0;
  const completedTasks =
    activeGroup?.tasks.filter((t) => t.completed).length || 0;
  const progressPercent =
    totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

  const handleToggle = (taskId: string, currentCompleted: boolean) => {
    if (!activeGroup) return;
    onToggleTask(activeGroup.id, taskId);
    if (!currentCompleted) {
      try {
        confetti({
          particleCount: 20,
          spread: 50,
          origin: { y: 0.6 },
        });
      } catch {
        // ignore
      }
    }
  };

  const handleQuickAdd = (e: React.FormEvent) => {
    e.preventDefault();
    if (!quickInput.trim() || !activeGroup) return;
    onAddTask(activeGroup.id, quickInput.trim());
    setQuickInput("");
  };

  const handleQuickRoll = () => {
    if (!activeGroup || poolItems.length === 0) {
      onNavigateGenerate();
      return;
    }
    setIsRolling(true);
    let count = 0;
    const interval = setInterval(() => {
      count++;
      if (count > 5) {
        clearInterval(interval);
        const randomItem =
          poolItems[Math.floor(Math.random() * poolItems.length)];
        onAddTask(activeGroup.id, randomItem.text);
        setIsRolling(false);
        try {
          confetti({
            particleCount: 20,
            spread: 45,
            origin: { y: 0.5 },
          });
        } catch {
          // ignore
        }
      }
    }, 60);
  };

  if (!activeGroup) {
    return (
      <div className="compact-empty-state">
        <p>Belum ada daftar tugas.</p>
      </div>
    );
  }

  return (
    <div className="compact-widget-container">
      {/* Header Info: Group Selector & Mini Progress */}
      <div className="compact-header">
        <div className="compact-group-select-wrapper">
          {taskGroups.length > 1 ? (
            <div className="compact-select-container">
              <select
                className="compact-group-select"
                value={activeGroup.id}
                onChange={(e) => setSelectedGroupId(e.target.value)}
              >
                {taskGroups.map((g) => (
                  <option key={g.id} value={g.id}>
                    {g.title}
                  </option>
                ))}
              </select>
              <ChevronDown size={14} className="compact-select-arrow" />
            </div>
          ) : (
            <h3 className="compact-group-title">{activeGroup.title}</h3>
          )}
        </div>

        <div className="compact-header-actions">
          <button
            type="button"
            className={`compact-icon-btn ${isRolling ? "spinning" : ""}`}
            onClick={handleQuickRoll}
            title="Roll Ide dari Pool"
          >
            <Sparkles size={14} />
          </button>
          <span className="compact-counter-badge">
            {completedTasks}/{totalTasks}
          </span>
        </div>
      </div>

      {/* Mini Progress Bar */}
      <div className="compact-progress-track">
        <div
          className="compact-progress-bar"
          style={{ width: `${progressPercent}%` }}
        />
      </div>

      {/* Task List (Clean & Scrollable) */}
      <div className="compact-task-list">
        {activeGroup.tasks.length === 0 ? (
          <div className="compact-task-empty">
            <span>List masih kosong. Ketik di bawah untuk tambah tugas!</span>
          </div>
        ) : (
          activeGroup.tasks.map((task) => (
            <div
              key={task.id}
              className={`compact-task-item ${task.completed ? "completed" : ""}`}
            >
              <button
                type="button"
                className={`compact-checkbox ${task.completed ? "checked" : ""}`}
                onClick={() => handleToggle(task.id, task.completed)}
                title={task.completed ? "Tandai belum selesai" : "Tandai selesai"}
              >
                {task.completed && <Check size={12} strokeWidth={3} />}
              </button>

              <span
                className="compact-task-text"
                onClick={() => handleToggle(task.id, task.completed)}
              >
                {task.text}
              </span>

              <button
                type="button"
                className="compact-task-delete-btn"
                onClick={() => onDeleteTask(activeGroup.id, task.id)}
                title="Hapus tugas"
              >
                <Trash2 size={13} />
              </button>
            </div>
          ))
        )}
      </div>

      {/* Quick Add Bar */}
      <form className="compact-quick-add" onSubmit={handleQuickAdd}>
        <input
          type="text"
          className="compact-input"
          placeholder="+ Tambah tugas cepat..."
          value={quickInput}
          onChange={(e) => setQuickInput(e.target.value)}
        />
        <button
          type="submit"
          className="compact-add-submit"
          disabled={!quickInput.trim()}
          title="Tambah"
        >
          <Plus size={15} strokeWidth={2.5} />
        </button>
      </form>
    </div>
  );
};
