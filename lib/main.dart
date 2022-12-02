import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

final _router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: "/schedule/:scheduleId",
      builder: (context, state) => ScheduleScreen(
        scheduleId: state.params["scheduleId"] as String,
      ),
    ),
    GoRoute(
      path: "/schedule/:scheduleId/notifications",
      builder: (context, state) => ScheduleNotificationsSettingsScreen(
        scheduleId: state.params["scheduleId"] as String,
      ),
    ),
    GoRoute(
      path: "/schedule/:scheduleId/periodNames",
      builder: (context, state) => SchedulePeriodNamesSettingsScreen(
        scheduleId: state.params["scheduleId"] as String,
      ),
    ),
    GoRoute(
      path: "/schedule/:scheduleId/settingsImport",
      builder: (context, state) => ImportSettingsScreen(
        scheduleId: state.params["scheduleId"] as String,
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);

class SchedulesApp extends StatelessWidget {
  const SchedulesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
      routerConfig: _router,
    );
  }
}
