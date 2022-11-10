import 'extensions/string.dart';

class NotificationInterval {
  List<int> array;
  String name;

  NotificationInterval({
    required this.array,
    required this.name,
  });

  String get id => name.slugify();
  String get exportId {
    List<String> exported = name.split(" ");
    return exported[0].toLowerCase() + exported[1].toCapitalized();
  }

  Duration get duration => Duration(
        hours: array[0],
        minutes: array[1],
        seconds: array[2],
      );
}

class NotificationDay {
  String day;

  NotificationDay({
    required this.day,
  });

  String get id => day.slugify();
}

final List<NotificationInterval> notificationIntervals = [
  NotificationInterval(array: [1, 0, 0], name: "One hour"),
  NotificationInterval(array: [0, 30, 0], name: "Thirty minutes"),
  NotificationInterval(array: [0, 15, 0], name: "Fifteen minutes"),
  NotificationInterval(array: [0, 10, 0], name: "Ten minutes"),
  NotificationInterval(array: [0, 5, 0], name: "Five minutes"),
  NotificationInterval(array: [0, 1, 0], name: "One minute"),
  NotificationInterval(array: [0, 0, 30], name: "Thirty seconds"),
];

final List<NotificationDay> notificationDays = [
  NotificationDay(day: "Sunday"),
  NotificationDay(day: "Monday"),
  NotificationDay(day: "Tuesday"),
  NotificationDay(day: "Wednesday"),
  NotificationDay(day: "Thursday"),
  NotificationDay(day: "Friday"),
  NotificationDay(day: "Saturday"),
];
