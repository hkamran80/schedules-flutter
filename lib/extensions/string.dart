extension StringNumber on int {
  String twoDigits() => toString().padLeft(2, "0");
}

extension StringDateTime on String {
  String convertTo12Hour() {
    List<String> time = split(":").sublist(0, 2);

    String baseHour =
        (int.parse(time[0]) > 12 ? int.parse(time[0]) - 12 : int.parse(time[0]))
            .toString();

    String hour = baseHour.startsWith("0") ? baseHour.substring(1) : baseHour;

    return "$hour:${time[1]} ${int.parse(time[0]) >= 12 ? "PM" : "AM"}";
  }

  String convertTime(bool hour24) => hour24
      ? split("-").sublist(0, 2).join(":")
      : replaceAll("-", ":").convertTo12Hour();
}

extension StringRegExp on String {
  String slugify() =>
      replaceAll(RegExp('[^A-Za-z0-9]'), "",).replaceAll(" ", "-").toLowerCase();
}

// Source: https://stackoverflow.com/a/29629114/7313822
extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
      
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
