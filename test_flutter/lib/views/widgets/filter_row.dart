import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_theme.dart';

/// One filter section rendered as a summary row.
///
/// The header shows the section [title] on the left and [valueText] on the
/// right — muted when inactive (e.g. "All") and primary-colored with a round ×
/// clear button when [active]. Tapping the row calls [onTap] (expand a
/// chips/slider section, or open a picker). When [expanded] and [child] is
/// non-null, the inline input is shown below (chips / slider only).
class FilterRow extends StatelessWidget {
  const FilterRow({
    super.key,
    required this.title,
    required this.valueText,
    required this.active,
    required this.onTap,
    this.onClear,
    this.expanded = false,
    this.child,
    this.showDivider = true,
  });

  final String title;
  final String valueText;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final bool expanded;
  final Widget? child;

  /// Whether to draw the bottom divider. Suppressed for the last row inside an
  /// expanded group so it doesn't stack against the group's own border.
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.divider))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.sectionTitle),
                        if (active) ...[
                          const SizedBox(height: 4),
                          Text(
                            valueText,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.countFooter,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (active && onClear != null)
                    GestureDetector(
                      onTap: onClear,
                      child: SvgPicture.asset(
                        AppIcons.xMarkCircle,
                        width: 22,
                        height: 22,
                      ),
                    )
                  else if (!expanded && !title.contains("Shariah"))
                    Text(valueText, style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    )),
                ],
              ),
            ),
          ),
          if (expanded && child != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: child,
            ),
        ],
      ),
    );
  }
}
