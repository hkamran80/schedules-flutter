import 'package:schedules/utils/schedule.dart';
import 'package:collection/collection.dart';

class ScheduleVariant {
  String name;
  String color;
  List<ScheduleVariantItem> variants;

  ScheduleVariant({
    required this.name,
    required this.color,
    required this.variants,
  });
}

class ScheduleVariantItem {
  String id;
  String name;

  ScheduleVariantItem({
    required this.id,
    required this.name,
  });
}

class VariantOrSchedule {
  Type type;
  Schedule? schedule;
  ScheduleVariant? variant;

  VariantOrSchedule({required this.type, this.schedule, this.variant})
      : assert(
          (schedule != null || variant != null),
          'One of the parameters must be provided',
        );

  String get name =>
      type == Schedule ? schedule!.schedule["name"] : variant!.name;

  String get color =>
      type == Schedule ? schedule!.schedule["color"] : variant!.color;
}

Map<String, List<String>> generateVariants(Iterable<String> scheduleIds) {
  Map<String, List<String>> variantIndexes = {};

  for (var id in scheduleIds) {
    String rootId = id.split("-").sublist(0, 3).join("-");

    if (variantIndexes[rootId].runtimeType == Null) {
      variantIndexes[rootId] = [id];
    } else if (variantIndexes[rootId].runtimeType == List<String>) {
      variantIndexes[rootId] = [...variantIndexes[rootId]!, id];
    }
  }

  return {
    for (var variant
        in variantIndexes.entries.where((variant) => variant.value.length > 1))
      variant.key: variant.value
  };
}

Map<String, VariantOrSchedule> generateScheduleListWithVariants(
  Map<dynamic, dynamic> schedules,
) {
  List<String> scheduleIds = schedules.keys.cast<String>().toList();
  Map<String, List<String>> variants =
      generateVariants(schedules.keys.cast<String>());

  List<String> variantIds = variants.values.flattened.toList();
  List<String> withoutVariants = scheduleIds
      .where(
        (id) => !variantIds.contains(id),
      )
      .toList();

  Iterable variantEntries = variants.entries;

  List<String> idList = variantEntries
      .map((variant) {
        Iterable slice = variantEntries.toList().sublist(
            0,
            variantEntries
                .toList()
                .indexWhere((element) => element.key == variant.key));

        return {
          "variantId": variant.key,
          "index": scheduleIds.indexOf(variant.value.first) -
              slice
                  .map((e) => e.value.length)
                  .fold(0, (previous, current) => previous + current) +
              slice.length
        };
      })
      .fold(
        withoutVariants,
        (previous, variant) => [
          ...(previous as List).sublist(0, variant["index"]),
          variant["variantId"],
          ...previous.sublist(variant["index"])
        ],
      )
      .toList()
      .cast<String>();

  return idList.fold(
    {},
    (previous, id) => {
      ...previous,
      id: withoutVariants.contains(id)
          ? VariantOrSchedule(
              type: Schedule,
              schedule: Schedule(
                id,
                schedules[id],
              ),
            )
          : VariantOrSchedule(
              type: ScheduleVariant,
              variant: ScheduleVariant(
                name: schedules[variants[id]!.first]["name"]
                    .replaceAll(RegExp(r"\s\(.*\)"), ""),
                color: schedules[variants[id]!.first]["color"],
                variants: variants[id]!
                    .map(
                      (id) => ScheduleVariantItem(
                        id: id,
                        name: RegExp(r"\(.*\)")
                                .firstMatch(schedules[id]["name"].toString())
                                ?.group(0)
                                ?.replaceAll(
                                  RegExp(r"\(|\)", multiLine: true),
                                  "",
                                ) ??
                            "Unknown",
                      ),
                    )
                    .toList(),
              ),
            )
    },
  );
}
