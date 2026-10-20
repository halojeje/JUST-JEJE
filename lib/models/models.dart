class Task {
  final String id;
  String text;
  bool completed;
  final int createdAt;
  String? googleTaskId;

  Task({
    required this.id,
    required this.text,
    this.completed = false,
    required this.createdAt,
    this.googleTaskId,
  });

  Task copyWith({
    String? id,
    String? text,
    bool? completed,
    int? createdAt,
    String? googleTaskId,
  }) {
    return Task(
      id: id ?? this.id,
      text: text ?? this.text,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      googleTaskId: googleTaskId ?? this.googleTaskId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'completed': completed,
      'createdAt': createdAt,
      'googleTaskId': googleTaskId,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String? ?? 'task-${DateTime.now().millisecondsSinceEpoch}',
      text: json['text'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      createdAt: (json['createdAt'] is num)
          ? (json['createdAt'] as num).toInt()
          : (json['created_at'] is num
              ? (json['created_at'] as num).toInt()
              : DateTime.now().millisecondsSinceEpoch),
      googleTaskId: json['googleTaskId'] as String? ?? json['google_task_id'] as String?,
    );
  }
}

class TaskGroup {
  final String id;
  String title;
  List<Task> tasks;

  TaskGroup({
    required this.id,
    required this.title,
    required this.tasks,
  });

  TaskGroup copyWith({
    String? id,
    String? title,
    List<Task>? tasks,
  }) {
    return TaskGroup(
      id: id ?? this.id,
      title: title ?? this.title,
      tasks: tasks ?? List.from(this.tasks),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }

  factory TaskGroup.fromJson(Map<String, dynamic> json) {
    var rawTasks = json['tasks'] as List<dynamic>? ?? [];
    List<Task> parsedTasks = rawTasks
        .map((t) => Task.fromJson(t as Map<String, dynamic>))
        .toList();

    return TaskGroup(
      id: json['id'] as String? ?? 'group-${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Daftar Tugas',
      tasks: parsedTasks,
    );
  }
}

class PoolItem {
  final String id;
  String text;
  String? category;
  final int createdAt;

  PoolItem({
    required this.id,
    required this.text,
    this.category,
    required this.createdAt,
  });

  PoolItem copyWith({
    String? id,
    String? text,
    String? category,
    int? createdAt,
  }) {
    return PoolItem(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'createdAt': createdAt,
    };
  }

  factory PoolItem.fromJson(Map<String, dynamic> json) {
    return PoolItem(
      id: json['id'] as String? ?? 'pool-${DateTime.now().millisecondsSinceEpoch}',
      text: json['text'] as String? ?? '',
      category: json['category'] as String? ?? 'Umum',
      createdAt: (json['createdAt'] is num)
          ? (json['createdAt'] as num).toInt()
          : (json['created_at'] is num
              ? (json['created_at'] as num).toInt()
              : DateTime.now().millisecondsSinceEpoch),
    );
  }
}

class GoogleSyncConfig {
  String clientId;
  bool isConnected;
  String? userEmail;
  String? userName;
  String? userPicture;
  bool autoSync;
  int? lastSyncedAt;

  GoogleSyncConfig({
    required this.clientId,
    this.isConnected = false,
    this.userEmail,
    this.userName,
    this.userPicture,
    this.autoSync = false,
    this.lastSyncedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'isConnected': isConnected,
      'userEmail': userEmail,
      'userName': userName,
      'userPicture': userPicture,
      'autoSync': autoSync,
      'lastSyncedAt': lastSyncedAt,
    };
  }

  factory GoogleSyncConfig.fromJson(Map<String, dynamic> json) {
    return GoogleSyncConfig(
      clientId: json['clientId'] as String? ?? '',
      isConnected: json['isConnected'] as bool? ?? false,
      userEmail: json['userEmail'] as String?,
      userName: json['userName'] as String?,
      userPicture: json['userPicture'] as String?,
      autoSync: json['autoSync'] as bool? ?? false,
      lastSyncedAt: (json['lastSyncedAt'] as num?)?.toInt(),
    );
  }
}

class SupabaseConfig {
  String url;
  String publishableKey;
  bool isConnected;
  bool autoSync;
  int? lastSyncedAt;

  SupabaseConfig({
    required this.url,
    required this.publishableKey,
    this.isConnected = true,
    this.autoSync = true,
    this.lastSyncedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'publishableKey': publishableKey,
      'isConnected': isConnected,
      'autoSync': autoSync,
      'lastSyncedAt': lastSyncedAt,
    };
  }

  factory SupabaseConfig.fromJson(Map<String, dynamic> json) {
    return SupabaseConfig(
      url: json['url'] as String? ?? '',
      publishableKey: json['publishableKey'] as String? ?? '',
      isConnected: json['isConnected'] as bool? ?? true,
      autoSync: json['autoSync'] as bool? ?? true,
      lastSyncedAt: (json['lastSyncedAt'] as num?)?.toInt(),
    );
  }
}
