import 'package:flutter/material.dart';
import '../../../providers/app_settings_provider.dart';

class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final List<String> categoryKeys;
  final Function(String?) onChanged;
  final AppSettingsProvider settings;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.categoryKeys,
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
      items: categoryKeys.map((catKey) {
        return DropdownMenuItem(
          value: catKey,
          child: Row(
            children: [
              Icon(
                settings.getCategoryIcon(catKey),
                color: settings.getCategoryColor(catKey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  settings.translateCategory(catKey),
                  overflow: TextOverflow.ellipsis,
                ),
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
