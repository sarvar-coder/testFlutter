import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/filter_viewmodel.dart';
import 'filter_section_list.dart';

/// "Stock Filters" screen: pill tabs (Basic / Fundamental / Technical), the
/// config-driven section list per tab, and a pinned bottom bar with the live
/// match count plus Clear all / Apply.
class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key, this.onApply});

  /// Called when Apply is tapped. Defaults to popping back; Step 9 wires this
  /// to push the results screen.
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FilterViewModel>();
    final config = vm.config;

    if (config == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tabs = config.tabs;

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Stock Filters',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _PillTabBar(titles: [for (final t in tabs) t.title]),
            ),
          ),
        ),
        body: TabBarView(
          children: [for (final tab in tabs) FilterSectionList(tab: tab)],
        ),
        bottomNavigationBar: _BottomBar(
          onApply: onApply ?? () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

/// A row of independent pill chips: the selected tab is a solid black pill,
/// the others are white with a thin light-grey border.
class _PillTabBar extends StatelessWidget {
  const _PillTabBar({required this.titles});

  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (var i = 0; i < titles.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Flexible(
                fit: FlexFit.loose,
                child: _Pill(
                  label: titles[i],
                  selected: i == controller.index,
                  onTap: () => controller.animateTo(i),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// A single tappable, content-sized pill chip used by [_PillTabBar].
class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.black : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadii.tabBarPill),
          border: selected ? null : Border.all(color: AppColors.divider),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: AppTextStyles.chipLabel.copyWith(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pinned footer: "N stocks match your filters" + Clear all / Apply buttons.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FilterViewModel>();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: vm.clearAll,
                    style: TextButton.styleFrom(
                      backgroundColor: vm.hasActiveFilters
                          ? AppColors.black
                          : AppColors.clearAllInactive,
                      foregroundColor: vm.hasActiveFilters
                          ? Colors.white
                          : AppColors.textMuted,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.button),
                      ),
                    ),
                    child: const Text('Clear all'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApply,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
