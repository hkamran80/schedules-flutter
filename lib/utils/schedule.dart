import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../extensions/string.dart';

class Schedule {
  String scheduleId;
  Map<dynamic, dynamic> schedule;

  Set<Period> periods = {};

  Schedule(this.scheduleId, this.schedule);

  void generateDayPeriods(String day) {
    if ((schedule["schedule"] as Map<String, dynamic>).containsKey(day)) {
      final Map<dynamic, dynamic> daySchedule = schedule["schedule"][day];

      for (final periodName in daySchedule.keys) {
        final period = daySchedule[periodName];

        PeriodTimes times = period is List
            ? PeriodTimes(period[0], period[1])
            : PeriodTimes(period["times"][0], period["times"][1]);

        bool allowEditing = true;
        if (period is List && (periodName as String).contains("Passing (")) {
          allowEditing = false;
        } else if (period is! List) {
          allowEditing = period["allowEditing"];
        }

        if (periods.every(
            (schedulePeriod) => schedulePeriod.originalName != periodName)) {
          periods.add(
            Period(
              periodName,
              periodName,
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

        return null;
      }
    }

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

      return daySchedulePeriods.length - 1 == daySchedulePeriods.indexOf(currentPeriod)
          ? null
          : daySchedulePeriods.elementAt(daySchedulePeriods.indexOf(currentPeriod) + 1);
    }

    return null;
  }

  bool get currentPeriodExists =>
      currentPeriod.runtimeType.toString().toLowerCase() != "null";

  bool get nextPeriodExists =>
      nextPeriod.runtimeType.toString().toLowerCase() != "null";
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
