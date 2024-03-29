import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:schedules/widgets/schedule_card.dart';

import '../provider/schedules.dart';

class ImportSettingsScreen extends StatefulWidget {
  const ImportSettingsScreen({
    Key? key,
    required this.scheduleId,
  }) : super(key: key);

  final String scheduleId;

  @override
  State<ImportSettingsScreen> createState() => _ImportSettingsScreenState();
}

class _ImportSettingsScreenState extends State<ImportSettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final schedules = Provider.of<SchedulesProvider>(context);
    final schedule = schedules.scheduleMap[widget.scheduleId]!;

    TextEditingController importTextController = TextEditingController();

    return Material(
      color: backgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            backgroundColor: backgroundColor,
            title: Text(
              "${schedule.shortName}: Import Settings",
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
                  const SizedBox(height: 5),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.pink,
                          width: 0.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.pink,
                        ),
                      ),
                      focusColor: Colors.pink,
                      fillColor: Colors.pink,
                      labelText: "Settings",
                      floatingLabelStyle: TextStyle(
                        color: Colors.pink,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.pink,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textInputAction: TextInputAction.done,
                    controller: importTextController,
                    maxLines: null,
                  ),
                  const SizedBox(height: 25),
                  ScheduleCard(
                    name: "Import",
                    backgroundColor: Colors.pink,
                    onPressed: () async {
                      if (importTextController.text.trim().isNotEmpty) {
                        String result = await schedule.importSettings(
                          importTextController.text.trim(),
                        );

                        if (result == "SUCCESS") {
                          setState(() => context.pop());

                          // Fluttertoast.showToast(
                          //   msg: "Successfully imported settings!",
                          //   toastLength: Toast.LENGTH_SHORT,
                          //   gravity: ToastGravity.BOTTOM,
                          //   timeInSecForIosWeb: 1,
                          //   backgroundColor: Colors.green,
                          //   textColor: Colors.white,
                          //   fontSize: 16.0,
                          // );
                        } else {
                          // Fluttertoast.showToast(
                          //   msg: "Error: $result",
                          //   toastLength: Toast.LENGTH_SHORT,
                          //   gravity: ToastGravity.BOTTOM,
                          //   timeInSecForIosWeb: 1,
                          //   backgroundColor: Colors.red,
                          //   textColor: Colors.white,
                          //   fontSize: 16.0,
                          // );
                        }
                      }
                    },
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
