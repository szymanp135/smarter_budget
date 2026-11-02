import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class BudgetCategory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String displayName;

  @HiveField(2)
  final int iconCodePoint;

  @HiveField(3)
  final int colorValue;

  @HiveField(4)
  final String type;

  BudgetCategory({
    required this.id,
    required this.displayName,
    required this.iconCodePoint,
    required this.colorValue,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'iconCodePoint': iconCodePoint,
    'colorValue': colorValue,
    'type': type,
  };

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? '',
      iconCodePoint: json['iconCodePoint'] ?? 0,
      colorValue: json['colorValue'] ?? 0,
      type: json['type'] ?? 'expense',
    );
  }
}
