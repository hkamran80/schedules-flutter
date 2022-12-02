import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../extensions/color.dart';
import '../provider/schedules.dart';
import '../widgets/info_card.dart';
import '../widgets/toggle_card.dart';
import 'about.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hour24Enabled = false;
  bool _notificationsEnabled = true;
  bool _sentryEnabled = false;
  DateTime _lastLoadTime = DateTime.now();
  String _defaultSchedule = "";

  bool temporary = false;

  TextStyle headingStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  @override
  void initState() {
    super.initState();
    _loadHour24();
    _loadNotificationsEnabled();
    _loadLastLoadTime();
    _loadDefaultSchedule();
    _loadSentry();
  }

  void _loadHour24() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _hour24Enabled = (prefs.getBool('_hour24Enabled') ?? false);
      },
    );
  }

  void _toggleHour24(bool newState) async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _hour24Enabled = newState;
        prefs.setBool('_hour24Enabled', newState);
      },
    );
  }

  void _loadNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _notificationsEnabled =
            (prefs.getBool('_notificationsEnabled') ?? true);
      },
    );
  }

  void _toggleNotificationsEnabled(bool newState) async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _notificationsEnabled = newState;
        prefs.setBool('_notificationsEnabled', newState);
      },
    );
  }

  void _loadLastLoadTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _lastLoadTime = DateTime.parse(
          prefs.getString("schedulesLoadTime") ??
              DateTime.now().toIso8601String(),
        );
      },
    );
  }

  void _loadSentry() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _sentryEnabled = (prefs.getBool('_sentryEnabled') ?? false);
      },
    );
  }

  void _toggleSentry(bool newState) async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _sentryEnabled = newState;
        prefs.setBool('_sentryEnabled', newState);
      },
    );
  }

  void _loadDefaultSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _defaultSchedule = (prefs.getString('_defaultSchedule') ?? "");
      },
    );
  }

  Future<void> _setDefaultSchedule(String newDefault) async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        prefs.setString("_defaultSchedule", newDefault);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final schedules = Provider.of<SchedulesProvider>(context);

    return Material(
      color: backgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            backgroundColor: backgroundColor,
            title: const Text(
              "Settings",
            ),
            actions: [
              IconButton(
                onPressed: () => context.push("/about"),
                icon: const Icon(
                  LucideIcons.info,
                  size: 20,
                ),
              )
            ],
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
                    "Settings",
                    style: TextStyle(
                      color: Colors.pink,
                    ),
                  ),
                  ToggleCard(
                    title: "24-hour time",
                    subtitle: "Use 24-hour time instead of 12-hour time",
                    action: (newState) => _toggleHour24(newState),
                    initialValue: _hour24Enabled,
                  ),
                  ToggleCard(
                    title: "Notifications",
                    subtitle:
                        "Schedules will alert you at certain time remainings. This can be customized on a per-schedule basis or globally.",
                    action: (newState) => _toggleNotificationsEnabled(newState),
                    initialValue: _notificationsEnabled,
                  ),
                  ToggleCard(
                    title: "Error Logging",
                    subtitle:
                        "If an error occurs, Sentry will send an error report to the developer",
                    action: (newState) => _toggleSentry(newState),
                    initialValue: _sentryEnabled,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      bottom: 12,
                      right: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Default Schedule",
                                style: TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                              Text(
                                "The schedule to open at launch",
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black54
                                      : Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownButton(
                          icon: const Icon(
                            LucideIcons.chevronDown,
                            size: 20,
                          ),
                          dropdownColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? HexColor.fromHex("#F7F7F7")
                                  : HexColor.fromHex("#151515"),
                          value: _defaultSchedule,
                          selectedItemBuilder: ((context) => [
                                Container(
                                  alignment: Alignment.centerRight,
                                  constraints:
                                      const BoxConstraints(minWidth: 100),
                                  child: const Text("None"),
                                ),
                                ...schedules.scheduleMap.values
                                    .map(
                                      (schedule) => Container(
                                        alignment: Alignment.centerRight,
                                        constraints:
                                            const BoxConstraints(minWidth: 100),
                                        child: Text(
                                          schedule.shortName,
                                        ),
                                      ),
                                    )
                                    .toList()
                              ]),
                          items: [
                            const DropdownMenuItem(
                              value: "",
                              child: Text(
                                "None",
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            ...schedules.scheduleMap.values
                                .map(
                                  (schedule) => DropdownMenuItem(
                                    value: schedule.scheduleId,
                                    child: Text(
                                      schedule.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                                .toList()
                          ],
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                          ),
                          onChanged: (value) {
                            setState(
                              () {
                                _defaultSchedule = value as String;
                              },
                            );

                            _setDefaultSchedule(value as String);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Information
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    "Information",
                    style: TextStyle(
                      color: Colors.pink,
                    ),
                  ),
                  InfoCard(
                    title: "Last Refreshed",
                    subtitle: "The last time the schedules were updated",
                    value: "${DateFormat.yMMMMd().format(
                      _lastLoadTime.toLocal(),
                    )} ${DateFormat.Hm().format(
                      _lastLoadTime.toLocal(),
                    )}",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
