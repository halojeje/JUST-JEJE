import { useState, useEffect, useRef } from "react";
import { TaskGroup, PoolItem, GoogleSyncConfig, SupabaseConfig } from "./types";
import {
  loadTaskGroups,
  saveTaskGroups,
  loadPoolItems,
  savePoolItems,
  loadGoogleConfig,
  saveGoogleConfig,
  loadSupabaseConfig,
  saveSupabaseConfig,
  DEFAULT_TASK_GROUPS,
  DEFAULT_POOL_ITEMS,
} from "./utils/storage";
import {
  fetchRemoteData,
  pushAllToSupabase,
  setupRealtimeSubscription,
  deleteGroupFromSupabase,
  deleteTaskFromSupabase,
  deletePoolItemFromSupabase,
  updateUserSettingsInSupabase,
} from "./utils/supabaseSync";
import { normalizeThemeId } from "./utils/themes";
import { Header } from "./components/Header";
import { TaskCard } from "./components/TaskCard";
import { GenerateView } from "./components/GenerateView";
import { SettingsView } from "./components/SettingsView";
import { AddIdeaModal } from "./components/AddIdeaModal";
import { AddTaskModal } from "./components/AddTaskModal";
import { WidgetTopBar } from "./components/WidgetTopBar";
import { CompactWidgetView } from "./components/CompactWidgetView";
import { resizeWindow, isTauri } from "./utils/tauriWindow";
import { Plus } from "lucide-react";
import "./App.css";

