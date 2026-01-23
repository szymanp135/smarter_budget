import 'package:flutter/material.dart';
import '../../providers/app_settings_provider.dart';
import '../../screens/statistics_screen.dart';

class TimeRangeSelector extends StatelessWidget {
  final TimeRange selectedRange;
  final Function(TimeRange) onRangeChanged;
  final AppSettingsProvider settings;

  const TimeRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final Map<TimeRange, String> labels = {
      TimeRange.month1: settings.t('1_month'),
      TimeRange.month3: settings.t('3_months'),
      TimeRange.month6: settings.t('6_months'),
      TimeRange.year1: settings.t('1_year'),
      TimeRange.all: settings.t('all_time'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TimeRange>(
          value: selectedRange,
          isExpanded: true,
          icon: const Icon(Icons.calendar_month),
          items: TimeRange.values
              .map(
                (range) => DropdownMenuItem(
                  value: range,
                  child: Text(
                    labels[range]!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) onRangeChanged(newValue);
          },
        ),
      ),
    );
  }
}
