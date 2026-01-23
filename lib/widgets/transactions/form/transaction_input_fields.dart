import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../providers/app_settings_provider.dart';

class TransactionInputFields extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final String dateText;
  final VoidCallback onDateTap;
  final AppSettingsProvider settings;

  const TransactionInputFields({
    super.key,
    required this.amountController,
    required this.descriptionController,
    required this.dateText,
    required this.onDateTap,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: '${settings.t('amount')} (${settings.currencySymbol()})',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.attach_money),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.isEmpty) return newValue;
              String text = newValue.text.replaceAll(',', '.');
              if ('.'.allMatches(text).length > 1) {
                return oldValue;
              }
              if (text.contains('.')) {
                final parts = text.split('.');
                if (parts.length > 1 && parts[1].length > 2) {
                  return oldValue;
                }
              }
              return newValue.copyWith(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
            }),
          ],
          validator: (value) {
            final sanitizedValue = value?.replaceAll(',', '.');
            if (sanitizedValue == null || sanitizedValue.isEmpty) {
              return settings.t('enter_amount');
            }
            if ((double.tryParse(sanitizedValue) ?? 0.0) <= 0.0) {
              return settings.t('invalid_number');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: onDateTap,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: settings.t('date'),
              prefixIcon: const Icon(Icons.calendar_today),
              border: const OutlineInputBorder(),
            ),
            child: Text(
              dateText,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: settings.t('description'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.description),
          ),
        ),
      ],
    );
  }
}
