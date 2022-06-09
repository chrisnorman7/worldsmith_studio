import 'package:path/path.dart' as path;
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

/// A sound manager with a custom [soundsDirectory].
class ProjectSoundManager extends SoundManager {
  /// Create an instance.
  ProjectSoundManager({
    required super.game,
    required super.context,
    required this.soundsDirectory,
    required BufferCache super.bufferCache,
  });

  /// The directory where sounds are stored.
  String soundsDirectory;

  /// Use [soundsDirectory].
  @override
  void handlePlaySound(final PlaySound event) {
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
      id: event.id,
    );
    super.handlePlaySound(newEvent);
  }
}
