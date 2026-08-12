import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../catalog.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';

class TrendingScreen extends StatelessWidget {
  final Map<String, CompanyStats> companyStats;
  final VoidCallback onBack;
  final void Function(RideEntry) onPick;
  final bool Function(RideEntry) isFav;
  final void Function(RideEntry) onToggleFav;
  final String locale;
  final bool isRtl;

  const TrendingScreen({
    super.key, required this.companyStats, required this.onBack,
    required this.onPick, required this.isFav, required this.onToggleFav,
    required this.locale, required this.isRtl,
  });

  String tx(String key, [Map<String, String>? p]) => i18n.t(locale, key, p);

  @override
  Widget build(BuildContext context) {
    final items = trending;
    return Scaffold(
      backgroundColor: cSand,
      appBar: TopBar(title: tx('trending'), onBack: onBack, isRtl: isRtl),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final r = items[i];
          final stats = ratingFor(r.company, companyStats);
          final fav = isFav(r);
          final color = hexColor(r.colorHex);
          return GestureDetector(
            onTap: () => onPick(r),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: cLine)),
              child: Row(children: [
                Stack(children: [
                  CircleAvatar(radius: 22, backgroundColor: color,
                    child: Text(r.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  if (i == 0) Positioned(right: -2, top: -2,
                    child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: cGold, shape: BoxShape.circle),
                      child: const Center(child: Text('★', style: TextStyle(color: cNavy, fontSize: 9, fontWeight: FontWeight.bold))))),
                ]),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.company, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cText)),
                  Text('${r.from} → ${r.to}', style: const TextStyle(color: cMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.access_time, size: 11, color: cMuted), const SizedBox(width: 3),
                    Text(fmtTime(r.time), style: const TextStyle(color: cNavy, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, size: 11, color: cGold), const SizedBox(width: 3),
                    Text('${stats.rating}', style: const TextStyle(color: cMuted, fontSize: 11)),
                    const SizedBox(width: 8),
                    const Icon(Icons.bar_chart, size: 11, color: cTeal), const SizedBox(width: 3),
                    Text(tx('bookedThisWeek', {'count': '${r.bookings}'}), style: const TextStyle(color: cMuted, fontSize: 11)),
                  ]),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  GestureDetector(onTap: () => onToggleFav(r),
                    child: Icon(fav ? Icons.favorite : Icons.favorite_outline, color: fav ? cBrick : cMuted, size: 18)),
                  const SizedBox(height: 6),
                  Text('AED ${r.priceMonthly.toStringAsFixed(0)}/mo', style: const TextStyle(color: cNavy, fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
              ]),
            ),
          );
        },
      ),
    );
  }
}
