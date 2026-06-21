import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/filter_config.dart';
import '../../data/models/filter_state.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/filter_viewmodel.dart';
import '../widgets/chip_selector.dart';
import '../widgets/collapsible_section.dart';
import '../widgets/custom_range_slider.dart';
import '../widgets/filter_row.dart';
import '../widgets/range_slider_filter.dart';
import '../widgets/searchable_dropdown.dart';

/// Renders one tab (Basic / Fundamental / Technical) entirely from config.
///
/// The three tabs share this single widget — each section's [FilterType] maps
/// to the right input widget, and group headers come from `section.group`.
/// Expand/collapse state is local UI state; all selection state lives in
/// [FilterViewModel].
class FilterSectionList extends StatefulWidget {
  const FilterSectionList({super.key, required this.tab});

  final FilterTab tab;

  @override
  State<FilterSectionList> createState() => _FilterSectionListState();
}

class _FilterSectionListState extends State<FilterSectionList> {
  /// Only the Basic tab uses the new collapsed summary-row design; the other
  /// tabs keep the original expand/collapse tiles.
  late final bool _isBasic = widget.tab.key == 'basic';

  /// Fundamental groups its parameters under collapsible category rows
  /// (Valuation, Profitability, …) as a two-level accordion.
  late final bool _isFundamental = widget.tab.key == 'fundamental';

  /// Technical uses the same two-level accordion as Fundamental, but its
  /// single-section groups (e.g. Beta) render as a standalone summary row.
  late final bool _isTechnical = widget.tab.key == 'technical';

  /// Sections currently expanded inline. Basic starts collapsed (summary list)
  /// and Fundamental / Technical params start collapsed inside their groups;
  /// any other tab starts fully expanded (original behavior).
  late final Set<String> _expanded = (_isBasic || _isFundamental || _isTechnical)
      ? {}
      : widget.tab.sections.map((s) => s.key).toSet();

  /// Expanded category rows (Fundamental only); all start collapsed.
  final Set<String> _expandedGroups = {};

  void _toggle(String key) {
    setState(() {
      if (!_expanded.remove(key)) _expanded.add(key);
    });
  }

  void _toggleGroup(String group) {
    setState(() {
      if (!_expandedGroups.remove(group)) _expandedGroups.add(group);
    });
  }

