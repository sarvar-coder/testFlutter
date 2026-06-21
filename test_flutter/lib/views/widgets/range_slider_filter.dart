import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'hollow_slider_shapes.dart';

/// A single-value slider (e.g. Dividend yield 0%–5%) acting as a minimum.
///
/// Dumb widget: reports the live value via [onChanged]. Min/max labels and the
/// current value (with [unit]) are rendered above the track.
class RangeSliderFilter extends StatelessWidget {
  const RangeSliderFilter({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.unit = '',
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(min, max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_fmt(min)}$unit', style: AppTextStyles.countFooter),
            Text(
              '${_fmt(clamped)}$unit',
              style: AppTextStyles.chipLabel.copyWith(fontWeight: FontWeight.w600),
            ),
            Text('${_fmt(max)}$unit', style: AppTextStyles.countFooter),
          ],
        ),
        SliderTheme(
          data: hollowSliderTheme(context),
          child: Slider(
            value: clamped,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
