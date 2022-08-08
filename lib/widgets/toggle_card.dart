import 'package:flutter/material.dart';

class ToggleCard extends StatelessWidget {
  const ToggleCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.initialValue,
    required this.action,
    this.disabled,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final bool initialValue;
  final void Function(bool) action;
  final bool? disabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: subtitle != null
            ? const EdgeInsets.only(
                top: 12,
                bottom: 12,
              )
            : const EdgeInsets.only(
                top: 6,
                bottom: 6,
              ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black54
                            : Colors.white54,
                      ),
                    ),
                ],
              ),
            ),
            disabled == null || (disabled != null && !disabled!)
                ? Switch(value: initialValue, onChanged: action)
                : const Switch(
                    value: false,
                    onChanged: null,
                  ),
          ],
        ),
      ),
      onTap: () {
        action(!initialValue);
      },
    );
  }
}
