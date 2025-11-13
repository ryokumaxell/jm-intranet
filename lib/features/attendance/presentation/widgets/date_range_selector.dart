import 'package:flutter/material.dart';

class DateRangeSelector extends StatelessWidget {
  final DateTimeRange value;
  final ValueChanged<DateTimeRange> onChanged;
  const DateRangeSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.date_range),
      label: Text('${_fmt(value.start)} - ${_fmt(value.end)}'),
      onPressed: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDateRange: value,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(),
              child: child!,
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
    );
  }

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}