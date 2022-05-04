import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'about.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  static const routeName = "/settings";

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hour24Enabled = false;
  // bool _notificationsEnabled = true;
  bool _sentryEnabled = true;
  DateTime _lastLoadTime = DateTime.now();

  TextStyle headingStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  @override
  void initState() {
    super.initState();
    _loadHour24();
    // _loadNotificationsEnabled();
    _loadLastLoadTime();
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

  // void _loadNotificationsEnabled() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(
  //     () {
  //       _notificationsEnabled =
  //           (prefs.getBool('_notificationsEnabled') ?? true);
  //     },
  //   );
  // }

  // void _toggleNotificationsEnabled(bool newState) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(
  //     () {
  //       _notificationsEnabled = newState;
  //       prefs.setBool('_notificationsEnabled', newState);
  //     },
  //   );
  // }

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
        _sentryEnabled = (prefs.getBool('_sentryEnabled') ?? true);
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
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       "Notifications",
              //       style: headingStyle,
              //     ),
              //     Switch(
              //       value: _notificationsEnabled,
              //       onChanged: (newState) =>
              //           _toggleNotificationsEnabled(newState),
              //     ),
              //   ],
              // ),
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
                    DateFormat.yMMMMd().format(
                          _lastLoadTime.toLocal(),
                        ) +
                        " " +
                        DateFormat.Hm().format(
                          _lastLoadTime.toLocal(),
                        ),
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
