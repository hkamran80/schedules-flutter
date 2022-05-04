import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class SchedulesProvider with ChangeNotifier {
  Map<dynamic, dynamic> schedules = {};
  bool loading = true;
  bool isRequestError = false;

  getSchedules() async {
    loading = true;
    isRequestError = false;

    if (kDebugMode) {
      print("Loading schedules...");
    }

    try {
      final response = await http.get(schedulesLink);

      schedules = json.decode(
        response.body,
      ) as Map;
      await _saveSchedules(
        response.body,
      );
      _saveScheduleLoadTime(
        DateTime.now(),
      );

      if (kDebugMode) {
        print("Loaded!");
      }

      notifyListeners();
    } catch (error) {
      loading = false;
      isRequestError = true;

      if (kDebugMode) {
        print("Request error");
      }

      notifyListeners();
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/schedules.json');
  }

  Future<File> _saveSchedules(String contents) async {
    final file = await _localFile;
    return file.writeAsString(contents);
  }

  void _saveScheduleLoadTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      "schedulesLoadTime",
      time.toIso8601String(),
    );
    loading = false;
  }
}
