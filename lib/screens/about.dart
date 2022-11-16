import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../credits.dart';
import '../widgets/about_card.dart';

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
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Material(
      color: backgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            backgroundColor: backgroundColor,
            title: const Text(
              "About",
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 15.0,
              right: 15.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // App Information
                  const Text(
                    "App Information",
                    style: TextStyle(
                      color: Colors.pink,
                    ),
                  ),
                  AboutCard(
                    icon: LucideIcons.info,
                    title: applicationName,
                    subtitle: "Version $_version ($_buildNumber)",
                  ),
                  InkWell(
                    child: const AboutCard(
                      icon: LucideIcons.github,
                      title: "Repository",
                      subtitle: "Opens in your browser",
                    ),
                    onTap: () => _launchUrl(repositoryLink),
                  ),
                  InkWell(
                    child: const AboutCard(
                      icon: LucideIcons.flag,
                      title: "Feedback",
                      subtitle: "Report a bug or request a feature",
                    ),
                    onTap: () => _launchUrl(newIssueLink),
                  ),
                  InkWell(
                    child: const AboutCard(
                      icon: LucideIcons.list,
                      title: "Licenses",
                    ),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: applicationName,
                        applicationVersion: "Version $_version ($_buildNumber)",
                        applicationLegalese:
                            "Copyright © 2022 Thirteenth Willow. All rights reserved.",
                      );
                    },
                  ),

                  // Credits
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    "Credits",
                    style: TextStyle(
                      color: Colors.pink,
                    ),
                  ),
                  ...credits
                      .map(
                        (credit) => credit.uri != null
                            ? InkWell(
                                child: AboutCard(
                                  icon: credit.icon,
                                  title: credit.name,
                                  subtitle: credit.role,
                                ),
                                onTap: () => _launchUrl(credit.uri!),
                              )
                            : AboutCard(
                                icon: credit.icon,
                                title: credit.name,
                                subtitle: credit.role,
                              ),
                      )
                      .toList(),

                  // Legal
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    "Legal",
                    style: TextStyle(
                      color: Colors.pink,
                    ),
                  ),
                  const AboutCard(
                    icon: LucideIcons.copyright,
                    title: "Copyright",
                    subtitle:
                        "Copyright © 2022 Thirteenth Willow. All rights reserved.",
                  ),
                  InkWell(
                    child: const AboutCard(
                      icon: LucideIcons.shield,
                      title: "Terms of Service",
                      subtitle: "Opens in your browser",
                    ),
                    onTap: () => _launchUrl(tosLink),
                  ),
                  InkWell(
                    child: const AboutCard(
                      icon: LucideIcons.shield,
                      title: "Privacy Policy",
                      subtitle: "Opens in your browser",
                    ),
                    onTap: () => _launchUrl(privacyPolicyLink),
                  ),

                  const SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
