import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
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
    bool loadedFromNetwork = false;

    if (kDebugMode) {
      print("Loading schedules...");
    }

    bool network = await _hasNetwork();

    if (network) {
      if (kDebugMode) {
        print("Loading from UT...");
      }

      try {
        final response = await http.get(schedulesLink).timeout(
              const Duration(seconds: 10),
            );

        String hash = sha256.convert(utf8.encode(response.body)).toString();
        if ((await _getScheduleHash()) != hash) {
          schedules = json.decode(
            response.body,
          ) as Map;

          await _saveSchedules(
            response.body,
          );
          _saveScheduleLoadTime(
            DateTime.now(),
          );
          _saveScheduleHash(hash);

          loading = false;
          isRequestError = false;
          loadedFromNetwork = true;

          if (kDebugMode) {
            print("Loaded from UT!");
          }

          notifyListeners();
        }
      } catch (error) {
        // loading = false;
        // isRequestError = true;
        loadedFromNetwork = false;

        if (kDebugMode) {
          print("Request error");
        }

        notifyListeners();
      }
    }

    if (!loadedFromNetwork && await (await _localFile).exists()) {
      String schedulesFileContents = await _loadSchedulesFromFile();
      if (schedulesFileContents == "[error]") {
        loading = false;
        isRequestError = true;

        if (kDebugMode) {
          print("File error");
        }

        notifyListeners();
      } else {
        try {
          schedules = json.decode(
            schedulesFileContents,
          ) as Map;

          loading = false;
          isRequestError = false;

          if (kDebugMode) {
            print("Loaded from file!");
          }

          notifyListeners();
        } catch (e) {
          loading = false;
          isRequestError = true;

          if (kDebugMode) {
            print("Parsing error");
          }

          notifyListeners();
        }
      }
    } else {
      loading = false;
      isRequestError = false;

      if (kDebugMode) {
        print("File doesn't exist");
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

  Future<String> _loadSchedulesFromFile() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      return "[error]";
    }
  }

  void _saveScheduleLoadTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      "schedulesLoadTime",
      time.toIso8601String(),
    );
    loading = false;
  }

  void _saveScheduleHash(String digest) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("schedulesHash", digest);
  }

  Future<String> _getScheduleHash() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString("schedulesHash") ?? "");
  }

  Future<bool> _hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
