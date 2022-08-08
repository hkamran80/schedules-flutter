import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class Credit {
  String name;
  String role;
  IconData icon;
  Uri? uri;

  Credit({
    required this.name,
    required this.role,
    required this.icon,
    this.uri,
  });
}

final List<Credit> credits = [
  Credit(
    name: "H. Kamran",
    role: "Developer",
    icon: FeatherIcons.user,
    uri: Uri.parse("https://hkamran.com"),
  ),
  Credit(
    name: "J. Quam",
    role: "UI/UX Design, Logo Design",
    icon: FeatherIcons.layers,
    uri: Uri.parse("https://unsplash.com/@jquam"),
  ),
  Credit(
    name: "Andrew Zheng",
    role: "UI/UX Design",
    icon: FeatherIcons.layout,
    uri: Uri.parse("https://getfind.app"),
  ),
];
