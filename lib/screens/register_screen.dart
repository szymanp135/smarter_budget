import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/auth/auth_layout.dart';
import 'currency_selection_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  String? error;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, settings, _) {
        final userProv = Provider.of<UserProvider>(context, listen: false);
        final primaryColor = Theme.of(context).colorScheme.primary;

        return AuthLayout(
          title: settings.t('create_account'),
          children: [
            TextField(
              controller: username,
              decoration: InputDecoration(
                labelText: settings.t('username'),
                prefixIcon: const Icon(Icons.person_add),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: settings.t('password'),
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: settings.t('repeat_password'),
                prefixIcon: const Icon(Icons.lock_reset),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                  if (username.text.trim().isEmpty || password.text.isEmpty) {
                    setState(() {
                      error = settings.t('fill_all_fields');
                    });
                    return;
                  }

                  if (password.text != confirmPassword.text) {
                    setState(() {
                      error = settings.t('passwords_do_not_match');
                    });
                    return;
                  }

                  final selectedTheme = settings.theme;
                  final selectedLanguage = settings.language;

                  final ok = await userProv.register(
                    username.text.trim(),
                    password.text,
                  );

                  if (!ok) {
                    if (mounted) {
                      setState(() => error = settings.t('username_exists'));
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

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CurrencySelectionScreen(),
                      ),
                    );
                  }
                },
                child: Text(
                  settings.t('create_account'),
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
                Navigator.pop(context);
              },
              child: Text(
                settings.t('go_to_login'),
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
