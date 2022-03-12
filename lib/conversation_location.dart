import 'package:worldsmith/worldsmith.dart';

/// A class to hold information about the location of its [conversation].
class ConversationLocation {
  /// Create an instance.
  const ConversationLocation({
    required this.category,
    required this.conversation,
  });

  /// Return an instance with the properties inferred.
  ConversationLocation.find(
      {required World world, required String conversationId})
      : category = world.conversationCategories.firstWhere(
          (element) => element.conversations
              .where(
                (element) => element.id == conversationId,
              )
              .isNotEmpty,
        ),
        conversation = world.conversations
            .firstWhere((element) => element.id == conversationId);

  /// The category where the [conversation] resides.
  final ConversationCategory category;

  /// The conversation this instance represents.
  final Conversation conversation;
}
