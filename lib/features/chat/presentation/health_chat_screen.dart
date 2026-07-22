import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/chat_message.dart';
import '../../../shared/widgets/async_view.dart';
import '../application/chat_controller.dart';
import '../../../shared/widgets/brand_mark.dart';
import 'widgets/chat_bubble.dart';

class HealthChatScreen extends ConsumerStatefulWidget {
  const HealthChatScreen({super.key});

  @override
  ConsumerState<HealthChatScreen> createState() => _HealthChatScreenState();
}

class _HealthChatScreenState extends ConsumerState<HealthChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) {
        return;
      }
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  void _send(String text) {
    if (text.trim().isEmpty) {
      return;
    }
    _input.clear();
    ref.read(chatControllerProvider.notifier).send(text);
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    final ChatState state = ref.watch(chatControllerProvider);
    final TextTheme text = Theme.of(context).textTheme;

    ref.listen(chatControllerProvider, (ChatState? previous, ChatState next) {
      if (next.messages.length != (previous?.messages.length ?? 0)) {
        _scrollToEnd();
      }
      if (next.error != null && previous?.error == null) {
        AppSnack.error(context, next.error!);
      }
    });

    final ChatMessage last = state.messages.last;
    final List<String> suggestions = state.isReplying
        ? const <String>[]
        : last.suggestions;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: <Widget>[
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              alignment: Alignment.center,
              child: const BrandMark(size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Health assistant', style: text.titleMedium),
                Text(
                  'Reads your twin, not the internet',
                  style: text.labelSmall,
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Start over',
            onPressed: state.messages.length > 1
                ? () => ref.read(chatControllerProvider.notifier).clear()
                : null,
            icon: const Icon(Icons.refresh_rounded, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.lg,
                  AppSpacing.page,
                  AppSpacing.lg,
                ),
                children: <Widget>[
                  for (final ChatMessage message in state.messages)
                    ChatBubble(
                      message: message,
                      onEmergency: () => context.push(Routes.emergency),
                    ),
                  if (state.isReplying) const TypingBubble(),
                ],
              ),
            ),
            if (suggestions.isNotEmpty)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  itemCount: suggestions.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (BuildContext context, int index) {
                    final String suggestion = suggestions[index];
                    return Center(
                      child: ActionChip(
                        label: Text(suggestion),
                        labelStyle: text.bodyMedium,
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        onPressed: () {
                          if (suggestion.contains('Report a symptom')) {
                            context.push(Routes.symptomCheck);
                            return;
                          }
                          if (suggestion.contains('clinical summary')) {
                            context.push(Routes.clinicalSummary);
                            return;
                          }
                          _send(suggestion);
                        },
                      ),
                    );
                  },
                ),
              ),
            _Composer(
              controller: _input,
              enabled: !state.isReplying,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.page,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: text.bodyLarge,
                  onSubmitted: onSend,
                  decoration: InputDecoration(
                    hintText: 'Ask about your health',
                    fillColor: AppColors.surfaceMuted,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (BuildContext context, TextEditingValue value, _) {
                  final bool canSend = enabled && value.text.trim().isNotEmpty;
                  return IconButton.filled(
                    onPressed: canSend ? () => onSend(value.text) : null,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.surfaceMuted,
                      minimumSize: const Size.square(46),
                    ),
                    icon: Icon(
                      Icons.arrow_upward_rounded,
                      size: 20,
                      color: canSend
                          ? AppColors.onPrimary
                          : AppColors.textTertiary,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Health guidance, not a diagnosis. Always confirm with a clinician.',
            style: text.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
