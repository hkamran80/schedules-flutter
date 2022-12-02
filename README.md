# Schedules (mobile)

![Version 1.0.3](https://img.shields.io/badge/Version-1.0.3-%23BE154D?style=for-the-badge)
![Language](https://img.shields.io/badge/Language-Dart-02569B?style=for-the-badge)

## Development

Before doing anything, [install Flutter](https://docs.flutter.dev/get-started/install).
Flutter recommends [Visual Studio Code](https://code.visualstudio.com/) or
[Android Studio](https://developer.android.com/studio)/[IntellJ](https://www.jetbrains.com/idea/)
for development.<sup>[1](https://docs.flutter.dev/get-started/editor)</sup>

To begin, clone this repository, then open it in your editor of choice. Schedules
(mobile) is written in Dart, which has a slight learning curve. Dart maintains an
[overview of the language](https://dart.dev/overview), and Flutter maintains several
guides for developers from other platforms: [Android](https://docs.flutter.dev/get-started/flutter-for/android-devs),
[iOS](https://docs.flutter.dev/get-started/flutter-for/ios-devs), and more.

## Building

If you want to publish Schedules, keep this in mind about the Sentry SDK.

- If you would like to use Sentry, create a `secrets.dart` file with two constants:
  `sentryDsn` and `sentryEnvironment`
- If you do not want to use Sentry, remove the `sentry_flutter` package, all mentions
  of the Sentry SDK (`main.dart` and `secrets.dart`), and the conditional loading
  system in `main.dart`

## Contributing

All contributions are welcome! Feel free to fork and make PRs to improve Schedules!

## Resources

### Schedules

- [Release notes](releasenotes.md)
- [Schedules backend](https://github.com/hkamran80/schedules-configuration)
- [Schedules (web)](https://github.com/hkamran80/schedules)

### Contact

I'll do my best to respond as fast as possible, usually within 24 hours.

- [Discord](https://discord.com/invite/M586RvpCWP)
- [Email](mailto:hkamran@hkamran.com)
- [Twitter](https://twitter.com/hkamran80)

## License

```
Schedules (mobile) - All your schedules in one app
Copyright (C) 2022 H. Kamran (Thirteenth Willow)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```
