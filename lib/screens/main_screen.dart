import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'transaction_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import '../providers/app_settings_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final showBottomBar = screenHeight >= 70;

    return Consumer<AppSettingsProvider>(
      builder: (context, settings, _) {
        final screens = [const TransactionScreen(), const StatisticsScreen()];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              settings.t('app_name'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          body: screens[_selectedIndex],

          bottomNavigationBar: showBottomBar
              ? BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) => setState(() => _selectedIndex = index),
                  type: BottomNavigationBarType.fixed,

                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  iconSize: 24,

                  showSelectedLabels: true,
                  showUnselectedLabels: true,

                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.list_alt),
                      label: settings.t('transactions'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.bar_chart),
                      label: settings.t('statistics'),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
