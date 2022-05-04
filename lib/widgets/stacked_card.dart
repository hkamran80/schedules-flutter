import 'package:flutter/material.dart';

class StackedCard extends StatelessWidget {
  const StackedCard({
    Key? key,
    required this.header,
    required this.content,
  }) : super(key: key);

  final String header;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
          Text(
            content,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 36,
            ),
          ),
        ],
      ),
    );
  }
}
