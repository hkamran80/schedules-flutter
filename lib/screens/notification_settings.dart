import 'package:flutter/material.dart';
import 'package:schedules/notification_constants.dart';
import 'package:schedules/utils/schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/schedules.dart';
import '../widgets/toggle_card.dart';

class ScheduleNotificationsSettingsScreen extends StatefulWidget {
  const ScheduleNotificationsSettingsScreen({
    Key? key,
    required this.scheduleId,
    required this.schedulesData,
    required this.schedule,
  }) : super(key: key);

  static const routeName = "/schedule/notifications";

  final String scheduleId;
  final SchedulesProvider schedulesData;
  final Schedule schedule;

  @override
  State<ScheduleNotificationsSettingsScreen> createState() =>
      _ScheduleNotificationsSettingsScreenState();
}

class _ScheduleNotificationsSettingsScreenState
    extends State<ScheduleNotificationsSettingsScreen> {
  final Map<NotificationInterval, bool> _notificationIntervals = {};
  final Map<NotificationDay, bool> _notificationDays = {};
  final Map<Period, bool> _notificationPeriods = {};

  @override
  void initState() {
    super.initState();
    _loadNotificationIntervals();
    _loadNotificationDays();
    _loadNotificationPeriods();
  }

  void _loadNotificationIntervals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        for (var interval in notificationIntervals) {
          _notificationIntervals[interval] =
              (prefs.getBool("${widget.scheduleId}.${interval.id}") ?? true);
        }
      },
    );
  }

  void _loadNotificationDays() async {
    final prefs = await SharedPreferences.getInstance();
    final days = (widget.schedulesData.schedules[widget.scheduleId]["schedule"]
            as Map<String, dynamic>)
        .keys
        .toList();

    setState(
      () {
        for (var day in notificationDays) {
          if (days.contains(day.day.substring(0, 3).toUpperCase())) {
            _notificationDays[day] =
                (prefs.getBool("${widget.scheduleId}.${day.id}") ?? true);
          }
        }
      },
    );
  }

  void _loadNotificationPeriods() async {
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
        for (var period in periods) {
          _notificationPeriods[period] =
              (prefs.getBool("${widget.scheduleId}.${period.id}") ?? true);
        }
      },
    );
  }

  Future<void> _setNotificationIntervalState(
    NotificationInterval interval,
    bool newValue,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    setState(
      () {
        _notificationIntervals[interval] = newValue;
        prefs.setBool("${widget.scheduleId}.${interval.id}", newValue);
      },
    );
  }

  Future<void> _setNotificationDayState(
    NotificationDay day,
    bool newValue,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    setState(
      () {
        _notificationDays[day] = newValue;
        prefs.setBool("${widget.scheduleId}.${day.id}", newValue);
      },
    );
  }

  Future<void> _setNotificationPeriodState(
    Period period,
    bool newValue,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    setState(
      () {
        _notificationPeriods[period] = newValue;
        prefs.setBool("${widget.scheduleId}.${period.id}", newValue);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Material(
      color: backgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            backgroundColor: backgroundColor,
            title: Text(
              "${widget.schedulesData.schedules[widget.scheduleId]["shortName"]}: Notifications",
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 15.0,
              right: 15.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const Text(
                    "Intervals",
                    style: TextStyle(
                      color: Colors.pink,
                    ),
                  ),
                  ..._notificationIntervals.entries
                      .map(
                        (interval) => ToggleCard(
                          title: interval.key.name,
                          initialValue: interval.value,
                          action: (newValue) => _setNotificationIntervalState(
                            interval.key,
                            newValue,
                          ),
                        ),
                      )
                      .toList(),

                  // Days
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    "Days",
                    style: TextStyle(
                      color: Colors.pink,
                    ),
                  ),
                  ..._notificationDays.entries
                      .map(
                        (day) => ToggleCard(
                          title: day.key.day,
                          initialValue: day.value,
                          action: (newValue) => _setNotificationDayState(
                            day.key,
                            newValue,
                          ),
                        ),
                      )
                      .toList(),

                  // Periods
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    "Periods",
                    style: TextStyle(
                      color: Colors.pink,
                    ),
                  ),
                  ..._notificationPeriods.entries
                      .map(
                        (period) => ToggleCard(
                          title: period.key.name,
                          initialValue: period.value,
                          action: (newValue) => _setNotificationPeriodState(
                            period.key,
                            newValue,
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
