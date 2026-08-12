import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../catalog.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';

class CompanyDetailScreen extends StatefulWidget {
  final CompanyEntry company;
  final Map<String, CompanyStats> companyStats;
  final VoidCallback onBack;
  final void Function(RideEntry) onPickRoute;
  final String locale;
  final bool isRtl;
  final bool isCompanyFav;
  final VoidCallback onToggleCompanyFav;
  final bool Function(RideEntry) isRouteFav;
  final void Function(RideEntry) onToggleRouteFav;

  const CompanyDetailScreen({
    super.key, required this.company, required this.companyStats,
    required this.onBack, required this.onPickRoute,
    required this.locale, required this.isRtl,
    required this.isCompanyFav, required this.onToggleCompanyFav,
    required this.isRouteFav, required this.onToggleRouteFav,
  });

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  bool _showFleet = false;
  String? _sortMode;

  String tx(String key, [Map<String, String>? p]) => i18n.t(widget.locale, key, p);

  List<RideEntry> get _sortedRoutes {
    final list = [...widget.company.routes];
    if (_sortMode == 'nearest') list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    if (_sortMode == 'departure') list.sort((a, b) => minutesFrom(a.time).compareTo(minutesFrom(b.time)));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.company;
    final stats = ratingFor(c.name, widget.companyStats);
    final color = hexColor(c.colorHex);
    final fleet = fleetData[c.name] ?? [];

    return Scaffold(
      backgroundColor: cSand,
      appBar: TopBar(
        title: c.name,
        onBack: widget.onBack,
        isRtl: widget.isRtl,
        trailing: IconButton(
          icon: Icon(widget.isCompanyFav ? Icons.favorite : Icons.favorite_outline,
            color: widget.isCompanyFav ? cBrick : Colors.white, size: 20),
          onPressed: widget.onToggleCompanyFav,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: cLine)),
              child: Row(children: [
                CircleAvatar(radius: 28, backgroundColor: color,
                  child: Text(c.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: cText)),
                  Text(c.tagline, style: const TextStyle(color: cMuted, fontSize: 12), maxLines: 2),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.star, color: cGold, size: 13),
                    const SizedBox(width: 3),
                    Text('${stats.rating} (${stats.reviewCount})', style: const TextStyle(color: cMuted, fontSize: 12)),
                    const SizedBox(width: 10),
                    const Icon(Icons.directions_bus, size: 13, color: cMuted),
                    const SizedBox(width: 3),
                    Text('${c.fleetSize} ${tx('fleetSize')}', style: const TextStyle(color: cMuted, fontSize: 12)),
                  ]),
                ])),
              ]),
            ),
            const SizedBox(height: 14),
            // Fleet toggle
            GestureDetector(
              onTap: () => setState(() => _showFleet = !_showFleet),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: cLine)),
                child: Row(children: [
                  const Icon(Icons.directions_bus, color: cNavy, size: 18),
                  const SizedBox(width: 10),
                  Text(tx('fleetScheduleTitle'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cText)),
                  const Spacer(),
                  Icon(_showFleet ? Icons.expand_less : Icons.expand_more, color: cMuted),
                ]),
              ),
            ),
            if (_showFleet) ...[
              const SizedBox(height: 8),
              for (final bus in fleet)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: cLine)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(bus.busNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cText)),
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: cSand, borderRadius: BorderRadius.circular(6)),
                        child: Text(bus.vehicleType, style: const TextStyle(color: cMuted, fontSize: 11))),
                      const Spacer(),
                      Text('${bus.seatsAvailable} ${tx('seatsAvailableLabel')}', style: const TextStyle(color: cTeal, fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, children: bus.timings.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: cNavy.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                      child: Text(fmtTime(t), style: const TextStyle(color: cNavy, fontSize: 11, fontWeight: FontWeight.w600)),
                    )).toList()),
                  ]),
                ),
            ],
            const SizedBox(height: 14),
            // Routes
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(tx('routesCount'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cText)),
              Row(children: [
                for (final s in ['nearest', 'departure'])
                  GestureDetector(
                    onTap: () => setState(() => _sortMode = s),
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _sortMode == s ? cNavy : cSand,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _sortMode == s ? cNavy : cLine),
                      ),
                      child: Text(s == 'nearest' ? tx('sortNearest') : tx('sortDeparture'),
                        style: TextStyle(color: _sortMode == s ? Colors.white : cMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ]),
            ]),
            const SizedBox(height: 8),
            for (final r in _sortedRoutes) _routeCard(r),
          ],
        ),
      ),
    );
  }

  Widget _routeCard(RideEntry r) {
    final isFav = widget.isRouteFav(r);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: cLine)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('${r.from} → ${r.to}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cText))),
          GestureDetector(onTap: () => widget.onToggleRouteFav(r),
            child: Icon(isFav ? Icons.favorite : Icons.favorite_outline, color: isFav ? cBrick : cMuted, size: 18)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.access_time, size: 12, color: cMuted),
          const SizedBox(width: 4),
          Text(fmtTime(r.time), style: const TextStyle(color: cNavy, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          const Icon(Icons.event_seat, size: 12, color: cMuted),
          const SizedBox(width: 4),
          Text('${r.seatsLeft} ${tx('seatsLeft')}', style: TextStyle(color: r.seatsLeft <= 2 ? cBrick : cTeal, fontSize: 12)),
          const Spacer(),
          Text('AED ${r.priceMonthly.toStringAsFixed(0)}/mo', style: const TextStyle(color: cNavy, fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => widget.onPickRoute(r),
            style: ElevatedButton.styleFrom(
              backgroundColor: cGold, foregroundColor: cNavy,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(tx('bookRoute'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ),
      ]),
    );
  }
}
