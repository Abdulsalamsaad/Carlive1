import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../i18n.dart' as i18n;

class MyRidesScreen extends StatelessWidget {
  final List<Subscription> subs;
  final String locale;
  final bool isRtl;
  final void Function(Subscription) onOpen;
  final void Function(Subscription) onRate;

  const MyRidesScreen({
    super.key, required this.subs, required this.locale, required this.isRtl,
    required this.onOpen, required this.onRate,
  });

  String tx(String key) => i18n.t(locale, key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cSand,
      body: SafeArea(
        child: Column(
          children: [
            // Title bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(children: [
                Text(tx('myRides'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cText)),
              ]),
            ),
            Expanded(
              child: subs.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.confirmation_number_outlined, size: 56, color: cLine),
                      const SizedBox(height: 14),
                      Text(tx('noRidesTitle'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: cText)),
                      const SizedBox(height: 6),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(tx('noRidesSub'), style: const TextStyle(color: cMuted, fontSize: 13), textAlign: TextAlign.center)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: subs.length,
                      itemBuilder: (ctx, i) => _subCard(subs[i], context),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subCard(Subscription s, BuildContext ctx) {
    final isActive = s.status == 'active';
    final color = hexColor(s.colorHex);
    return GestureDetector(
      onTap: () => onOpen(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: cLine)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(radius: 20, backgroundColor: color,
                    child: Text(s.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.company, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cText)),
                    Text('${s.from} → ${s.to}', style: const TextStyle(color: cMuted, fontSize: 12)),
                    Text('${tx('departsLabel')}: ${s.departureLabel}', style: const TextStyle(color: cNavy, fontSize: 12, fontWeight: FontWeight.w600)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? cTeal.withOpacity(0.1) : cBrick.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(isActive ? tx('active') : tx('cancelledStatus'),
                      style: TextStyle(color: isActive ? cTeal : cBrick, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            if (isActive && !s.hasRated)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: cLine))),
                child: Row(children: [
                  Text(tx('rateThisRide'), style: const TextStyle(color: cMuted, fontSize: 12)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => onRate(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: cGold.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.star, color: cGold, size: 14),
                        const SizedBox(width: 4),
                        Text(tx('rateRide'), style: const TextStyle(color: cGoldDeep, fontSize: 12, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}
