// Google Tasks API & OAuth Service

export const DEFAULT_GOOGLE_CLIENT_ID =
  "755927229847-n686i4no9st9ev53alqmevl4e86nmqvj.apps.googleusercontent.com";

let currentAccessToken: string | null = sessionStorage.getItem("just_jeje_google_access_token");

export function getStoredGoogleToken(): string | null {
  return currentAccessToken;
}

export function setStoredGoogleToken(token: string | null): void {
  currentAccessToken = token;
  if (token) {
    sessionStorage.setItem("just_jeje_google_access_token", token);
  } else {
    sessionStorage.removeItem("just_jeje_google_access_token");
  }
}

interface GoogleTokenResponse {
  access_token?: string;
  error?: string;
}

interface TokenClient {
  requestAccessToken: (options?: { prompt?: string }) => void;
}

interface GoogleAccounts {
  oauth2: {
    initTokenClient: (config: {
      client_id: string;
      scope: string;
      callback: (response: GoogleTokenResponse) => void;
    }) => TokenClient;
  };
}

declare global {
  interface Window {
    google?: {
      accounts?: GoogleAccounts;
    };
  }
}

/**
 * Melakukan otentikasi Google OAuth via Google Identity Services
 */
export function requestGoogleLogin(clientId: string): Promise<{ accessToken: string; email: string }> {
  return new Promise((resolve, reject) => {
    const cleanId = (clientId || DEFAULT_GOOGLE_CLIENT_ID).trim();
    if (!cleanId) {
      reject(new Error("Client ID Google belum diisi."));
      return;
    }

    if (!window.google?.accounts?.oauth2) {
      reject(
        new Error(
          "Google Identity Services belum siap atau koneksi terhalang. Coba muat ulang halaman."
        )
      );
      return;
    }

    try {
      const client = window.google.accounts.oauth2.initTokenClient({
        client_id: cleanId,
        scope: "https://www.googleapis.com/auth/tasks https://www.googleapis.com/auth/userinfo.email",
        callback: async (response) => {
          if (response.error) {
            reject(new Error(`Login Google dibatalkan atau error: ${response.error}`));
            return;
          }

          if (response.access_token) {
            setStoredGoogleToken(response.access_token);
            try {
              // Ambil info email akun yang sedang login
              const userRes = await fetch("https://www.googleapis.com/oauth2/v3/userinfo", {
                headers: { Authorization: `Bearer ${response.access_token}` },
              });
              if (userRes.ok) {
                const userData = await userRes.json();
                resolve({
                  accessToken: response.access_token,
                  email: userData.email || "jeihanm@gmail.com",
                });
                return;
              }
            } catch (err) {
              console.warn("Gagal mengambil email dari userinfo endpoint:", err);
            }

            resolve({
              accessToken: response.access_token,
              email: "jeihanm@gmail.com",
            });
          } else {
            reject(new Error("Tidak menerima token akses dari Google."));
          }
        },
      });

      client.requestAccessToken({ prompt: "consent" });
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : String(e);
      reject(new Error(`Gagal membuka dialog login Google: ${msg}`));
    }
  });
}

/**
 * Menyinkronkan daftar tugas lokal ke Google Tasks (tasks.google.com)
 */
export async function syncTasksToGoogle(
  accessToken: string,
  tasks: Array<{ id: string; text: string; completed: boolean }>
): Promise<{ success: boolean; count: number; message: string }> {
  if (!accessToken) {
    return {
      success: false,
      count: 0,
      message: "Sesi Google Anda telah berakhir. Silakan hubungkan kembali akun Google Anda.",
    };
  }

  try {
    // 1. Dapatkan daftar default Google Tasks pengguna
    const listRes = await fetch("https://tasks.googleapis.com/tasks/v1/users/@me/lists/@default", {
      headers: { Authorization: `Bearer ${accessToken}` },
    });

    if (!listRes.ok) {
      if (listRes.status === 401) {
        setStoredGoogleToken(null);
        throw new Error("Token autentikasi kedaluwarsa. Silakan login Google kembali.");
      }
      throw new Error(`Google Tasks API Error: ${listRes.statusText}`);
    }

    const listData = await listRes.json();
    const listId = listData.id || "@default";

    // 2. Ambil tugas yang sudah ada di Google Tasks agar tidak menduplikasi
    const existingRes = await fetch(
      `https://tasks.googleapis.com/tasks/v1/lists/${encodeURIComponent(listId)}/tasks?showCompleted=true&maxResults=100`,
      {
        headers: { Authorization: `Bearer ${accessToken}` },
      }
    );
    const existingData = await existingRes.json();
    const existingItems = Array.isArray(existingData.items) ? existingData.items : [];

    let addedCount = 0;

    // 3. Masukkan tugas baru yang belum ada di Google Tasks
    for (const task of tasks) {
      const alreadyExists = existingItems.some(
        (ext: { title?: string }) => ext.title?.trim().toLowerCase() === task.text.trim().toLowerCase()
      );

      if (!alreadyExists) {
        const postRes = await fetch(
          `https://tasks.googleapis.com/tasks/v1/lists/${encodeURIComponent(listId)}/tasks`,
          {
            method: "POST",
            headers: {
              Authorization: `Bearer ${accessToken}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              title: task.text,
              status: task.completed ? "completed" : "needsAction",
            }),
          }
        );

        if (postRes.ok) {
          addedCount++;
        }
      }
    }

    return {
      success: true,
      count: addedCount,
      message: `Berhasil menyinkronkan tugas ke Google Tasks (${addedCount} tugas baru diunggah)!`,
    };
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    return {
      success: false,
      count: 0,
      message: `Gagal sinkron Google Tasks: ${msg}`,
    };
  }
}
