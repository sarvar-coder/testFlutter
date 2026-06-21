import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// An expand/collapse tile used to wrap a filter section.
///
/// Dumb widget: the parent owns [expanded] and toggles it via [onToggle].
/// [active] draws the small accent dot that signals the section is narrowing
/// results (driven by `FilterState.isActive`).
class CollapsibleSection extends StatelessWidget {
  const CollapsibleSection({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
    this.active = false,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(title, style: AppTextStyles.sectionTitle),
                        ),
                        if (active) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: child,
            ),
        ],
      ),
    );
  }
}
