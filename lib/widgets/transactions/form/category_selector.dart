import 'package:flutter/material.dart';
import 'package:smart_budget/models/category.dart';
import '../../../providers/app_settings_provider.dart';

class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final List<BudgetCategory> categories;
  final Function(String?) onChanged;
  final AppSettingsProvider settings;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onChanged,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedCategory,
      hint: Text(
        settings.t('select_category'),
        overflow: TextOverflow.ellipsis,
      ),
      isExpanded: true,
      items: categories.map((cat) {
        return DropdownMenuItem(
          value: cat.id,
          child: Row(
            children: [
              Icon(
                IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'),
                color: Color(cat.colorValue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(cat.displayName, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) =>
          value == null ? settings.t('select_category') : null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }
}
