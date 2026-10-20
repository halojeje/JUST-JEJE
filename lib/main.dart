import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'models/models.dart';
import 'services/storage_service.dart';
import 'services/supabase_service.dart';
import 'theme/app_themes.dart';
import 'widgets/app_header.dart';
import 'widgets/custom_scaffold.dart';
import 'widgets/modals/add_idea_modal.dart';
import 'widgets/modals/add_list_modal.dart';
import 'views/dashboard_view.dart';
import 'views/generate_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/settings_view.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_service.dart';
import 'services/home_widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseAuthService.initialize();
  runApp(const JustJejeApp());
}

class JustJejeApp extends StatefulWidget {
  const JustJejeApp({super.key});

  @override
  State<JustJejeApp> createState() => _JustJejeAppState();
}

class _JustJejeAppState extends State<JustJejeApp> {
  String _currentView = "dashboard"; // 'dashboard' | 'generate' | 'settings'

  List<TaskGroup> _taskGroups = [];
  List<PoolItem> _poolItems = [];
  GoogleSyncConfig _googleConfig = StorageService.getDefaultGoogleConfig();
  SupabaseConfig _supabaseConfig = StorageService.getDefaultSupabaseConfig();

  String _username = "Username";
  String _userEmail = "user@email.com";
  String? _userPicture;
  bool _isLoggedIn = false;
  bool _showRegister = false;
  String _currentThemeId = "basic";

