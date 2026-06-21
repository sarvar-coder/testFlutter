import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'hollow_slider_shapes.dart';

/// A two-thumb range slider shown when the "Custom" chip is selected.
///
/// Dumb widget: takes the metric's [boundMin]/[boundMax] (the slider extent)
/// and the current selection [min]/[max] (either may be null — the thumbs then
/// rest at the bounds). Reports the picked range via [onChanged]. The selected
/// endpoints are rendered above the track with [unit], matching the Figma
/// Dividend-yield mockup ("0% … 5%").
class CustomRangeSlider extends StatelessWidget {
  const CustomRangeSlider({
    super.key,
    required this.boundMin,
    required this.boundMax,
    required this.onChanged,
    this.min,
    this.max,
    this.unit = '',
  });

  final double boundMin;
  final double boundMax;
  final num? min;
  final num? max;
  final String unit;

  /// Reports the picked (min, max) on every drag.
  final void Function(num min, num max) onChanged;

  @override
  Widget build(BuildContext context) {
    // Guard against a degenerate range (boundMin == boundMax).
    final lo = boundMin;
    final hi = boundMax > boundMin ? boundMax : boundMin + 1;

    final start = (min?.toDouble() ?? lo).clamp(lo, hi);
    final end = (max?.toDouble() ?? hi).clamp(lo, hi);
    final values = RangeValues(start, end <= start ? hi : end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_fmt(values.start)}$unit',
              style: AppTextStyles.chipLabel.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${_fmt(values.end)}$unit',
              style: AppTextStyles.chipLabel.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SliderTheme(
          data: hollowSliderTheme(context),
          child: RangeSlider(
            values: values,
            min: lo,
            max: hi,
            onChanged: (range) => onChanged(range.start, range.end),
          ),
        ),
      ],
    );
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
