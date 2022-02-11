import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/ziggurat.dart';

import '../constants.dart';
import '../project_context.dart';
import '../src/json/app_preferences.dart';
import '../util.dart';
import 'project/project_context_widget.dart';

/// A list view for opening and creating projects.
class HomePage extends StatefulWidget {
  /// Create an instance.
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences? _preferences;
  Game? _game;

  /// Build the widget.
  @override
  Widget build(BuildContext context) {
    var game = _game;
    if (game == null) {
      game = Game(appName);
      _game = game;
    }
    final prefs = _preferences;
    final Widget child;
    if (prefs == null) {
      loadPreferences();
      child = const Center(
        child:
            CircularProgressIndicator(semanticsLabel: 'Loading preferences...'),
      );
    } else {
      final children = <Widget>[
        ElevatedButton(
          onPressed: () => newProject(context: context, game: game!),
          child: const Icon(
            Icons.create_sharp,
            semanticLabel: 'Create Project',
          ),
          autofocus: true,
        ),
        ElevatedButton(
          onPressed: openProject,
          child: const Icon(
            Icons.file_open,
            semanticLabel: 'Open Project',
          ),
        )
      ];
      final preferences = AppPreferences.load(prefs);
      for (final path in preferences.recentProjects) {
        if (File(path).existsSync()) {
          children.add(
            ListTile(
              title: Text(path),
              onTap: () => openProject(path),
            ),
          );
        }
      }
      child = ListView(
        children: children,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(appName),
      ),
      body: child,
    );
  }

  /// Load user preferences.
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _preferences = prefs);
  }

  /// Create a new project.
  Future<void> newProject(
      {required BuildContext context, required Game game}) async {
    final filename = await FilePicker.platform.saveFile(
      allowedExtensions: ['json'],
      dialogTitle: 'Create Project',
      fileName: 'project.json',
    );
    if (filename == null) {
      return;
    }
    final projectContext = ProjectContext(
      game: game,
      file: File(filename),
      world: World(),
    )..save();
    pushWidget(
      context: context,
      builder: (context) => ProjectContextWidget(
        projectContext: projectContext,
      ),
    );
  }

  /// Open a project.
  ///
  /// If [filename] is `null`, then use the file picker dialogue.
  Future<void> openProject([String? filename]) async {}
}
