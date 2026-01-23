import 'package:flutter/material.dart';
import '../../providers/app_settings_provider.dart';

class SavingsCard extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;
  final AppSettingsProvider settings;

  const SavingsCard({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositive = balance >= 0;
    int expenseFlex;
    int savingsFlex;

    double totalTurnover = income + expense;

    if (totalTurnover == 0) {
      expenseFlex = 0;
      savingsFlex = 0;
    } else {
      double expenseRatio = expense / totalTurnover;
      double incomeRatio = income / totalTurnover;

      expenseFlex = (expenseRatio * 1000).toInt();
      savingsFlex = (incomeRatio * 1000).toInt();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            settings.t('your_balance'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${balance > 0 ? '+' : ''}${balance.toStringAsFixed(2)} ${settings.currencySymbol()}',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.red,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  if (expenseFlex > 0)
                    Expanded(
                      flex: expenseFlex,
                      child: Container(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                  if (savingsFlex > 0)
                    Expanded(
                      flex: savingsFlex,
                      child: Container(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                  if (expenseFlex == 0 && savingsFlex == 0)
                    Expanded(
                      child: Container(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.t('expense'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${expense.toStringAsFixed(2)} ${settings.currencySymbol()}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      settings.t('income'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${income.toStringAsFixed(2)} ${settings.currencySymbol()}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
