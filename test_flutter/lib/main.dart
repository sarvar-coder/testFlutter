import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/models/stock.dart';
import 'data/repositories/stock_repository.dart';
import 'viewmodels/filter_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'views/search/search_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload the full stock list once so the Search screen has data immediately;
  // FilterViewModel loads its own copy (+ the filter config) during init().
  const repository = StockRepository();
  final stocks = await repository.loadStocks();

  runApp(StockScreenerApp(repository: repository, allStocks: stocks));
}

class StockScreenerApp extends StatelessWidget {
  const StockScreenerApp({
    super.key,
    required this.repository,
    required this.allStocks,
  });

  final StockRepository repository;
  final List<Stock> allStocks;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FilterViewModel(repository)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(allStocks),
        ),
      ],
      child: MaterialApp(
        title: 'Stock Screener',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _Root(),
      ),
    );
  }
}

/// Gates the app on the FilterViewModel's initial load: shows a spinner until
/// the filter config + dataset are ready, then the Search screen.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<FilterViewModel, bool>((vm) => vm.isLoading);
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const SearchScreen();
  }
}
