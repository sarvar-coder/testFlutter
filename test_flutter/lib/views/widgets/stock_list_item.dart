import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/stock.dart';

/// A single stock row: circular logo icon + ticker + name.
///
/// Pure presentation — no logic. Every stock shares the same bundled logo
/// asset ([_logoAsset]).
class StockListItem extends StatelessWidget {
  const StockListItem({
    super.key,
    required this.stock,
    this.onTap,
  });

  final Stock stock;
  final VoidCallback? onTap;

  /// Shared logo shown for every stock.
  static const String _logoAsset = 'assets/images/adobe_icon.png';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: const CircleAvatar(
        radius: 22,
        backgroundColor: Colors.transparent,
        backgroundImage: AssetImage(_logoAsset),
      ),
      title: Text(
        stock.ticker,
        style: AppTextStyles.chipLabel.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        stock.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.countFooter,
      ),
    );
  }
}
