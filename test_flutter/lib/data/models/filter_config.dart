// Data-driven filter configuration parsed from `assets/mock/filters.json`.
//
// Shape: FilterConfig -> tabs[] -> sections[] -> options[]. The views render
// the filter UI straight from this tree, so adding a filter is a JSON edit
// rather than a code change.

/// The kind of input a section renders.
enum FilterType { chips, dropdown, searchable, slider, unknown }

FilterType _parseType(String? raw) {
  switch (raw) {
    case 'chips':
      return FilterType.chips;
    case 'dropdown':
      return FilterType.dropdown;
    case 'searchable':
      return FilterType.searchable;
    case 'slider':
      return FilterType.slider;
    default:
      return FilterType.unknown;
  }
}

/// One selectable option inside a `chips` section.
///
/// Matching semantics (see FilterViewModel): a value passes when it satisfies
/// every present bound — `>= min`, `<= max`, `== equals`. [custom] marks the
/// "Custom" chip that reveals From/To inputs.
class FilterOption {
  final String label;
  final num? min;
  final num? max;
  final String? equals;
  final bool custom;

  const FilterOption({
    required this.label,
    this.min,
    this.max,
    this.equals,
    this.custom = false,
  });

  /// The "All" / unbounded option that always passes.
  bool get isAll => min == null && max == null && equals == null && !custom;

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      label: json['label'] as String,
      min: json['min'] as num?,
      max: json['max'] as num?,
      equals: json['equals'] as String?,
      custom: (json['custom'] as bool?) ?? false,
    );
  }
}

/// One filter section (a row in a tab), e.g. "Market cap" or "P/E ratio".
class FilterSection {
  final String key;
  final String title;

  /// Optional UI grouping header (e.g. "Valuation", "Profitability").
  final String? group;

  final FilterType type;

  /// Numeric metric key on [Stock] this section filters (chips/slider).
  /// For dropdown/searchable this doubles as the categorical field key.
  final String? metric;

  /// Slider bounds + unit (only for `slider` type).
  final num? min;
  final num? max;
  final String? unit;

  /// Default value text shown on the row when nothing is selected. Falls back
  /// to "All" when null (e.g. the Region row uses "Global").
  final String? placeholder;

  final List<FilterOption> options;

  const FilterSection({
    required this.key,
    required this.title,
    required this.type,
    this.group,
    this.metric,
    this.min,
    this.max,
    this.unit,
    this.placeholder,
    this.options = const [],
  });

  factory FilterSection.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>?;
    return FilterSection(
      key: json['key'] as String,
      title: json['title'] as String,
      group: json['group'] as String?,
      type: _parseType(json['type'] as String?),
      metric: json['metric'] as String?,
      min: json['min'] as num?,
      max: json['max'] as num?,
      unit: json['unit'] as String?,
      placeholder: json['placeholder'] as String?,
      options: rawOptions == null
          ? const []
          : rawOptions
              .map((e) => _optionFrom(e))
              .toList(growable: false),
    );
  }

  /// Options come either as plain strings (dropdown/searchable) or objects
  /// (chips). Normalize both into [FilterOption].
  static FilterOption _optionFrom(dynamic e) {
    if (e is String) return FilterOption(label: e);
    return FilterOption.fromJson(e as Map<String, dynamic>);
  }
}

/// One tab: Basic / Fundamental / Technical.
class FilterTab {
  final String key;
  final String title;
  final List<FilterSection> sections;

  const FilterTab({
    required this.key,
    required this.title,
    required this.sections,
  });

  factory FilterTab.fromJson(Map<String, dynamic> json) {
    return FilterTab(
      key: json['key'] as String,
      title: json['title'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map((e) => FilterSection.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

/// Root of the filter configuration.
class FilterConfig {
  final List<FilterTab> tabs;

  const FilterConfig({required this.tabs});

  /// Flatten all sections across tabs — handy for the matching engine.
  List<FilterSection> get allSections =>
      [for (final tab in tabs) ...tab.sections];

  factory FilterConfig.fromJson(Map<String, dynamic> json) {
    return FilterConfig(
      tabs: (json['tabs'] as List<dynamic>)
          .map((e) => FilterTab.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
