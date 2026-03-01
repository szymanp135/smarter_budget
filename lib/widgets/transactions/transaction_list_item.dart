import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:smarter_budget/providers/category_provider.dart';
import '../../models/transaction.dart';
import '../../providers/app_settings_provider.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final AppSettingsProvider settings;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Future<bool> Function(DismissDirection) onConfirmDismiss;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.settings,
    required this.onTap,
    required this.onDelete,
    required this.onConfirmDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final converted = settings.convertAmount(transaction.amount);
    final symbol = settings.currencySymbol();
    final isIncome = transaction.type == "income";
    final category = Provider.of<CategoryProvider>(
      context,
    ).getCategoryById(transaction.categoryId);

    final String displayTitle = transaction.title.isEmpty && category != null
        ? category.displayName
        : transaction.title;

    final bool showSubtitle = transaction.title.isNotEmpty;

    return Dismissible(
      key: Key(transaction.id),
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
              CircleAvatar(
                backgroundColor: isIncome
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                child: Icon(
                  IconData(
                    category?.iconCodePoint ??
                        Icons.question_mark_rounded.codePoint,
                    fontFamily: 'MaterialIcons',
                  ),
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                      child: _buildMarqueeOrText(
                        displayTitle,
                        Theme.of(context).textTheme.bodyLarge!,
                      ),
                    ),
                    if (showSubtitle)
                      Text(
                        category?.displayName ??
                            'unknown category (id: ${transaction.categoryId})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${converted.toStringAsFixed(2)} $symbol',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.red,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarqueeOrText(String text, TextStyle style) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: double.infinity);

        if (textPainter.width > constraints.maxWidth) {
          return Marquee(
            text: text,
            style: style,
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            blankSpace: 30.0,
            velocity: 30.0,
            pauseAfterRound: const Duration(seconds: 2),
            startPadding: 0.0,
            accelerationDuration: const Duration(seconds: 1),
            accelerationCurve: Curves.linear,
          );
        } else {
          return Text(text, style: style);
        }
      },
    );
  }
}
