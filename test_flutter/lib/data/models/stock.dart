/// A single screenable stock with every metric the filters compare against.
///
/// String fields (sector/industry/region/exchange/shariah) are matched by
/// equality from dropdown/searchable filters. Numeric fields are matched by
/// min/max bounds from chip/slider filters and are exposed by [metric] so the
/// ViewModel can look a value up by the `metric` key declared in filters.json
/// (avoids a giant switch per filter).
class Stock {
  final String ticker;
  final String name;
  final String logoColor;

  // Categorical fields (equality matching).
  final String sector;
  final String industry;
  final String region;
  final String exchange;
  final String shariah;

  // Basic numeric metrics.
  final num marketCap;
  final num price;
  final num avgVolume3M;

  // Fundamental metrics.
  final num peRatio;
  final num psRatio;
  final num pbRatio;
  final num pcfRatio;
  final num roe;
  final num roa;
  final num roi;
  final num grossMargin;
  final num operatingMargin;
  final num netProfitMargin;
  final num revenueGrowth;
  final num epsGrowth;
  final num currentRatio;
  final num quickRatio;
  final num zScore;
  final num freeCashFlow;
  final num dividendYield;
  final num dividendGrowth5Y;

  // Technical metrics.
  final num priceChange1D;
  final num priceChange1M;
  final num priceChange3M;
  final num week52High;
  final num week52Low;
  final String sma50Position; // "over" | "under"
  final num sma50Distance; // % price is above(+)/below(-) the 50-day SMA
  final num sma150Distance;
  final num sma200Distance;
  final num beta;

  /// How far below the 52-week high the price sits, as a positive percent
  /// (0 = at the high). Used by the "52-week high" filter.
  num get pctFrom52WHigh =>
      week52High == 0 ? 0 : (week52High - price) / week52High * 100;

  /// How far above the 52-week low the price sits, as a positive percent
  /// (0 = at the low). Used by the "52-week low" filter.
  num get pctAbove52WLow =>
      week52Low == 0 ? 0 : (price - week52Low) / week52Low * 100;

  const Stock({
    required this.ticker,
    required this.name,
    required this.logoColor,
    required this.sector,
    required this.industry,
    required this.region,
    required this.exchange,
    required this.shariah,
    required this.marketCap,
    required this.price,
    required this.avgVolume3M,
    required this.peRatio,
    required this.psRatio,
    this.pbRatio = 0,
    this.pcfRatio = 0,
    required this.roe,
    this.roa = 0,
    this.roi = 0,
    this.grossMargin = 0,
    this.operatingMargin = 0,
    this.netProfitMargin = 0,
    required this.revenueGrowth,
    this.epsGrowth = 0,
    required this.currentRatio,
    this.quickRatio = 0,
    this.zScore = 0,
    this.freeCashFlow = 0,
    required this.dividendYield,
    this.dividendGrowth5Y = 0,
    required this.priceChange1D,
    this.priceChange1M = 0,
    this.priceChange3M = 0,
    this.week52High = 0,
    this.week52Low = 0,
    required this.sma50Position,
    this.sma50Distance = 0,
    this.sma150Distance = 0,
    this.sma200Distance = 0,
    required this.beta,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      ticker: json['ticker'] as String,
      name: json['name'] as String,
      logoColor: json['logoColor'] as String,
      sector: json['sector'] as String,
      industry: json['industry'] as String,
      region: json['region'] as String,
      exchange: json['exchange'] as String,
      shariah: json['shariah'] as String,
      marketCap: json['marketCap'] as num,
      price: json['price'] as num,
      avgVolume3M: json['avgVolume3M'] as num,
      peRatio: json['peRatio'] as num,
      psRatio: json['psRatio'] as num,
      pbRatio: (json['pbRatio'] as num?) ?? 0,
      pcfRatio: (json['pcfRatio'] as num?) ?? 0,
      roe: json['roe'] as num,
      roa: (json['roa'] as num?) ?? 0,
      roi: (json['roi'] as num?) ?? 0,
      grossMargin: (json['grossMargin'] as num?) ?? 0,
      operatingMargin: (json['operatingMargin'] as num?) ?? 0,
      netProfitMargin: (json['netProfitMargin'] as num?) ?? 0,
      revenueGrowth: json['revenueGrowth'] as num,
      epsGrowth: (json['epsGrowth'] as num?) ?? 0,
      currentRatio: json['currentRatio'] as num,
      quickRatio: (json['quickRatio'] as num?) ?? 0,
      zScore: (json['zScore'] as num?) ?? 0,
      freeCashFlow: (json['freeCashFlow'] as num?) ?? 0,
      dividendYield: json['dividendYield'] as num,
      dividendGrowth5Y: (json['dividendGrowth5Y'] as num?) ?? 0,
      priceChange1D: json['priceChange1D'] as num,
      priceChange1M: (json['priceChange1M'] as num?) ?? 0,
      priceChange3M: (json['priceChange3M'] as num?) ?? 0,
      week52High: (json['week52High'] as num?) ?? 0,
      week52Low: (json['week52Low'] as num?) ?? 0,
      sma50Position: json['sma50Position'] as String,
      sma50Distance: (json['sma50Distance'] as num?) ?? 0,
      sma150Distance: (json['sma150Distance'] as num?) ?? 0,
      sma200Distance: (json['sma200Distance'] as num?) ?? 0,
      beta: json['beta'] as num,
    );
  }

  /// Look up a numeric metric by the `metric` key used in filters.json.
  /// Returns `null` for non-numeric / unknown keys.
  num? metric(String key) {
    switch (key) {
      case 'marketCap':
        return marketCap;
      case 'price':
        return price;
      case 'avgVolume3M':
        return avgVolume3M;
      case 'peRatio':
        return peRatio;
      case 'psRatio':
        return psRatio;
      case 'pbRatio':
        return pbRatio;
      case 'pcfRatio':
        return pcfRatio;
      case 'roe':
        return roe;
      case 'roa':
        return roa;
      case 'roi':
        return roi;
      case 'grossMargin':
        return grossMargin;
      case 'operatingMargin':
        return operatingMargin;
      case 'netProfitMargin':
        return netProfitMargin;
      case 'revenueGrowth':
        return revenueGrowth;
      case 'epsGrowth':
        return epsGrowth;
      case 'currentRatio':
        return currentRatio;
      case 'quickRatio':
        return quickRatio;
      case 'zScore':
        return zScore;
      case 'freeCashFlow':
        return freeCashFlow;
      case 'dividendYield':
        return dividendYield;
      case 'dividendGrowth5Y':
        return dividendGrowth5Y;
      case 'priceChange1D':
        return priceChange1D;
      case 'priceChange1M':
        return priceChange1M;
      case 'priceChange3M':
        return priceChange3M;
      case 'pctFrom52WHigh':
        return pctFrom52WHigh;
      case 'pctAbove52WLow':
        return pctAbove52WLow;
      case 'sma50Distance':
        return sma50Distance;
      case 'sma150Distance':
        return sma150Distance;
      case 'sma200Distance':
        return sma200Distance;
      case 'beta':
        return beta;
      default:
        return null;
    }
  }

  /// Look up a categorical (string) value by key — for `equals` chips and
  /// dropdown/searchable matching.
  String? category(String key) {
    switch (key) {
      case 'sector':
        return sector;
      case 'industry':
        return industry;
      case 'region':
        return region;
      case 'exchange':
        return exchange;
      case 'shariah':
        return shariah;
      case 'sma50Position':
        return sma50Position;
      default:
        return null;
    }
  }
}
