import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:smart_budget/providers/user_provider.dart';

import '../models/category.dart';

enum CategoryType { income, expense }

class CategoryProvider extends ChangeNotifier {
  late UserProvider _userProvider;

  bool _isInitialized = false;
  Box<BudgetCategory>? _categoriesBox;

  bool get isInitialized => _isInitialized;

  Box<BudgetCategory>? get categoriesBox => _categoriesBox;

  void init(UserProvider userProvider) async {
    _userProvider = userProvider;
    await _openCategoriesBox(_userProvider.currentUser!.userId);

    if (categoriesBox != null && categoriesBox!.isEmpty) {
      for (var cat in _categoryInitialDatabase.keys) {
        addCategory(
          displayName: _categoryInitialDatabase[cat]!.$1,
          icon: _categoryInitialDatabase[cat]!.$2,
          color: _categoryInitialDatabase[cat]!.$3,
          type: _categoryInitialDatabase[cat]!.$4,
        );
      }
    }

    _isInitialized = true;
  }

  Future<void> _openCategoriesBox(String userId) async {
    final name = 'categories_$userId';
    if (Hive.isBoxOpen(name)) {
      _categoriesBox = Hive.box<BudgetCategory>(name);
      return;
    }
    _categoriesBox = await Hive.openBox<BudgetCategory>(name);
  }

  List<BudgetCategory> getIncomeCategories() {
    final box = categoriesBox;
    if (box == null || box.isEmpty) {
      return [];
    }

    final incomeCategories = box.values
        .where((cat) => cat.type == 'income')
        .toList();
    return incomeCategories;
  }

  List<BudgetCategory> getExpenseCategories() {
    final box = categoriesBox;
    if (box == null || box.isEmpty) {
      return [];
    }

    final incomeCategories = box.values
        .where((cat) => cat.type == 'expense')
        .toList();
    return incomeCategories;
  }

  void addCategory({
    required String displayName,
    required IconData icon,
    required Color color,
    required String type,
  }) {
    final box = categoriesBox;
    if (box == null) {
      throw Exception('Category database not initialized');
    }

    final sortedCategoriesList = box.values.toList();
    sortedCategoriesList.sort((a, b) {
      final valA = int.tryParse(a.id) ?? 0;
      final valB = int.tryParse(b.id) ?? 0;
      return valB - valA;
    });
    final topCategoryId = sortedCategoriesList.isNotEmpty
        ? sortedCategoriesList[0].id
        : '0';
    final categoryId = ((int.tryParse(topCategoryId) ?? 0) + 1).toString();
    final newCategory = BudgetCategory(
      id: categoryId,
      displayName: displayName,
      iconCodePoint: icon.codePoint,
      colorValue: color.toARGB32(),
      type: type,
    );
    box.add(newCategory);
    notifyListeners();
  }

  void updateCategory({
    required BudgetCategory oldCategory,
    required String newDisplayName,
    required IconData newIconData,
    required Color newColor,
    required CategoryType newType,
  }) {
    final box = categoriesBox;
    if (box == null) {
      return;
    }

    final newCategory = BudgetCategory(
      id: oldCategory.id,
      displayName: newDisplayName,
      iconCodePoint: newIconData.codePoint,
      colorValue: newColor.toARGB32(),
      type: newType.name.toLowerCase(),
    );

    final key = getCategoryKey(oldCategory.id);
    box.put(key, newCategory);
    notifyListeners();
  }

  bool deleteCategory({
    required String categoryId,
    required UserProvider userProvider,
  }) {
    final box = categoriesBox;
    if (box == null) {
      return false;
    }

    // find key of category with categoryId
    final key = getCategoryKey(categoryId);

    // check whether transactions with deleting categoryId exist
    // if so then don't delete category
    final transactionsBox = userProvider.transactionsBox;
    if (transactionsBox != null) {
      for (var tx in transactionsBox.values) {
        if (tx.categoryId == categoryId) {
          return false;
        }
      }
    }

    // delete category
    box.delete(key);
    notifyListeners();
    return true;
  }

  bool categoryNameExists(String categoryName) {
    final box = categoriesBox;
    if (box == null) {
      return false;
    }

    for (var cat in box.values) {
      if (cat.displayName == categoryName) {
        return true;
      }
    }
    return false;
  }

  dynamic getCategoryKey(String categoryId) {
    final box = categoriesBox;
    if (box == null) {
      return null;
    }

    dynamic key;
    for (var k in box.keys) {
      final c = box.get(k);
      if (c?.id == categoryId) {
        key = k;
        break;
      }
    }
    return key;
  }

  final Map<String, (String, IconData, Color, String)>
  _categoryInitialDatabase = {
    'salary': (
      'Wypłata',
      Icons.account_balance_wallet_rounded,
      Colors.green,
      'income',
    ),
    'bonus': ('Premia', Icons.star_rounded, Colors.teal, 'income'),
    'gift': ('Prezent', Icons.card_giftcard_rounded, Colors.amber, 'income'),
    'investment': (
      'Inwestycje',
      Icons.trending_up_rounded,
      Colors.indigo,
      'income',
    ),
    'otherIncome': (
      'Inne przychody',
      Icons.attach_money_rounded,
      Colors.blueGrey,
      'income',
    ),
    'food': ('Jedzenie', Icons.fastfood_rounded, Colors.orange, 'expense'),
    'transport': (
      'Transport',
      Icons.directions_bus_rounded,
      Colors.blue,
      'expense',
    ),
    'shopping': (
      'Zakupy',
      Icons.shopping_bag_rounded,
      Colors.purple,
      'expense',
    ),
    'bills': (
      'Rachunki',
      Icons.receipt_long_rounded,
      Colors.redAccent,
      'expense',
    ),
    'entertainment': (
      'Rozrywka',
      Icons.movie_rounded,
      Colors.pinkAccent,
      'expense',
    ),
    'otherExpense': (
      'Inne wydatki',
      Icons.category_rounded,
      Colors.grey,
      'expense',
    ),
    'unknownCategory': (
      'Nieznana Kategoria',
      Icons.question_mark_rounded,
      Colors.grey,
      'unknown',
    ),
  };
}
