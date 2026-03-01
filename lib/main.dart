import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smart_budget/providers/category_provider.dart';

import 'models/category.dart';
import 'models/transaction.dart';
import 'models/user.dart';
import 'models/enums_adapters.dart';
import 'providers/app_settings_provider.dart';
import 'providers/user_provider.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await initializeDateFormatting('pl_PL', null);
  await initializeDateFormatting('en_US', null);

  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(AppUserAdapter());
  Hive.registerAdapter(AppThemeAdapter());
  Hive.registerAdapter(AppLanguageAdapter());
  Hive.registerAdapter(AppCurrencyAdapter());
  Hive.registerAdapter(BudgetCategoryAdapter());

  await Hive.openBox('users');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),

        ChangeNotifierProxyProvider<UserProvider, AppSettingsProvider>(
          create: (context) {
            final userProvider = Provider.of<UserProvider>(
              context,
              listen: false,
            );
            final categoryProvider = Provider.of<CategoryProvider>(
              context,
              listen: false,
            );
            final settings = AppSettingsProvider(userProvider);

            userProvider.init(settings);
            userProvider.loadLastUser();
            categoryProvider.init(userProvider);

            return settings;
          },
          update: (_, __, existing) => existing!,
        ),
      ],
      child: const SmartBudgetApp(),
    ),
  );
}

class SmartBudgetApp extends StatelessWidget {
  const SmartBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'SmartBudget',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: settings.themeMode,

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US'), Locale('pl', 'PL')],

          home: Consumer<UserProvider>(
            builder: (context, userProv, _) {
              if (!userProv.isInitialized) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userProv.currentUser != null) {
                return const MainScreen();
              }

              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
