import 'package:flutter/material.dart';
import 'package:schedules/notification_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/schedules.dart';
import '../widgets/toggle_card.dart';

class ScheduleSettingsScreen extends StatefulWidget {
  const ScheduleSettingsScreen({
    Key? key,
    required this.scheduleId,
    required this.schedulesData,
  }) : super(key: key);

  static const routeName = "/schedule/settings";

  final String scheduleId;
  final SchedulesProvider schedulesData;

  @override
  State<ScheduleSettingsScreen> createState() => _ScheduleSettingsScreenState();
}

class _ScheduleSettingsScreenState extends State<ScheduleSettingsScreen> {
  final Map<NotificationInterval, bool> _notificationIntervals = {};

  @override
  void initState() {
    super.initState();
    _loadNotificationIntervals();
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
              "Settings for ${widget.schedulesData.schedules[widget.scheduleId]["shortName"]}",
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
                    "Notification Intervals",
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
                      .toList()
                  // ToggleCard(
                  //   title: "24-hour time",
                  //   subtitle: "Use 24-hour time instead of 12-hour time",
                  //   action: (newState) => _toggleHour24(newState),
                  //   initialValue: _hour24Enabled,
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
