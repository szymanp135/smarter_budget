import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget/models/category.dart';
import 'package:smart_budget/providers/category_provider.dart';
import 'package:smart_budget/providers/user_provider.dart';
import 'package:smart_budget/widgets/categories/category_add_dialog.dart';

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

  void deleteCategory(
    CategoryProvider categoryProvider,
    BudgetCategory category,
    UserProvider userProvider,
  ) {
    categoryProvider.deleteCategory(
      categoryId: category.id,
      userProvider: userProvider,
    );
  }

  void onTap(CategoryProvider categoryProvider, BudgetCategory category) {}

  void onDelete(CategoryProvider categoryProvider, BudgetCategory category) {}

  Future<bool> onConfirmDismiss(
    DismissDirection direction,
    CategoryProvider categoryProvider,
    UserProvider userProvider,
    BudgetCategory category,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      onTap(categoryProvider, category);
      return false;
    } else if (direction == DismissDirection.endToStart) {
      deleteCategory(categoryProvider, category, userProvider);
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
          await showAddCategoryDialog(context, settings, categories);
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
                      onTap: () => onTap(categories, category),
                      onConfirmDismiss: (dismissDirection) => onConfirmDismiss(
                        dismissDirection,
                        categories,
                        users,
                        category,
                      ),
                      onDelete: () => onDelete(categories, category),
                    );
                  },
                  itemCount: categoryBox.values.length,
                ),
              ],
            ),
    );
  }
}
