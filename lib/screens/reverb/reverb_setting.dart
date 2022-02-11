/// Provides the [ReverbSetting] class.
import 'package:ziggurat/sound.dart';

/// The setting for a [ReverbPreset] instance.
class ReverbSetting {
  /// Create an instance.
  const ReverbSetting({
    required this.name,
    required this.defaultValue,
    required this.min,
    required this.max,
    this.modify = 0.1,
  });

  /// The name of this setting.
  final String name;

  /// The default value for this setting.
  final double defaultValue;

  /// The minimum value for this setting.
  final double min;

  /// The maximum value for this setting.
  final double max;

  /// How much this setting should be modified with the plus and minus keys.
  final double modify;
}
