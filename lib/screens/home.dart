import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:schedules/constants.dart';
import 'package:schedules/widgets/schedule_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../extensions/color.dart';
import '../provider/schedules.dart';
import '../utils/schedule.dart';
import '../utils/schedule_variant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _defaultSchedule = "";
  bool _switched = false;

  void _launchUrl(Uri uri, {LaunchMode? launchMode}) async {
    if (!await launchUrl(
      uri,
      mode: launchMode ?? LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $uri';
    }
  }

  @override
  void initState() {
    super.initState();
    _getSchedules();
    _loadDefaultSchedule();
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

  Future<void> _loadDefaultSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _defaultSchedule = (prefs.getString('_defaultSchedule') ?? "");
      },
    );
  }

  void _deleteDefaultSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () {
        prefs.setString('_defaultSchedule', "");
        _defaultSchedule = "";
      },
    );
  }

  void _switchToDefaultSchedule(BuildContext ctx) {
    if (kDebugMode) {
      print("Loading default schedule: \"$_defaultSchedule\"");
    }

    if (GoRouter.of(context).location == "/") {
      context.push('/schedule/$_defaultSchedule');
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final schedulesData = Provider.of<SchedulesProvider>(context);

    Map<String, VariantOrSchedule> schedulesList = Map.fromEntries(
      generateScheduleListWithVariants(
        schedulesData.schedules,
      ).entries.toList()
        ..sort(
          (schedule1, schedule2) => schedule1.value.comparableName.compareTo(
            schedule2.value.comparableName,
          ),
        ),
    );

    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        if (schedulesData.schedules.isNotEmpty &&
            _defaultSchedule != "" &&
            schedulesData.schedules.containsKey(_defaultSchedule) &&
            !_switched) {
          _switched = true;
          _switchToDefaultSchedule(context);
        } else if (schedulesData.schedules.isNotEmpty &&
            _defaultSchedule != "" &&
            !schedulesData.schedules.containsKey(_defaultSchedule) &&
            !_switched) {
          _deleteDefaultSchedule();
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
            ),
            actions: [
              IconButton(
                onPressed: () {
                  schedulesData.getSchedules();
                },
                icon: const Icon(
                  LucideIcons.refreshCw,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () => context.push("/settings"),
                icon: const Icon(
                  LucideIcons.settings,
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
            sliver: schedulesData.loading
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: "Loading",
                      ),
                    ),
                  )
                : schedulesData.schedules.isNotEmpty
                    ? SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            ...schedulesList.entries
                                .map(
                                  (schedule) => ScheduleCard(
                                    name: schedule.value.name,
                                    location: schedule.value.location,
                                    backgroundColor:
                                        HexColor.fromHex(schedule.value.color),
                                    onPressed: () {
                                      if (schedule.value.type == Schedule) {
                                        context
                                            .push("/schedule/${schedule.key}");
                                      } else {
                                        showModalBottomSheet(
                                          elevation: 10,
                                          backgroundColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          context: context,
                                          builder: (ctx) => Container(
                                            width:
                                                MediaQuery.of(ctx).size.width,
                                            height:
                                                MediaQuery.of(ctx).size.height *
                                                    0.40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              color: Theme.of(ctx).brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey.shade900
                                                  : Colors.grey.shade100,
                                            ),
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(25.0),
                                              child: ListView(
                                                children: [
                                                  Text(
                                                    schedule.value.name,
                                                    style: const TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  ...schedule
                                                      .value.variant!.variants
                                                      .map(
                                                        (variant) =>
                                                            ScheduleCard(
                                                          name: variant.name,
                                                          backgroundColor:
                                                              HexColor.fromHex(
                                                                  schedule.value
                                                                      .color),
                                                          onPressed: () =>
                                                              context.push(
                                                                  "/schedule/${variant.id}"),
                                                        ),
                                                      )
                                                      .toList()
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                )
                                .toList(),
                            const Divider(
                              thickness: 4.0,
                              indent: 8.0,
                              endIndent: 8.0,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ScheduleCard(
                              name: "Missing your school?",
                              backgroundColor: HexColor.fromHex("#BE154D"),
                              onPressed: () => _launchUrl(
                                requestLink,
                                launchMode: LaunchMode.inAppWebView,
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                          ],
                        ),
                      )
                    : const SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            "No schedules available",
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
