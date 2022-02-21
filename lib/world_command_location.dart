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
    required List<CommandCategory> categories,
    required String commandId,
  })  : category = categories.firstWhere(
          (element) => element.commands
              .where(
                (element) => element.id == commandId,
              )
              .isNotEmpty,
        ),
        command = categories
            .firstWhere(
              (element) => element.commands
                  .where(
                    (element) => element.id == commandId,
                  )
                  .isNotEmpty,
            )
            .commands
            .firstWhere((element) => element.id == commandId);

  /// The category for the [command].
  final CommandCategory category;

  /// The command to use.
  final WorldCommand command;
}
