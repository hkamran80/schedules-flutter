import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:schedules/utils/datetime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../extensions/date.dart';
import '../extensions/string.dart';
import '../notification_constants.dart';
import 'notification_service.dart';

// TODO: Add `fixOffsetTime` from web to fix `11:09 AM`
class Schedule {
  String scheduleId;
  Map<dynamic, dynamic> schedule;

  Set<Period> periods = {};
  String _periodName = "";
  bool _notificationsScheduled = false;

  Schedule(this.scheduleId, this.schedule);

  String get name => schedule["name"];
  String get shortName => schedule["shortName"];
  String get color => schedule["color"];
  String get timezone => schedule["timezone"];
  String get location => schedule["location"];

  Map<String, dynamic> get periodSchedule =>
      schedule["schedule"] as Map<String, dynamic>;

  void generateDayPeriods(String day) async {
    final prefs = await SharedPreferences.getInstance();
    if (periodSchedule.containsKey(day)) {
      final Map<dynamic, dynamic> daySchedule = schedule["schedule"][day];
      for (String originalPeriodName in daySchedule.keys) {
        final period = daySchedule[originalPeriodName];

        PeriodTimes times = period is List
            ? PeriodTimes(period[0], period[1])
            : PeriodTimes(period["times"][0], period["times"][1]);

        bool allowEditing = true;
        if (period is List && originalPeriodName.contains("Passing (")) {
          allowEditing = false;
        } else if (period is! List) {
          allowEditing = period["allowEditing"];
        }

        if (periods.every((schedulePeriod) =>
            schedulePeriod.originalName != originalPeriodName)) {
          String? customName = prefs
              .getString("$scheduleId.${originalPeriodName.slugify()}.name");
          String newPeriodName = customName != null
              ? "$customName ($originalPeriodName)"
              : originalPeriodName;

          periods.add(
            Period(
              newPeriodName,
              originalPeriodName,
              times,
              allowEditing,
            ),
          );
        }
      }
    }
  }

  List<Period> daySchedule(String day) {
    if (periodSchedule.containsKey(day)) {
      final Map<dynamic, dynamic> daySchedule = schedule["schedule"][day];
      List<Period> dayPeriods = [];
      for (String originalPeriodName in daySchedule.keys) {
        final period = daySchedule[originalPeriodName];

        PeriodTimes times = period is List
            ? PeriodTimes(period[0], period[1])
            : PeriodTimes(period["times"][0], period["times"][1]);

        Period existingPeriod = periods.firstWhere(
          (period) => period.originalName == originalPeriodName,
        );

        dayPeriods.add(
          Period(
            existingPeriod.name,
            originalPeriodName,
            times,
            existingPeriod.allowEditing,
          ),
        );
      }
      return dayPeriods;
    }

    return [];
  }

  List<Period> get daySchedulePeriods => daySchedule(
        override == null
            ? DateFormat.E()
                .format(
                  DateTime.now(),
                )
                .toUpperCase()
            : override!,
      );

  int getCurrentTime() => int.parse(
        DateFormat.Hms()
            .format(
              DateTime.now(),
            )
            .replaceAll(
              ":",
              "",
            ),
      );

  Period? get currentPeriod {
    if (periods.isNotEmpty) {
      int currentTime = getCurrentTime();

      try {
        return daySchedulePeriods.firstWhereOrNull((schedulePeriod) {
          if (int.parse(schedulePeriod.times.start.replaceAll(":", "")) <=
                  currentTime &&
              currentTime <=
                  int.parse(schedulePeriod.times.end.replaceAll(":", ""))) {
            if (_periodName != schedulePeriod.name) {
              _notificationsScheduled = false;
              _periodName = schedulePeriod.originalName;
            }

            return true;
          } else {
            return false;
          }
        },);
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }

        _periodName = "";
        return null;
      }
    }

