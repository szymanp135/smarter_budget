import 'package:flutter/material.dart';
import 'package:smarter_budget/models/category.dart';
import '../../../providers/app_settings_provider.dart';

class TransactionSummary extends StatelessWidget {
  final String type;
  final BudgetCategory? category;
  final String amount;
  final String date;
  final String description;
  final AppSettingsProvider settings;

  const TransactionSummary({
    super.key,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(
            "${settings.t('type')}:",
            settings.t(type),
            type == 'income' ? Colors.green : Colors.red,
          ),
          const Divider(),
          _buildSummaryRow(
            "${settings.t('category')}:",
            category?.displayName ?? '-',
            null,
          ),
          const Divider(),
          _buildSummaryRow(
            "${settings.t('amount')}:",
            "$amount ${settings.currencySymbol()}",
            Theme.of(context).colorScheme.primary,
            isBold: true,
          ),
          const Divider(),
          _buildSummaryRow("${settings.t('date')}:", date, null),
          const Divider(),
          _buildSummaryRow(
            "${settings.t('description2')}:",
            description.isEmpty ? "-" : description,
            Colors.grey[700],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color? valueColor, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 14,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
