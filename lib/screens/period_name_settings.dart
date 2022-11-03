import 'package:flutter/material.dart';
import 'package:schedules/utils/schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/schedules.dart';

class SchedulePeriodNamesSettingsScreen extends StatefulWidget {
  const SchedulePeriodNamesSettingsScreen({
    Key? key,
    required this.scheduleId,
    required this.schedulesData,
    required this.schedule,
  }) : super(key: key);

  static const routeName = "/schedule/periodNames";

  final String scheduleId;
  final SchedulesProvider schedulesData;
  final Schedule schedule;

  @override
  State<SchedulePeriodNamesSettingsScreen> createState() =>
      _SchedulePeriodNamesSettingsScreenState();
}

class _SchedulePeriodNamesSettingsScreenState
    extends State<SchedulePeriodNamesSettingsScreen> {
  final Map<Period, String> _periods = {};

  @override
  void initState() {
    super.initState();
    _loadPeriodNames();
  }

  void _loadPeriodNames() async {
    final prefs = await SharedPreferences.getInstance();
    Set<Period> periods = {};

    for (var day in widget.schedule.schedule["schedule"].keys) {
      final Map<dynamic, dynamic> daySchedule =
          widget.schedule.schedule["schedule"][day];

      for (final periodName in daySchedule.keys) {
        final period = daySchedule[periodName];

        PeriodTimes times = period is List
            ? PeriodTimes(period[0], period[1])
            : PeriodTimes(period["times"][0], period["times"][1]);

        bool allowEditing = true;
        if (period is List && (periodName as String).contains("Passing (")) {
          allowEditing = false;
        } else if (period is! List) {
          allowEditing = period["allowEditing"];
        }

        if (periods.every(
            (schedulePeriod) => schedulePeriod.originalName != periodName)) {
          periods.add(
            Period(
              periodName,
              periodName,
              times,
              allowEditing,
            ),
          );
        }
      }
    }

    setState(
      () {
        for (var period in periods.where(
          (period) => period.allowEditing,
        )) {
          _periods[period] =
              (prefs.getString("${widget.scheduleId}.${period.id}.name") ?? "");
        }
      },
    );
  }

  Future<void> _setPeriodName(
    Period period,
    String newValue,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    setState(
      () {
        _periods[period] = newValue;
        prefs.setString("${widget.scheduleId}.${period.id}.name", newValue);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: backgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            backgroundColor: backgroundColor,
            title: Text(
              "${widget.schedulesData.schedules[widget.scheduleId]["shortName"]}: Period Names",
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: 15.0,
              right: 15.0,
              bottom: bottomPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const Text(
                    "Period Names",
                    style: TextStyle(
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  ..._periods.entries
                      .map(
                        (period) => Padding(
                          padding: const EdgeInsets.only(
                            top: 6,
                            bottom: 6,
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              textSelectionTheme: const TextSelectionThemeData(
                                cursorColor: Colors.pink,
                                selectionColor: Colors.pink,
                                selectionHandleColor: Colors.pink,
                              ),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.pink,
                                    width: 0.0,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.pink,
                                  ),
                                ),
                                focusColor: Colors.pink,
                                fillColor: Colors.pink,
                                labelText: period.key.originalName,
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.pink,
                                ),
                                hintStyle: const TextStyle(
                                  color: Colors.pink,
                                ),
                                // hintText: 'Enter a search term',
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              controller: TextEditingController()
                                ..text = period.value,
                              onSubmitted: (value) => _setPeriodName(
                                period.key,
                                value,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
