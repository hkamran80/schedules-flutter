class NotificationInterval {
  List<int> array;
  String name;

  NotificationInterval({
    required this.array,
    required this.name,
  });

  String get id => name.toLowerCase().replaceAll(" ", "-");
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
