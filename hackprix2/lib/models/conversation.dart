// lib/models/conversation.dart

// This class defines the structure of a Conversation object.
class Conversation {
  final String otherUserId;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  // This field is now populated by your updated backend
  final String otherUsername;

  Conversation({
    required this.otherUserId,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.otherUsername,
  });

  // This factory constructor creates a Conversation object from a JSON map.
  // It matches the structure of the data your backend sends.
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      otherUserId: json['otherUserId'],
      lastMessage: json['lastMessage'] ?? 'No messages yet',
      lastMessageTimestamp: DateTime.parse(json['lastMessageTimestamp']),
      // The backend now provides this directly
      otherUsername: json['otherUsername'] ?? 'Unknown User',
    );
  }
}
