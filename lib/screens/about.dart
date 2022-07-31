import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  static const routeName = "/about";

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  void _launchUrl(Uri uri) async {
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $uri';
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
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.pink),
                      overlayColor:
                          MaterialStateProperty.all(Colors.pink.shade200),
                    ),
                    child: const Text("View licenses"),
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
                  const SizedBox(height: 15),
                  const Text(
                    "Credits",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Text(
                              "H. Kamran",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Developer",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Text(
                              "J. Quam",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "UI/UX Design, Logo Design",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Text(
                              "Andrew Zheng",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "UI/UX Design",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
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
