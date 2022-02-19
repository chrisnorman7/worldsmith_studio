import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:path/path.dart' as path;
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

/// A sound manager with a custom [soundsDirectory].
class ProjectSoundManager extends SoundManager {
  /// Create an instance.
  ProjectSoundManager({
    required Game game,
    required Context context,
    required this.soundsDirectory,
    required BufferCache bufferCache,
  }) : super(
          game: game,
          context: context,
          bufferCache: bufferCache,
        );

  /// The directory where sounds are stored.
  String soundsDirectory;

  /// Use [soundsDirectory].
  @override
  void handlePlaySound(PlaySound event) {
    final reference = event.sound;
    final newEvent = PlaySound(
      game: event.game,
      sound: AssetReference(
        path.join(soundsDirectory, reference.name),
        reference.type,
        encryptionKey: reference.encryptionKey,
      ),
      channel: event.channel,
      keepAlive: event.keepAlive,
      gain: event.gain,
      looping: event.looping,
      pitchBend: event.pitchBend,
    );
    super.handlePlaySound(newEvent);
  }
}
