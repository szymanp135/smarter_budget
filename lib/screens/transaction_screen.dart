import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../providers/user_provider.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/transactions/budget_card.dart';
import '../widgets/transactions/transaction_list_item.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  String _formatMonthYear(DateTime date, AppLanguage language) {
    final locale = language == AppLanguage.pl ? 'pl_PL' : 'en_US';
    return DateFormat.yMMMM(locale).format(date);
  }

  dynamic _findKeyByTransactionId(Box box, String transactionId) {
    for (var entry in box.toMap().entries) {
      if (entry.value.id == transactionId) {
        return entry.key;
      }
    }
    return null;
  }

  void _openEdit(BuildContext context, Transaction tx, dynamic txKey) {
    if (txKey != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EditTransactionScreen(transaction: tx, transactionKey: txKey),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final settings = Provider.of<AppSettingsProvider>(context);
    final box = userProv.transactionsBox;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: box == null
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<Transaction> b, _) {
                final now = DateTime.now();
                final currentMonthExpenses = b.values.where(
                  (tx) =>
                      tx.date.year == now.year &&
                      tx.date.month == now.month &&
                      tx.type == 'expense',
                );

                double monthlyExpensesSum = 0;
                for (var tx in currentMonthExpenses) {
                  monthlyExpensesSum += settings.convertAmount(tx.amount);
                }

                final limit = userProv.currentUser?.monthlyLimit;
                final groupedData = userProv.getGroupedTransactions();

                return CustomScrollView(
                  slivers: [
                    if (limit != null && limit > 0)
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _BudgetCardDelegate(
                          child: BudgetCard(
                            currentExpenses: monthlyExpensesSum,
                            limit: limit,
                            settings: settings,
                          ),
                        ),
                      ),

                    if (groupedData.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text(
                              settings.t('no_transactions'),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ),
                      )
                    else
                      ...groupedData.map((group) {
                        return SliverMainAxisGroup(
                          slivers: [
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _StickyHeaderDelegate(
                                title: _formatMonthYear(
                                  group.date,
                                  settings.language,
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final tx = group.transactions[index];
                                final txKey = _findKeyByTransactionId(b, tx.id);

                                return TransactionListItem(
                                  transaction: tx,
                                  settings: settings,
                                  onDelete: () async {
                                    if (txKey == null) return;

                                    final deletedTransaction = tx;
                                    await b.delete(txKey);

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(
                                      context,
                                    ).clearSnackBars();

                                    bool isUndoPerformed = false;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 4),
                                        content: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final isVeryNarrow =
                                                constraints.maxWidth < 120;

                                            return Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    settings.t(
                                                      'transaction_deleted',
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isVeryNarrow)
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.undo,
                                                    ),
                                                    tooltip: settings.t('undo'),
                                                    color: Colors.red,
                                                    onPressed: () async {
                                                      if (isUndoPerformed) {
                                                        return;
                                                      }
                                                      isUndoPerformed = true;
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).hideCurrentSnackBar();
                                                      await b.add(
                                                        deletedTransaction,
                                                      );
                                                    },
                                                  )
                                                else
                                                  TextButton(
                                                    onPressed: () async {
                                                      if (isUndoPerformed) {
                                                        return;
                                                      }
                                                      isUndoPerformed = true;
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).hideCurrentSnackBar();
                                                      await b.add(
                                                        deletedTransaction,
                                                      );
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.red,
                                                      textStyle:
                                                          const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      settings
                                                          .t('undo')
                                                          .toUpperCase(),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  onConfirmDismiss: (direction) async {
                                    if (direction ==
                                        DismissDirection.startToEnd) {
                                      _openEdit(context, tx, txKey);
                                      return false;
                                    }
                                    return true;
                                  },
                                  onTap: () => _openEdit(context, tx, txKey),
                                );
                              }, childCount: group.transactions.length),
                            ),
                          ],
                        );
                      }),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                  ],
                );
              },
            ),
    );
  }
}

class _BudgetCardDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _BudgetCardDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.topCenter,
      child: child,
    );
  }

  @override
  double get maxExtent => 130.0;

  @override
  double get minExtent => 130.0;

  @override
  bool shouldRebuild(covariant _BudgetCardDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;

  _StickyHeaderDelegate({required this.title});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      alignment: Alignment.centerLeft,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.title != title;
  }
}
