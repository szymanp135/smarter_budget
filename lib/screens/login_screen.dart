import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/auth/auth_layout.dart';
import 'register_screen.dart';
import 'main_screen.dart';
import 'currency_selection_screen.dart';

class _SettingsDropdowns extends StatelessWidget {
  const _SettingsDropdowns();

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<AppLanguage>(
                value: settings.language,
                items: [
                  DropdownMenuItem(
                    value: AppLanguage.pl,
                    child: Text(
                      settings.t('polish'),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  DropdownMenuItem(
                    value: AppLanguage.en,
                    child: Text(
                      settings.t('english'),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) settings.changeLanguage(value);
                },
                underline: const SizedBox(),
              ),
              const SizedBox(width: 8),
              DropdownButton<AppTheme>(
                value: settings.theme,
                items: [
                  DropdownMenuItem(
                    value: AppTheme.light,
                    child: Text(
                      settings.t('light_theme'),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  DropdownMenuItem(
                    value: AppTheme.dark,
                    child: Text(
                      settings.t('dark_theme'),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) settings.toggleTheme(value);
                },
                underline: const SizedBox(),
              ),
              const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, settings, _) {
        final userProv = Provider.of<UserProvider>(context, listen: false);
        final primaryColor = Theme.of(context).colorScheme.primary;

        return AuthLayout(
          title: settings.t('app_name'),
          appBarActions: const [_SettingsDropdowns()],
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: settings.t('username'),
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: settings.t('password'),
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final selectedTheme = settings.theme;
                  final selectedLanguage = settings.language;
                  final ok = await userProv.login(
                    usernameController.text.trim(),
                    passwordController.text,
                  );

                  if (!ok) {
                    if (mounted) {
                      setState(() => error = settings.t('invalid_credentials'));
                    }
                  } else {
                    if (!context.mounted) return;

                    await userProv.updateSettings(
                      theme: selectedTheme,
                      language: selectedLanguage,
                    );

                    if (!context.mounted) return;

                    settings.changeLanguage(selectedLanguage);
                    settings.toggleTheme(selectedTheme);

                    final user = userProv.currentUser;
                    final nextScreen = user != null && user.currency == null
                        ? const CurrencySelectionScreen()
                        : const MainScreen();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => nextScreen),
                    );
                  }
                },
                child: Text(
                  settings.t('login'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() => error = null);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: Text(
                settings.t('create_account'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}
