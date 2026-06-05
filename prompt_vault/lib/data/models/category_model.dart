import 'package:flutter/material.dart';
import '../../core/utils/extensions.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String colorHex;
  final int? promptCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    this.promptCount,
  });

  Color get color => HexColor.fromHex(colorHex);

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '⚡',
      colorHex: json['color'] as String? ?? '#8B8BA7',
      promptCount: json['prompt_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'color': colorHex,
  };

  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? colorHex,
    int? promptCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      promptCount: promptCount ?? this.promptCount,
    );
  }

  // Pre-defined default categories
  static const List<CategoryModel> defaults = [
    CategoryModel(id: '', name: 'Semua', icon: '🌐', colorHex: '#6C63FF'),
    CategoryModel(id: 'coding', name: 'Coding', icon: '💻', colorHex: '#6C63FF'),
    CategoryModel(id: 'writing', name: 'Writing', icon: '✍️', colorHex: '#FF6584'),
    CategoryModel(id: 'riset', name: 'Riset', icon: '🔬', colorHex: '#00D4FF'),
    CategoryModel(id: 'analisis', name: 'Analisis', icon: '📊', colorHex: '#FFB347'),
    CategoryModel(id: 'kreatif', name: 'Kreatif', icon: '🎨', colorHex: '#A8E6CF'),
    CategoryModel(id: 'bisnis', name: 'Bisnis', icon: '💼', colorHex: '#C9B1FF'),
    CategoryModel(id: 'belajar', name: 'Belajar', icon: '📚', colorHex: '#FFD93D'),
    CategoryModel(id: 'lainnya', name: 'Lainnya', icon: '⚡', colorHex: '#8B8BA7'),
  ];
}