    _periodName = "";
    return null;
  }

  String get timeRemaining {
    if (currentPeriodExists) {
      TimeRemaining timeRemaining =
          calculateTimeRemaining(currentPeriod!.times.end);

      if (!_notificationsScheduled) {
        _notify(timeRemaining.remaining);
        _scheduleNotifications(timeRemaining.remaining);
      }

      return timeRemaining.countdown;
    }

    return "";
  }

  Period? get nextPeriod {
    if (currentPeriodExists) {
      int currentPeriodIndex = daySchedulePeriods.indexWhere(
          (period) => currentPeriod!.originalName == period.originalName);

      return daySchedulePeriods.length - 1 == currentPeriodIndex
          ? null
          : daySchedulePeriods.elementAt(
              currentPeriodIndex + 1,
            );
    }

    return null;
  }

  Period? get timeToNextPeriod {
    if (periods.isNotEmpty && !currentPeriodExists) {
      int currentTime = getCurrentTime();

      try {
        return daySchedulePeriods.firstWhereOrNull((schedulePeriod) {
          if (int.parse(schedulePeriod.times.start.replaceAll(":", "")) >=
              currentTime) {
            return true;
          }

          return false;
        });
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }

        return null;
      }
    }

    return null;
  }

  String get timeRemainingToNextPeriod {
    if (timeToNextPeriodExists) {
      TimeRemaining timeRemaining =
          calculateTimeRemaining(timeToNextPeriod!.times.start);

      return timeRemaining.countdown;
    }

    return "";
  }

  List<OffDay> get offDays {
    List<OffDay> offDays = [];

    for (MapEntry offDay in schedule["offDays"].entries) {
      offDays.add(
        OffDay(
          offDay.key,
          offDay.value[0].toString().toDate(),
          offDay.value.length == 2 ? offDay.value[1].toString().toDate() : null,
        ),
      );
    }

    return offDays;
  }

  OffDay? get activeOffDay =>
      offDays.where((offDay) => offDay.inEffect).firstOrNull;

  String? get override {
    Function eq = const ListEquality().equals;

    for (MapEntry override in schedule["overrides"].entries) {
      if (eq(
        override.key.split("-").toList().map(int.parse).toList(),
        DateTime.now().ymd(),
      )) {
        return override.value;
      }
    }

    return null;
  }

  bool get currentPeriodExists =>
      currentPeriod.runtimeType.toString().toLowerCase() != "null";

  bool get nextPeriodExists =>
      nextPeriod.runtimeType.toString().toLowerCase() != "null";

  bool get timeToNextPeriodExists =>
      timeToNextPeriod.runtimeType.toString().toLowerCase() != "null";

  Future<void> _notify(Duration remaining) async {
    if (currentPeriodExists) {
      List<int> remainingArray = [
        remaining.inHours,
        remaining.inMinutes.remainder(60).toInt(),
        remaining.inSeconds.remainder(60).toInt()
      ];

      try {
        Function equals = const ListEquality().equals;

        NotificationInterval interval = notificationIntervals.firstWhere(
          (notificationInterval) =>
              equals(notificationInterval.array, remainingArray),
        );

        final prefs = await SharedPreferences.getInstance();
        if ((prefs.getBool("_notificationsEnabled") ?? true) &&
            (prefs.getBool("$scheduleId.${interval.id}") ?? true) &&
            (prefs.getBool(
                    "$scheduleId.${DateFormat.EEEE().format(DateTime.now()).toLowerCase()}") ??
                true) &&
            (prefs.getBool("$scheduleId.${currentPeriod!.id}") ?? true)) {
          await NotificationService().createNotification(
            _generateNotificationId(DateTime.now()),
            schedule["shortName"] + ": " + currentPeriod!.name,
            "${interval.name} remaining",
            "com.hkamran.schedules.${interval.id}",
            interval.name,
            interval.name,
            null,
            null,
            null,
          );
        } else {
          if (kDebugMode) {
            print("User disabled interval notification");
          }
        }
        // ignore: empty_catches
      } catch (error) {}
    }
  }

  Future<void> _scheduleNotifications(Duration remaining) async {
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getBool("_notificationsEnabled") ?? true) &&
        currentPeriodExists &&
        (prefs.getBool(
                "$scheduleId.${DateFormat.EEEE().format(DateTime.now()).toLowerCase()}") ??
            true)) {
      if (!_notificationsScheduled &&
          _periodName == currentPeriod!.name &&
          (prefs.getBool("$scheduleId.${currentPeriod!.id}") ?? true)) {
        List<int> remainingArray = [
          remaining.inHours,
          remaining.inMinutes.remainder(60).toInt(),
          remaining.inSeconds.remainder(60).toInt()
        ];

        List<NotificationInterval> intervals = notificationIntervals
            .where(
              (interval) =>
                  (interval.array[0] <= remainingArray[0]) &&
                  (interval.array[1] <= remainingArray[1]),
            )
            .where(
              (interval) =>
                  (prefs.getBool("$scheduleId.${interval.id}") ?? true),
            )
            .toList();

        for (var interval in intervals) {
          DateTime scheduledTime = DateFormat("y-M-d H:m:s")
              .parse(
                "${DateTime.now().toString().split(" ")[0]} ${currentPeriod!.times.end}",
              )
              .subtract(interval.duration);

          await NotificationService().scheduleNotification(
            _generateNotificationId(scheduledTime),
            schedule["shortName"] + ": " + currentPeriod!.name,
            "${interval.name} remaining",
            scheduledTime,
            "com.hkamran.schedules.${interval.id}",
            interval.name,
            interval.name,
            null,
            null,
            null,
          );
        }

        _notificationsScheduled = true;
      }
    }
  }

  int _generateNotificationId(DateTime scheduledTime) {
    String year = scheduledTime.year.toString();
    return int.parse(scheduledTime.month.twoDigits() +
        scheduledTime.day.twoDigits() +
        year.substring(year.length - 2) +
        scheduledTime.hour.twoDigits() +
        scheduledTime.minute.twoDigits());
  }

  Future<void> editPeriodName(String originalName, String newName) async {
    final prefs = await SharedPreferences.getInstance();

    List<Period> periodsList = periods.toList();
    int index = periodsList.indexWhere(
      (period) => period.originalName == originalName,
    );

    periodsList[index].name = "${newName.trim()} ($originalName)";

    prefs.setString(
      "$scheduleId.${originalName.slugify()}.name",
      newName.trim(),
    );
    periods = periodsList.toSet();
  }

  Map<String, String> get _periodNames => periods
          .where(
        (period) => period.allowEditing == true,
      )
          .fold(
        {},
        (previous, period) => {
          ...previous,
          period.originalName: period.name.contains(" (")
              ? period.name.replaceAll(" (${period.originalName})", "")
              : ""
        },
      );

  Future<Map<String, dynamic>> generateExport() async {
    final prefs = await SharedPreferences.getInstance();

    // Allowed notifications
    Map<String, bool> exportNotificationIntervals = {};
    Map<String, bool> exportNotificationDays = {};
    Map<String, bool> exportNotificationPeriods = {};

    for (var interval in notificationIntervals) {
      exportNotificationIntervals[interval.exportId] =
          (prefs.getBool("$scheduleId.${interval.id}") ?? true);
    }

    List<String> days = periodSchedule.keys.toList();

    for (var day in notificationDays) {
      if (days.contains(day.day.substring(0, 3).toUpperCase())) {
        exportNotificationDays[day.id] =
            (prefs.getBool("$scheduleId.${day.id}") ?? true);
      }
    }

    for (var period in periods) {
      exportNotificationPeriods[period.originalName] =
          (prefs.getBool("$scheduleId.${period.id}") ?? true);
    }

    Map<String, Map<String, bool>> exportNotifications = {
      "intervals": exportNotificationIntervals,
      "days": exportNotificationDays,
      "periods": exportNotificationPeriods
    };

    return {
      "hour24": (prefs.getBool('_hour24Enabled') ?? false),
      "periodNames": _periodNames,
      "notifications": (prefs.getBool('_notificationsEnabled') ?? true),
      "allowedNotifications": exportNotifications,
    };
  }

  Future<String> importSettings(String importText) async {
    try {
      Map<String, dynamic> json = jsonDecode(importText);
      if (json.containsKey("hour24") &&
          json.containsKey("periodNames") &&
          json.containsKey("notifications")) {
        // TODO: Add check for `periodNames` (uses `CastMap`)
        if (json["hour24"].runtimeType == bool &&
            json["notifications"].runtimeType == bool) {
          List<String> importNames = (json["periodNames"] as LinkedHashMap)
              .cast<String, String>()
              .keys
              .toList();

          if (periods.isEmpty) {
            for (String day in periodSchedule.keys) {
              generateDayPeriods(day);
            }
          }

          List<String> originalPeriodNames = _periodNames.keys.toList();

          bool difference = importNames
              .toSet()
              .difference(originalPeriodNames.toSet())
              .isEmpty;
          bool lengthDifference =
              importNames.length == originalPeriodNames.length;

          if (difference && lengthDifference) {
            final prefs = await SharedPreferences.getInstance();

            prefs.setBool(
              '_hour24Enabled',
              json["hour24"] as bool,
            );

            prefs.setBool(
              '_notificationsEnabled',
              json["notifications"] as bool,
            );

            for (var importName in (json["periodNames"] as LinkedHashMap)
                .cast<String, String>()
                .entries) {
              editPeriodName(importName.key, importName.value);
            }

            return "SUCCESS";
          } else {
            return "Period names do not match";
          }
        } else {
          return "Keys have incorrect types";
        }
      } else {
        return "Missing required keys in JSON";
      }
    } on FormatException catch (_) {
      return "Invalid JSON";
    }
  }
}

class Period {
  String name;
  String originalName;
  PeriodTimes times;
  bool allowEditing;

  Period(this.name, this.originalName, this.times, this.allowEditing);

  @override
  String toString() {
    return "Period(\"$name\", \"$originalName\", $times, $allowEditing)";
  }

  String get id => originalName.slugify();
}

class PeriodTimes {
  String start;
  String end;

  PeriodTimes(this.start, this.end);

  @override
  String toString() {
    return "PeriodTimes(\"$start\", \"$end\")";
  }
}

class OffDay {
  String name;
  DateTime startDate;
  DateTime? endDate;

  OffDay(this.name, this.startDate, this.endDate);

  List<DateTime> get dateRange =>
      endDate != null ? startDate.dateRange(endDate!) : [startDate];

  bool get inEffect {
    List<int> ymd = DateTime.now().ymd();
    Function eq = const ListEquality().equals;

    return dateRange
        .map((date) => date.ymd())
        .where((date) => eq(date, ymd))
        .isNotEmpty;
  }
}
