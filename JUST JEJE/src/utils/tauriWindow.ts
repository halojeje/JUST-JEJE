import { getCurrentWindow, LogicalSize } from "@tauri-apps/api/window";

/**
 * Check if the application is running inside a Tauri desktop container
 */
export const isTauri = (): boolean => {
  return typeof window !== "undefined" && Boolean((window as any).__TAURI_INTERNALS__);
};

/**
 * Minimize the Tauri desktop window
 */
export const minimizeWindow = async (): Promise<void> => {
  if (!isTauri()) return;
  try {
    const appWindow = getCurrentWindow();
    await appWindow.minimize();
  } catch (err) {
    console.warn("Failed to minimize Tauri window:", err);
  }
};

/**
 * Close the Tauri desktop window
 */
export const closeWindow = async (): Promise<void> => {
  if (!isTauri()) return;
  try {
    const appWindow = getCurrentWindow();
    await appWindow.close();
  } catch (err) {
    console.warn("Failed to close Tauri window:", err);
  }
};

/**
 * Toggle or set Always On Top status
 */
export const setAlwaysOnTop = async (alwaysOnTop: boolean): Promise<boolean> => {
  if (!isTauri()) {
    localStorage.setItem("just_jeje_pinned", alwaysOnTop ? "1" : "0");
    return alwaysOnTop;
  }
  try {
    const appWindow = getCurrentWindow();
    await appWindow.setAlwaysOnTop(alwaysOnTop);
    localStorage.setItem("just_jeje_pinned", alwaysOnTop ? "1" : "0");
    return alwaysOnTop;
  } catch (err) {
    console.warn("Failed to set always on top:", err);
    return false;
  }
};

/**
 * Check initial Always On Top status
 */
export const getIsAlwaysOnTop = async (): Promise<boolean> => {
  const saved = localStorage.getItem("just_jeje_pinned");
  if (!isTauri()) {
    return saved === "1";
  }
  try {
    const appWindow = getCurrentWindow();
    const isTop = await appWindow.isAlwaysOnTop();
    return isTop;
  } catch {
    return saved === "1";
  }
};

/**
 * Adjust window dimensions (e.g., when switching between compact widget & full view)
 */
export const resizeWindow = async (width: number, height: number): Promise<void> => {
  if (!isTauri()) return;
  try {
    const appWindow = getCurrentWindow();
    await appWindow.setSize(new LogicalSize(width, height));
  } catch (err) {
    console.warn("Failed to resize Tauri window:", err);
  }
};
