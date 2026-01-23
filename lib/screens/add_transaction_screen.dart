import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/transactions/transaction_form.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Provider.of<UserProvider>(context).transactionsBox;

    return TransactionForm(
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
