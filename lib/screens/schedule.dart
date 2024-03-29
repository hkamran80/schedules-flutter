import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../extensions/color.dart';
import '../modals/timetable.dart';
import '../provider/schedules.dart';
import '../utils/schedule.dart';
import '../widgets/stacked_card.dart';
import '../extensions/string.dart';

class ScheduleScreenArguments {
  final String scheduleId;

  ScheduleScreenArguments(this.scheduleId);
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({
    Key? key,
    required this.scheduleId,
  }) : super(key: key);

  final String scheduleId;

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

  String get threeLetterDay => DateFormat.E()
      .format(
        DateTime.now(),
      )
      .toUpperCase();

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final schedules = Provider.of<SchedulesProvider>(context);

    if (!schedules.scheduleMap.containsKey(widget.scheduleId)) {
      // setState(() => context.go("/"));
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go("/"));
      return Material(
        color: backgroundColor,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              backgroundColor: backgroundColor,
              title: const Text(
                "Unknown",
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 5.0,
                right: 5.0,
              ),
              sliver: SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Unknown Schedule",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 36,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "The schedule that attempted to open does not exist.",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final schedule = schedules.scheduleMap[widget.scheduleId]!;
    if (schedule.periods.isEmpty) {
      setState(
        () {
          for (String day in schedule.periodSchedule.keys) {
            schedule.generateDayPeriods(day);
          }
        },
      );
    }

    return Material(
      color: backgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            backgroundColor: backgroundColor,
            title: Text(
              schedule.shortName,
            ),
            leading: Navigator.canPop(context)
                ? null
                : IconButton(
                    onPressed: () => context.go("/"),
                    icon: const Icon(
                      LucideIcons.home,
                      size: 20,
                    ),
                  ),
            actions: [
              if (schedule.periodSchedule.containsKey(
                threeLetterDay,
              ))
                IconButton(
                  onPressed: () => _showTimetable(
                    context,
                    schedule.daySchedule(
                      schedule.override == null
                          ? threeLetterDay
                          : schedule.override!,
                    ),
                  ),
                  icon: const Icon(
                    LucideIcons.calendar,
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
                    value: "periodNames",
                    child: Text(
                      "Period Names",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: "importSettings",
                    child: Text(
                      "Import Settings",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: "exportSettings",
                    child: Text(
                      "Export Settings",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == "notifications") {
                    context
                        .push("/schedule/${widget.scheduleId}/notifications");
                  } else if (value == "periodNames") {
                    context.push("/schedule/${widget.scheduleId}/periodNames");
                  } else if (value == "importSettings") {
                    context
                        .push("/schedule/${widget.scheduleId}/settingsImport");
                  } else if (value == "exportSettings") {
                    Clipboard.setData(
                      ClipboardData(
                        text: jsonEncode(
                          await schedule.generateExport(),
                        ),
                      ),
                    ).then(
                      (_) {
                        // Fluttertoast.showToast(
                        //   msg: "Exported settings!",
                        //   toastLength: Toast.LENGTH_SHORT,
                        //   gravity: ToastGravity.CENTER,
                        //   timeInSecForIosWeb: 1,
                        //   backgroundColor: Colors.green,
                        //   textColor: Colors.white,
                        //   fontSize: 16.0,
                        // );
                      },
                    );
                  }
                },
                color: Theme.of(context).brightness == Brightness.light
                    ? HexColor.fromHex("#F7F7F7")
                    : HexColor.fromHex("#151515"),
                icon: const Icon(
                  LucideIcons.settings,
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
              child: schedule.activeOffDay == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          child: schedule.currentPeriodExists
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    StackedCard(
                                      header: schedule.currentPeriod!.name,
                                      content: schedule.timeRemaining,
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                        Container(
                          child: schedule.nextPeriodExists
                              ? StackedCard(
                                  header: schedule.nextPeriod!.name,
                                  content: schedule.nextPeriod!.times.start
                                      .convertTime(
                                    _hour24Enabled,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Container(
                          child: schedule.timeToNextPeriodExists
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    StackedCard(
                                      header: schedule.timeToNextPeriod!.name,
                                      content:
                                          "${schedule.timeToNextPeriod!.times.start.convertTime(
                                        _hour24Enabled,
                                      )} — ${schedule.timeRemainingToNextPeriod}",
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                        Container(
                          child: !schedule.currentPeriodExists &&
                                  !schedule.nextPeriodExists &&
                                  !schedule.timeToNextPeriodExists
                              ? Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "No Remaining Periods",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 36,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "There are no periods for the rest of the day",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule.activeOffDay!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 36,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            schedule.activeOffDay!.endDate == null
                                ? "Enjoy your day off!"
                                : "Enjoy your break! It ends on ${DateFormat.yMMMMd().format(schedule.activeOffDay!.endDate!)}.",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }
}
