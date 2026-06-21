import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A multi-select picker opened as a bottom sheet.
///
/// Used by the filter rows: tapping a dropdown / searchable section calls
/// [MultiSelectPicker.show], which returns the chosen values (or `null` if the
/// sheet was dismissed without applying). When [searchable] is true the sheet
/// shows a search box that filters the options live.
class MultiSelectPicker {
  MultiSelectPicker._();

  static Future<List<String>?> show(
    BuildContext context, {
    required List<String> options,
    required List<String> selected,
    required String title,
    bool searchable = false,
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MultiSelectSheet(
        options: options,
        selected: selected,
        title: title,
        searchable: searchable,
      ),
    );
  }
}

class _MultiSelectSheet extends StatefulWidget {
  const _MultiSelectSheet({
    required this.options,
    required this.selected,
    required this.title,
    required this.searchable,
  });

  final List<String> options;
  final List<String> selected;
  final String title;
  final bool searchable;

  @override
  State<_MultiSelectSheet> createState() => _MultiSelectSheetState();
}

class _MultiSelectSheetState extends State<_MultiSelectSheet> {
  late final Set<String> _picked = widget.selected.toSet();
  String _query = '';

  void _toggle(String option) {
    setState(() {
      if (!_picked.remove(option)) _picked.add(option);
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.options
        : widget.options
            .where((o) => o.toLowerCase().contains(q))
            .toList(growable: false);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (widget.searchable)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  autofocus: true,
                  style: AppTextStyles.chipLabel,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.textMuted),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.chip),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final option in filtered)
                    CheckboxListTile(
                      value: _picked.contains(option),
                      onChanged: (_) => _toggle(option),
                      controlAffinity: ListTileControlAffinity.trailing,
                      fillColor:
                          WidgetStateProperty.all(Colors.transparent),
                      checkColor: AppColors.black,
                      side: WidgetStateBorderSide.resolveWith(
                        (_) => const BorderSide(
                          color: AppColors.textMuted,
                          width: 1.5,
                        ),
                      ),
                      title: Text(option, style: AppTextStyles.chipLabel),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_picked.toList(growable: false)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
