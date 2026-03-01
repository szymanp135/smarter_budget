import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:smart_budget/providers/app_settings_provider.dart';
import 'package:smart_budget/providers/category_provider.dart';
import 'package:smart_budget/widgets/common/color_picker.dart';

Future<void> showAddCategoryDialog(
  BuildContext context,
  AppSettingsProvider settings,
  CategoryProvider categoryProvider,
) async {
  void Function(void Function())? dialogSetState;

  // name input stuff
  String initialValue = '';
  String? errorText;
  final nameController = TextEditingController(text: initialValue);

  // color picker stuff
  Color pickerColor = Colors.blue;

  // icon picker stuff
  IconPickerIcon? pickerIcon;
  const _defaultIconData = Icons.attach_money_rounded;

  // category type stuff
  CategoryType categoryType = CategoryType.income;

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(settings.t('add_category')),
      content: StatefulBuilder(
        builder: (context, setState) {
          dialogSetState = setState;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                settings.t('category_enter_name'),
                //style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: settings.t('category_enter_name'),
                  errorText: errorText,
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
              const SizedBox(height: 16),
              Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(settings.t('pick_color')),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      pickerColor = await showColorPickerDialog(
                        context,
                        settings,
                        pickerColor,
                      );
                      setState(() => {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pickerColor,
                    ),
                    child: const Text(''),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(settings.t('pick_icon')),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      pickerIcon = await showIconPicker(
                        context,
                        configuration: SinglePickerConfiguration(
                          iconPackModes: [IconPack.roundedMaterial],
                        ),
                      );
                      setState(() => {});
                    },
                    child: Icon(
                      pickerIcon?.data ?? Icons.attach_money_rounded,
                      color: pickerColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(settings.t('pick_type')),
                  const SizedBox(width: 16),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<CategoryType>(
                      value: categoryType,
                      borderRadius: BorderRadius.circular(12),
                      items: [
                        DropdownMenuItem(
                          value: CategoryType.income,
                          child: Text(settings.t('income')),
                        ),
                        DropdownMenuItem(
                          value: CategoryType.expense,
                          child: Text(settings.t('expense')),
                        ),
                      ],
                      onChanged: (type) {
                        if (type != null) categoryType = type;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(settings.t('cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            dialogSetState?.call(() {
              if (nameController.text.trim().isEmpty) {
                errorText = settings.t('warning_empty_text_field');
                return;
              } else if (categoryProvider.categoryNameExists(
                nameController.text.trim(),
              )) {
                errorText = settings.t('warning_such_category_exists');
                return;
              }

              categoryProvider.addCategory(
                displayName: nameController.text,
                icon: pickerIcon?.data ?? _defaultIconData,
                color: pickerColor,
                type: categoryType.name.toLowerCase(),
              );
              Navigator.pop(ctx);
            });
          },
          child: Text(settings.t('add')),
        ),
      ],
    ),
  );
}
