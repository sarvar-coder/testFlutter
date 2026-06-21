import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/filter_config.dart';

/// A flowing row of selectable pills for a `chips` section.
///
/// Dumb widget: takes the [options], the currently [selectedLabel], and reports
/// taps via [onSelected]. The selected chip uses the accent green background.
class ChipSelector extends StatelessWidget {
  const ChipSelector({
    super.key,
    required this.options,
    required this.selectedLabel,
    required this.onSelected,
  });

  final List<FilterOption> options;
  final String? selectedLabel;
  final ValueChanged<FilterOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          _Chip(
            label: option.label,
            selected: option.label == selectedLabel,
            onTap: () => onSelected(option),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.black : AppColors.divider,
      borderRadius: BorderRadius.circular(AppRadii.chip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: AppTextStyles.chipLabel.copyWith(
              color: selected ? Colors.white : AppColors.black,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
