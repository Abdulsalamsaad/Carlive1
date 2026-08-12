import 'package:flutter/material.dart';
import '../constants.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';

class FaqScreen extends StatelessWidget {
  final VoidCallback onBack;
  final String locale;
  final bool isRtl;

  const FaqScreen({super.key, required this.onBack, required this.locale, required this.isRtl});

  static const _faqs = [
    {'q': 'How do I book a commute pass?', 'a': 'Search for your route, pick a company, choose your schedule and plan, then pay. Your pass is saved on this device.'},
    {'q': 'Can I cancel my pass?', 'a': 'Yes. Open the pass from My Rides and tap "Cancel this ride". Cancellations take effect at the next billing cycle.'},
    {'q': 'How does the monthly plan work?', 'a': 'Monthly plans cover 28+ days and auto-renew. You pay once and ride every selected working day for the full period.'},
    {'q': 'Are the companies licensed?', 'a': 'All companies listed on Dubai Carlift are licensed by the Roads and Transport Authority (RTA) in Dubai.'},
    {'q': 'What payment methods are accepted?', 'a': 'We accept card, cash to driver, and Tabby (split into 4 interest-free payments).'},
    {'q': 'How do I contact my driver?', 'a': 'Open your active pass from My Rides. You can call or message your driver directly from the pass detail screen.'},
    {'q': 'Is my data safe?', 'a': 'All your data is stored locally on your device. We do not upload personal data to any server.'},
  ];

  @override
  Widget build(BuildContext context) {
    final tx = (String key) => i18n.t(locale, key);
    return Scaffold(
      backgroundColor: cSand,
      appBar: TopBar(title: tx('faqTitle'), onBack: onBack, isRtl: isRtl),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _faqs.length,
        itemBuilder: (ctx, i) {
          final faq = _faqs[i];
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: cLine)),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                title: Text(faq['q']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cText)),
                iconColor: cGold, collapsedIconColor: cMuted,
                children: [
                  Text(faq['a']!, style: const TextStyle(color: cMuted, fontSize: 13, height: 1.5)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
