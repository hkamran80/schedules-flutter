extension DateTimeGeneral on DateTime {
  List<int> ymd() => [year, month, day];

  List<DateTime> dateRange(DateTime endDate) => List.generate(
        endDate.difference(this).inDays + 1,
        (i) => add(
          Duration(days: i),
        ),
      );
}
