import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/chat_message.dart';
import '../../../../shared/widgets/brand_mark.dart';
import '../../../../shared/widgets/status_pill.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, this.onEmergency});

  final ChatMessage message;
  final VoidCallback? onEmergency;

  @override
  Widget build(BuildContext context) {
    return message.role == ChatRole.user
        ? _UserBubble(message: message)
        : _AssistantBubble(message: message, onEmergency: onEmergency);
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.lg),
            topRight: Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(AppRadius.lg),
            bottomRight: Radius.circular(AppRadius.xs),
          ),
        ),
        child: Text(
          message.text,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.onPrimary),
        ),
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.message, this.onEmergency});

  final ChatMessage message;
  final VoidCallback? onEmergency;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool isEmergency = message.isEmergency;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: BrandMark(
              size: 26,
              color: isEmergency ? AppColors.danger : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isEmergency ? AppColors.dangerTint : AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xs),
                  topRight: Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(AppRadius.lg),
                  bottomRight: Radius.circular(AppRadius.lg),
                ),
                border: Border.all(
                  color: isEmergency ? AppColors.dangerTint : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message.text,
                    style: text.bodyLarge?.copyWith(
                      color: isEmergency
                          ? AppColors.danger
                          : AppColors.textPrimary,
                      height: 1.55,
                    ),
                  ),
                  if (message.groundedOn.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.lg),
                    Text('Read from your twin', style: text.labelSmall),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: message.groundedOn
                          .map(
                            (String source) => StatusPill(
                              label: source,
                              tone: isEmergency
                                  ? StatusTone.critical
                                  : StatusTone.neutral,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                  if (isEmergency && onEmergency != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: onEmergency,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        minimumSize: const Size.fromHeight(46),
                      ),
                      child: const Text('Open emergency card'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key});

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: BrandMark(size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xs),
                topRight: Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(AppRadius.lg),
                bottomRight: Radius.circular(AppRadius.lg),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(3, (int index) {
                    final double t = (_controller.value - index * 0.18) % 1.0;
                    final double lift = t < 0.5 ? (0.5 - t) * 2 : 0;
                    return Padding(
                      padding: EdgeInsets.only(right: index == 2 ? 0 : 5),
                      child: Transform.translate(
                        offset: Offset(0, -3 * lift),
                        child: Container(
                          height: 6,
                          width: 6,
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary.withValues(
                              alpha: 0.45 + (0.55 * lift),
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
