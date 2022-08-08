import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../provider/schedules.dart';
import 'about.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    Key? key,
    required this.schedulesData,
  }) : super(key: key);

  static const routeName = "/settings";

  final SchedulesProvider schedulesData;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hour24Enabled = false;
  bool _notificationsEnabled = true;
  bool _sentryEnabled = false;
  DateTime _lastLoadTime = DateTime.now();
  String _defaultSchedule = "";

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

  Future<void> _showDefaultScheduleSelection(BuildContext ctx) async {
    await showModalBottomSheet(
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
          key: Key(_defaultSchedule),
          padding: const EdgeInsets.all(25.0),
          child: ListView(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RadioListTile(
                    title: const Text(
                      "None",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    value: "",
                    groupValue: _defaultSchedule,
                    onChanged: (value) {
                      setState(
                        () {
                          _defaultSchedule = value as String;
                        },
                      );

                      _setDefaultSchedule(value as String);

                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              ...widget.schedulesData.schedules.entries
                  .map(
                    (schedule) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RadioListTile(
                          title: Text(
                            schedule.value["name"] as String,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          value: schedule.key as String,
                          groupValue: _defaultSchedule,
                          onChanged: (value) {
                            setState(
                              () {
                                _defaultSchedule = value as String;
                              },
                            );

                            _setDefaultSchedule(value as String);

                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  )
                  .toList()
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AboutScreen.routeName);
            },
            icon: const Icon(
              FeatherIcons.info,
              size: 20,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(50, 25, 50, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "24-hour Time",
                    style: headingStyle,
                  ),
                  Switch(
                    value: _hour24Enabled,
                    onChanged: (newState) => _toggleHour24(newState),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Notifications",
                    style: headingStyle,
                  ),
                  const Switch(
                    value: false,
                    onChanged: null,
                  )
                  // Switch(
                  //   value: _notificationsEnabled,
                  //   onChanged: (newState) =>
                  //       _toggleNotificationsEnabled(newState),
                  // ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  _showDefaultScheduleSelection(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Default Schedule",
                      style: headingStyle,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _defaultSchedule != ""
                              ? widget.schedulesData.schedules[_defaultSchedule]
                                  ["shortName"]
                              : "None",
                          style: headingStyle.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          FeatherIcons.chevronRight,
                          size: 20,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 13),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Error Logging",
                    style: headingStyle,
                  ),
                  Switch(
                    value: _sentryEnabled,
                    onChanged: (newState) => _toggleSentry(newState),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Last Refreshed",
                    style: headingStyle,
                  ),
                  Text(
                    "${DateFormat.yMMMMd().format(
                      _lastLoadTime.toLocal(),
                    )} ${DateFormat.Hm().format(
                      _lastLoadTime.toLocal(),
                    )}",
                    style: headingStyle.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
