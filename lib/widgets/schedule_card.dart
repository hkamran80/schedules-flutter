import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    Key? key,
    required this.name,
    required this.backgroundColor,
    required this.onPressed,
  }) : super(key: key);

  final String name;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: backgroundColor.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white,
            alignment: Alignment.centerLeft,
            backgroundColor: backgroundColor,
          ),
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              0,
              15,
              0,
              15,
            ),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
