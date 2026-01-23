import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../providers/app_settings_provider.dart';

class StatisticsPieChart extends StatefulWidget {
  final List<PieChartSectionData> sections;
  final List<MapEntry<String, double>> pieData;
  final AppSettingsProvider settings;
  final dynamic uniqueKey;
  final Function(int) onTouch;

  const StatisticsPieChart({
    super.key,
    required this.sections,
    required this.pieData,
    required this.settings,
    required this.uniqueKey,
    required this.onTouch,
  });

  @override
  State<StatisticsPieChart> createState() => _StatisticsPieChartState();
}

class _StatisticsPieChartState extends State<StatisticsPieChart> {
  @override
  Widget build(BuildContext context) {
    if (widget.pieData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            widget.settings.t('no_transactions'),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PieChart(
            key: ValueKey(widget.uniqueKey),
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    widget.onTouch(-1);
                    return;
                  }
                  widget.onTouch(
                    pieTouchResponse.touchedSection!.touchedSectionIndex,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: widget.sections,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildPieLegend(widget.pieData, widget.settings),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildPieLegend(
    List<MapEntry<String, double>> data,
    AppSettingsProvider settings,
  ) {
    if (data.isEmpty) return const SizedBox.shrink();

    double totalSum = data.fold(0, (sum, item) => sum + item.value);

    List<double> rawPercentages = data
        .map((e) => (e.value / totalSum * 100))
        .toList();

    double roundedSum = 0;
    List<double> finalPercentages = [];
    for (var p in rawPercentages) {
      double rounded = double.parse(p.toStringAsFixed(1));
      finalPercentages.add(rounded);
      roundedSum += rounded;
    }

    double diff = 100.0 - roundedSum;
    if (diff.abs() > 0.01) {
      int maxIndex = 0;
      double maxVal = -1;
      for (int i = 0; i < rawPercentages.length; i++) {
        if (rawPercentages[i] > maxVal) {
          maxVal = rawPercentages[i];
          maxIndex = i;
        }
      }
      finalPercentages[maxIndex] += diff;
    }

    return Column(
      children: data.asMap().entries.map((mapEntry) {
        final index = mapEntry.key;
        final entry = mapEntry.value;
        final rawPercentage = (entry.value / totalSum * 100);

        String percentageString;
        if (rawPercentage < 0.1 && rawPercentage > 0) {
          percentageString = '<0.1%';
        } else {
          percentageString = '${finalPercentages[index].toStringAsFixed(1)}%';
        }

        final color = settings.getCategoryColor(entry.key);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                radius: 12,
                child: Icon(
                  settings.getCategoryIcon(entry.key),
                  size: 14,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Text(
                        settings.translateCategory(entry.key),
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 1,
                      child: Text(
                        '${entry.value.toStringAsFixed(2)} ${settings.currencySymbol()} ($percentageString)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
