import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';

class PromoDetailScreen extends StatelessWidget {
  final AdEntry ad;
  final VoidCallback onBack;
  final String locale;
  final bool isRtl;

  const PromoDetailScreen({super.key, required this.ad, required this.onBack, required this.locale, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final tx = (String key) => i18n.t(locale, key);
    final c1 = hexColor(ad.grad[0]);
    final c2 = hexColor(ad.grad[1]);
    return Scaffold(
      backgroundColor: cSand,
      appBar: TopBar(title: tx('adSponsored'), onBack: onBack, isRtl: isRtl),
      body: Column(
        children: [
          Container(
            width: double.infinity, height: 180,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [c1, c2], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.local_offer, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(ad.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              const SizedBox(height: 6),
              Text(ad.sponsor, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Offer details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: cText)),
                const SizedBox(height: 12),
                const Text('This limited-time offer is available to all Dubai Carlift users. '
                    'Apply the promotion code at checkout or tap the button below to book with the discount automatically applied.',
                  style: TextStyle(color: cMuted, fontSize: 14, height: 1.6)),
                const Spacer(),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cGold, foregroundColor: cNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(tx('adLearnMore'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
