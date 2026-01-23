import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import 'app_settings_provider.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class GroupedTransaction {
  final DateTime date;
  final List<Transaction> transactions;

  GroupedTransaction({required this.date, required this.transactions});
}

class UserProvider extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isInitialized = false;

  AppUser? get currentUser => _currentUser;

  String? get currentUsername => _currentUser?.username;

  bool get isInitialized => _isInitialized;

  late AppSettingsProvider _settingsProvider;

  Box get usersBox => Hive.box('users');

  Box<Transaction>? _transactionsBox;

  Box<Transaction>? get transactionsBox => _transactionsBox;

  void init(AppSettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
  }

  Future<void> loadLastUser() async {
    _isInitialized = false;

    try {
      final lastUserId = usersBox.get('lastLoggedInUserId');
      if (lastUserId is String) {
        final user = usersBox.get(lastUserId) as AppUser?;
        if (user != null) {
          _currentUser = user;
          await _syncSettingsAndOpenBox(user);
        }
      }
    } catch (e) {
      debugPrint('Error loading last user: $e');
    }

    _isInitialized = true;

    Future.microtask(() => notifyListeners());
  }

  Future<bool> login(String username, String password) async {
    try {
      final users = usersBox.values.toList();

      final user = users.firstWhere((u) {
        return u.username == username && u.password == _hashPassword(password);
      });

      _currentUser = user;

      await usersBox.put('lastLoggedInUserId', user.userId);

      await _syncSettingsAndOpenBox(user);

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    final existingUsers = usersBox.values.where((u) => u.username == username);
    if (existingUsers.isNotEmpty) {
      return false;
    }

    final newUser = AppUser(
      userId: const Uuid().v4(),
      username: username,
      password: _hashPassword(password),
    );

    await usersBox.put(newUser.userId, newUser);

    _currentUser = newUser;

    await usersBox.put('lastLoggedInUserId', newUser.userId);

    await _syncSettingsAndOpenBox(newUser);

    notifyListeners();

    return true;
  }

  Future<void> _syncSettingsAndOpenBox(AppUser user) async {
    _settingsProvider.syncSettings(user.theme, user.language, user.currency);
    await _openUserTransactionsBox(user.userId);
  }

  Future<void> _openUserTransactionsBox(String userId) async {
    final name = 'transactions_$userId';
    if (Hive.isBoxOpen(name)) {
      _transactionsBox = Hive.box<Transaction>(name);
      return;
    }
    _transactionsBox = await Hive.openBox<Transaction>(name);
  }

  Future<void> logout() async {
    if (_transactionsBox != null) {
      try {
        await _transactionsBox!.close();
      } catch (_) {}
      _transactionsBox = null;
    }

    await usersBox.delete('lastLoggedInUserId');

    _currentUser = null;
    _isInitialized = true;
    Future.microtask(() => notifyListeners());
  }

  Future<void> updateSettings({
    AppTheme? theme,
    AppLanguage? language,
    AppCurrency? currency,
    double? monthlyLimit,
  }) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      theme: theme,
      language: language,
      currency: currency,
      monthlyLimit: monthlyLimit,
    );

    await usersBox.put(updatedUser.userId, updatedUser);
    _currentUser = updatedUser;

    notifyListeners();
  }

  List<GroupedTransaction> getGroupedTransactions() {
    final box = transactionsBox;
    if (box == null || box.isEmpty) {
      return [];
    }

    final allTransactions = box.values.toList();

    allTransactions.sort((a, b) => b.date.compareTo(a.date));

    final Map<String, List<Transaction>> groupedMap = {};

    for (var tx in allTransactions) {
      final key = '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}';

      if (!groupedMap.containsKey(key)) {
        groupedMap[key] = [];
      }
      groupedMap[key]!.add(tx);
    }

    return groupedMap.entries.map((entry) {
      final year = int.parse(entry.key.substring(0, 4));
      final month = int.parse(entry.key.substring(5, 7));
      return GroupedTransaction(
        date: DateTime(year, month),
        transactions: entry.value,
      );
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