  /// Sections grouped by their `group` field, preserving first-seen order
  /// (Dart maps keep insertion order). Falls back to the section title for
  /// ungrouped sections.
  List<MapEntry<String, List<FilterSection>>> _groupedSections() {
    final groups = <String, List<FilterSection>>{};
    for (final s in widget.tab.sections) {
      groups.putIfAbsent(s.group ?? s.title, () => []).add(s);
    }
    return groups.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FilterViewModel>();

    if (_isFundamental || _isTechnical) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final entry in _groupedSections())
            // A group with a single section (e.g. Technical's Beta) renders as a
            // standalone summary row rather than a redundant accordion layer.
            if (entry.value.length == 1)
              _row(context, vm, entry.value.first)
            else
              CollapsibleSection(
                title: entry.key,
                expanded: _expandedGroups.contains(entry.key),
                active: entry.value.any((s) => vm.state.isActive(s.key)),
                onToggle: () => _toggleGroup(entry.key),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < entry.value.length; i++)
                      _row(context, vm, entry.value[i],
                          showDivider: i < entry.value.length - 1),
                  ],
                ),
              ),
          const SizedBox(height: 16),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (var i = 0; i < widget.tab.sections.length; i++) ...[
          _maybeGroupHeader(i),
          if (_isBasic)
            _row(context, vm, widget.tab.sections[i])
          else
            CollapsibleSection(
              title: widget.tab.sections[i].title,
              expanded: _expanded.contains(widget.tab.sections[i].key),
              active: vm.state.isActive(widget.tab.sections[i].key),
              onToggle: () => _toggle(widget.tab.sections[i].key),
              child: _input(context, vm, widget.tab.sections[i]),
            ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  /// Build one section's summary row (Basic tab). Chips / slider sections expand
  /// inline; dropdown / searchable sections open a multi-select picker on tap.
  Widget _row(
    BuildContext context,
    FilterViewModel vm,
    FilterSection section, {
    bool showDivider = true,
  }) {
    final selection = vm.state.selectionFor(section.key);
    final active = vm.state.isActive(section.key);
    final isPicker = section.type == FilterType.dropdown ||
        section.type == FilterType.searchable;

    return FilterRow(
      title: section.title,
      valueText: _summary(section, selection) ?? (section.placeholder ?? 'All'),
      active: active,
      onClear: active ? () => vm.clearSection(section.key) : null,
      expanded: !isPicker && _expanded.contains(section.key),
      showDivider: showDivider,
      onTap: isPicker
          ? () => _openPicker(context, vm, section, selection)
          : () => _toggle(section.key),
      child: isPicker ? null : _input(context, vm, section),
    );
  }

  Future<void> _openPicker(
    BuildContext context,
    FilterViewModel vm,
    FilterSection section,
    FilterSelection? selection,
  ) async {
    final result = await MultiSelectPicker.show(
      context,
      options: [for (final o in section.options) o.label],
      selected: selection?.dropdownValues ?? const [],
      title: section.title,
      searchable: section.type == FilterType.searchable,
    );
    if (result != null) vm.setDropdownValues(section.key, result);
  }

  /// The right-side summary text for a row, or null when the section is
  /// inactive (the row then shows the muted "All" placeholder).
  String? _summary(FilterSection section, FilterSelection? selection) {
    if (selection == null || !selection.isActive) return null;
    switch (section.type) {
      case FilterType.chips:
        return selection.optionLabel;
      case FilterType.dropdown:
      case FilterType.searchable:
        return _joinValues(selection.dropdownValues);
      case FilterType.slider:
        final value = selection.sliderValue;
        if (value == null) return null;
        return '${_fmtNum(value)}${section.unit ?? ''}';
      case FilterType.unknown:
        return null;
    }
  }

  /// Join picked values, collapsing the overflow into a "+N" suffix
  /// (e.g. "Technology, Energy +2").
  String _joinValues(List<String> values, {int head = 2}) {
    if (values.length <= head) return values.join(', ');
    return '${values.take(head).join(', ')} +${values.length - head}';
  }

  String _fmtNum(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  /// A group header (e.g. "Valuation") shown when this section starts a new
  /// group, matching the Fundamental / Technical layout.
  Widget _maybeGroupHeader(int index) {
    final section = widget.tab.sections[index];
    final group = section.group;
    if (group == null) return const SizedBox.shrink();
    final prev = index == 0 ? null : widget.tab.sections[index - 1].group;
    if (group == prev) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Text(
        group.toUpperCase(),
        style: AppTextStyles.countFooter.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Map a section's type to the matching input widget.
  Widget _input(BuildContext context, FilterViewModel vm, FilterSection section) {
    final selection = vm.state.selectionFor(section.key);
    switch (section.type) {
      case FilterType.chips:
        return _chips(vm, section, selection);

      case FilterType.dropdown:
      case FilterType.searchable:
        // Rendered via the multi-select picker on row tap, not inline.
        return const SizedBox.shrink();

      case FilterType.slider:
        final min = (section.min ?? 0).toDouble();
        final max = (section.max ?? 100).toDouble();
        return RangeSliderFilter(
          value: selection?.sliderValue ?? min,
          min: min,
          max: max,
          unit: section.unit ?? '',
          onChanged: (value) => vm.setSlider(section.key, value),
        );

      case FilterType.unknown:
        return const SizedBox.shrink();
    }
  }

  /// Chip row, plus the From/To fields when the "Custom" chip is selected.
  Widget _chips(
    FilterViewModel vm,
    FilterSection section,
    FilterSelection? selection,
  ) {
    // Default to highlighting the "All" chip when nothing is picked yet.
    final selectedLabel = selection?.optionLabel ?? 'All';
    final customSelected = section.options.any(
      (o) => o.custom && o.label == selectedLabel,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChipSelector(
          options: section.options,
          selectedLabel: selectedLabel,
          onSelected: (option) => vm.selectChip(section.key, option),
        ),
        if (customSelected) ...[
          const SizedBox(height: 12),
          CustomRangeSlider(
            boundMin: (section.min ?? 0).toDouble(),
            boundMax: (section.max ?? 100).toDouble(),
            unit: section.unit ?? '',
            min: selection?.customMin,
            max: selection?.customMax,
            onChanged: (min, max) =>
                vm.setCustomRange(section.key, min: min, max: max),
          ),
        ],
      ],
    );
  }
}
