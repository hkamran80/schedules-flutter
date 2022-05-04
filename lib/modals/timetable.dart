import 'package:flutter/material.dart';

import '../utils/schedule.dart';
import '../extensions/string.dart';

class Timetable extends StatelessWidget {
  const Timetable(
      {Key? key, required this.periods, required this.hour24Enabled})
      : super(key: key);

  final List<Period?> periods;
  final bool hour24Enabled;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: periods
          .map(
            (period) => Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  period!.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  period.times.start.convertTime(hour24Enabled) +
                      " - " +
                      period.times.end.convertTime(hour24Enabled),
                ),
                const SizedBox(height: 15),
              ],
            ),
          )
          .toList(),
    );
  }
}
