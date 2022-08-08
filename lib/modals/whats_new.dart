import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WhatsNew extends StatefulWidget {
  const WhatsNew({
    Key? key,
  }) : super(key: key);

  @override
  State<WhatsNew> createState() => _WhatsNewState();
}

class _WhatsNewState extends State<WhatsNew> {
  List<String> _whatsNew = [];

  @override
  void initState() {
    super.initState();
    _readJson();
  }

  Future<void> _readJson() async {
    final String response =
        await rootBundle.loadString('assets/whats-new.json');
    List<dynamic> whatsNewRaw = await json.decode(response);

    setState(
      () {
        _whatsNew = whatsNewRaw.map((e) => e.toString()).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _whatsNew.isEmpty
        ? const Center(
            child: CircularProgressIndicator(
              semanticsLabel: "Loading",
            ),
          )
        : ListView(
            children: _whatsNew
                .map(
                  (whatsNewItem) => Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        whatsNewItem,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                )
                .toList(),
          );
  }
}
