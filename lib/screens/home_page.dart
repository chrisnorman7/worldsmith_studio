import 'dart:io';
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/ziggurat.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../constants.dart';
import '../intents.dart';
import '../project_context.dart';
import '../project_sound_manager.dart';
import '../src/json/app_preferences.dart';
import '../util.dart';
import '../widgets/keyboard_shortcuts_list.dart';
import 'project/project_context_widget.dart';

/// A list view for opening and creating projects.
class HomePage extends StatefulWidget {
  /// Create an instance.
  const HomePage({
    final Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences? _preferences;
  Game? _game;
  ProjectSoundManager? _soundManager;
  late final Synthizer synthizer;
  late final Sdl sdl;
  bool? _checkedForUpdate;
  String? _documentsDirectory;

  /// Initialise synthizer.
  @override
  void initState() {
    super.initState();
    synthizer = Synthizer();
    sdl = Sdl()..init();
  }

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final prefs = _preferences;
    final documentsDirectory = _documentsDirectory;
    final Widget child;
    if (prefs == null || documentsDirectory == null) {
      loadPreferences();
      child = const Center(
        child:
            CircularProgressIndicator(semanticsLabel: 'Loading preferences...'),
      );
    } else {
      final preferences = AppPreferences.load(prefs);
      final recentProjectPaths = preferences.recentProjects
          .where((final element) => File(element).existsSync() == true)
          .toList();
      final children = [
        ListTile(
          autofocus: recentProjectPaths.isEmpty,
          title: const Icon(Icons.create_sharp),
          subtitle: const Text('Create Project'),
          onTap: () => newProject(
            context: context,
            preferences: preferences,
            documentsDirectory: documentsDirectory,
          ),
        ),
        ListTile(
          title: const Icon(Icons.file_open),
          subtitle: const Text('Open Project'),
          onTap: () => openProject(
            context: context,
            preferences: preferences,
          ),
        ),
        const Divider(),
      ];
      child = CallbackShortcuts(
        bindings: {
          CreateProjectIntent.hotkey: () => newProject(
                context: context,
                preferences: preferences,
                documentsDirectory: documentsDirectory,
              ),
          OpenProjectIntent.hotkey: () => openProject(
                context: context,
                preferences: preferences,
              ),
          LaunchManualIntent.hotkey: () => launch(manualUrl)
        },
        child: WithKeyboardShortcuts(
          keyboardShortcuts: const [
            KeyboardShortcut(
              description: 'Create a new project.',
              keyName: 'n',
              control: true,
            ),
            KeyboardShortcut(
              description: 'Open an existing project',
              keyName: 'o',
              control: true,
            ),
            KeyboardShortcut(
              description: 'Open the manual in your web browser.',
              keyName: '/',
              control: true,
              shift: true,
            )
          ],
          child: ListView.builder(
            itemBuilder: (final context, final index) {
              if (index < children.length) {
                return children[index];
              } else {
                final filename = recentProjectPaths[index - children.length];
                final accessed = File(filename).statSync().accessed;
                return ListTile(
                  autofocus: index == children.length,
                  title: Text(filename),
                  subtitle: Text(dateFormat.format(accessed)),
                  onTap: () => openProject(
                    context: context,
                    preferences: preferences,
                    filename: filename,
                  ),
                );
              }
            },
            itemCount: children.length + recentProjectPaths.length,
          ),
        ),
      );
    }
    final checkedForUpdate = _checkedForUpdate;
    if (checkedForUpdate == null) {
      _checkedForUpdate = false;
      checkForUpdates(context);
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<VoidCallback>(
            itemBuilder: (final context) => [
              PopupMenuItem(
                child: const Text('Check For Updates'),
                value: () => setState(() {
                  _checkedForUpdate = true;
                  checkForUpdates(context);
                }),
              ),
              const PopupMenuItem(
                value: launchManual,
                child: Text('Open Manual'),
              ),
              const PopupMenuItem(
                value: launchReportIssue,
                child: Text('Report Issue'),
              ),
              PopupMenuItem(
                child: const Text('Visit GitHub'),
                value: () =>
                    launch('https://github.com/chrisnorman7/worldsmith_studio'),
              ),
              PopupMenuItem(
                child: const Text('About'),
                value: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (final context) => const AboutDialog(
                      applicationLegalese:
                          'This is free and unencumbered software released '
                          'into the public domain.',
                      applicationName: appName,
                      applicationVersion: appVersion,
                    ),
                  );
                },
              )
            ],
            icon: const Icon(Icons.help_outline),
            initialValue: launchManual,
            onSelected: (final f) => f(),
            tooltip: 'Help',
          )
        ],
        title: const Text(appName),
      ),
      body: child,
    );
  }

  /// Load user preferences.
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final directory = await getApplicationDocumentsDirectory();
    _documentsDirectory = directory.path;
    setState(() => _preferences = prefs);
  }

  /// Create a new project.
  Future<void> newProject({
    required final BuildContext context,
    required final AppPreferences preferences,
    required final String documentsDirectory,
  }) async {
    final filename = await FilePicker.platform.saveFile(
      allowedExtensions: ['json'],
      dialogTitle: 'Create Project',
      fileName: 'project.json',
      initialDirectory: documentsDirectory,
    );
    if (filename == null) {
      return;
    } else if (Platform.resolvedExecutable.startsWith(path.dirname(filename))) {
      return showError(
        context: context,
        message: 'You cannot create projects along side the program files.',
      );
    }
    final file = File(filename);
    if (file.existsSync()) {
      await confirm(
        context: context,
        message: 'Are you sure you want to overwrite $filename?',
        title: 'Overwrite File',
        yesCallback: () {
          Navigator.pop(context);
          createProjectContext(
            context: context,
            preferences: preferences,
            file: file,
          );
        },
      );
    } else {
      await createProjectContext(
        context: context,
        preferences: preferences,
        file: file,
      );
    }
  }

  /// Finish off the project creation process.
  Future<void> createProjectContext({
    required final BuildContext context,
    required final AppPreferences preferences,
    required final File file,
    World? world,
  }) async {
    final worldWasNull = world == null;
    world ??= World();
    var game = _game;
    if (game == null) {
      game = Game(appName);
      _game = game;
    }
    var soundManager = _soundManager;
    if (soundManager == null) {
      final options = world.soundOptions;
      String? libsndfilePath;
      if (Platform.isLinux) {
        libsndfilePath = options.libsndfilePathLinux;
      } else if (Platform.isWindows) {
        libsndfilePath = options.libsndfilePathWindows;
      } else if (Platform.isMacOS) {
        libsndfilePath = options.libsndfilePathMac;
      }
      if (libsndfilePath == null ||
          File(libsndfilePath).existsSync() == false) {
        libsndfilePath = null;
      }
      synthizer.initialize(
        libsndfilePath: libsndfilePath,
        logLevel: options.synthizerLogLevel,
        loggingBackend: options.synthizerLoggingBackend,
      );
      final context = synthizer.createContext();
      final bufferCache = BufferCache(
        synthizer: synthizer,
        maxSize: pow(1024, 3).floor(),
        random: game.random,
      );
      soundManager = ProjectSoundManager(
        game: game,
        context: context,
        bufferCache: bufferCache,
        soundsDirectory: file.parent.path,
      );
      _soundManager = soundManager;
      game.sounds.listen(
        (final event) {
          // ignore: avoid_print
          print('Sound: $event');
          soundManager!.handleEvent(event);
        },
        // ignore: avoid_print
        onDone: () => print('Sound stream finished.'),
        onError: (final dynamic e, final dynamic s) {
          // ignore: avoid_print
          print(e);
          if (s != null) {
            // ignore: avoid_print
            print(s);
          }
        },
      );
    } else {
      soundManager.soundsDirectory = file.parent.path;
    }
    final filename = file.path;
    final projectContext = ProjectContext(
      game: game,
      file: file,
      world: world,
      sdl: sdl,
      audioContext: soundManager.context,
    );
    if (worldWasNull) {
      projectContext.save();
    }
    final prefs = await SharedPreferences.getInstance();
    preferences.recentProjects
        .removeWhere((final element) => element == filename);
    if (preferences.recentProjects.isEmpty) {
      preferences.recentProjects.add(filename);
    } else {
      preferences.recentProjects.insert(0, filename);
    }
    preferences.save(prefs);
    await pushWidget(
      context: context,
      builder: (final context) => ProjectContextWidget(
        projectContext: projectContext,
      ),
    );
    setState(() {});
  }

  /// Open a project.
  ///
  /// If [filename] is `null`, then use the file picker dialogue.
  Future<void> openProject({
    required final BuildContext context,
    required final AppPreferences preferences,
    final String? filename,
  }) async {
    var projectPath = filename;
    if (projectPath == null) {
      final result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['.json'],
        dialogTitle: 'Open Project',
      );
      if (result == null) {
        return;
      }
      projectPath = result.files.single.path;
      if (projectPath == null) {
        return showError(
          context: context,
          message:
              'There was an internal error, and the file could not be opened.',
        );
      }
    }
    final file = File(projectPath);
    if (file.existsSync() == false) {
      return showError(
        context: context,
        message: 'The file $filename no longer exists.',
      );
    }
    final world = World.fromFilename(projectPath);
    return createProjectContext(
      context: context,
      preferences: preferences,
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
        ..context.destroy();
    }
    _game?.destroy();
    synthizer.shutdown();
    sdl.quit();
    for (final joystick in (_game?.joysticks ?? {}).values) {
      joystick.close();
    }
  }

  /// Check for updates.
  Future<void> checkForUpdates(final BuildContext context) async {
    try {
      final tag = await getLatestTag();
      final name = tag.name;
      if (name != appVersion) {
        await showDialog<void>(
          context: context,
          builder: (final context) => AlertDialog(
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => launch(
                  'https://github.com/chrisnorman7/worldsmith_studio/releases/latest',
                ),
                child: const Text('Download'),
              )
            ],
            content: Focus(
              autofocus: true,
              child: Text(
                'There is a new version available. You are running version '
                '$appVersion, but ${tag.name} is available.',
              ),
            ),
          ),
        );
      } else if (_checkedForUpdate ?? true) {
        showError(
          context: context,
          message: 'You are up to date.',
          title: 'No Updates Available',
        );
      }
    } on Exception catch (e, s) {
      showError(
        context: context,
        message: '$e\n$s',
        title: 'Error Checking For Update',
      );
    }
    _checkedForUpdate = true;
  }
}
