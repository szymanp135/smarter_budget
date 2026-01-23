import 'package:flutter/material.dart';
import '../../providers/app_settings_provider.dart';

class BudgetCard extends StatelessWidget {
  final double currentExpenses;
  final double limit;
  final AppSettingsProvider settings;

  const BudgetCard({
    super.key,
    required this.currentExpenses,
    required this.limit,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    if (limit <= 0) return const SizedBox.shrink();

    final defaultTextColor = Theme.of(context).colorScheme.onSurface;
    final amountColor = currentExpenses > limit ? Colors.red : defaultTextColor;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            settings.t('your_budget'),
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "${currentExpenses.toStringAsFixed(2)} / ${limit.toStringAsFixed(2)} ${settings.currencySymbol()}",
            style: TextStyle(fontWeight: FontWeight.bold, color: amountColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (currentExpenses / limit).clamp(0.0, 1.0),
            backgroundColor: Colors.grey[300],
            color: currentExpenses > limit ? Colors.red : Colors.green,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          if (currentExpenses > limit)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "${settings.t('over_budget_by')} ${(currentExpenses - limit).toStringAsFixed(2)}!",
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
