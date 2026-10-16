import React, { useState, useEffect } from "react";
import {
  Pin,
  PinOff,
  Minus,
  X,
  GripHorizontal,
  LayoutGrid,
  ListTodo,
} from "lucide-react";
import {
  isTauri,
  minimizeWindow,
  closeWindow,
  setAlwaysOnTop,
  getIsAlwaysOnTop,
} from "../utils/tauriWindow";

interface WidgetTopBarProps {
  isCompactMode: boolean;
  onToggleCompactMode: () => void;
  isOnline?: boolean;
}

export const WidgetTopBar: React.FC<WidgetTopBarProps> = ({
  isCompactMode,
  onToggleCompactMode,
  isOnline = false,
}) => {
  const [isPinned, setIsPinned] = useState(true);
  const [inTauri, setInTauri] = useState(false);

  useEffect(() => {
    setInTauri(isTauri());
    getIsAlwaysOnTop().then((pinned) => {
      setIsPinned(pinned);
    });
  }, []);

  const handleTogglePin = async () => {
    const nextState = !isPinned;
    setIsPinned(nextState);
    await setAlwaysOnTop(nextState);
  };

  const handleMinimize = async () => {
    await minimizeWindow();
  };

  const handleClose = async () => {
    await closeWindow();
  };

  return (
    <div className="widget-topbar" data-tauri-drag-region>
      {/* Brand & Status Indicator */}
      <div className="widget-topbar-left" data-tauri-drag-region>
        <span className={`status-dot ${isOnline ? "online" : ""}`} title={isOnline ? "Supabase Online" : "Local Mode"} />
        <span className="widget-logo-text" data-tauri-drag-region>
          JUST JEJE
        </span>
        <span className="widget-mode-badge" data-tauri-drag-region>
          {isCompactMode ? "MINI" : "WIDGET"}
        </span>
      </div>

      {/* Center Drag Handle Grip */}
      <div className="widget-topbar-center" data-tauri-drag-region title="Geser untuk memindahkan widget">
        <GripHorizontal size={16} className="drag-grip-icon" data-tauri-drag-region />
      </div>

      {/* Right Controls */}
      <div className="widget-topbar-right">
        {/* Toggle Always-On-Top (Pin) */}
        <button
          type="button"
          className={`widget-btn ${isPinned ? "active-pin" : ""}`}
          onClick={handleTogglePin}
          title={isPinned ? "Widget Selalu di Atas (Pinned)" : "Pin Widget ke Atas"}
        >
          {isPinned ? <Pin size={13} className="pin-active-icon" /> : <PinOff size={13} />}
        </button>

        {/* Toggle Compact vs Full View */}
        <button
          type="button"
          className={`widget-btn ${isCompactMode ? "active-compact" : ""}`}
          onClick={onToggleCompactMode}
          title={isCompactMode ? "Perluas Tampilan Penuh" : "Mode Widget Minimalis (Ringkas)"}
        >
          {isCompactMode ? <LayoutGrid size={13} /> : <ListTodo size={13} />}
        </button>

        {/* Tauri Native Window Controls (Minimize & Close) */}
        {inTauri && (
          <>
            <button
              type="button"
              className="widget-btn"
              onClick={handleMinimize}
              title="Minimize ke Taskbar"
            >
              <Minus size={13} />
            </button>
            <button
              type="button"
              className="widget-btn widget-btn-close"
              onClick={handleClose}
              title="Tutup Widget"
            >
              <X size={13} />
            </button>
          </>
        )}
      </div>
    </div>
  );
};
