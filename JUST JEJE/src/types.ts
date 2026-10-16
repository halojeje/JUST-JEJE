export interface Task {
  id: string;
  text: string;
  completed: boolean;
  createdAt: number;
  googleTaskId?: string;
}

export interface TaskGroup {
  id: string;
  title: string;
  tasks: Task[];
}

export interface PoolItem {
  id: string;
  text: string;
  category?: string;
  createdAt: number;
}

export interface GoogleSyncConfig {
  clientId: string;
  isConnected: boolean;
  userEmail?: string;
  userName?: string;
  userPicture?: string;
  autoSync: boolean;
  lastSyncedAt?: number;
}

export interface SupabaseConfig {
  url: string;
  publishableKey: string;
  isConnected: boolean;
  autoSync: boolean;
  lastSyncedAt?: number;
}

