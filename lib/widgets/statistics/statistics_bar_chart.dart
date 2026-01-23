import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../providers/app_settings_provider.dart';

class StatisticsBarChart extends StatelessWidget {
  final List<BarChartGroupData> groups;
  final List<String> labels;
  final AppSettingsProvider settings;
  final dynamic uniqueKey;

  const StatisticsBarChart({
    super.key,
    required this.groups,
    required this.labels,
    required this.settings,
    required this.uniqueKey,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      key: ValueKey(uniqueKey),
      BarChartData(
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 0,
              color: Colors.grey.withValues(alpha: 0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ],
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex >= labels.length) {
                return null;
              }
              final bool isIncome = rodIndex == 0;
              final Color valueColor = isIncome
                  ? Colors.greenAccent
                  : Colors.redAccent;
              String type = isIncome
                  ? settings.t('income')
                  : settings.t('expense');
              return BarTooltipItem(
                '$type\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text:
                        '${rod.toY.toStringAsFixed(2)} ${settings.currencySymbol()}',
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 60,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Transform.translate(
                    offset: const Offset(0, 10),
                    child: Transform.rotate(
                      angle: -math.pi / 6,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          labels[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10),
                          softWrap: false,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 46,
              getTitlesWidget: (value, meta) {
                if (value == meta.max) {
                  return const SizedBox.shrink();
                }
                String text;
                if (value >= 1000000000) {
                  text = '${(value / 1000000000).toStringAsFixed(1)}G';
                } else if (value >= 1000000) {
                  text = '${(value / 1000000).toStringAsFixed(1)}M';
                } else if (value >= 1000) {
                  text = '${(value / 1000).toStringAsFixed(1)}k';
                } else {
                  text = value.toInt().toString();
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    text,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: groups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          checkToShowHorizontalLine: (value) => value != 0,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        alignment: BarChartAlignment.spaceAround,
      ),
    );
  }
}
