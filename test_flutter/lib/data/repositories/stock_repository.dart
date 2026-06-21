import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/filter_config.dart';
import '../models/stock.dart';

/// Loads the static stock dataset and the filter configuration from bundled
/// JSON assets. No API — everything comes from `assets/mock/`.
class StockRepository {
  const StockRepository();

  static const String _stocksAsset = 'assets/mock/stocks.json';
  static const String _filtersAsset = 'assets/mock/filters.json';

  /// Read every stock row from `stocks.json`.
  Future<List<Stock>> loadStocks() async {
    final raw = await rootBundle.loadString(_stocksAsset);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Stock.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Read the tab/section/option filter tree from `filters.json`.
  Future<FilterConfig> loadFilterConfig() async {
    final raw = await rootBundle.loadString(_filtersAsset);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return FilterConfig.fromJson(decoded);
  }
}
