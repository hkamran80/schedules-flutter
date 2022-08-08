import 'package:flutter/material.dart';

class AboutCard extends StatelessWidget {
  const AboutCard({
    Key? key,
    this.icon,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  final IconData? icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 12,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon!),
              const SizedBox(
                width: 25.0,
              ),
            ],
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
          ],
        ));
  }
}
