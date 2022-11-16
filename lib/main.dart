import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/import_settings.dart';
import 'screens/notification_settings.dart';
import 'screens/period_name_settings.dart';
import 'secrets.dart';
import 'provider/schedules.dart';
import 'screens/about.dart';
import 'screens/home.dart';
import 'screens/schedule.dart';
import 'screens/settings.dart';
import 'utils/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();

  final prefs = await SharedPreferences.getInstance();
  final appRunner = ChangeNotifierProvider(
    create: (context) => SchedulesProvider(),
    child: const SchedulesApp(),
  );

  if (prefs.getBool("_sentryEnabled") ?? false) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.environment = sentryEnvironment;
        options.tracesSampleRate = 1.0;
        options.enableAutoSessionTracking = true;
      },
      appRunner: () => runApp(appRunner),
    );
  } else {
    runApp(appRunner);
  }
}

class SchedulesApp extends StatelessWidget {
  const SchedulesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic generateScreenWithId(context, dynamic screen) {
      ScheduleScreenArguments args =
          ModalRoute.of(context)!.settings.arguments as ScheduleScreenArguments;

      return screen(
        scheduleId: args.scheduleId,
      );
    }

    return MaterialApp(
      title: 'Schedules',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        textTheme: GoogleFonts.nunitoSansTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.black,
          onPrimary: Colors.black,
          secondary: Colors.pink,
        ),
        cardTheme: const CardTheme(
          color: Colors.black87,
        ),
        iconTheme: const IconThemeData(
          color: Colors.pink,
        ),
        textTheme: GoogleFonts.nunitoSansTextTheme(
          const TextTheme(
            subtitle1: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
            subtitle2: TextStyle(
              color: Colors.white70,
              fontSize: 18.0,
            ),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.pink,
          selectionColor: Colors.pink,
          selectionHandleColor: Colors.pink,
        ),
        toggleableActiveColor: Colors.pink,
        primaryColor: Colors.white,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        ScheduleScreen.routeName: (context) => generateScreenWithId(
              context,
              ScheduleScreen,
            ),
        ScheduleNotificationsSettingsScreen.routeName: (context) =>
            generateScreenWithId(
              context,
              ScheduleNotificationsSettingsScreen,
            ),
        SchedulePeriodNamesSettingsScreen.routeName: (context) =>
            generateScreenWithId(
              context,
              SchedulePeriodNamesSettingsScreen,
            ),
        ImportSettingsScreen.routeName: (context) => generateScreenWithId(
              context,
              ImportSettingsScreen,
            ),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        AboutScreen.routeName: (context) => const AboutScreen(),
      },
    );
  }
}
