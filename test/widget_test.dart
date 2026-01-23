import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget/main.dart';
import 'package:smart_budget/providers/app_settings_provider.dart';
import 'package:smart_budget/providers/user_provider.dart';

void main() {
  testWidgets('SmartBudgetApp builds without crashing and shows title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProxyProvider<UserProvider, AppSettingsProvider>(
            create: (context) {
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              final settings = AppSettingsProvider(userProvider);
              userProvider.init(settings);
              return settings;
            },
            update: (_, __, existing) => existing!,
          ),
        ],
        child: const SmartBudgetApp(),
      ),
    );
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
