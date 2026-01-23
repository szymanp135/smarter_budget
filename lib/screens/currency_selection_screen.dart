import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/user_provider.dart';
import 'main_screen.dart';

class CurrencySelectionScreen extends StatelessWidget {
  const CurrencySelectionScreen({super.key});

  void _selectCurrency(BuildContext context, AppCurrency currency) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.updateSettings(currency: currency);

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          settings.t('select_currency_title'),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          settings.t('select_currency_prompt'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 48),
                        _buildCurrencyButton(
                          context,
                          label: 'PLN (Złoty)',
                          onPressed: () =>
                              _selectCurrency(context, AppCurrency.pln),
                        ),
                        const SizedBox(height: 16),
                        _buildCurrencyButton(
                          context,
                          label: 'EUR (Euro)',
                          onPressed: () =>
                              _selectCurrency(context, AppCurrency.eur),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrencyButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
