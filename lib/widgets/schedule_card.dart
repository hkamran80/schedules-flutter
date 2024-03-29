import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    Key? key,
    required this.name,
    this.location,
    required this.backgroundColor,
    required this.onPressed,
  }) : super(key: key);

  final String name;
  final String? location;
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              0,
              15,
              0,
              15,
            ),
            child: location == null
                ? Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        location!,
                        style: const TextStyle(
                          fontSize: 12.0,
                        ),
                      )
                    ],
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
