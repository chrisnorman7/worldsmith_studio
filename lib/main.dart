// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';

import 'constants.dart';
import 'intents.dart';
import 'screens/home_page.dart';
import 'util.dart';

void main() => runApp(const MyApp());

/// The main app class.
class MyApp extends StatelessWidget {
  /// Create an instance.
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) => MaterialApp(
        title: appName,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomePage(),
        actions: {
          ...WidgetsApp.defaultActions,
          LaunchManualIntent: CallbackAction<LaunchManualIntent>(
            onInvoke: (intent) => launchManual(),
          )
        },
        shortcuts: {
          ...WidgetsApp.defaultShortcuts,
          LaunchManualIntent.hotkey: const LaunchManualIntent()
        },
      );
}
