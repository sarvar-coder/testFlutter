// The user's current filter selections, keyed by section key.
//
// Kept separate from FilterConfig (which is static UI config): this is the
// mutable-but-copied value object the FilterViewModel holds and recomputes
// matches from.

/// One section's current selection.
///
/// Only the field(s) relevant to the section's type are populated:
/// - chips:      [optionLabel] (+ [customMin]/[customMax] when "Custom")
/// - dropdown/searchable: [dropdownValues] (one or more picked values)
/// - slider:     [sliderValue]
class FilterSelection {
  final String? optionLabel;
  final num? customMin;
  final num? customMax;
  final List<String> dropdownValues;
  final double? sliderValue;

  const FilterSelection({
    this.optionLabel,
    this.customMin,
    this.customMax,
    this.dropdownValues = const [],
    this.sliderValue,
  });

  /// `true` when this selection actually narrows results (not "All"/unset).
  bool get isActive {
    if (dropdownValues.isNotEmpty) return true;
    if (sliderValue != null) return true;
    if (optionLabel == null) return false;
    if (optionLabel == 'All') return false;
    return true;
  }

  FilterSelection copyWith({
    String? optionLabel,
    num? customMin,
    num? customMax,
    List<String>? dropdownValues,
    double? sliderValue,
  }) {
    return FilterSelection(
      optionLabel: optionLabel ?? this.optionLabel,
      customMin: customMin ?? this.customMin,
      customMax: customMax ?? this.customMax,
      dropdownValues: dropdownValues ?? this.dropdownValues,
      sliderValue: sliderValue ?? this.sliderValue,
    );
  }
}

/// All selections across the whole filter screen.
class FilterState {
  final Map<String, FilterSelection> bySection;

  const FilterState({this.bySection = const {}});

  /// Empty selection set (the "Clear all" / initial state).
  factory FilterState.empty() => const FilterState(bySection: {});

  FilterSelection? selectionFor(String sectionKey) => bySection[sectionKey];

  /// Whether a given section currently narrows results.
  bool isActive(String sectionKey) =>
      bySection[sectionKey]?.isActive ?? false;

  /// Sections that are currently active — what the matching engine iterates.
  Iterable<String> get activeSectionKeys =>
      bySection.entries.where((e) => e.value.isActive).map((e) => e.key);

  /// Return a copy with [selection] set for [sectionKey]. Passing `null`
  /// removes the selection for that section.
  FilterState withSelection(String sectionKey, FilterSelection? selection) {
    final next = Map<String, FilterSelection>.from(bySection);
    if (selection == null) {
      next.remove(sectionKey);
    } else {
      next[sectionKey] = selection;
    }
    return FilterState(bySection: next);
  }
}
