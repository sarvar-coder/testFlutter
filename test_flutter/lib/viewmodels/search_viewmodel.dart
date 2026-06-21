import 'package:flutter/foundation.dart';

import '../data/models/stock.dart';

/// Drives the search field on the Search screen and the "search within a
/// filtered list" box on the Results screen.
///
/// It searches over whatever source list it's given via [setSource]:
/// the full stock list (Search screen) or the FilterViewModel's matched list
/// (Results screen). With an empty query it surfaces [source] unchanged.
class SearchViewModel extends ChangeNotifier {
  SearchViewModel([List<Stock> source = const []]) : _source = source;

  List<Stock> _source;
  String _query = '';
  List<Stock> _results = const [];
  bool _filtered = false;

  String get query => _query;

  /// Stocks matching the current query (or the full source when query is empty).
  List<Stock> get results => _query.isEmpty ? _source : _results;

  /// Whether the current source is a filtered (matched) set rather than the
  /// full stock list — drives the Search screen's "applied filter" state.
  bool get filtered => _filtered;

  /// Size of the source list, i.e. the matched count. Stable regardless of the
  /// in-list query, so it backs the "N stocks match your filters" header.
  int get sourceCount => _source.length;

  /// Replace the list being searched (e.g. when the matched set changes) and
  /// re-apply the current query. Pass [filtered] true when [source] is a
  /// filtered subset so the UI can reflect the applied-filter state.
  void setSource(List<Stock> source, {bool filtered = false}) {
    _source = source;
    _filtered = filtered;
    _applyQuery();
    notifyListeners();
  }

  /// Update the query and recompute matches (case-insensitive, ticker or name).
  void setQuery(String value) {
    final next = value.trim();
    if (next == _query) return;
    _query = next;
    _applyQuery();
    notifyListeners();
  }

  /// Clear the query, falling back to the full source list.
  void clear() {
    if (_query.isEmpty) return;
    _query = '';
    _results = const [];
    notifyListeners();
  }

  void _applyQuery() {
    if (_query.isEmpty) {
      _results = const [];
      return;
    }
    final q = _query.toLowerCase();
    _results = _source
        .where((s) =>
            s.ticker.toLowerCase().contains(q) ||
            s.name.toLowerCase().contains(q))
        .toList(growable: false);
  }
}
