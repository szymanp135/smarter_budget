import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget/providers/category_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/transactions/transaction_form.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Provider.of<UserProvider>(context).transactionsBox;
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return TransactionForm(
      categoryProvider: categoryProvider,
      titleKey: 'add_transaction',
      buttonKey: 'save',
      onSubmit: (tx) {
        if (box != null) {
          box.add(tx);
        }
      },
    );
  }
}
