import 'package:flutter/material.dart';
import '../../../providers/app_settings_provider.dart';

class TransactionTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;
  final bool isNarrowScreen;
  final double maxWidth;
  final AppSettingsProvider settings;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.isNarrowScreen,
    required this.maxWidth,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ToggleButtons(
        direction: isNarrowScreen ? Axis.vertical : Axis.horizontal,
        isSelected: [selectedType == "expense", selectedType == "income"],
        onPressed: (index) {
          onTypeChanged(index == 0 ? "expense" : "income");
        },
        borderRadius: BorderRadius.circular(8),
        fillColor: selectedType == "expense" ? Colors.red : Colors.green,
        selectedColor: Colors.white,
        color: Colors.grey[600],
        constraints: BoxConstraints(
          minWidth: isNarrowScreen
              ? (maxWidth > 60 ? maxWidth - 60 : 100)
              : 100,
          minHeight: 40,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              settings.t('expense'),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              settings.t('income'),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
