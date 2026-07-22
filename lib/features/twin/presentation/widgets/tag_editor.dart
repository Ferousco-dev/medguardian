import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class TagEditor extends StatefulWidget {
  const TagEditor({
    super.key,
    required this.label,
    required this.values,
    required this.onChanged,
    this.suggestions = const <String>[],
    this.hintText,
  });

  final String label;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final List<String> suggestions;
  final String? hintText;

  @override
  State<TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) {
      return;
    }
    final bool exists = widget.values.any(
      (String v) => v.toLowerCase() == value.toLowerCase(),
    );
    if (exists) {
      _controller.clear();
      return;
    }
    widget.onChanged(<String>[...widget.values, value]);
    _controller.clear();
  }

  void _remove(String value) {
    widget.onChanged(
      widget.values.where((String v) => v != value).toList(growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    final List<String> unused = widget.suggestions
        .where(
          (String s) => !widget.values.any(
            (String v) => v.toLowerCase() == s.toLowerCase(),
          ),
        )
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.label, style: text.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _controller,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          style: text.bodyLarge,
          onSubmitted: _add,
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_rounded, size: 20),
              onPressed: () => _add(_controller.text),
            ),
          ),
        ),
        if (widget.values.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: widget.values
                .map(
                  (String value) => InputChip(
                    label: Text(value),
                    onDeleted: () => _remove(value),
                    deleteIcon: const Icon(Icons.close_rounded, size: 15),
                    backgroundColor: AppColors.primaryTint,
                    labelStyle: text.labelMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
        if (unused.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: unused
                .map(
                  (String suggestion) => ActionChip(
                    label: Text(suggestion),
                    avatar: const Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => _add(suggestion),
                    backgroundColor: AppColors.surface,
                    labelStyle: text.bodySmall,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ],
    );
  }
}
