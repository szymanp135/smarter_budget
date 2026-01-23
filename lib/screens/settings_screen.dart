import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/app_settings_provider.dart';
import '../providers/user_provider.dart';
import '../screens/login_screen.dart';
import '../widgets/common/section_header.dart';
import '../widgets/settings/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportCSV(
    BuildContext context,
    UserProvider userProv,
    AppSettingsProvider settings,
  ) async {
    final transactions = userProv.transactionsBox?.values.toList() ?? [];

    if (transactions.isEmpty) {
      final msg = settings.t('no_transactions');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    try {
      List<List<dynamic>> rows = [];
      rows.add([
        settings.t('date'),
        settings.t('title'),
        settings.t('category'),
        settings.t('type'),
        settings.t('amount'),
      ]);

      for (var tx in transactions) {
        rows.add([
          DateFormat('yyyy-MM-dd').format(tx.date),
          tx.title,
          settings.t(tx.category),
          settings.t(tx.type),
          tx.amount,
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);
      List<int> bytes = [0xEF, 0xBB, 0xBF];
      bytes.addAll(utf8.encode(csvData));
      Uint8List dataToSave = Uint8List.fromList(bytes);

      final now = DateTime.now();
      final fileName =
          'smart_budget_${DateFormat('yyyyMMdd_HHmmss').format(now)}';
      String savedPath = "";

      if (Platform.isAndroid) {
        final directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          savedPath = await FileSaver.instance.saveFile(
            name: fileName,
            bytes: dataToSave,
            ext: 'csv',
            mimeType: MimeType.csv,
          );
        } else {
          final path = '${directory.path}/$fileName.csv';
          final file = File(path);
          await file.writeAsBytes(dataToSave);
          savedPath = path;
        }
      } else {
        savedPath = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: dataToSave,
          ext: 'csv',
          mimeType: MimeType.csv,
        );
      }

      if (context.mounted) {
        final successMsg = "${settings.t('csv_saved')}$savedPath";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final errorMsg = "${settings.t('csv_error')}$e";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final userProv = Provider.of<UserProvider>(context);
    final cardColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final iconColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(settings.t('settings'))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(Icons.person, size: 40, color: iconColor),
                    ),
                    const SizedBox(height: 16),
                    Consumer<UserProvider>(
                      builder: (context, provider, child) {
                        final username = provider.currentUsername;
                        if (username != null) {
                          return Text(
                            '${settings.t('welcome_message')} $username!',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SectionHeader(title: settings.t('preferences')),
              Card(
                color: cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.palette_outlined,
                      title: settings.t('theme'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AppTheme>(
                          value: settings.theme,
                          borderRadius: BorderRadius.circular(12),
                          items: [
                            DropdownMenuItem(
                              value: AppTheme.light,
                              child: Text(
                                settings.t('light_theme'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: AppTheme.dark,
                              child: Text(
                                settings.t('dark_theme'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) settings.toggleTheme(v);
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    SettingsTile(
                      icon: Icons.language,
                      title: settings.t('language'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AppLanguage>(
                          value: settings.language,
                          borderRadius: BorderRadius.circular(12),
                          items: [
                            DropdownMenuItem(
                              value: AppLanguage.pl,
                              child: Text(
                                settings.t('polish'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: AppLanguage.en,
                              child: Text(
                                settings.t('english'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) settings.changeLanguage(v);
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    SettingsTile(
                      icon: Icons.attach_money,
                      title: settings.t('currency'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AppCurrency>(
                          value: settings.currency,
                          borderRadius: BorderRadius.circular(12),
                          items: const [
                            DropdownMenuItem(
                              value: AppCurrency.pln,
                              child: Text("PLN"),
                            ),
                            DropdownMenuItem(
                              value: AppCurrency.eur,
                              child: Text("EUR"),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) settings.changeCurrency(v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(title: settings.t('budget')),
              Card(
                color: cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SettingsTile(
                  icon: Icons.savings_outlined,
                  title: settings.t('monthly_limit'),
                  subtitle:
                      userProv.currentUser?.monthlyLimit != null &&
                          userProv.currentUser!.monthlyLimit! > 0
                      ? '${userProv.currentUser!.monthlyLimit!.toStringAsFixed(2)} ${settings.currencySymbol()}'
                      : settings.t('no_limit'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        _showLimitDialog(context, settings, userProv),
                  ),
                  onTap: () => _showLimitDialog(context, settings, userProv),
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(title: settings.t('data_section')),
              Card(
                color: cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SettingsTile(
                  icon: Icons.save_alt,
                  title: settings.t('save_csv'),
                  subtitle: settings.t('download_history'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _exportCSV(context, userProv, settings),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.errorContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onErrorContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () =>
                      _showLogoutDialog(context, settings, userProv),
                  icon: const Icon(Icons.logout),
                  label: Text(
                    settings.t('logout'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showLimitDialog(
    BuildContext context,
    AppSettingsProvider settings,
    UserProvider userProv,
  ) {
    String initialValue = '';
    if (userProv.currentUser?.monthlyLimit != null &&
        userProv.currentUser!.monthlyLimit! > 0) {
      initialValue = userProv.currentUser!.monthlyLimit!.toStringAsFixed(2);
      if (initialValue.endsWith('.00')) {
        initialValue = initialValue.substring(0, initialValue.length - 3);
      }
    }

    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(settings.t('set_limit')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              settings.t('limit_description'),
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  String text = newValue.text.replaceAll(',', '.');
                  if ('.'.allMatches(text).length > 1) return oldValue;
                  if (text.contains('.')) {
                    final parts = text.split('.');
                    if (parts.length > 1 && parts[1].length > 2) {
                      return oldValue;
                    }
                  }
                  if (text.length > 1 &&
                      text.startsWith('0') &&
                      text[1] != '.') {
                    text = text.substring(1);
                  }
                  return newValue.copyWith(
                    text: text,
                    selection: TextSelection.collapsed(offset: text.length),
                  );
                }),
              ],
              decoration: InputDecoration(
                suffixText: settings.currencySymbol(),
                hintText: settings.t('example_hint'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(settings.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text.replaceAll(',', '.'));
              userProv.updateSettings(monthlyLimit: val ?? 0.0);
              Navigator.pop(ctx);
            },
            child: Text(settings.t('save')),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    AppSettingsProvider settings,
    UserProvider userProv,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(settings.t('logout_confirmation')),
          content: Text(settings.t('logout_message')),
          actions: [
            TextButton(
              child: Text(settings.t('no')),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(settings.t('yes')),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await userProv.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
