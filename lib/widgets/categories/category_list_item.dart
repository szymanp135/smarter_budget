import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:smart_budget/models/category.dart';
import 'package:smart_budget/providers/category_provider.dart';
import '../../models/transaction.dart';
import '../../providers/app_settings_provider.dart';

class CategoryListItem extends StatelessWidget {
  final BudgetCategory category;
  final CategoryProvider categoryProvider;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Future<bool> Function(DismissDirection) onConfirmDismiss;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.categoryProvider,
    required this.onTap,
    required this.onDelete,
    required this.onConfirmDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(category.id),
      background: Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.edit, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: onConfirmDismiss,
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
                  color: Color(category.colorValue),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(category.displayName)),
              const SizedBox(width: 8),
              Icon(
                switch (category.type) {
                  'income' => Icons.trending_up_rounded,
                  'expense' => Icons.trending_down_rounded,
                  _ => Icons.question_mark_rounded,
                },
                color: switch (category.type) {
                  'income' => Colors.green,
                  'expense' => Colors.red,
                  _ => Colors.grey,
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
