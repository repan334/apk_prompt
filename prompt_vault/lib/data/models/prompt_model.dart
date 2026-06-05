class PromptModel {
  final String id;
  final String title;
  final String content;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? useCase;
  final String? notes;
  final List<String> tags;
  final bool isFavorite;
  final int usageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PromptModel({
    required this.id,
    required this.title,
    required this.content,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.useCase,
    this.notes,
    this.tags = const [],
    this.isFavorite = false,
    this.usageCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PromptModel.fromJson(Map<String, dynamic> json) {
    List<String> tags = [];
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        tags = List<String>.from(json['tags'] as List);
      }
    }

    // Handle category from join
    String? catName;
    String? catIcon;
    String? catColor;
    if (json['categories'] != null) {
      final cat = json['categories'] as Map<String, dynamic>;
      catName = cat['name'] as String?;
      catIcon = cat['icon'] as String?;
      catColor = cat['color'] as String?;
    }

    return PromptModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      categoryId: json['category_id'] as String?,
      categoryName: catName ?? json['category_name'] as String?,
      categoryIcon: catIcon ?? json['category_icon'] as String?,
      categoryColor: catColor ?? json['category_color'] as String?,
      useCase: json['use_case'] as String?,
      notes: json['notes'] as String?,
      tags: tags,
      isFavorite: json['is_favorite'] as bool? ?? false,
      usageCount: json['usage_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'category_id': categoryId,
    'use_case': useCase,
    'notes': notes,
    'tags': tags,
    'is_favorite': isFavorite,
    'usage_count': usageCount,
  };

  Map<String, dynamic> toInsertJson() => {
    'title': title,
    'content': content,
    'category_id': categoryId,
    'use_case': useCase,
    'notes': notes,
    'tags': tags,
    'is_favorite': isFavorite,
    'usage_count': 0,
  };

  PromptModel copyWith({
    String? id,
    String? title,
    String? content,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    String? useCase,
    String? notes,
    List<String>? tags,
    bool? isFavorite,
    int? usageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PromptModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      useCase: useCase ?? this.useCase,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get previewContent {
    if (content.length <= 120) return content;
    return '${content.substring(0, 120)}...';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PromptModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
