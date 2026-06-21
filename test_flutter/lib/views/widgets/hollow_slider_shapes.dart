import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Shared visual tuning for the hollow-thumb slider style.
const double _thumbRadius = 11;
const double _thumbBorder = 2;
const double _trackHeight = 2;

/// A [SliderThemeData] giving the thin black track + hollow circular thumbs
/// look (white fill, black outline) used across the filter sliders.
SliderThemeData hollowSliderTheme(BuildContext context) {
  return SliderTheme.of(context).copyWith(
    trackHeight: _trackHeight,
    activeTrackColor: AppColors.black,
    inactiveTrackColor: AppColors.black,
    overlayShape: SliderComponentShape.noOverlay,
    thumbShape: const _HollowThumbShape(),
    rangeThumbShape: const _HollowRangeThumbShape(),
  );
}

void _paintHollowThumb(Canvas canvas, Offset center) {
  final fill = Paint()
    ..color = AppColors.background
    ..style = PaintingStyle.fill;
  final border = Paint()
    ..color = AppColors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = _thumbBorder;
  // Inset the stroke by half its width so the outline isn't clipped.
  final r = _thumbRadius - _thumbBorder / 2;
  canvas.drawCircle(center, r, fill);
  canvas.drawCircle(center, r, border);
}

/// Hollow thumb for a single-value [Slider].
class _HollowThumbShape extends SliderComponentShape {
  const _HollowThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    _paintHollowThumb(context.canvas, center);
  }
}

/// Hollow thumb for a two-thumb [RangeSlider].
class _HollowRangeThumbShape extends RangeSliderThumbShape {
  const _HollowRangeThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool isPressed = false,
  }) {
    _paintHollowThumb(context.canvas, center);
  }
}
