import 'package:worldsmith/worldsmith.dart';

/// A class to hold information about the location of its [conversation].
class ConversationLocation {
  /// Create an instance.
  const ConversationLocation({
    required this.category,
    required this.conversation,
  });

  /// Return an instance with the properties inferred.
  ConversationLocation.find({
    required final World world,
    required final String conversationId,
  })  : category = world.conversationCategories.firstWhere(
          (final element) => element.conversations
              .where(
                (final element) => element.id == conversationId,
              )
              .isNotEmpty,
        ),
        conversation = world.conversations
            .firstWhere((final element) => element.id == conversationId);

  /// The category where the [conversation] resides.
  final ConversationCategory category;

  /// The conversation this instance represents.
  final Conversation conversation;
}
