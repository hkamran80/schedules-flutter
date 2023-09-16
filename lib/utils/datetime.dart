import 'package:schedules/extensions/string.dart';

TimeRemaining calculateTimeRemaining(String time) {
  DateTime now = DateTime.now();
  List<String> splitTime = time.split(":");

  Duration remaining = DateTime(
    now.year,
    now.month,
    now.day,
    int.parse(splitTime[0]),
    int.parse(splitTime[1]),
    int.parse(splitTime[2]),
  ).difference(
    DateTime.now(),
  );

  String hours = remaining.inHours.twoDigits();
  String minutes = remaining.inMinutes.remainder(60).twoDigits();
  String seconds = remaining.inSeconds.remainder(60).twoDigits();

  return TimeRemaining("$hours:$minutes:$seconds", remaining);
}

class TimeRemaining {
  String countdown;
  Duration remaining;

  TimeRemaining(this.countdown, this.remaining);
}
