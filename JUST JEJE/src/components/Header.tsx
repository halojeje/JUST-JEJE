import React from "react";
import { Settings, LayoutGrid, ChevronLeft, ChevronRight } from "lucide-react";

interface HeaderProps {
  currentView: "dashboard" | "generate" | "settings";
  onOpenSettings: () => void;
  onNavigateGenerate: () => void;
  onNavigateDashboard: () => void;
  onOpenAddIdea?: () => void;
}

export const Header: React.FC<HeaderProps> = ({
  currentView,
  onOpenSettings,
  onNavigateGenerate,
  onNavigateDashboard,
}) => {
  return (
    <header className="app-header">
      {currentView === "dashboard" && (
        <>
          {/* Settings Button: Blue Outlined Rounded Square */}
          <button
            id="btn-settings"
            className="icon-square-btn"
            onClick={onOpenSettings}
            title="Pengaturan"
          >
            <Settings size={22} color="#1e88e5" strokeWidth={2} />
          </button>

          {/* Center Brand Title */}
          <h1 className="header-title">JUST JEJE</h1>

          {/* Generate / Grid Button: Blue Outlined Rounded Square */}
          <button
            id="btn-to-generate"
            className="icon-square-btn"
            onClick={onNavigateGenerate}
            title="Ke Halaman Generate"
          >
            <LayoutGrid size={22} color="#1e88e5" strokeWidth={2} />
          </button>
        </>
      )}

      {currentView === "generate" && (
        <>
          {/* Back Button: Blue Outlined Rounded Square */}
          <button
            id="btn-back-dashboard"
            className="icon-square-btn"
            onClick={onNavigateDashboard}
            title="Kembali ke Dashboard"
          >
            <ChevronLeft size={24} color="#1e88e5" strokeWidth={2.4} />
          </button>

          {/* Center Title: Bank Idea */}
          <h1 className="header-title">Bank Idea</h1>

          {/* Empty spacer to keep title perfectly centered */}
          <div className="header-spacer" />
        </>
      )}

      {currentView === "settings" && (
        <>
          {/* Empty spacer to keep title perfectly centered */}
          <div className="header-spacer" />

          {/* Center Title: Profil */}
          <h1 className="header-title">Profil</h1>

          {/* Exit / Back Button: Blue Outlined Rounded Square */}
          <button
            id="btn-exit-settings"
            className="icon-square-btn"
            onClick={onNavigateDashboard}
            title="Kembali ke Dashboard"
          >
            <ChevronRight size={24} color="#1e88e5" strokeWidth={2.4} />
          </button>
        </>
      )}
    </header>
  );
};