function App() {
  const [currentView, setCurrentView] = useState<"dashboard" | "generate" | "settings">("dashboard");
  const [isCompactMode, setIsCompactMode] = useState<boolean>(false);
  const [taskGroups, setTaskGroups] = useState<TaskGroup[]>(loadTaskGroups);
  const [poolItems, setPoolItems] = useState<PoolItem[]>(loadPoolItems);
  const [googleConfig, setGoogleConfig] = useState<GoogleSyncConfig>(loadGoogleConfig);
  const [supabaseConfig, setSupabaseConfig] = useState<SupabaseConfig>(loadSupabaseConfig);

  const [username, setUsername] = useState<string>(() => {
    return localStorage.getItem("just_jeje_username") || "Username";
  });
  const [currentTheme, setCurrentTheme] = useState<string>(() => {
    return normalizeThemeId(localStorage.getItem("just_jeje_theme") || "basic");
  });

  const [isAddIdeaOpen, setIsAddIdeaOpen] = useState(false);
  const [isAddTaskOpen, setIsAddTaskOpen] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const lastThemeChangeTimeRef = useRef<number>(0);

  // Synchronize with LocalStorage
  useEffect(() => {
    localStorage.setItem("just_jeje_username", username);
  }, [username]);

  const handleThemeChange = (newTheme: string) => {
    const themeId = normalizeThemeId(newTheme);
    lastThemeChangeTimeRef.current = Date.now();
    localStorage.setItem("just_jeje_theme", themeId);
    document.documentElement.setAttribute("data-theme", themeId);
    document.body.setAttribute("data-theme", themeId);
    setCurrentTheme(themeId);
    showToast(`Tema diganti: ${themeId.toUpperCase()}`);

    if (supabaseConfig.isConnected && supabaseConfig.url) {
      updateUserSettingsInSupabase(username, themeId).catch(console.warn);
    }
  };

  useEffect(() => {
    const themeId = normalizeThemeId(currentTheme);
    localStorage.setItem("just_jeje_theme", themeId);
    document.documentElement.setAttribute("data-theme", themeId);
    document.body.setAttribute("data-theme", themeId);
  }, [currentTheme]);

  // Synchronize with LocalStorage
  useEffect(() => {
    saveTaskGroups(taskGroups);
  }, [taskGroups]);

  useEffect(() => {
    savePoolItems(poolItems);
  }, [poolItems]);

  useEffect(() => {
    saveSupabaseConfig(supabaseConfig);
  }, [supabaseConfig]);

  // Initial fetch and Supabase Realtime subscription
  useEffect(() => {
    if (!supabaseConfig.isConnected || !supabaseConfig.url) return;

    let isMounted = true;
    fetchRemoteData().then((remote) => {
      if (!isMounted || !remote) return;
      if (remote.taskGroups && remote.taskGroups.length > 0) setTaskGroups(remote.taskGroups);
      if (remote.poolItems && remote.poolItems.length > 0) setPoolItems(remote.poolItems);
      if (remote.username) setUsername(remote.username);
      if (remote.theme && Date.now() - lastThemeChangeTimeRef.current > 4000) {
        const tId = normalizeThemeId(remote.theme);
        setCurrentTheme(tId);
        document.documentElement.setAttribute("data-theme", tId);
        document.body.setAttribute("data-theme", tId);
      }
    });

    const unsubscribe = setupRealtimeSubscription(() => {
      fetchRemoteData().then((remote) => {
        if (!isMounted || !remote) return;
        if (remote.taskGroups) setTaskGroups(remote.taskGroups);
        if (remote.poolItems) setPoolItems(remote.poolItems);
        if (remote.username) setUsername(remote.username);
        if (remote.theme && Date.now() - lastThemeChangeTimeRef.current > 4000) {
          const tId = normalizeThemeId(remote.theme);
          setCurrentTheme(tId);
          document.documentElement.setAttribute("data-theme", tId);
          document.body.setAttribute("data-theme", tId);
        }
      });
    });

    return () => {
      isMounted = false;
      unsubscribe();
    };
  }, [supabaseConfig.isConnected, supabaseConfig.url]);

  // Auto-sync debounced changes to Supabase
  useEffect(() => {
    if (!supabaseConfig.isConnected || !supabaseConfig.autoSync || !supabaseConfig.url) return;

    const timer = setTimeout(() => {
      pushAllToSupabase(taskGroups, poolItems, username, currentTheme).catch((err) => {
        console.warn("Auto sync Supabase gagal:", err);
      });
    }, 1500);

    return () => clearTimeout(timer);
  }, [taskGroups, poolItems, username, currentTheme, supabaseConfig.isConnected, supabaseConfig.autoSync, supabaseConfig.url]);


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
    setTaskGroups((prev) => {
      const updated = prev.map((grp) => {
        if (grp.id === groupId) {
          return {
            ...grp,
            tasks: grp.tasks.filter((t) => t.id !== taskId),
          };
        }
        return grp;
      });
      saveTaskGroups(updated);
      return updated;
    });
    showToast("Tugas dihapus");
    deleteTaskFromSupabase(taskId).catch(console.warn);
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
      const remaining = taskGroups.filter((g) => g.id !== groupId);
      setTaskGroups(remaining);
      saveTaskGroups(remaining);
      showToast(`Daftar "${title}" berhasil dihapus`);

      // Hapus secara permanen dari Supabase agar tidak kembali lagi
      deleteGroupFromSupabase(groupId).catch(console.warn);
      if (supabaseConfig.isConnected && supabaseConfig.url) {
        pushAllToSupabase(remaining, poolItems, username, currentTheme).catch(console.warn);
      }
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
    setPoolItems((prev) => {
      const updated = prev.filter((item) => item.id !== id);
      savePoolItems(updated);
      return updated;
    });
    showToast("Ide dihapus dari Pool");
    deletePoolItemFromSupabase(id).catch(console.warn);
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
    if (cfg.userName && (!username || username === "Username")) {
      setUsername(cfg.userName);
      localStorage.setItem("just_jeje_username", cfg.userName);
    }
  };

  const handleSaveSupabaseConfig = (cfg: SupabaseConfig) => {
    setSupabaseConfig(cfg);
    saveSupabaseConfig(cfg);
  };

  const handleSyncSupabaseNow = async () => {
    showToast("Menyinkronkan data ke Supabase...");
    const res = await pushAllToSupabase(taskGroups, poolItems, username, currentTheme);
    showToast(res.message);
  };

  const handleToggleCompactMode = () => {
    const nextMode = !isCompactMode;
    setIsCompactMode(nextMode);
    localStorage.setItem("just_jeje_compact_widget", nextMode ? "1" : "0");
    if (nextMode) {
      resizeWindow(340, 520);
    } else {
      resizeWindow(380, 640);
    }
  };

  return (
    <div
      className={`app-shell ${isCompactMode ? "mode-compact-shell" : ""}`}
      data-theme={normalizeThemeId(currentTheme)}
    >
      <div className={`mobile-canvas ${isCompactMode ? "mode-compact-canvas" : ""}`}>
        {/* Desktop Widget Frameless Bar (Drag, Pin Always-on-top, Compact Toggle, Window buttons) */}
        {(isTauri() || isCompactMode) && (
          <WidgetTopBar
            isCompactMode={isCompactMode}
            onToggleCompactMode={handleToggleCompactMode}
            isOnline={supabaseConfig.isConnected}
          />
        )}

        {isCompactMode ? (
          <CompactWidgetView
            taskGroups={taskGroups}
            poolItems={poolItems}
            onAddTask={handleAddTask}
            onToggleTask={handleToggleTask}
            onDeleteTask={handleDeleteTask}
            onNavigateGenerate={() => {
              setIsCompactMode(false);
              setCurrentView("generate");
            }}
          />
        ) : (
          <>


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
                  {taskGroups.length === 0 ? (
                    <div className="empty-dashboard-state">
                      <p>Belum ada daftar to-do list.</p>
                      <button
                        className="btn-generate-action"
                        onClick={() => handleAddListGroup("Tugas Baru")}
                      >
                        + Buat List Baru
                      </button>
                    </div>
                  ) : (
                    taskGroups.map((group) => (
                      <TaskCard
                        key={group.id}
                        group={group}
                        canDeleteGroup={true}
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
                    ))
                  )}

                  {/* Floating Action Button (FAB) at Bottom Right */}
                  <button
                    id="btn-fab-add"
                    className="fab-button"
                    onClick={() => setIsAddTaskOpen(true)}
                    title="Tambah Tugas atau List Baru"
                  >
                    <Plus size={38} strokeWidth={2.4} color="#0d47a1" />
                  </button>
                </div>
              )}

              {currentView === "generate" && (
                <div className="generate-content-wrapper">
                  <GenerateView
                    poolItems={poolItems}
                    onDeletePoolItem={handleDeletePoolItem}
                    onEditPoolItem={handleEditPoolItem}
                    onSendToDashboard={handleSendToDashboard}
                    onOpenAddIdea={() => setIsAddIdeaOpen(true)}
                    onRestoreDefaults={() => setPoolItems(DEFAULT_POOL_ITEMS)}
                    onAddIdea={handleAddPoolItem}
                  />
                </div>
              )}

              {currentView === "settings" && (
                <SettingsView
                  config={googleConfig}
                  onSaveConfig={handleSaveGoogleConfig}
                  supabaseConfig={supabaseConfig}
                  onSaveSupabaseConfig={handleSaveSupabaseConfig}
                  onSyncSupabaseNow={handleSyncSupabaseNow}
                  onResetToDefaults={handleResetToDefaults}
                  onBack={() => setCurrentView("dashboard")}
                  taskGroups={taskGroups}
                  currentTheme={currentTheme}
                  onThemeChange={handleThemeChange}
                  username={username}
                  onUpdateUsername={setUsername}
                />
              )}
            </main>
          </>
        )}

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
