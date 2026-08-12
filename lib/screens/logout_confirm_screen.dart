import 'package:flutter/material.dart';
import '../constants.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';

class LogoutConfirmScreen extends StatelessWidget {
  final VoidCallback onBack;
  final Future<void> Function() onLogout;
  final String locale;
  final bool isRtl;

  const LogoutConfirmScreen({super.key, required this.onBack, required this.onLogout, required this.locale, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final tx = (String key) => i18n.t(locale, key);
    return Scaffold(
      backgroundColor: cSand,
      appBar: TopBar(title: tx('logout'), onBack: onBack, isRtl: isRtl),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: cBrick.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.logout, color: cBrick, size: 32),
            ),
            const SizedBox(height: 20),
            Text(tx('logout'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: cText)),
            const SizedBox(height: 8),
            Text(tx('logoutConfirm'), style: const TextStyle(color: cMuted, fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: cLine),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(tx('staySignedIn'), style: const TextStyle(color: cText, fontWeight: FontWeight.w600)),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: onLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cBrick, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(tx('logoutBtn'), style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
            ]),
          ],
        ),
      ),
    );
  }
}
