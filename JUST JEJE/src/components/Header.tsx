import React from "react";
import { Settings, LayoutGrid, ChevronLeft } from "lucide-react";

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
  if (currentView === "settings") {
    return null;
  }

  return (
    <header className="app-header">
      {currentView === "dashboard" ? (
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
      ) : (
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

          {/* Center Title: Generate */}
          <h1 className="header-title">Generate</h1>

          {/* Empty spacer to keep title perfectly centered */}
          <div className="header-spacer" />
        </>
      )}
    </header>
  );
};
