import 'package:worldsmith/worldsmith.dart';

/// A class to hold quest information.
class QuestLocation {
  /// Create an instance.
  const QuestLocation({
    required this.quest,
    required this.stage,
  });

  /// The quest to use.
  final Quest quest;

  /// The stage in the [quest].
  final QuestStage? stage;
}
