import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarter_budget/models/category.dart';
import 'package:smarter_budget/providers/category_provider.dart';
import 'package:smarter_budget/providers/user_provider.dart';
import 'package:smarter_budget/widgets/categories/category_form_dialog.dart';

import '../providers/app_settings_provider.dart';
import '../widgets/categories/category_list_item.dart';

class CategoriesManagerScreen extends StatelessWidget {
  const CategoriesManagerScreen({super.key});

  Widget categoryCard(BudgetCategory category) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Divider(),
          SizedBox(height: 12),
          Row(
            children: [
              SizedBox(width: 8),
              Icon(
                IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
                color: Color(category.colorValue),
              ),
              SizedBox(width: 8),
              Expanded(child: Text(category.displayName)),
              Icon(
                switch (category.type) {
                  'income' => Icons.trending_up_rounded,
                  'expense' => Icons.trending_down_rounded,
                  _ => Icons.question_mark_rounded,
                },
                color: switch (category.type) {
                  'income' => Colors.green,
                  'expense' => Colors.red,
                  _ => Colors.grey,
                },
              ),
              SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  void deleteCategory({
    required CategoryProvider categoryProvider,
    required BudgetCategory category,
    required UserProvider userProvider,
  }) {
    categoryProvider.deleteCategory(
      categoryId: category.id,
      userProvider: userProvider,
    );
  }

  void onTap({
    required BuildContext context,
    required AppSettingsProvider settings,
    required CategoryProvider categoryProvider,
    required BudgetCategory category,
  }) async {
    await showCategoryFormDialog(
      context: context,
      settings: settings,
      categoryProvider: categoryProvider,
      category: category,
    );
  }

  void onDelete({
    required UserProvider userProvider,
    required CategoryProvider categoryProvider,
    required BudgetCategory category,
  }) {
    deleteCategory(
      categoryProvider: categoryProvider,
      category: category,
      userProvider: userProvider,
    );
  }

  Future<bool> onConfirmDismiss({
    required BuildContext context,
    required AppSettingsProvider settings,
    required DismissDirection direction,
    required CategoryProvider categoryProvider,
    required UserProvider userProvider,
    required BudgetCategory category,
  }) async {
    if (direction == DismissDirection.startToEnd) {
      onTap(
        context: context,
        settings: settings,
        categoryProvider: categoryProvider,
        category: category,
      );
      return false;
    } else if (direction == DismissDirection.endToStart) {
      deleteCategory(
        categoryProvider: categoryProvider,
        category: category,
        userProvider: userProvider,
      );
      return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final categories = Provider.of<CategoryProvider>(context);
    final users = Provider.of<UserProvider>(context);
    final categoryBox = categories.categoriesBox;

    return Scaffold(
      appBar: AppBar(title: Text(settings.t('category_manager'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showCategoryFormDialog(
            context: context,
            settings: settings,
            categoryProvider: categories,
          );
        },
        child: const Icon(Icons.add),
      ),
      body: !categories.isInitialized || categoryBox == null
          ? Center(child: Text(settings.t('categories_uninitialized')))
          : CustomScrollView(
              slivers: [
                SliverList.builder(
                  itemBuilder: (context, index) {
                    final category = categoryBox.values.toList()[index];
                    return CategoryListItem(
                      category: category,
                      categoryProvider: categories,
                      onTap: () => onTap(
                        context: context,
                        settings: settings,
                        categoryProvider: categories,
                        category: category,
                      ),
                      onConfirmDismiss: (dismissDirection) => onConfirmDismiss(
                        context: context,
                        settings: settings,
                        direction: dismissDirection,
                        categoryProvider: categories,
                        userProvider: users,
                        category: category,
                      ),
                      onDelete: () => onDelete(
                        categoryProvider: categories,
                        category: category,
                        userProvider: users,
                      ),
                    );
                  },
                  itemCount: categoryBox.values.length,
                ),
                SliverToBoxAdapter(child: SizedBox(height: 64)),
              ],
            ),
    );
  }
}
