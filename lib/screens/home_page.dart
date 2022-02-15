// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/ziggurat.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../constants.dart';
import '../intents.dart';
import '../project_context.dart';
import '../src/json/app_preferences.dart';
import '../util.dart';
import 'project/project_context_widget.dart';

const _createProjectIntent = CreateProjectIntent();
const _openProjectIntent = OpenProjectIntent();

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
  SoundManager? _soundManager;

  /// Build the widget.
  @override
  Widget build(BuildContext context) {
    var game = _game;
    if (game == null) {
      game = Game(appName);
      _game = game;
    }
    var soundManager = _soundManager;
    if (soundManager == null) {
      final synthizer = Synthizer()..initialize();
      final context = synthizer.createContext();
      final bufferCache = BufferCache(
        synthizer: synthizer,
        maxSize: pow(1024, 3).floor(),
        random: game.random,
      );
      soundManager = SoundManager(
        game: game,
        context: context,
        bufferCache: bufferCache,
      );
      _soundManager = soundManager;
      game.sounds.listen(
        (event) {
          print('Sound: $event');
          soundManager!.handleEvent(event);
        },
        onDone: () => print('Sound stream finished.'),
        onError: (Object e, StackTrace? s) {
          print(e);
          if (s != null) {
            print(s);
          }
        },
      );
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
      final preferences = AppPreferences.load(prefs);
      final recentProjectPaths = preferences.recentProjects
          .where((element) => File(element).existsSync() == true)
          .toList();
      child = ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0) {
            return ElevatedButton(
              onPressed: Actions.handler(context, _createProjectIntent),
              child: const Icon(
                Icons.create_sharp,
                semanticLabel: 'Create Project',
              ),
              autofocus: recentProjectPaths.isEmpty,
            );
          } else if (index == 1) {
            return ElevatedButton(
              onPressed: Actions.handler(context, _openProjectIntent),
              child: const Icon(
                Icons.file_open,
                semanticLabel: 'Open Project',
              ),
            );
          } else {
            final filename = recentProjectPaths[index - 2];
            return ListTile(
              autofocus: index == 2,
              title: Text(filename),
              onTap: () => openProject(
                context: context,
                preferences: preferences,
                game: game!,
                filename: filename,
              ),
            );
          }
        },
        itemCount: recentProjectPaths.length + 2,
      );
    }
    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text(appName),
      ),
      body: child,
    );
    if (prefs == null) {
      return scaffold;
    }
    final preferences = AppPreferences.load(prefs);
    return Shortcuts(
      shortcuts: const {
        CreateProjectIntent.hotkey: _createProjectIntent,
        OpenProjectIntent.hotkey: _openProjectIntent
      },
      child: Actions(
        actions: {
          CreateProjectIntent: CallbackAction<CreateProjectIntent>(
            onInvoke: (intent) => newProject(
              context: context,
              preferences: preferences,
              game: game!,
            ),
          ),
          OpenProjectIntent: CallbackAction<OpenProjectIntent>(
            onInvoke: (intent) => openProject(
              context: context,
              preferences: preferences,
              game: game!,
            ),
          )
        },
        child: scaffold,
      ),
    );
  }

  /// Load user preferences.
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _preferences = prefs);
  }

  /// Create a new project.
  Future<void> newProject({
    required BuildContext context,
    required AppPreferences preferences,
    required Game game,
  }) async {
    final filename = await FilePicker.platform.saveFile(
      allowedExtensions: ['json'],
      dialogTitle: 'Create Project',
      fileName: 'project.json',
    );
    if (filename == null) {
      return;
    }
    final file = File(filename);
    if (file.existsSync()) {
      confirm(
        context: context,
        message: 'Are you sure you want to overwrite $filename?',
        noCallback: () => Navigator.pop(context),
        title: 'Overwrite File',
        yesCallback: () {
          Navigator.pop(context);
          createProjectContext(
            context: context,
            preferences: preferences,
            game: game,
            file: file,
          );
        },
      );
    } else {
      createProjectContext(
        context: context,
        preferences: preferences,
        game: game,
        file: file,
      );
    }
  }

  /// Finish off the project creation process.
  Future<void> createProjectContext({
    required BuildContext context,
    required AppPreferences preferences,
    required Game game,
    required File file,
    World? world,
  }) async {
    final filename = file.path;
    final projectContext = ProjectContext(
      game: game,
      file: file,
      world: world ?? World(),
    );
    if (world == null) {
      projectContext.save();
    }
    final prefs = await SharedPreferences.getInstance();
    preferences.recentProjects.removeWhere((element) => element == filename);
    if (preferences.recentProjects.isEmpty) {
      preferences.recentProjects.add(filename);
    } else {
      preferences.recentProjects.insert(0, filename);
    }
    preferences.save(prefs);
    await pushWidget(
      context: context,
      builder: (context) => ProjectContextWidget(
        projectContext: projectContext,
      ),
    );
    setState(() {});
  }

  /// Open a project.
  ///
  /// If [filename] is `null`, then use the file picker dialogue.
  Future<void> openProject({
    required BuildContext context,
    required AppPreferences preferences,
    required Game game,
    String? filename,
  }) async {
    if (filename == null) {
      final result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['.json'],
        dialogTitle: 'Open Project',
      );
      if (result == null) {
        return;
      }
      filename = result.files.single.path;
      if (filename == null) {
        return showSnackBar(
          context: context,
          message:
              'There was an internal error, and the file could not be opened.',
        );
      }
    }
    final file = File(filename);
    if (file.existsSync() == false) {
      return showSnackBar(
        context: context,
        message: 'The file $filename no longer exists.',
      );
    }
    final world = loadJson(filename);
    return createProjectContext(
      context: context,
      preferences: preferences,
      game: game,
      file: file,
      world: world,
    );
  }

  /// Shut down synthizer.
  @override
  void dispose() {
    super.dispose();
    final soundManager = _soundManager;
    if (soundManager != null) {
      soundManager
        ..bufferCache?.destroy()
        ..context.destroy()
        ..context.synthizer.shutdown();
    }
  }
}
