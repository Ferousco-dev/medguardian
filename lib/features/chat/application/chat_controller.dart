import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/demo/demo_chat.dart';
import '../../../data/models/chat_message.dart';

class ChatState {
  const ChatState({
    this.messages = const <ChatMessage>[],
    this.isReplying = false,
    this.error,
  });

  final List<ChatMessage> messages;
  final bool isReplying;
  final Object? error;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isReplying,
    Object? error,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isReplying: isReplying ?? this.isReplying,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatController extends AutoDisposeNotifier<ChatState> {
  @override
  ChatState build() => ChatState(messages: <ChatMessage>[DemoChat.greeting]);

  Future<void> send(String text) async {
    final String message = text.trim();
    if (message.isEmpty || state.isReplying) {
      return;
    }

    final ChatMessage outgoing = ChatMessage(
      id: 'user_${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.user,
      text: message,
      sentAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: <ChatMessage>[...state.messages, outgoing],
      isReplying: true,
      clearError: true,
    );

    try {
      final ChatMessage reply = await ref
          .read(intelligenceRepositoryProvider)
          .sendChatMessage(message, state.messages);

      state = state.copyWith(
        messages: <ChatMessage>[...state.messages, reply],
        isReplying: false,
      );
    } catch (error) {
      state = state.copyWith(isReplying: false, error: error);
    }
  }

  void retryLast() {
    final ChatMessage? lastUser = state.messages
        .where((ChatMessage m) => m.role == ChatRole.user)
        .lastOrNull;
    if (lastUser == null) {
      return;
    }
    state = state.copyWith(
      messages: state.messages
          .where((ChatMessage m) => m.id != lastUser.id)
          .toList(growable: false),
      clearError: true,
    );
    send(lastUser.text);
  }

  void clear() {
    state = ChatState(messages: <ChatMessage>[DemoChat.greeting]);
  }
}

final AutoDisposeNotifierProvider<ChatController, ChatState>
chatControllerProvider =
    NotifierProvider.autoDispose<ChatController, ChatState>(ChatController.new);
