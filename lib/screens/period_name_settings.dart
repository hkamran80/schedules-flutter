import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedules/utils/schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/schedules.dart';

class SchedulePeriodNamesSettingsScreen extends StatefulWidget {
  const SchedulePeriodNamesSettingsScreen({
    Key? key,
    required this.scheduleId,
  }) : super(key: key);

  static const routeName = "/schedule/periodNames";

  final String scheduleId;

  @override
  State<SchedulePeriodNamesSettingsScreen> createState() =>
      _SchedulePeriodNamesSettingsScreenState();
}

class _SchedulePeriodNamesSettingsScreenState
    extends State<SchedulePeriodNamesSettingsScreen> {
  final Map<Period, String> _periods = {};

  @override
  void initState() {
    super.initState();
  }

  void _loadPeriodNames(Set<Period> periods) async {
    final prefs = await SharedPreferences.getInstance();

    setState(
      () {
        for (var period in periods.where(
          (period) => period.allowEditing,
        )) {
          _periods[period] =
              (prefs.getString("${widget.scheduleId}.${period.id}.name") ?? "");
        }
      },
    );
  }

  Future<void> _setPeriodName(
    Period period,
    String newValue,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    setState(
      () {
        _periods[period] = newValue;
        prefs.setString("${widget.scheduleId}.${period.id}.name", newValue);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final schedules = Provider.of<SchedulesProvider>(context);
    final schedule = schedules.scheduleMap[widget.scheduleId]!;

    if (_periods.isEmpty) {
      _loadPeriodNames(schedule.periods);
    }

    return Material(
      color: backgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            backgroundColor: backgroundColor,
            title: Text(
              "${schedule.shortName}: Period Names",
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: 15.0,
              right: 15.0,
              bottom: bottomPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const Text(
                    "Period Names",
                    style: TextStyle(
                      color: Colors.pink,
                    ),
                  ),
                  const Text(
                    "To load your updated period names, please exit the schedule, then re-enter it",
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  ..._periods.entries
                      .map(
                        (period) => Padding(
                          padding: const EdgeInsets.only(
                            top: 6,
                            bottom: 6,
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              textSelectionTheme: const TextSelectionThemeData(
                                cursorColor: Colors.pink,
                                selectionColor: Colors.pink,
                                selectionHandleColor: Colors.pink,
                              ),
                            ),
                            child: Builder(
                              builder: (BuildContext context) {
                                TextEditingController controller =
                                    TextEditingController();
                                controller.text = period.value;

                                return Focus(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 0.0,
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                        ),
                                      ),
                                      focusColor: Colors.pink,
                                      fillColor: Colors.pink,
                                      labelText: period.key.originalName,
                                      floatingLabelStyle: const TextStyle(
                                        color: Colors.pink,
                                      ),
                                      hintStyle: const TextStyle(
                                        color: Colors.pink,
                                      ),
                                      // hintText: 'Enter a search term',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    controller: controller,
                                    onSubmitted: (value) => _setPeriodName(
                                      period.key,
                                      value.trim(),
                                    ),
                                  ),
                                  onFocusChange: (hasFocus) => _setPeriodName(
                                    period.key,
                                    controller.text.trim(),
                                  ),
                                );
                              },
                            ),
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
