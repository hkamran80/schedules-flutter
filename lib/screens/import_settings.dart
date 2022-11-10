import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:schedules/notification_constants.dart';
import 'package:schedules/utils/schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/schedules.dart';

class ImportSettingsScreen extends StatefulWidget {
  const ImportSettingsScreen({
    Key? key,
    required this.scheduleId,
    required this.schedulesData,
    required this.schedule,
  }) : super(key: key);

  static const routeName = "/schedule/settingsImport";

  final String scheduleId;
  final SchedulesProvider schedulesData;
  final Schedule schedule;

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
    TextEditingController importTextController = TextEditingController();

    return Material(
      color: backgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            backgroundColor: backgroundColor,
            title: Text(
              "${widget.schedulesData.schedules[widget.scheduleId]["shortName"]}: Import Settings",
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
                    controller: importTextController,
                    maxLines: null,
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      alignment: Alignment.centerLeft,
                      backgroundColor: Colors.pink,
                    ),
                    onPressed: () {
                      if (importTextController.text.trim().isNotEmpty) {
                        try {
                          widget.schedule.importSettings(
                            importTextController.text.trim(),
                          );
                        } catch (error) {
                          print(error);
                          Fluttertoast.showToast(
                              msg: "Error: $error",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 2,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        15,
                        0,
                        15,
                      ),
                      child: Text(
                        "Import",
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
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