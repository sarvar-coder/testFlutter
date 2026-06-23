import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    this.summary,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  final bool active;

  /// One-line summary of the active selections inside this section, shown below
  /// the title while collapsed. When non-null it replaces the [active] dot.
  final String? summary;

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child:
                                  Text(title, style: AppTextStyles.sectionTitle),
                            ),
                            if (active && summary == null) ...[
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
                        if (summary != null && !expanded) ...[
                          const SizedBox(height: 4),
                          Text(
                            summary!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.countFooter,
                          ),
                        ],
                      ],
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: expanded ? 2 : 0,
                    child: SvgPicture.asset(
                      AppIcons.chevronDown,
                      width: 24,
                      height: 24,
                    ),
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
