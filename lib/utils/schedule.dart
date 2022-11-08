import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../extensions/string.dart';
import '../notification_constants.dart';
import 'notification_service.dart';

class Schedule {
  String scheduleId;
  Map<dynamic, dynamic> schedule;

  Set<Period> periods = {};
  String _periodName = "";
  bool _notificationsScheduled = false;

  Schedule(this.scheduleId, this.schedule);

  void generateDayPeriods(String day) async {
    final prefs = await SharedPreferences.getInstance();
    if ((schedule["schedule"] as Map<String, dynamic>).containsKey(day)) {
      final Map<dynamic, dynamic> daySchedule = schedule["schedule"][day];

      for (final originalPeriodName in daySchedule.keys) {
        final period = daySchedule[originalPeriodName];

        PeriodTimes times = period is List
            ? PeriodTimes(period[0], period[1])
            : PeriodTimes(period["times"][0], period["times"][1]);

        bool allowEditing = true;
        if (period is List &&
            (originalPeriodName as String).contains("Passing (")) {
          allowEditing = false;
        } else if (period is! List) {
          allowEditing = period["allowEditing"];
        }

        if (periods.every((schedulePeriod) =>
            schedulePeriod.originalName != originalPeriodName)) {
          String periodId = (originalPeriodName as String).slugify();

          String? customName = prefs.getString("$scheduleId.$periodId.name");
          String newPeriodName;
          if (customName != null) {
            newPeriodName = "$customName ($originalPeriodName)";
          } else {
            newPeriodName = originalPeriodName;
          }

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

  List<Period?> daySchedule(String day) {
    if ((schedule["schedule"] as Map<String, dynamic>).containsKey(day) &&
        periods.isNotEmpty) {
      return (schedule["schedule"][day] as Map<String, dynamic>).keys.map(
        (schedulePeriodName) {
          return periods.firstWhere(
            (period) => period.originalName == schedulePeriodName,
          );
        },
      ).toList();
    }

    return [];
  }

  Period? get currentPeriod {
    if (periods.isNotEmpty) {
      int currentTime = int.parse(
        DateFormat.Hms()
            .format(
              DateTime.now(),
            )
            .replaceAll(
              ":",
              "",
            ),
      );

      try {
        return periods.firstWhere(
          (schedulePeriod) {
            if (int.parse(schedulePeriod.times.start.replaceAll("-", "")) <=
                    currentTime &&
                currentTime <=
                    int.parse(schedulePeriod.times.end.replaceAll("-", ""))) {
              if (_periodName != schedulePeriod.name) {
                _notificationsScheduled = false;
                _periodName = schedulePeriod.originalName;
              }

              return true;
            } else {
              return false;
            }
          },
        );
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
      DateTime now = DateTime.now();
      List<String> endTime = currentPeriod!.times.end.split("-");

      Duration remaining = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(endTime[0]),
        int.parse(endTime[1]),
        int.parse(endTime[2]),
      ).difference(
        DateTime.now(),
      );

      String hours = remaining.inHours.twoDigits();
      String minutes = remaining.inMinutes.remainder(60).twoDigits();
      String seconds = remaining.inSeconds.remainder(60).twoDigits();

      if (!_notificationsScheduled) {
        _notify(remaining);
        _scheduleNotifications(remaining);
      }
      return "$hours:$minutes:$seconds";
    }

    return "";
  }

  Period? get nextPeriod {
    if (currentPeriodExists) {
      List<Period?> daySchedulePeriods = daySchedule(
        DateFormat.E()
            .format(
              DateTime.now(),
            )
            .toUpperCase(),
      );

      return daySchedulePeriods.length - 1 ==
              daySchedulePeriods.indexOf(currentPeriod)
          ? null
          : daySchedulePeriods
              .elementAt(daySchedulePeriods.indexOf(currentPeriod) + 1);
    }

    return null;
  }

  bool get currentPeriodExists =>
      currentPeriod.runtimeType.toString().toLowerCase() != "null";

  bool get nextPeriodExists =>
      nextPeriod.runtimeType.toString().toLowerCase() != "null";

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
                "${DateTime.now().toString().split(" ")[0]} ${currentPeriod!.times.end.replaceAll("-", ":")}",
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

  Future<Map<String, dynamic>> generateExport() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, String> exportPeriods = periods
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

    // Allowed notifications
    Map<String, bool> exportNotificationIntervals = {};
    Map<String, bool> exportNotificationDays = {};
    Map<String, bool> exportNotificationPeriods = {};

    for (var interval in notificationIntervals) {
      exportNotificationIntervals[interval.exportId] =
          (prefs.getBool("$scheduleId.${interval.id}") ?? true);
    }

    List<String> days =
        (schedule["schedule"] as Map<String, dynamic>).keys.toList();

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
      "periodNames": exportPeriods,
      "notifications": (prefs.getBool('_notificationsEnabled') ?? true),
      "allowedNotifications": exportNotifications,
    };
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
