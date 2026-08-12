import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../catalog.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';
import '../widgets/ad_banner.dart';

class ResultsScreen extends StatefulWidget {
  final TripConfig trip;
  final ValueChanged<RideEntry> onSelect;
  final VoidCallback onBack;
  final List<FavoriteEntry> favorites;
  final void Function(RideEntry) onToggleFavorite;
  final Map<String, CompanyStats> companyStats;
  final String locale;
  final bool isRtl;

  const ResultsScreen({
    super.key, required this.trip, required this.onSelect, required this.onBack,
    required this.favorites, required this.onToggleFavorite, required this.companyStats,
    required this.locale, required this.isRtl,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String _sort = 'relevance';

  String tx(String key, [Map<String, String>? p]) => i18n.t(widget.locale, key, p);

  bool _isFav(RideEntry r) => widget.favorites.any((f) => f.type == 'route' && f.rideId == r.id);

  List<RideEntry> get _results {
    final target = minutesFrom(widget.trip.time);
    final all = catalog.where((r) => r.from == widget.trip.from && r.to == widget.trip.to && (minutesFrom(r.time) - target).abs() <= 90).toList();
    if (_sort == 'earliest') all.sort((a, b) => minutesFrom(a.time).compareTo(minutesFrom(b.time)));
    if (_sort == 'cheapest') all.sort((a, b) => a.priceDaily.compareTo(b.priceDaily));
    return all;
  }

  double _price(RideEntry r) {
    final f = widget.trip.frequency;
    if (f == 'weekly') return r.priceWeekly;
    if (f == 'monthly') return r.priceMonthly;
    return r.priceDaily;
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      backgroundColor: cSand,
      appBar: TopBar(title: tx('searchRides'), onBack: widget.onBack, isRtl: widget.isRtl),
      body: Column(
        children: [
          // Sort pills
          Container(
            color: cCard, height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                for (final s in ['relevance', 'earliest', 'cheapest'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _sort = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: _sort == s ? cNavy : cSand,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _sort == s ? cNavy : cLine),
                        ),
                        child: Text(tx(s), style: TextStyle(color: _sort == s ? Colors.white : cText, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  results.isEmpty ? tx('noResults') : tx('matchingCount', {'count': '${results.length}'}),
                  style: const TextStyle(color: cMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.directions_bus, size: 48, color: cLine),
                        const SizedBox(height: 12),
                        Text(tx('noResults'), style: const TextStyle(color: cText, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(tx('noResultsSub'), style: const TextStyle(color: cMuted, fontSize: 12), textAlign: TextAlign.center),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: results.length + 1,
                    itemBuilder: (ctx, i) {
                      if (i == 1) return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AdBannerWidget(
                          ad: const AdEntry(id: 'ad2', title: 'Arabia Transit — 20% off your first month', sponsor: 'Arabia Transit', grad: ['#E8A33D', '#C6821F']),
                          onTap: () {},
                        ),
                      );
                      final idx = i > 1 ? i - 1 : i;
                      if (idx >= results.length) return const SizedBox();
                      final r = results[idx];
                      return _rideCard(r);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _rideCard(RideEntry r) {
    final stats = ratingFor(r.company, widget.companyStats);
    final isFav = _isFav(r);
    final price = _price(r);
    final color = hexColor(r.colorHex);

    return GestureDetector(
      onTap: () => widget.onSelect(r),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cCard, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cLine),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 20, backgroundColor: color, child: Text(r.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.company, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cText)),
                      Row(children: [
                        const Icon(Icons.star, color: cGold, size: 12),
                        const SizedBox(width: 3),
                        Text('${stats.rating} (${stats.reviewCount})', style: const TextStyle(color: cMuted, fontSize: 11)),
                      ]),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.onToggleFavorite(r),
                  child: Icon(isFav ? Icons.favorite : Icons.favorite_outline, color: isFav ? cBrick : cMuted, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _badge(Icons.access_time, fmtTime(r.time), cNavy),
                const SizedBox(width: 8),
                _badge(Icons.timer_outlined, '${r.duration} ${tx('min')}', cMuted),
                const SizedBox(width: 8),
                _badge(Icons.event_seat, '${r.seatsLeft} ${tx('seatsLeft')}', r.seatsLeft <= 2 ? cBrick : cTeal),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('AED ${price.toStringAsFixed(0)}${tx('perDay')}', style: const TextStyle(color: cNavy, fontWeight: FontWeight.bold, fontSize: 15)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: cGold, borderRadius: BorderRadius.circular(8)),
                  child: Text(tx('bookNow'), style: const TextStyle(color: cNavy, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
