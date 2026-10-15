import React from "react";
import { Settings, Sparkles, ChevronLeft, Plus } from "lucide-react";

interface HeaderProps {
  currentView: "dashboard" | "generate" | "settings";
  onOpenSettings: () => void;
  onNavigateGenerate: () => void;
  onNavigateDashboard: () => void;
  onOpenAddIdea: () => void;
}

export const Header: React.FC<HeaderProps> = ({
  currentView,
  onOpenSettings,
  onNavigateGenerate,
  onNavigateDashboard,
  onOpenAddIdea,
}) => {
  if (currentView === "settings") {
    return null;
  }

  return (
    <header className="app-header">
      {currentView === "dashboard" ? (
        <>
          <button
            id="btn-settings"
            className="nav-btn nav-btn-outline"
            onClick={onOpenSettings}
            title="Buka Pengaturan"
          >
            <Settings size={18} className="btn-icon" />
            <span>Settings</span>
          </button>

          <h1 className="header-title">JUST JEJE</h1>

          <button
            id="btn-to-generate"
            className="nav-btn nav-btn-outline"
            onClick={onNavigateGenerate}
            title="Ke Halaman Generate"
          >
            <Sparkles size={18} className="btn-icon" />
            <span>Generate</span>
          </button>
        </>
      ) : (
        <>
          <button
            id="btn-back-dashboard"
            className="icon-square-btn"
            onClick={onNavigateDashboard}
            title="Kembali ke Dashboard"
          >
            <ChevronLeft size={22} />
          </button>

          <h1 className="header-title">Generate</h1>

          <button
            id="btn-add-idea-header"
            className="nav-btn nav-btn-dark-outline"
            onClick={onOpenAddIdea}
            title="Tambah Ide ke Pool"
          >
            <Plus size={16} strokeWidth={2.5} />
            <span>ADD</span>
          </button>
        </>
      )}
    </header>
  );
};
