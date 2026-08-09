import 'package:flutter/material.dart';
import '../../presentation/utils/icon_helper.dart';
import 'transaction_type.dart';

class CategoryItem {
  final String id;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final TransactionType type;
  final bool isCustom;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    this.type = TransactionType.expense,
    this.isCustom = true,
  });

  IconData get icon => AppIconHelper.getIcon(iconCodePoint);
  Color get color => Color(colorValue);

  CategoryItem copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? colorValue,
    TransactionType? type,
    bool? isCustom,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'type': type.name,
      'isCustom': isCustom,
    };
  }

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCodePoint: map['iconCodePoint'] as int,
      colorValue: map['colorValue'] as int,
      type: TransactionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      isCustom: map['isCustom'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryItem && (other.id == id || other.name.toLowerCase() == name.toLowerCase());
  }

  @override
  int get hashCode => id.hashCode ^ name.toLowerCase().hashCode;
}
