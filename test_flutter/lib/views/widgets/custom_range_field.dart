import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

/// From / To numeric inputs shown when the "Custom" chip is selected.
///
/// Dumb widget: reports the parsed (min, max) on every edit via [onChanged];
/// either value can be `null` when its field is empty.
class CustomRangeField extends StatelessWidget {
  const CustomRangeField({
    super.key,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final num? min;
  final num? max;

  /// Called with (min, max) — either may be null when its field is blank.
  final void Function(num? min, num? max) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NumberField(
            label: 'From',
            initial: min,
            onChanged: (value) => onChanged(value, max),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NumberField(
            label: 'To',
            initial: max,
            onChanged: (value) => onChanged(min, value),
          ),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.initial,
    required this.onChanged,
  });

  final String label;
  final num? initial;
  final ValueChanged<num?> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial?.toString(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      style: AppTextStyles.chipLabel,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.chip),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.chip),
          borderSide: const BorderSide(color: AppColors.black),
        ),
      ),
      onChanged: (text) => onChanged(num.tryParse(text.trim())),
    );
  }
}