  bool _isLoading = true;
  Timer? _debounceSyncTimer;
  void Function()? _unsubscribeRealtime;
  StreamSubscription? _firestoreSubscription;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 700),
    );
    _loadInitialData();
  }

  @override
  void dispose() {
    _debounceSyncTimer?.cancel();
    _unsubscribeRealtime?.call();
    _firestoreSubscription?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final loggedIn = await StorageService.loadIsLoggedIn();
    final email = await StorageService.loadUserEmail();
    final user = await StorageService.loadUsername();
    final pic = await StorageService.loadUserPicture();
    final gConfig = await StorageService.loadGoogleConfig();
    final sConfig = await StorageService.loadSupabaseConfig();
    final theme = await StorageService.loadTheme();

    List<TaskGroup> groups;
    List<PoolItem> pool;

    if (loggedIn && email.isNotEmpty && email != "user@email.com") {
      final cachedGroups = await StorageService.loadTaskGroupsForUser(email);
      final cachedPool = await StorageService.loadPoolItemsForUser(email);
      groups = cachedGroups ?? StorageService.getNewUserTaskGroups();
      pool = cachedPool ?? StorageService.getNewUserPoolItems();
    } else {
      groups = await StorageService.loadTaskGroups();
      pool = await StorageService.loadPoolItems();
    }

    setState(() {
      _taskGroups = groups;
      _poolItems = pool;
      _googleConfig = gConfig;
      _supabaseConfig = sConfig;
      _username = user;
      _userEmail = email;
      _userPicture = pic;
      _isLoggedIn = loggedIn;
      _currentThemeId = theme;
      _isLoading = false;
    });

    final currentTheme = AppThemes.getThemeById(theme);
    HomeWidgetService.syncFromGroups(groups, currentTheme);

    _initSupabaseSync(sConfig);

    if (loggedIn && email.isNotEmpty && email != "user@email.com") {
      _syncUserFromFirestore(email, user, pic);
    }
  }

  void _initSupabaseSync(SupabaseConfig config) {
    if (!config.isConnected || config.url.isEmpty) return;

    // 1. Fetch remote initial
    SupabaseService.fetchRemoteData(config).then((remote) {
      if (remote == null || !mounted) return;
      setState(() {
        if (remote.taskGroups.isNotEmpty) _taskGroups = remote.taskGroups;
        if (remote.poolItems.isNotEmpty) _poolItems = remote.poolItems;
        if (remote.username != null && remote.username!.isNotEmpty) {
          _username = remote.username!;
        }
        if (remote.theme != null && remote.theme!.isNotEmpty) {
          _currentThemeId = remote.theme!;
        }
      });
      StorageService.saveTaskGroups(_taskGroups);
      StorageService.savePoolItems(_poolItems);
      StorageService.saveUsername(_username);
      StorageService.saveTheme(_currentThemeId);
      final activeTheme = AppThemes.getThemeById(_currentThemeId);
      HomeWidgetService.syncFromGroups(_taskGroups, activeTheme);
    });

    // 2. Realtime subscription
    _unsubscribeRealtime?.call();
    _unsubscribeRealtime = SupabaseService.setupRealtimeSubscription(
      config,
      () {
        SupabaseService.fetchRemoteData(config).then((remote) {
          if (remote == null || !mounted) return;
          setState(() {
            if (remote.taskGroups.isNotEmpty) _taskGroups = remote.taskGroups;
            if (remote.poolItems.isNotEmpty) _poolItems = remote.poolItems;
            if (remote.username != null) _username = remote.username!;
            if (remote.theme != null) _currentThemeId = remote.theme!;
          });
          final activeTheme = AppThemes.getThemeById(_currentThemeId);
          HomeWidgetService.syncFromGroups(_taskGroups, activeTheme);
        });
      },
    );
  }

  void _triggerAutoSync() {
    StorageService.saveTaskGroups(_taskGroups);
    StorageService.savePoolItems(_poolItems);
    StorageService.saveUsername(_username);
    StorageService.saveTheme(_currentThemeId);

    if (_isLoggedIn && _userEmail.isNotEmpty && _userEmail != "user@email.com") {
      StorageService.saveTaskGroupsForUser(_userEmail, _taskGroups);
      StorageService.savePoolItemsForUser(_userEmail, _poolItems);

      FirestoreService.saveUserData(
        email: _userEmail,
        taskGroups: _taskGroups,
        poolItems: _poolItems,
        username: _username,
        theme: _currentThemeId,
        userPicture: _userPicture,
      );
    }

    final activeTheme = AppThemes.getThemeById(_currentThemeId);
    HomeWidgetService.syncFromGroups(_taskGroups, activeTheme);

    if (!_supabaseConfig.isConnected ||
        !_supabaseConfig.autoSync ||
        _supabaseConfig.url.isEmpty) {
      return;
    }

    _debounceSyncTimer?.cancel();
    _debounceSyncTimer = Timer(const Duration(milliseconds: 1500), () {
      SupabaseService.pushAllToSupabase(
        config: _supabaseConfig,
        taskGroups: _taskGroups,
        poolItems: _poolItems,
        username: _username,
        theme: _currentThemeId,
      );
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppThemes.font(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF1F2937),
      ),
    );
  }

  // --- Task Handlers ---
  void _handleAddTask(String groupId, String text) {
    final newTask = Task(
      id: "task-${DateTime.now().millisecondsSinceEpoch}",
      text: text,
      completed: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _taskGroups = _taskGroups.map((grp) {
        if (grp.id == groupId) {
          return grp.copyWith(tasks: [...grp.tasks, newTask]);
        }
        return grp;
      }).toList();
    });

    _showToast("Tugas ditambahkan: \"$text\"");
    _triggerAutoSync();
  }

  void _handleToggleTask(String groupId, String taskId) {
    setState(() {
      _taskGroups = _taskGroups.map((grp) {
        if (grp.id == groupId) {
          return grp.copyWith(
            tasks: grp.tasks.map((t) {
              if (t.id == taskId) {
                return t.copyWith(completed: !t.completed);
              }
              return t;
            }).toList(),
          );
        }
        return grp;
      }).toList();
    });

    _triggerAutoSync();
  }

  void _handleDeleteTask(String groupId, String taskId) {
    setState(() {
      _taskGroups = _taskGroups.map((grp) {
        if (grp.id == groupId) {
          return grp.copyWith(
            tasks: grp.tasks.where((t) => t.id != taskId).toList(),
          );
        }
        return grp;
      }).toList();
    });

    _showToast("Tugas dihapus");
    SupabaseService.deleteTaskFromSupabase(_supabaseConfig, taskId);
    _triggerAutoSync();
  }

  void _handleEditTask(String groupId, String taskId, String newText) {
    setState(() {
      _taskGroups = _taskGroups.map((grp) {
        if (grp.id == groupId) {
          return grp.copyWith(
            tasks: grp.tasks.map((t) {
              if (t.id == taskId) {
                return t.copyWith(text: newText);
              }
              return t;
            }).toList(),
          );
        }
        return grp;
      }).toList();
    });

    _showToast("Tugas diperbarui");
    _triggerAutoSync();
  }

  void _handleUpdateGroupTitle(String groupId, String newTitle) {
    setState(() {
      _taskGroups = _taskGroups.map((grp) {
        if (grp.id == groupId) {
          return grp.copyWith(title: newTitle);
        }
        return grp;
      }).toList();
    });

    _showToast("Judul daftar diperbarui");
    _triggerAutoSync();
  }

  void _handleAddListGroup(String title) {
    final newGroup = TaskGroup(
      id: "group-${DateTime.now().millisecondsSinceEpoch}",
      title: title,
      tasks: [],
    );

    setState(() {
      _taskGroups = [..._taskGroups, newGroup];
    });

    _showToast("Daftar baru \"$title\" berhasil dibuat!");
    _triggerAutoSync();
  }

  void _handleDeleteGroup(String groupId) {
    final group = _taskGroups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => _taskGroups[0],
    );
    final title = group.title;

    setState(() {
      _taskGroups = _taskGroups.where((g) => g.id != groupId).toList();
    });

    _showToast("Daftar \"$title\" berhasil dihapus");
    SupabaseService.deleteGroupFromSupabase(_supabaseConfig, groupId);
    _triggerAutoSync();
  }

  // --- Pool Handlers ---
  void _handleAddPoolItem(String text, String? category) {
    final newItem = PoolItem(
      id: "pool-${DateTime.now().millisecondsSinceEpoch}",
      text: text,
      category: category ?? "Umum",
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _poolItems = [newItem, ..._poolItems];
    });

    _showToast("Ide baru dimasukkan ke Pool!");
    _triggerAutoSync();
  }

  void _handleDeletePoolItem(String id) {
    setState(() {
      _poolItems = _poolItems.where((p) => p.id != id).toList();
    });

    _showToast("Ide dihapus dari Pool");
    SupabaseService.deletePoolItemFromSupabase(_supabaseConfig, id);
    _triggerAutoSync();
  }

  void _handleEditPoolItem(String id, String newText) {
    setState(() {
      _poolItems = _poolItems.map((p) {
        if (p.id == id) {
          return p.copyWith(text: newText);
        }
        return p;
      }).toList();
    });

    _showToast("Ide diperbarui");
    _triggerAutoSync();
  }

  void _handleSaveToPool(String text) {
    _handleAddPoolItem(text, "Disimpan dari To-Do");
  }

  void _handleSendToDashboard(String text) {
    if (_taskGroups.isNotEmpty) {
      _handleAddTask(_taskGroups[0].id, text);
      setState(() => _currentView = "dashboard");
    }
  }

  void _handleThemeChange(String newThemeId) {
    final normalized = AppThemes.normalizeThemeId(newThemeId);
    setState(() {
      _currentThemeId = normalized;
    });
    StorageService.saveTheme(normalized);
    _showToast("Tema diganti: ${normalized.toUpperCase()}");

    if (_supabaseConfig.isConnected && _supabaseConfig.url.isNotEmpty) {
      SupabaseService.updateUserSettingsInSupabase(
        _supabaseConfig,
        _username,
        normalized,
      );
    }
  }

  Future<void> _handleSyncSupabaseNow() async {
    _showToast("Menyinkronkan data ke Supabase...");
    final res = await SupabaseService.pushAllToSupabase(
      config: _supabaseConfig,
      taskGroups: _taskGroups,
      poolItems: _poolItems,
      username: _username,
      theme: _currentThemeId,
    );
    _showToast(res.message);
  }

  void _handleResetToDefaults() {
    final defGroups = StorageService.getDefaultTaskGroups();
    final defPool = StorageService.getDefaultPoolItems();
    setState(() {
      _taskGroups = defGroups;
      _poolItems = defPool;
    });
    StorageService.saveTaskGroups(defGroups);
    StorageService.savePoolItems(defPool);
    _showToast("Data dikembalikan ke setelan awal mockup!");
  }

  Future<void> _handleLoginSuccess(String name, String email, String? avatarUrl) async {
    setState(() {
      _username = name;
      _userEmail = email;
      _userPicture = avatarUrl;
      _isLoggedIn = true;
      _showRegister = false;
      _currentView = "dashboard";
    });
    StorageService.saveUsername(name);
    StorageService.saveUserEmail(email);
    StorageService.saveUserPicture(avatarUrl);
    StorageService.saveIsLoggedIn(true);

    _showToast("Selamat datang, $name!");
    await _syncUserFromFirestore(email, name, avatarUrl);
  }

  void _handleLogout() {
    _firestoreSubscription?.cancel();
    FirebaseAuthService.signOut();
    setState(() {
      _isLoggedIn = false;
      _userEmail = "user@email.com";
      _userPicture = null;
      _username = "Username";
      _showRegister = false;
      _currentView = "dashboard";
      _taskGroups = [];
      _poolItems = [];
    });
    StorageService.clearAuth();
    _showToast("Anda telah logout.");
  }

  Future<void> _syncUserFromFirestore(String email, [String? name, String? avatarUrl]) async {
    _firestoreSubscription?.cancel();

    // 1. Try local per-user cache first
    final cachedGroups = await StorageService.loadTaskGroupsForUser(email);
    final cachedPool = await StorageService.loadPoolItemsForUser(email);

    if (cachedGroups != null) {
      setState(() {
        _taskGroups = cachedGroups;
        if (cachedPool != null) _poolItems = cachedPool;
      });
    }

    // 2. Query Firestore
    final remoteUser = await FirestoreService.fetchUserData(email);

    if (remoteUser != null) {
      // User already has data in Firestore!
      setState(() {
        _taskGroups = remoteUser.taskGroups;
        _poolItems = remoteUser.poolItems;
        if (remoteUser.username != null && remoteUser.username!.isNotEmpty) {
          _username = remoteUser.username!;
        }
        if (remoteUser.theme != null && remoteUser.theme!.isNotEmpty) {
          _currentThemeId = remoteUser.theme!;
        }
        if (remoteUser.userPicture != null) {
          _userPicture = remoteUser.userPicture;
        }
      });
      StorageService.saveTaskGroupsForUser(email, _taskGroups);
      StorageService.savePoolItemsForUser(email, _poolItems);
      StorageService.saveUsername(_username);
      StorageService.saveTheme(_currentThemeId);
    } else {
      // First time user! Empty card like brand new!
      final freshGroups = StorageService.getNewUserTaskGroups(); // tasks: [] (kosong seperti baru!)
      final freshPool = StorageService.getNewUserPoolItems(); // [] (kosong!)

      setState(() {
        _taskGroups = freshGroups;
        _poolItems = freshPool;
      });

      StorageService.saveTaskGroupsForUser(email, freshGroups);
      StorageService.savePoolItemsForUser(email, freshPool);

      await FirestoreService.saveUserData(
        email: email,
        taskGroups: freshGroups,
        poolItems: freshPool,
        username: name ?? _username,
        theme: _currentThemeId,
        userPicture: avatarUrl ?? _userPicture,
      );
    }

    final activeTheme = AppThemes.getThemeById(_currentThemeId);
    HomeWidgetService.syncFromGroups(_taskGroups, activeTheme);

    // 3. Listen to realtime Firestore updates for this user
    _firestoreSubscription = FirestoreService.setupRealtimeSubscription(
      email,
      (updatedUser) {
        if (!mounted) return;
        setState(() {
          _taskGroups = updatedUser.taskGroups;
          _poolItems = updatedUser.poolItems;
          if (updatedUser.username != null && updatedUser.username!.isNotEmpty) {
            _username = updatedUser.username!;
          }
          if (updatedUser.theme != null && updatedUser.theme!.isNotEmpty) {
            _currentThemeId = updatedUser.theme!;
          }
        });
        StorageService.saveTaskGroupsForUser(email, _taskGroups);
        StorageService.savePoolItemsForUser(email, _poolItems);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemes.getThemeById(_currentThemeId);

    return MaterialApp(
      title: 'JUST JEJE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: theme.isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: theme.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.primary,
          brightness: theme.isDark ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          if (_isLoading) {
            return Scaffold(
              backgroundColor: theme.bg,
              body: Center(
                child: CircularProgressIndicator(color: theme.primary),
              ),
            );
          }

          if (!_isLoggedIn) {
            if (_showRegister) {
              return RegisterView(
                onRegisterSuccess: _handleLoginSuccess,
                onNavigateLogin: () => setState(() => _showRegister = false),
                theme: theme,
              );
            }
            return LoginView(
              onLoginSuccess: _handleLoginSuccess,
              onNavigateRegister: () => setState(() => _showRegister = true),
              theme: theme,
            );
          }

          return CustomScaffold(
            theme: theme,
            confettiController: _confettiController,
            appBar: AppHeader(
              currentView: _currentView,
              onOpenSettings: () => setState(() => _currentView = "settings"),
              onNavigateGenerate: () =>
                  setState(() => _currentView = "generate"),
              onNavigateDashboard: () =>
                  setState(() => _currentView = "dashboard"),
              theme: theme,
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _currentView == "dashboard"
                  ? DashboardView(
                      taskGroups: _taskGroups,
                      poolItems: _poolItems,
                      onDeleteGroup: _handleDeleteGroup,
                      onUpdateGroupTitle: _handleUpdateGroupTitle,
                      onAddTask: _handleAddTask,
                      onToggleTask: _handleToggleTask,
                      onDeleteTask: _handleDeleteTask,
                      onEditTask: _handleEditTask,
                      onSaveToPool: _handleSaveToPool,
                      onNavigateGenerate: () =>
                          setState(() => _currentView = "generate"),
                      onOpenAddList: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AddListModal(
                            onAddListGroup: _handleAddListGroup,
                            theme: theme,
                          ),
                        );
                      },
                      onTriggerConfetti: () => _confettiController.play(),
                      theme: theme,
                    )
                  : _currentView == "generate"
                  ? GenerateView(
                      poolItems: _poolItems,
                      onDeletePoolItem: _handleDeletePoolItem,
                      onEditPoolItem: _handleEditPoolItem,
                      onSendToDashboard: _handleSendToDashboard,
                      onOpenAddIdea: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AddIdeaModal(
                            onAddIdea: _handleAddPoolItem,
                            theme: theme,
                          ),
                        );
                      },
                      onRestoreDefaults: () {
                        setState(
                          () =>
                              _poolItems = StorageService.getDefaultPoolItems(),
                        );
                        StorageService.savePoolItems(_poolItems);
                      },
                      onAddIdea: _handleAddPoolItem,
                      theme: theme,
                    )
                  : SettingsView(
                      googleConfig: _googleConfig,
                      onSaveGoogleConfig: (cfg) {
                        setState(() => _googleConfig = cfg);
                        StorageService.saveGoogleConfig(cfg);
                      },
                      supabaseConfig: _supabaseConfig,
                      onSaveSupabaseConfig: (cfg) {
                        setState(() => _supabaseConfig = cfg);
                        StorageService.saveSupabaseConfig(cfg);
                        _initSupabaseSync(cfg);
                      },
                      onSyncSupabaseNow: _handleSyncSupabaseNow,
                      onResetToDefaults: _handleResetToDefaults,
                      taskGroups: _taskGroups,
                      currentThemeId: _currentThemeId,
                      onThemeChange: _handleThemeChange,
                      username: _username,
                      onUpdateUsername: (name) {
                        setState(() => _username = name);
                        StorageService.saveUsername(name);
                      },
                      userEmail: _userEmail,
                      userPicture: _userPicture,
                      onUpdateUserPicture: (pic) {
                        setState(() => _userPicture = pic);
                        StorageService.saveUserPicture(pic);
                      },
                      onLogout: _handleLogout,
                      theme: theme,
                    ),
            ),
            floatingActionButton: _currentView == "dashboard"
                ? FloatingActionButton.extended(
                    heroTag: "fab_add_list",
                    elevation: 3,
                    backgroundColor: theme.isDark
                        ? const Color(0xFF2D354B)
                        : const Color(0xFFCFD3D8),
                    foregroundColor: theme.isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF4B5563),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: theme.isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.transparent,
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 19),
                    label: Text(
                      "Buat List Baru",
                      style: AppThemes.font(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AddListModal(
                          onAddListGroup: _handleAddListGroup,
                          theme: theme,
                        ),
                      );
                    },
                  )
                : null,
          );
        },
      ),
    );
  }
}
