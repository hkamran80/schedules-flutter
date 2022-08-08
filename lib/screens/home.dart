import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:schedules/modals/whats_new.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../extensions/color.dart';
import '../provider/schedules.dart';
import 'settings.dart';
import 'schedule.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  static const routeName = "/";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _defaultSchedule = "";
  bool _switched = false;

  @override
  void initState() {
    super.initState();
    _getSchedules();
    _loadDefaultSchedule();
    _checkForNewVersion();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getSchedules() async {
    final schedulesData = Provider.of<SchedulesProvider>(
      context,
      listen: false,
    );

    schedulesData.getSchedules();
  }

  Future<void> _checkForNewVersion() async {
    final prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String savedBuildNumber = (prefs.getString("buildNumber") ?? "");
    if (savedBuildNumber != "" && savedBuildNumber != packageInfo.buildNumber) {
      // ignore: use_build_context_synchronously
      _showWhatsNew(context);
    }
  }

  Future<void> _loadDefaultSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _defaultSchedule = (prefs.getString('_defaultSchedule') ?? "");
      },
    );
  }

  void _showWhatsNew(BuildContext ctx) {
    showModalBottomSheet(
      elevation: 10,
      backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
      context: ctx,
      builder: (ctx) => Container(
        width: MediaQuery.of(ctx).size.width,
        height: MediaQuery.of(ctx).size.height * 0.25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Theme.of(ctx).brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.grey.shade100,
        ),
        alignment: Alignment.center,
        child: const Padding(
          padding: EdgeInsets.all(25.0),
          child: WhatsNew(),
        ),
      ),
    );
  }

  void _switchToDefaultSchedule(BuildContext ctx) {
    if (kDebugMode) {
      print("Loading default schedule: \"$_defaultSchedule\"");
    }

    Navigator.pushNamed(
      ctx,
      "/schedule",
      arguments: ScheduleScreenArguments(
        _defaultSchedule,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final schedulesData = Provider.of<SchedulesProvider>(context);

    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        if (schedulesData.schedules.isNotEmpty &&
            _defaultSchedule != "" &&
            schedulesData.schedules.containsKey(_defaultSchedule) &&
            !_switched) {
          _switched = true;
          _switchToDefaultSchedule(context);
        }
      },
    );

    return Material(
      color: backgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: backgroundColor,
            title: const Text(
              "Schedules",
              style: TextStyle(
                fontSize: 40.0,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  schedulesData.getSchedules();
                },
                icon: const Icon(
                  FeatherIcons.refreshCw,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, SettingsScreen.routeName);
                },
                icon: const Icon(
                  FeatherIcons.settings,
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
                schedulesData.schedules.entries
                    .map(
                      (schedule) => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  HexColor.fromHex(schedule.value["color"])
                                              .computeLuminance() >
                                          0.5
                                      ? Colors.black
                                      : Colors.white,
                              alignment: Alignment.centerLeft,
                              backgroundColor: HexColor.fromHex(
                                schedule.value["color"],
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                ScheduleScreen.routeName,
                                arguments: ScheduleScreenArguments(
                                  schedule.key,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                0,
                                15,
                                0,
                                15,
                              ),
                              child: Text(
                                schedule.value["name"],
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
