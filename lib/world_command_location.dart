import 'package:worldsmith/worldsmith.dart';

/// A class for showing [WorldCommand] instances and their [CommandCategory].
class WorldCommandLocation {
  /// Create an instance.
  const WorldCommandLocation({
    required this.category,
    required this.command,
  });

  /// Find the right location from the given [categories].
  WorldCommandLocation.find({
    required final List<CommandCategory> categories,
    required final String commandId,
  })  : category = categories.firstWhere(
          (final element) => element.commands
              .where(
                (final element) => element.id == commandId,
              )
              .isNotEmpty,
        ),
        command = categories
            .firstWhere(
              (final element) => element.commands
                  .where(
                    (final element) => element.id == commandId,
                  )
                  .isNotEmpty,
            )
            .commands
            .firstWhere((final element) => element.id == commandId);

  /// The category for the [command].
  final CommandCategory category;

  /// The command to use.
  final WorldCommand command;

  /// Get a description of this location.
  String get description => '${category.name} -> ${command.name}';
}
