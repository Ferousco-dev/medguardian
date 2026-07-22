enum ChatRole { user, assistant }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.sentAt,
    this.groundedOn = const <String>[],
    this.suggestions = const <String>[],
    this.isEmergency = false,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime sentAt;

  /// What on the twin the answer drew from, shown as small chips so the user
  /// can see the reply is not generic.
  final List<String> groundedOn;

  final List<String> suggestions;
  final bool isEmergency;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: json['role'] == 'user' ? ChatRole.user : ChatRole.assistant,
      text: json['text'] as String? ?? '',
      sentAt: DateTime.parse(json['sent_at'] as String),
      groundedOn: _strings(json['grounded_on']),
      suggestions: _strings(json['suggestions']),
      isEmergency: json['is_emergency'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'role': role == ChatRole.user ? 'user' : 'assistant',
    'text': text,
    'sent_at': sentAt.toIso8601String(),
  };

  static List<String> _strings(dynamic value) {
    if (value is List) {
      return value.map((dynamic e) => e.toString()).toList(growable: false);
    }
    return const <String>[];
  }
}
