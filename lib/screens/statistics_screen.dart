import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/category_provider.dart';
import '../providers/user_provider.dart';
import '../models/transaction.dart';
import '../widgets/statistics/savings_card.dart';
import '../widgets/statistics/time_range_selector.dart';
import '../widgets/statistics/statistics_bar_chart.dart';
import '../widgets/statistics/statistics_pie_chart.dart';
import 'dart:math' as math;

enum TimeRange { month1, month3, month6, year1, all }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  TimeRange _selectedRange = TimeRange.month3;
  String _pieChartType = 'expense';
  int _touchedPieIndex = -1;

  Set<String> _selectedCategoryIds = {};
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final userProv = Provider.of<UserProvider>(context);
    final categoryProv = Provider.of<CategoryProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final allTransactions = userProv.transactionsBox?.values.toList() ?? [];

    if (!_isInitialized && allTransactions.isNotEmpty) {
      _selectedCategoryIds = allTransactions.map((tx) => tx.categoryId).toSet();
      _isInitialized = true;
    }

    final startDate = _calculateStartDate(_selectedRange, allTransactions);

    final filteredTransactions = allTransactions
        .where(
          (tx) =>
              tx.date.isAfter(startDate) || tx.date.isAtSameMomentAs(startDate),
        )
        .where((tx) => _selectedCategoryIds.contains(tx.categoryId))
        .toList();

    double totalIncome = 0;
    double totalExpense = 0;

    for (var tx in filteredTransactions) {
      final amount = settings.convertAmount(tx.amount);
      if (tx.type == 'income') {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }
    }
    final double balance = totalIncome - totalExpense;

    final chartData = _generateBarChartData(
      filteredTransactions,
      _selectedRange,
      settings,
    );

    const double minBarGroupWidth = 50.0;
    const double horizontalPadding = 32.0;
    double calculatedWidth = chartData.groups.length * minBarGroupWidth;

    double finalChartWidth = math.max(
      screenWidth - horizontalPadding,
      calculatedWidth,
    );

    final pieTransactions = filteredTransactions
        .where((tx) => tx.type == _pieChartType)
        .toList();
    final pieData = _generatePieChartData(pieTransactions, settings);

    final uniqueCategoryIds = allTransactions
        .map((tx) => tx.categoryId)
        .toSet();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  settings.t('select_period'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ),
              TimeRangeSelector(
                selectedRange: _selectedRange,
                onRangeChanged: (val) => setState(() => _selectedRange = val),
                settings: settings,
              ),
              const SizedBox(height: 16),
              _buildCategoryFilterButton(
                context,
                uniqueCategoryIds,
                categoryProv,
                settings,
              ),
              const SizedBox(height: 24),
              SavingsCard(
                income: totalIncome,
                expense: totalExpense,
                balance: balance,
                settings: settings,
              ),
              const SizedBox(height: 32),
              Text(
                _selectedRange == TimeRange.all
                    ? settings.t('yearly_balance')
                    : settings.t('monthly_balance'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: finalChartWidth,
                  height: 300,
                  padding: const EdgeInsets.only(right: 16, bottom: 10),
                  child: StatisticsBarChart(
                    groups: chartData.groups,
                    labels: chartData.labels,
                    settings: settings,
                    uniqueKey:
                        '$_selectedRange-${_selectedCategoryIds.hashCode}',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      settings.t('category_details'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPieTypeToggle(settings),
                ],
              ),
              const SizedBox(height: 16),
              StatisticsPieChart(
                sections: _generatePieSections(context, pieData, settings),
                pieData: pieData,
                settings: settings,
                uniqueKey:
                    '$_selectedRange-$_pieChartType-${_selectedCategoryIds.hashCode}',
                onTouch: (index) => setState(() => _touchedPieIndex = index),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterButton(
    BuildContext context,
    Set<String> uniqueCategoryIds,
    CategoryProvider categoryProv,
    AppSettingsProvider settings,
  ) {
    return OutlinedButton.icon(
      onPressed: () => _showCategoryFilterSheet(
        context,
        uniqueCategoryIds,
        categoryProv,
        settings,
      ),
      icon: const Icon(Icons.filter_list, size: 18),
      label: Text(
        '${settings.t('categories_chosen')}: ${_selectedCategoryIds.length}/${uniqueCategoryIds.length}',
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showCategoryFilterSheet(
    BuildContext context,
    Set<String> categoryIds,
    CategoryProvider categoryProv,
    AppSettingsProvider settings,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateSheet) {
            final sortedIds = categoryIds.toList();
            return Container(
              padding: const EdgeInsets.all(16),
              height: math.min(MediaQuery.of(context).size.height * 0.6, 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        settings.t('statistics_choose_categories'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: sortedIds.isEmpty
                        ? Center(
                            child: Text(settings.t('history_no_categories')),
                          )
                        : ListView.builder(
                            itemCount: sortedIds.length,
                            itemBuilder: (context, index) {
                              final catId = sortedIds[index];
                              final category = categoryProv.getCategoryById(
                                catId,
                              );
                              final isSelected = _selectedCategoryIds.contains(
                                catId,
                              );
                              final categoryColor = Color(
                                category?.colorValue ?? Colors.grey.toARGB32(),
                              );

                              return CheckboxListTile(
                                title: Text(
                                  category?.displayName ??
                                      settings.t('unknown'),
                                ),
                                secondary: CircleAvatar(
                                  backgroundColor: categoryColor,
                                  radius: 12,
                                ),
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    setStateSheet(() {
                                      if (value == true) {
                                        _selectedCategoryIds.add(catId);
                                      } else {
                                        _selectedCategoryIds.remove(catId);
                                      }
                                    });
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPieTypeToggle(AppSettingsProvider settings) {
    return ToggleButtons(
      isSelected: [_pieChartType == 'expense', _pieChartType == 'income'],
      onPressed: (index) {
        setState(() {
          _pieChartType = index == 0 ? 'expense' : 'income';
          _touchedPieIndex = -1;
        });
      },
      borderRadius: BorderRadius.circular(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 30),
      children: const [
        Icon(Icons.arrow_downward, size: 18, color: Colors.red),
        Icon(Icons.arrow_upward, size: 18, color: Colors.green),
      ],
    );
  }

  Widget _buildPieTooltip(
    BuildContext context,
    MapEntry<String, double> entry,
    double percentage,
    AppSettingsProvider settings,
  ) {
    final category = Provider.of<CategoryProvider>(
      context,
    ).getCategoryById(entry.key);
    final categoryColor = Color(category?.colorValue ?? Colors.grey.toARGB32());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category?.displayName ?? 'unknown category',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.value.toStringAsFixed(2)} ${settings.currencySymbol()}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: categoryColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  DateTime _calculateStartDate(TimeRange range, List<Transaction> allTxs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (range) {
      case TimeRange.month1:
        return DateTime(today.year, today.month, 1);
      case TimeRange.month3:
        return DateTime(today.year, today.month - 2, 1);
      case TimeRange.month6:
        return DateTime(today.year, today.month - 5, 1);
      case TimeRange.year1:
        return DateTime(today.year, today.month - 11, 1);
      case TimeRange.all:
        if (allTxs.isEmpty) return DateTime(today.year, today.month, 1);
        DateTime oldest = allTxs.fold(
          now,
          (prev, curr) => curr.date.isBefore(prev) ? curr.date : prev,
        );
        return DateTime(oldest.year, 1, 1);
    }
  }

  _BarChartDataWrapper _generateBarChartData(
    List<Transaction> transactions,
    TimeRange range,
    AppSettingsProvider settings,
  ) {
    final Map<String, _Stats> grouped = {};
    final List<String> labels = [];
    final List<BarChartGroupData> groups = [];

    if (range == TimeRange.all) {
      if (transactions.isEmpty) return _BarChartDataWrapper([], []);
      int startYear = transactions.fold(
        DateTime.now().year,
        (prev, tx) => tx.date.year < prev ? tx.date.year : prev,
      );
      int endYear = DateTime.now().year;

      for (int y = startYear; y <= endYear; y++) {
        grouped[y.toString()] = _Stats();
      }

      for (var tx in transactions) {
        final key = tx.date.year.toString();
        if (grouped.containsKey(key)) {
          final amount = settings.convertAmount(tx.amount);
          if (tx.type == 'income') {
            grouped[key]!.income += amount;
          } else {
            grouped[key]!.expense += amount;
          }
        }
      }

      int index = 0;
      for (int y = startYear; y <= endYear; y++) {
        final key = y.toString();
        labels.add(key);
        final stats = grouped[key]!;
        groups.add(_createBarGroup(index, stats.income, stats.expense));
        index++;
      }
    } else if (range == TimeRange.month1) {
      final now = DateTime.now();
      final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

      for (int d = 1; d <= daysInMonth; d++) {
        grouped[d.toString()] = _Stats();
      }

      final filteredTxs = transactions.where(
        (tx) => (tx.date.year == now.year && tx.date.month == now.month),
      );

      for (var tx in filteredTxs) {
        final key = tx.date.day.toString();
        if (grouped.containsKey(key)) {
          final amount = settings.convertAmount(tx.amount);
          if (tx.type == 'income') {
            grouped[key]!.income += amount;
          } else {
            grouped[key]!.expense += amount;
          }
        }
      }

      for (int d = 1; d <= daysInMonth; d++) {
        final key = d.toString();
        labels.add(key);
        final stats = grouped[key]!;
        groups.add(_createBarGroup(d - 1, stats.income, stats.expense));
      }
    } else {
      final startDate = _calculateStartDate(range, transactions);
      final locale = settings.language == AppLanguage.pl ? 'pl_PL' : 'en_US';
      final now = DateTime.now();
      final endDate = DateTime(now.year, now.month + 1, 0);

      DateTime iterator = DateTime(startDate.year, startDate.month, 1);
      if (iterator.isAfter(endDate)) {
        iterator = DateTime(endDate.year, endDate.month, 1);
      }

      bool differentYears = startDate.year != endDate.year;

      while (iterator.isBefore(endDate) ||
          (iterator.month == endDate.month && iterator.year == endDate.year)) {
        final key =
            '${iterator.year}-${iterator.month.toString().padLeft(2, '0')}';
        grouped[key] = _Stats();
        iterator = DateTime(iterator.year, iterator.month + 1, 1);
      }

      final filteredTxs = transactions.where(
        (tx) =>
            tx.date.isAfter(startDate) || tx.date.isAtSameMomentAs(startDate),
      );

      for (var tx in filteredTxs) {
        final key =
            '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}';
        if (grouped.containsKey(key)) {
          final amount = settings.convertAmount(tx.amount);
          if (tx.type == 'income') {
            grouped[key]!.income += amount;
          } else {
            grouped[key]!.expense += amount;
          }
        }
      }

      int index = 0;
      final sortedKeys = grouped.keys.toList()..sort();

      for (var key in sortedKeys) {
        final stats = grouped[key]!;
        final year = int.parse(key.split('-')[0]);
        final month = int.parse(key.split('-')[1]);
        final date = DateTime(year, month);
        String label = DateFormat.MMM(locale).format(date);

        if (differentYears) {
          label =
              "${DateFormat.MMM(locale).format(date)}\n'${year.toString().substring(2)}";
        } else {
          label = DateFormat.MMM(locale).format(date);
        }

        labels.add(label);
        groups.add(_createBarGroup(index, stats.income, stats.expense));
        index++;
      }
    }
    return _BarChartDataWrapper(groups, labels);
  }

  BarChartGroupData _createBarGroup(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          color: Colors.green,
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          backDrawRodData: BackgroundBarChartRodData(show: false),
        ),
        BarChartRodData(
          toY: expense,
          color: Colors.redAccent,
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  List<MapEntry<String, double>> _generatePieChartData(
    List<Transaction> txs,
    AppSettingsProvider settings,
  ) {
    final Map<String, double> categoryTotals = {};
    for (var tx in txs) {
      final amount = settings.convertAmount(tx.amount);
      categoryTotals.update(
        tx.categoryId,
        (val) => val + amount,
        ifAbsent: () => amount,
      );
    }
    return categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  List<PieChartSectionData> _generatePieSections(
    BuildContext context,
    List<MapEntry<String, double>> data,
    AppSettingsProvider settings,
  ) {
    double totalSum = data.fold(0, (sum, item) => sum + item.value);

    return List.generate(data.length, (i) {
      final isTouched = i == _touchedPieIndex;
      final entry = data[i];
      final percentage = totalSum > 0 ? (entry.value / totalSum * 100) : 0.0;
      final radius = isTouched ? 60.0 : 55.0;

      final showLabel = percentage > 5;
      final category = Provider.of<CategoryProvider>(
        context,
      ).getCategoryById(entry.key);

      return PieChartSectionData(
        color: Color(category?.colorValue ?? Colors.grey.toARGB32()),
        value: entry.value,
        title: showLabel && !isTouched
            ? '${percentage.toStringAsFixed(1)}%'
            : '',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
        badgeWidget: isTouched
            ? _buildPieTooltip(context, entry, percentage, settings)
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    });
  }
}

class _Stats {
  double income = 0;
  double expense = 0;
}

class _BarChartDataWrapper {
  final List<BarChartGroupData> groups;
  final List<String> labels;

  _BarChartDataWrapper(this.groups, this.labels);
}
