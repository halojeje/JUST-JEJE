import { useState, useEffect } from "react";
import { TaskGroup, PoolItem, GoogleSyncConfig } from "./types";
import {
  loadTaskGroups,
  saveTaskGroups,
  loadPoolItems,
  savePoolItems,
  loadGoogleConfig,
  saveGoogleConfig,
  DEFAULT_TASK_GROUPS,
  DEFAULT_POOL_ITEMS,
} from "./utils/storage";
import { Header } from "./components/Header";
import { TaskCard } from "./components/TaskCard";
import { GenerateView } from "./components/GenerateView";
import { SettingsView } from "./components/SettingsView";
import { AddIdeaModal } from "./components/AddIdeaModal";
import { AddTaskModal } from "./components/AddTaskModal";
import { Plus } from "lucide-react";
import "./App.css";

function App() {
  const [currentView, setCurrentView] = useState<"dashboard" | "generate" | "settings">("dashboard");
  const [taskGroups, setTaskGroups] = useState<TaskGroup[]>(loadTaskGroups);
  const [poolItems, setPoolItems] = useState<PoolItem[]>(loadPoolItems);
  const [googleConfig, setGoogleConfig] = useState<GoogleSyncConfig>(loadGoogleConfig);

  const [username, setUsername] = useState<string>(() => {
    return localStorage.getItem("just_jeje_username") || "Username";
  });
  const [currentTheme, setCurrentTheme] = useState<string>(() => {
    return localStorage.getItem("just_jeje_theme") || "Basic Baby Blue";
  });

  const [isAddIdeaOpen, setIsAddIdeaOpen] = useState(false);
  const [isAddTaskOpen, setIsAddTaskOpen] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // Synchronize with LocalStorage
  useEffect(() => {
    localStorage.setItem("just_jeje_username", username);
  }, [username]);

  useEffect(() => {
    localStorage.setItem("just_jeje_theme", currentTheme);
  }, [currentTheme]);

  // Synchronize with LocalStorage
  useEffect(() => {
    saveTaskGroups(taskGroups);
  }, [taskGroups]);

  useEffect(() => {
    savePoolItems(poolItems);
  }, [poolItems]);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage(null);
    }, 2800);
  };

  // --- Task Handlers ---
  const handleAddTask = (groupId: string, text: string) => {
    setTaskGroups((prev) =>
      prev.map((grp) => {
        if (grp.id === groupId) {
          return {
            ...grp,
            tasks: [
              ...grp.tasks,
              {
                id: `task-${Date.now()}-${Math.random().toString(36).substr(2, 4)}`,
                text,
                completed: false,
                createdAt: Date.now(),
              },
            ],
          };
        }
        return grp;
      })
    );
    showToast(`Tugas ditambahkan: "${text}"`);
  };

  const handleToggleTask = (groupId: string, taskId: string) => {
    setTaskGroups((prev) =>
      prev.map((grp) => {
        if (grp.id === groupId) {
          return {
            ...grp,
            tasks: grp.tasks.map((t) =>
              t.id === taskId ? { ...t, completed: !t.completed } : t
            ),
          };
        }
        return grp;
      })
    );
  };

  const handleDeleteTask = (groupId: string, taskId: string) => {
    setTaskGroups((prev) =>
      prev.map((grp) => {
        if (grp.id === groupId) {
          return {
            ...grp,
            tasks: grp.tasks.filter((t) => t.id !== taskId),
          };
        }
        return grp;
      })
    );
    showToast("Tugas dihapus");
  };

  const handleEditTask = (groupId: string, taskId: string, newText: string) => {
    setTaskGroups((prev) =>
      prev.map((grp) => {
        if (grp.id === groupId) {
          return {
            ...grp,
            tasks: grp.tasks.map((t) =>
              t.id === taskId ? { ...t, text: newText } : t
            ),
          };
        }
        return grp;
      })
    );
    showToast("Tugas diperbarui");
  };

  const handleUpdateGroupTitle = (groupId: string, newTitle: string) => {
    setTaskGroups((prev) =>
      prev.map((grp) => (grp.id === groupId ? { ...grp, title: newTitle } : grp))
    );
    showToast("Judul daftar diperbarui");
  };

  const handleAddListGroup = (title: string) => {
    const newGroup: TaskGroup = {
      id: `group-${Date.now()}`,
      title,
      tasks: [],
    };
    setTaskGroups((prev) => [...prev, newGroup]);
    showToast(`Daftar baru "${title}" berhasil dibuat!`);
  };

  const handleDeleteGroup = (groupId: string) => {
    const groupToDelete = taskGroups.find((g) => g.id === groupId);
    const title = groupToDelete ? groupToDelete.title : "daftar ini";
    if (window.confirm(`Yakin ingin menghapus list "${title}" beserta semua tugas di dalamnya?`)) {
      setTaskGroups((prev) => prev.filter((g) => g.id !== groupId));
      showToast(`Daftar "${title}" berhasil dihapus`);
    }
  };

  // --- Pool Handlers ---
  const handleAddPoolItem = (text: string, category?: string) => {
    const newItem: PoolItem = {
      id: `pool-${Date.now()}`,
      text,
      category,
      createdAt: Date.now(),
    };
    setPoolItems((prev) => [newItem, ...prev]);
    showToast(`Ide baru dimasukkan ke Pool!`);
  };

  const handleDeletePoolItem = (id: string) => {
    setPoolItems((prev) => prev.filter((item) => item.id !== id));
    showToast("Ide dihapus dari Pool");
  };

  const handleEditPoolItem = (id: string, newText: string) => {
    setPoolItems((prev) =>
      prev.map((item) => (item.id === id ? { ...item, text: newText } : item))
    );
    showToast("Ide diperbarui");
  };

  const handleSaveToPool = (text: string) => {
    handleAddPoolItem(text, "Disimpan dari To-Do");
  };

  const handleSendToDashboard = (text: string) => {
    if (taskGroups.length > 0) {
      handleAddTask(taskGroups[0].id, text);
      setCurrentView("dashboard");
    }
  };

  // Reset to default
  const handleResetToDefaults = () => {
    setTaskGroups(DEFAULT_TASK_GROUPS);
    setPoolItems(DEFAULT_POOL_ITEMS);
    saveTaskGroups(DEFAULT_TASK_GROUPS);
    savePoolItems(DEFAULT_POOL_ITEMS);
    showToast("Data dikembalikan ke setelan awal mockup!");
  };

  const handleSaveGoogleConfig = (cfg: GoogleSyncConfig) => {
    setGoogleConfig(cfg);
    saveGoogleConfig(cfg);
  };

  return (
    <div
      className="app-shell"
      data-theme={currentTheme.toLowerCase().replace(/\s+/g, "-")}
    >
      <div className="mobile-canvas">
        {/* Top Header (Hidden automatically on Settings view) */}
        <Header
          currentView={currentView}
          onOpenSettings={() => setCurrentView("settings")}
          onNavigateGenerate={() => setCurrentView("generate")}
          onNavigateDashboard={() => setCurrentView("dashboard")}
          onOpenAddIdea={() => setIsAddIdeaOpen(true)}
        />

        {/* Main Content Area */}
        <main className="content-area">
          {currentView === "dashboard" && (
            <div className="dashboard-content">
              {taskGroups.map((group, index) => (
                <TaskCard
                  key={group.id}
                  group={group}
                  canDeleteGroup={index > 0}
                  onDeleteGroup={handleDeleteGroup}
                  poolItems={poolItems}
                  onUpdateGroupTitle={handleUpdateGroupTitle}
                  onAddTask={handleAddTask}
                  onToggleTask={handleToggleTask}
                  onDeleteTask={handleDeleteTask}
                  onEditTask={handleEditTask}
                  onSaveToPool={handleSaveToPool}
                  onNavigateGenerate={() => setCurrentView("generate")}
                />
              ))}

              {/* Floating Action Button (FAB) at Bottom Right */}
              <button
                id="btn-fab-add"
                className="fab-button"
                onClick={() => setIsAddTaskOpen(true)}
                title="Tambah Tugas atau List Baru"
              >
                <Plus size={36} strokeWidth={2.4} />
              </button>
            </div>
          )}

          {currentView === "generate" && (
            <GenerateView
              poolItems={poolItems}
              onDeletePoolItem={handleDeletePoolItem}
              onEditPoolItem={handleEditPoolItem}
              onSendToDashboard={handleSendToDashboard}
              onOpenAddIdea={() => setIsAddIdeaOpen(true)}
              onRestoreDefaults={() => setPoolItems(DEFAULT_POOL_ITEMS)}
            />
          )}

          {currentView === "settings" && (
            <SettingsView
              config={googleConfig}
              onSaveConfig={handleSaveGoogleConfig}
              onResetToDefaults={handleResetToDefaults}
              onBack={() => setCurrentView("dashboard")}
              taskGroups={taskGroups}
              currentTheme={currentTheme}
              onThemeChange={setCurrentTheme}
              username={username}
              onUpdateUsername={setUsername}
            />
          )}
        </main>

        {/* Global Toast Notification */}
        {toastMessage && (
          <div className="global-toast">
            <span>{toastMessage}</span>
          </div>
        )}

        {/* Modals */}
        <AddIdeaModal
          isOpen={isAddIdeaOpen}
          onClose={() => setIsAddIdeaOpen(false)}
          onAddIdea={handleAddPoolItem}
        />

        <AddTaskModal
          isOpen={isAddTaskOpen}
          poolItems={poolItems}
          onClose={() => setIsAddTaskOpen(false)}
          onAddTask={(text) => {
            if (taskGroups.length > 0) {
              handleAddTask(taskGroups[0].id, text);
            }
          }}
          onAddListGroup={handleAddListGroup}
        />
      </div>
    </div>
  );
}

export default App;
