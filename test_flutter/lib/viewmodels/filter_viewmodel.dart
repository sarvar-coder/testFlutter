import 'package:flutter/foundation.dart';

import '../data/models/filter_config.dart';
import '../data/models/filter_state.dart';
import '../data/models/stock.dart';
import '../data/repositories/stock_repository.dart';

/// The heart of the MVVM layer: holds the filter config + dataset, the user's
/// current selections, and the live match count. Every mutation recomputes the
/// matched list and notifies listeners, so the count in the UI updates as the
/// user changes filters (the "count updates as filters change" sticky note).
class FilterViewModel extends ChangeNotifier {
  FilterViewModel(this._repository);

  final StockRepository _repository;

  FilterConfig? _config;
  FilterConfig? get config => _config;

  List<Stock> _allStocks = const [];

  FilterState _state = FilterState.empty();
  FilterState get state => _state;

  List<Stock> _matched = const [];

  /// The stocks currently passing all active filters (read by the results screen).
  List<Stock> get matched => _matched;

  /// Live count of matching stocks (read by the filter footer).
  int get matchCount => _matched.length;

  /// Whether any selection currently narrows results (drives the Search
  /// screen's "applied filter" state).
  bool get hasActiveFilters => _state.activeSectionKeys.isNotEmpty;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /// Load config + dataset, compute the initial (unfiltered) match set.
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _repository.loadFilterConfig(),
      _repository.loadStocks(),
    ]);
    _config = results[0] as FilterConfig;
    _allStocks = results[1] as List<Stock>;
    _state = FilterState.empty();
    _recompute();

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Mutators — each updates state, recomputes, and notifies.
  // ---------------------------------------------------------------------------

  /// Select a chip option. Picking the "All" option clears the section;
  /// picking a non-custom option clears any leftover custom range.
  void selectChip(String sectionKey, FilterOption option) {
    if (option.isAll) {
      _setSelection(sectionKey, null);
      return;
    }
    _setSelection(
      sectionKey,
      FilterSelection(
        optionLabel: option.label,
        customMin: option.custom ? _state.selectionFor(sectionKey)?.customMin : null,
        customMax: option.custom ? _state.selectionFor(sectionKey)?.customMax : null,
      ),
    );
  }

  /// Set the From/To values for a "Custom" chip selection.
  void setCustomRange(String sectionKey, {num? min, num? max}) {
    if (min == null && max == null) {
      _setSelection(sectionKey, null);
      return;
    }
    _setSelection(
      sectionKey,
      FilterSelection(optionLabel: 'Custom', customMin: min, customMax: max),
    );
  }

  /// Set the picked dropdown / searchable values. An empty list clears the
  /// section so it does not narrow results.
  void setDropdownValues(String sectionKey, List<String> values) {
    if (values.isEmpty) {
      _setSelection(sectionKey, null);
      return;
    }
    _setSelection(sectionKey, FilterSelection(dropdownValues: values));
  }

  /// Set a slider value. A value of 0 (the slider minimum) clears the section
  /// so it does not narrow results.
  void setSlider(String sectionKey, double value) {
    if (value <= 0) {
      _setSelection(sectionKey, null);
      return;
    }
    _setSelection(sectionKey, FilterSelection(sliderValue: value));
  }

  /// Reset every selection back to the unfiltered state.
  void clearAll() {
    _state = FilterState.empty();
    _recompute();
    notifyListeners();
  }

  /// Clear a single section's selection (backs the row's × button).
  void clearSection(String sectionKey) => _setSelection(sectionKey, null);

  void _setSelection(String sectionKey, FilterSelection? selection) {
    _state = _state.withSelection(sectionKey, selection);
    _recompute();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Matching engine.
  // ---------------------------------------------------------------------------

  /// Filter [_allStocks] against every active selection; sets [_matched].
  void _recompute() {
    final config = _config;
    if (config == null) {
      _matched = _allStocks;
      return;
    }

    // Map section key -> section for O(1) lookup of metric/type during matching.
    final sections = {for (final s in config.allSections) s.key: s};

    _matched = _allStocks.where((stock) {
      for (final key in _state.activeSectionKeys) {
        final section = sections[key];
        final selection = _state.selectionFor(key);
        if (section == null || selection == null) continue;
        if (!_passes(stock, section, selection)) return false;
      }
      return true;
    }).toList(growable: false);
  }

  /// Does [stock] satisfy one section's [selection]?
  bool _passes(Stock stock, FilterSection section, FilterSelection selection) {
    switch (section.type) {
      case FilterType.dropdown:
      case FilterType.searchable:
        final field = section.metric;
        if (field == null || selection.dropdownValues.isEmpty) return true;
        final cat = stock.category(field);
        return cat != null && selection.dropdownValues.contains(cat);

      case FilterType.slider:
        final metricKey = section.metric;
        final value = metricKey == null ? null : stock.metric(metricKey);
        if (value == null || selection.sliderValue == null) return true;
        // Slider acts as a minimum (e.g. dividend yield >= N%).
        return value >= selection.sliderValue!;

      case FilterType.chips:
        return _passesChip(stock, section, selection);

      case FilterType.unknown:
        return true;
    }
  }

  bool _passesChip(Stock stock, FilterSection section, FilterSelection selection) {
    final metricKey = section.metric;

    // "Custom" range chip.
    if (selection.optionLabel == 'Custom') {
      final value = metricKey == null ? null : stock.metric(metricKey);
      if (value == null) return true;
      if (selection.customMin != null && value < selection.customMin!) return false;
      if (selection.customMax != null && value > selection.customMax!) return false;
      return true;
    }

    // Find the chosen predefined option on the section.
    final option = section.options
        .where((o) => o.label == selection.optionLabel)
        .cast<FilterOption?>()
        .firstWhere((o) => o != null, orElse: () => null);
    if (option == null || option.isAll) return true;

    // String equality chips (e.g. SMA Over/Under).
    if (option.equals != null) {
      return metricKey != null && stock.category(metricKey) == option.equals;
    }

    // Numeric min/max chips.
    final value = metricKey == null ? null : stock.metric(metricKey);
    if (value == null) return true;
    if (option.min != null && value < option.min!) return false;
    if (option.max != null && value > option.max!) return false;
    return true;
  }
}
