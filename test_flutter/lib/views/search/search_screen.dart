import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/stock.dart';
import '../../viewmodels/filter_viewmodel.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../filters/filter_screen.dart';
import '../widgets/stock_list_item.dart';

/// The app's start screen: a search field over the full stock list plus a
/// Filter action that opens the Stock Filters screen.
///
/// A row of category tabs (All / Stocks / News&Insights / Investors) sits under
/// the search field. Only stock data exists, so All and Stocks show the stock
/// list while News&Insights and Investors show an empty placeholder.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _tabs = ['All', 'Stocks', 'News&Insights', 'Investors'];

  int _selectedTab = 0;

  /// Whether the current tab is backed by stock data (All / Stocks).
  bool get _showsStocks => _selectedTab == 0 || _selectedTab == 1;

  Future<void> _openFilters(BuildContext context) async {
    final filterVM = context.read<FilterViewModel>();
    final searchVM = context.read<SearchViewModel>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // allow a near-full-height sheet
      useSafeArea: true, // respect status bar / notch at the top
      backgroundColor: AppColors.transparent, // let our rounded sheet show
      builder: (sheetContext) => Stack(
        children: [
          // Frosted-glass backdrop over the whole screen; tap to dismiss.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(sheetContext).maybePop(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                // Faint light wash so the blurred content reads as "behind".
                child: const ColoredBox(color: Color(0x0DFFFFFF)),
              ),
            ),
          ),
          // The sheet, anchored to the bottom. Drag the handle/sheet down to
          // close.
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Dismissible(
              key: const ValueKey('filter-sheet'),
              direction: DismissDirection.down,
              onDismissed: (_) => Navigator.of(sheetContext).maybePop(),
              child: FractionallySizedBox(
                heightFactor: 0.96,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadii.sheet),
                  ),
                  child: ColoredBox(
                    color: AppColors.background,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _DragHandle(),
                        Expanded(
                          child: FilterScreen(
                            // Apply just closes the sheet; the post-await sync
                            // below commits the current filter state onto the
                            // Search screen.
                            onApply: () => Navigator.of(sheetContext).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ),
          ),
        ],
      ),
    );

    // After the sheet closes by any means (Apply, back, or drag-to-dismiss),
    // reflect the current filter state on the Search screen so the green Filter
    // button and filtered list stay in sync — e.g. Clear all + back clears it.
    searchVM.setSource(
      filterVM.matched,
      filtered: filterVM.hasActiveFilters,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();
    final results = vm.results;
    final hasQuery = vm.query.isNotEmpty;
    final filtered = vm.filtered;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          SvgPicture.asset(
            AppIcons.chevronLeft,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Search',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.0,),
          )
        ],),
        actions: [
          TextButton.icon(
            onPressed: () => _openFilters(context),
            label: const Text(
              'Filter',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.0,),
            ),
            icon: SvgPicture.asset(
              AppIcons.filter,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                filtered ? AppColors.filterActive : AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
            iconAlignment: IconAlignment.end,
            style: TextButton.styleFrom(
              foregroundColor:
                  filtered ? AppColors.filterActive : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _SearchField(
              onChanged: vm.setQuery,
              onClear: vm.clear,
              showClear: hasQuery,
            ),
          ),
          _CategoryTabs(
            tabs: _tabs,
            selectedIndex: _selectedTab,
            onSelected: (i) => setState(() => _selectedTab = i),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _showsStocks
                ? _StockResults(
                    results: results,
                    hasQuery: hasQuery,
                    filtered: filtered,
                    matchCount: vm.sourceCount,
                  )
                : _EmptyState(message: 'No ${_tabs[_selectedTab].toLowerCase()} yet'),
          ),
        ],
      ),
    );
  }
}

/// The stock list portion shown on the All / Stocks tabs: a section header plus
/// the matching rows, or the empty placeholder when nothing matches.
class _StockResults extends StatelessWidget {
  const _StockResults({
    required this.results,
    required this.hasQuery,
    required this.filtered,
    required this.matchCount,
  });

  final List<Stock> results;
  final bool hasQuery;

  /// Whether a filter is currently applied (drives the count header).
  final bool filtered;

  /// Total matched count, shown in the "N stocks match your filters" header.
  final int matchCount;

  @override
  Widget build(BuildContext context) {
    // When unfiltered with nothing matching, keep the bare empty state.
    if (results.isEmpty && !filtered) {
      return const _EmptyState(message: 'No stocks found');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: filtered
              ? Text(
                  '$matchCount stocks match your filters',
                  style: AppTextStyles.sectionTitle,
                )
              : Text(
                  hasQuery ? 'Results' : 'Popular stocks',
                  style: AppTextStyles.countFooter.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: results.isEmpty
              ? const _EmptyState(message: 'No stocks found')
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, i) => StockListItem(stock: results[i]),
                ),
        ),
      ],
    );
  }
}

/// Horizontal row of category tabs. The selected tab is a black pill with white
/// text; the rest are plain muted-grey labels (matches the design).
class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Padding(
              padding: EdgeInsets.only(right: i == tabs.length - 1 ? 0 : 8),
              child: _Tab(
                label: tabs[i],
                selected: i == selectedIndex,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.black : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: AppTextStyles.chipLabel.copyWith(
              color: selected ? Colors.white : AppColors.textMuted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Grey grabber pill shown at the top of the filter bottom sheet, signalling
/// that the sheet can be dragged down to dismiss.
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.dragHandle,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.onChanged,
    required this.onClear,
    required this.showClear,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool showClear;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: AppTextStyles.chipLabel,
      decoration: InputDecoration(
        hintText: 'Search stocks, investors, or news',
        hintStyle: AppTextStyles.chipLabel.copyWith(color: AppColors.textMuted),
        // prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
        suffixIcon: widget.showClear
            ? IconButton(
                icon: SvgPicture.asset(
                  AppIcons.xMarkCircle,
                  width: 20,
                  height: 20,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onClear();
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.searchFieldBackground,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.chip),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: AppTextStyles.countFooter,
      ),
    );
  }
}
