import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarter_budget/providers/category_provider.dart';
import '../models/transaction.dart';
import '../providers/user_provider.dart';
import '../widgets/transactions/transaction_form.dart';

class EditTransactionScreen extends StatelessWidget {
  final Transaction transaction;
  final dynamic transactionKey;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.transactionKey,
  });

  @override
  Widget build(BuildContext context) {
    final box = Provider.of<UserProvider>(context).transactionsBox;
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return TransactionForm(
      transaction: transaction,
      titleKey: 'edit_transaction',
      buttonKey: 'save_changes',
      categoryProvider: categoryProvider,
      onSubmit: (tx) {
        if (box != null) {
          box.put(transactionKey, tx);
        }
      },
    );
  }
}
