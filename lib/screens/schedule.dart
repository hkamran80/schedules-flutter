import 'dart:async';
import 'dart:convert';

import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedules/modals/timetable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../extensions/color.dart';
import '../provider/schedules.dart';
import '../utils/schedule.dart';
import '../widgets/stacked_card.dart';
import '../extensions/string.dart';
import 'notification_settings.dart';

class ScheduleScreenArguments {
  final String scheduleId;

  ScheduleScreenArguments(this.scheduleId);
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({
    Key? key,
    required this.args,
    required this.schedulesData,
    required this.schedule,
  }) : super(key: key);

  static const routeName = "/schedule";
  final ScheduleScreenArguments args;
  final SchedulesProvider schedulesData;
  final Schedule schedule;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final format = DateFormat("H:m:s");

  bool _hour24Enabled = false;
  late Timer _scheduleTimer;
  Object _reloadKey = Object();

  @override
  void initState() {
    super.initState();
    _loadHour24();

    setState(
      () {
        widget.schedule.generateDayPeriods(
          DateFormat.E()
              .format(
                DateTime.now(),
              )
              .toUpperCase(),
        );
      },
    );

    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _scheduleTimer.cancel();
  }

  void _loadHour24() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _hour24Enabled = (prefs.getBool('_hour24Enabled') ?? false);
      },
    );
  }

  void _startTimer() async {
    setState(
      () {
        _scheduleTimer = Timer.periodic(
          const Duration(seconds: 1),
          (Timer timer) {
            setState(
              () {
                _reloadKey = Object();
              },
            );
          },
        );
      },
    );
  }

  void _showTimetable(BuildContext ctx, List<Period?> daySchedule) {
    showModalBottomSheet(
      elevation: 10,
      backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
      context: ctx,
      builder: (ctx) => Container(
        width: MediaQuery.of(ctx).size.width,
        height: MediaQuery.of(ctx).size.height * 0.75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Theme.of(ctx).brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.grey.shade100,
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Timetable(
            periods: daySchedule,
            hour24Enabled: _hour24Enabled,
          ),
        ),
      ),
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
              widget.schedulesData.schedules[widget.args.scheduleId]
                  ["shortName"],
            ),
            actions: [
              if ((widget.schedule.schedule["schedule"] as Map<String, dynamic>)
                  .containsKey(
                DateFormat.E()
                    .format(
                      DateTime.now(),
                    )
                    .toUpperCase(),
              ))
                IconButton(
                  onPressed: () => _showTimetable(
                    context,
                    widget.schedule.daySchedule(
                      DateFormat.E()
                          .format(
                            DateTime.now(),
                          )
                          .toUpperCase(),
                    ),
                  ),
                  icon: const Icon(
                    FeatherIcons.calendar,
                    size: 20,
                  ),
                ),
              PopupMenuButton(
                itemBuilder: (BuildContext context) => const [
                  PopupMenuItem(
                    value: "notifications",
                    child: Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: "settings",
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == "notifications") {
                    Navigator.pushNamed(
                      context,
                      ScheduleNotificationsSettingsScreen.routeName,
                      arguments: ScheduleScreenArguments(
                        widget.args.scheduleId,
                      ),
                    );
                  } else if (value == "settings") {
                    if (kDebugMode) {
                      print("Settings navigation is not yet implemented.");
                    }
                  }
                },
                color: Theme.of(context).brightness == Brightness.light
                    ? HexColor.fromHex("#F7F7F7")
                    : HexColor.fromHex("#151515"),
                icon: const Icon(
                  FeatherIcons.settings,
                  size: 20,
                ),
                position: PopupMenuPosition.under,
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 5.0,
              right: 5.0,
            ),
            sliver: SliverToBoxAdapter(
              key: ValueKey(_reloadKey),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    child: widget.schedule.currentPeriodExists
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StackedCard(
                                header: widget.schedule.currentPeriod!.name,
                                content: widget.schedule.timeRemaining,
                              ),
                              const SizedBox(height: 10),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  Container(
                    child: widget.schedule.nextPeriodExists
                        ? StackedCard(
                            header: widget.schedule.nextPeriod!.name,
                            content: widget.schedule.nextPeriod!.times.start
                                .convertTime(
                              _hour24Enabled,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Container(
                    child: !widget.schedule.nextPeriodExists &&
                            !widget.schedule.currentPeriodExists
                        ? Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "No Active Period",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 36,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "The current schedule does not have any periods listed for the current time",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "ISO-8601: ${DateTime.now().toIso8601String()}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Current Period (exists): ${widget.schedule.currentPeriodExists}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "Next Period (exists): ${widget.schedule.nextPeriodExists}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  jsonEncode(widget.schedulesData
                                          .schedules[widget.args.scheduleId])
                                      .toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
