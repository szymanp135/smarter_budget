import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smarter_budget/models/category.dart';
import 'package:smarter_budget/providers/category_provider.dart';
import '../../models/transaction.dart';
import '../../providers/app_settings_provider.dart';
import 'form/transaction_type_selector.dart';
import 'form/category_selector.dart';
import 'form/transaction_input_fields.dart';
import 'form/transaction_summary.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? transaction;
  final Function(Transaction) onSubmit;
  final String titleKey;
  final String buttonKey;
  final CategoryProvider categoryProvider;

  const TransactionForm({
    super.key,
    this.transaction,
    required this.onSubmit,
    required this.titleKey,
    required this.buttonKey,
    required this.categoryProvider,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  int _currentStep = 0;
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  late String type;
  String? categoryId;
  late TextEditingController amountController;
  late TextEditingController descriptionController;
  late DateTime _selectedDate;

  late List<BudgetCategory> expenseCategories;
  late List<BudgetCategory> incomeCategories;

  @override
  void initState() {
    super.initState();
    type = widget.transaction?.type ?? "expense";
    _selectedDate = widget.transaction?.date ?? DateTime.now();

    final settings = Provider.of<AppSettingsProvider>(context, listen: false);
    String initialAmount = '';

    if (widget.transaction != null) {
      double convertedAmount = settings.convertAmount(
        widget.transaction!.amount,
      );
      initialAmount = convertedAmount.toStringAsFixed(2);
      if (initialAmount.endsWith('.00')) {
        initialAmount = initialAmount.substring(0, initialAmount.length - 3);
      }
    }

    amountController = TextEditingController(text: initialAmount);
    descriptionController = TextEditingController(
      text: widget.transaction?.title ?? '',
    );

    final box = widget.categoryProvider.categoriesBox;
    if (box != null) {
      incomeCategories = box.values
          .where((cat) => cat.type == 'income')
          .toList();
      expenseCategories = box.values
          .where((cat) => cat.type == 'expense')
          .toList();
    }

    if (widget.transaction != null) {
      final savedCategoryId = widget.transaction!.categoryId;
      final currentList = type == "expense"
          ? expenseCategories
          : incomeCategories;
      if (currentList.contains(savedCategoryId)) {
        categoryId = savedCategoryId;
      } else {
        try {
          categoryId = currentList
              .firstWhere(
                (cat) => cat.id.toLowerCase() == savedCategoryId.toLowerCase(),
              )
              .id;
        } catch (e) {
          categoryId = null;
        }
      }
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    final settings = Provider.of<AppSettingsProvider>(context, listen: false);
    final Locale currentLocale = settings.language == AppLanguage.pl
        ? const Locale('pl', 'PL')
        : const Locale('en', 'US');

    showDatePicker(
      context: context,
      locale: currentLocale,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _submitData() {
    final finalTitle = descriptionController.text.trim();
    final parsedAmount =
        double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0;

    final settings = Provider.of<AppSettingsProvider>(context, listen: false);
    final rate = settings.convertAmount(1.0);

    final baseAmount = rate > 0 ? parsedAmount / rate : parsedAmount;

    final tx = Transaction(
      id:
          widget.transaction?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: finalTitle,
      amount: baseAmount,
      date: _selectedDate,
      categoryId: categoryId!,
      type: type,
    );
    widget.onSubmit(tx);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final List<BudgetCategory> currentCategoryKeys = type == "expense"
        ? expenseCategories
        : incomeCategories;
    final categoryProvider = Provider.of<CategoryProvider>(context);

    if (categoryId != null &&
        !currentCategoryKeys.any((cat) => cat.id == categoryId)) {
      categoryId = null;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text(settings.t(widget.titleKey))),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewportConstraints) {
            final double minSafeHeight = 450.0;
            final bool isNarrowScreen = viewportConstraints.maxWidth < 400;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight < minSafeHeight
                      ? minSafeHeight
                      : viewportConstraints.maxHeight,
                ),
                child: SizedBox(
                  height: viewportConstraints.maxHeight < minSafeHeight
                      ? minSafeHeight
                      : viewportConstraints.maxHeight,
                  child: Stepper(
                    type: isNarrowScreen
                        ? StepperType.vertical
                        : StepperType.horizontal,
                    physics: const ClampingScrollPhysics(),
                    elevation: 0,
                    currentStep: _currentStep,

                    onStepTapped: (step) {
                      if (step == _currentStep) return;

                      if (step < _currentStep) {
                        setState(() => _currentStep = step);
                        return;
                      }

                      bool isAllValid = true;
                      for (int i = _currentStep; i < step; i++) {
                        if (i == 0) {
                          if (!(_step1Key.currentState?.validate() ?? false)) {
                            isAllValid = false;
                            break;
                          }
                        }
                        if (i == 1) {
                          if (!(_step2Key.currentState?.validate() ?? false)) {
                            isAllValid = false;
                            break;
                          }
                        }
                      }

                      if (isAllValid) {
                        setState(() => _currentStep = step);
                      }
                    },

                    onStepContinue: () {
                      if (_currentStep == 0) {
                        if (_step1Key.currentState!.validate()) {
                          setState(() => _currentStep += 1);
                        }
                      } else if (_currentStep == 1) {
                        if (_step2Key.currentState!.validate()) {
                          setState(() => _currentStep += 1);
                        }
                      } else {
                        _submitData();
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep -= 1);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    controlsBuilder: (context, details) {
                      final isLastStep = _currentStep == 2;
                      final btnText = isLastStep
                          ? settings.t(widget.buttonKey)
                          : settings.t('next');
                      final backText = settings.t('back');

                      final nextButton = ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 45),
                        ),
                        child: Text(btnText, overflow: TextOverflow.ellipsis),
                      );

                      final backButton = TextButton(
                        onPressed: details.onStepCancel,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          minimumSize: const Size(0, 45),
                        ),
                        child: Text(backText, overflow: TextOverflow.ellipsis),
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: isNarrowScreen
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  nextButton,
                                  if (_currentStep > 0) ...[
                                    const SizedBox(height: 8),
                                    backButton,
                                  ],
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_currentStep > 0) ...[
                                    Flexible(child: backButton),
                                    const SizedBox(width: 16),
                                  ],
                                  Flexible(child: nextButton),
                                ],
                              ),
                      );
                    },
                    steps: [
                      Step(
                        title: isNarrowScreen
                            ? Text(
                                settings.t('step_type'),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )
                            : const SizedBox.shrink(),
                        label: isNarrowScreen
                            ? null
                            : SizedBox(
                                width: 60,
                                child: Text(
                                  settings.t('step_type'),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                        isActive: _currentStep >= 0,
                        state: _currentStep > 0
                            ? StepState.complete
                            : StepState.indexed,
                        content: Form(
                          key: _step1Key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TransactionTypeSelector(
                                selectedType: type,
                                onTypeChanged: (val) {
                                  setState(() {
                                    type = val;
                                    categoryId = null;
                                  });
                                },
                                isNarrowScreen: isNarrowScreen,
                                maxWidth: viewportConstraints.maxWidth,
                                settings: settings,
                              ),
                              const SizedBox(height: 24),
                              CategorySelector(
                                selectedCategory: categoryId,
                                categories: currentCategoryKeys,
                                onChanged: (val) =>
                                    setState(() => categoryId = val),
                                settings: settings,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Step(
                        title: isNarrowScreen
                            ? Text(
                                settings.t('step_details'),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )
                            : const SizedBox.shrink(),
                        label: isNarrowScreen
                            ? null
                            : SizedBox(
                                width: 60,
                                child: Text(
                                  settings.t('step_details'),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                        isActive: _currentStep >= 1,
                        state: _currentStep > 1
                            ? StepState.complete
                            : StepState.indexed,
                        content: Form(
                          key: _step2Key,
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              TransactionInputFields(
                                amountController: amountController,
                                descriptionController: descriptionController,
                                dateText: formattedDate,
                                onDateTap: _presentDatePicker,
                                settings: settings,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Step(
                        title: isNarrowScreen
                            ? Text(
                                settings.t('step_review'),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )
                            : const SizedBox.shrink(),
                        label: isNarrowScreen
                            ? null
                            : SizedBox(
                                width: 60,
                                child: Text(
                                  settings.t('step_review'),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                        isActive: _currentStep >= 2,
                        state: StepState.indexed,
                        content: TransactionSummary(
                          type: type,
                          category: categoryProvider.getCategoryById(
                            categoryId ?? '',
                          ),
                          amount: amountController.text,
                          date: formattedDate,
                          description: descriptionController.text.isEmpty
                              ? "-"
                              : descriptionController.text,
                          settings: settings,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
