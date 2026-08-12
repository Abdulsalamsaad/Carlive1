import 'package:flutter/material.dart';
import '../constants.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';

class LegalScreen extends StatelessWidget {
  final VoidCallback onBack;
  final String locale;
  final bool isRtl;

  const LegalScreen({super.key, required this.onBack, required this.locale, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final tx = (String key) => i18n.t(locale, key);
    return Scaffold(
      backgroundColor: cSand,
      appBar: TopBar(title: tx('legalTitle'), onBack: onBack, isRtl: isRtl),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          for (final item in [
            {'icon': Icons.privacy_tip_outlined, 'label': 'privacyPolicy'},
            {'icon': Icons.description_outlined, 'label': 'termsOfService'},
            {'icon': Icons.business_outlined, 'label': 'companyInfo'},
          ])
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: cLine)),
              child: ListTile(
                leading: Icon(item['icon'] as IconData, color: cNavy, size: 20),
                title: Text(tx(item['label'] as String), style: const TextStyle(color: cText, fontWeight: FontWeight.w500, fontSize: 14)),
                trailing: const Icon(Icons.open_in_new, color: cMuted, size: 16),
                onTap: () {},
              ),
            ),
          const SizedBox(height: 20),
          const Center(child: Text('Dubai Carlift · v1.0.0\n© 2025 Dubai Carlift LLC', textAlign: TextAlign.center, style: TextStyle(color: cMuted, fontSize: 12))),
        ],
      ),
    );
  }
}
