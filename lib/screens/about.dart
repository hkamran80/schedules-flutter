import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  static const routeName = "/about";

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  void _launchUrl(Uri _uri) async {
    if (!await launchUrl(
      _uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $_uri';
    }
  }

  String _version = "";
  String _buildNumber = "";

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  void _loadPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(
      () {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Image(
                    image: AssetImage("assets/logo.png"),
                    width: 125,
                    height: 125,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    applicationName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Version $_version ($_buildNumber)",
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => _launchUrl(repositoryLink),
                        icon: const Icon(
                          FeatherIcons.github,
                        ),
                        tooltip: "Open repository",
                      ),
                      IconButton(
                        onPressed: () => _launchUrl(newIssueLink),
                        icon: const Icon(
                          FeatherIcons.flag,
                        ),
                        tooltip: "Report a bug or create a feature request",
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () {
                      showLicensePage(
                        context: context,
                        applicationName: applicationName,
                        applicationVersion: "Version $_version ($_buildNumber)",
                        applicationLegalese:
                            "Copyright © 2022 UNISON Technologies Inc. All rights reserved.",
                      );
                    },
                    child: const Text("View licenses"),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.pink),
                      overlayColor:
                          MaterialStateProperty.all(Colors.pink.shade200),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Copyright © 2022 UNISON Technologies Inc.",
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    "All rights reserved.",
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
