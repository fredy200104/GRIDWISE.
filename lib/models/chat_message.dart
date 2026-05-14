/// Modelo de mensaje de chat
class ChatMessage {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
  });

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
  bool get isSystem => role == MessageRole.system;

  factory ChatMessage.user(String content) => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.assistant(String content, {String? id}) => ChatMessage(
        id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.system(String content) => ChatMessage(
        id: 'system_${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        role: MessageRole.system,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        content: map['content'] as String? ?? '',
        role: _roleFromString(map['role'] as String? ?? 'assistant'),
        timestamp: map['timestamp'] != null
            ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  static MessageRole _roleFromString(String role) {
    switch (role) {
      case 'user':
        return MessageRole.user;
      case 'system':
        return MessageRole.system;
      default:
        return MessageRole.assistant;
    }
  }
}

enum MessageRole { user, assistant, system }
