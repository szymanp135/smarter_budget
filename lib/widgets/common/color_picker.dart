import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:smarter_budget/providers/app_settings_provider.dart';

Future<Color> showColorPickerDialog(
  BuildContext context,
  AppSettingsProvider settings,
  Color pickerColor,
) async {
  void onColorChanged(Color color) {
    pickerColor = color;
  }

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(settings.t('pick_color')),
      content: BlockPicker(
        pickerColor: pickerColor,
        onColorChanged: onColorChanged,
      ),
      actions: [
        ElevatedButton(
          onPressed: () => {Navigator.pop(context)},
          child: Text(settings.t('done')),
        ),
      ],
    ),
  );

  return pickerColor;
}
