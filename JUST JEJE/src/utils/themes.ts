export interface ThemeItem {
  id: string;
  name: string;
  icon: string;
  bg: string;
  panel: string;
  pattern: "none" | "grid" | "check" | "dot" | "star" | "spook";
  patColor?: string;
  logo: string;
  isDark?: boolean;
  covers: string[];
  description: string;
}

export const THEMES: ThemeItem[] = [
  {
    id: "basic",
    name: "Basic",
    icon: "✏️",
    bg: "#f1efe9",
    panel: "#fbfaf7",
    pattern: "none",
    logo: "#4f5bd5",
    covers: ["#4f5bd5", "#e0663c", "#2f8f6b", "#c2459a", "#3a8ec9", "#b8862b", "#7a56c2", "#52606d"],
    description: "Tema standar dengan latar kertas hangat dan aksen biru elegan.",
  },
  {
    id: "neat",
    name: "Neat",
    icon: "●",
    bg: "#eeeeee",
    panel: "#fafafa",
    pattern: "none",
    logo: "#222222",
    covers: ["#1f1f1f", "#3d3d3d", "#5c5c5c", "#7a7a7a", "#2e2e2e", "#4d4d4d", "#6b6b6b", "#878787"],
    description: "Tampilan monokrom bersih, rapi, dan minimalis.",
  },
  {
    id: "cute",
    name: "Cute",
    icon: "🍰",
    bg: "#fdf2f7",
    panel: "#eef6ff",
    pattern: "grid",
    patColor: "#bcd7f5",
    logo: "#ffaecb",
    covers: ["#ffc8dd", "#bde0fe", "#ffe9a8", "#ffd1e8", "#cfe6ff", "#fff1bd", "#ffbfd6", "#a9d4fb"],
    description: "Warna pastel manis dengan motif kotak grid biru lembut.",
  },
  {
    id: "picnic",
    name: "Picnic",
    icon: "🧺",
    bg: "#fff8dc",
    panel: "#f1f9e8",
    pattern: "check",
    patColor: "#f5a99e",
    logo: "#f08a7e",
    covers: ["#f0b860", "#f08a7e", "#a9d47a", "#f6d36b", "#ec9a9a", "#c3e0a0", "#f2cf6a", "#f2b0b0"],
    description: "Motif taplak meja piknik kotak-kotak hangat bernuansa ceria.",
  },
  {
    id: "mint-chocolate",
    name: "Mint Chocolate",
    icon: "🍫",
    bg: "#dff3ec",
    panel: "#f3fbf8",
    pattern: "dot",
    patColor: "#7b5544",
    logo: "#6b4433",
    covers: ["#5c3d2e", "#3eb489", "#8b5e3c", "#7fd1b9", "#4a2f24", "#2e9e7a", "#a47148", "#98e0c8"],
    description: "Kombinasi mint segar dengan polkadot butiran cokelat manis.",
  },
  {
    id: "dreamland",
    name: "Dreamland",
    icon: "⭐",
    bg: "#151a30",
    panel: "#1d2340",
    pattern: "star",
    patColor: "#353d6e",
    logo: "#9fa8ff",
    isDark: true,
    covers: ["#3f51b5", "#7e57c2", "#00897b", "#5c6bc0", "#ad1457", "#1e88e5", "#6d4c41", "#455a64"],
    description: "Mode malam estetik bertabur bintang malam dan lavender lembut.",
  },
  {
    id: "halloween",
    name: "Halloween",
    icon: "🎃",
    bg: "#2b2238",
    panel: "#211a2c",
    pattern: "spook",
    patColor: "#4a3d60",
    logo: "#ff8a1f",
    isDark: true,
    covers: ["#ff8a1f", "#7b4fa0", "#3d9a5c", "#c8102e", "#f2b632", "#5a4a78", "#e86a10", "#8b1e3f"],
    description: "Nuansa gelap misterius dengan siluet kelelawar dan labu oranye menyala.",
  },
];

export function normalizeThemeId(themeInput: string): string {
  if (!themeInput) return "basic";
  const t = themeInput.toLowerCase().trim().replace(/[\s_]+/g, "-");
  if (t === "basic" || t.includes("baby-blue")) return "basic";
  if (t === "neat") return "neat";
  if (t === "cute") return "cute";
  if (t === "picnic") return "picnic";
  if (t === "mint-chocolate" || t.includes("mint") || t.includes("emerald")) return "mint-chocolate";
  if (t === "dreamland") return "dreamland";
  if (t === "halloween" || t.includes("dark")) return "halloween";
  return "basic";
}

export function getThemeById(id: string): ThemeItem {
  const normalized = normalizeThemeId(id);
  return THEMES.find((th) => th.id === normalized) || THEMES[0];
}
