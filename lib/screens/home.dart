import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
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
  @override
  void initState() {
    super.initState();
    _getSchedules();
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

    String _savedBuildNumber = (prefs.getString("buildNumber") ?? "");
    if (_savedBuildNumber != "" &&
        _savedBuildNumber != packageInfo.buildNumber) {
      _showWhatsNew(context);
    }
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

  @override
  Widget build(BuildContext context) {
    final schedulesData = Provider.of<SchedulesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: schedulesData.schedules.isEmpty
              ? Center(
                  child: Lottie.asset(
                    "assets/loading.json",
                    width: 175,
                    height: 175,
                  ),
                )
              : ListView(
                  children: schedulesData.schedules.entries
                      .map(
                        (schedule) => Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                primary:
                                    HexColor.fromHex(schedule.value["color"]),
                                onPrimary:
                                    HexColor.fromHex(schedule.value["color"])
                                                .computeLuminance() >
                                            0.5
                                        ? Colors.black
                                        : Colors.white,
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
                                padding:
                                    const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                child: Text(schedule.value["name"]),
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
    );
  }
}
