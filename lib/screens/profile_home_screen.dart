import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../i18n.dart' as i18n;
import '../widgets/ad_banner.dart';

class ProfileHomeScreen extends StatelessWidget {
  final UserProfile profile;
  final int ridesCount;
  final int unread;
  final String locale;
  final bool isRtl;
  final void Function(String) go;
  final VoidCallback onOpenFavorites;

  const ProfileHomeScreen({
    super.key, required this.profile, required this.ridesCount,
    required this.unread, required this.locale, required this.isRtl,
    required this.go, required this.onOpenFavorites,
  });

  String tx(String key) => i18n.t(locale, key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cSand,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            color: cNavy,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 28),
            child: Row(children: [
              CircleAvatar(radius: 26, backgroundColor: cGold,
                child: Text(profile.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: cNavy, fontWeight: FontWeight.bold, fontSize: 20))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(profile.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                Text(profile.phone, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                Text('$ridesCount ${tx('ridesBooked')}', style: const TextStyle(color: cGold, fontSize: 12, fontWeight: FontWeight.w600)),
              ])),
              IconButton(onPressed: () => go('editProfile'),
                icon: const Icon(Icons.edit_outlined, color: Colors.white60, size: 20)),
            ]),
          ),
          const SizedBox(height: 12),
          // Menu sections
          _section([
            _tile(Icons.person_outline, tx('editProfile'), () => go('editProfile')),
            _tile(Icons.language, tx('language'), () => go('language')),
            _tile(Icons.favorite_outline, tx('favorites'), onOpenFavorites),
          ]),
          const SizedBox(height: 8),
          _section([
            _tile(Icons.notifications_outlined, tx('notificationsTitle'), () => go('notifications'),
              badge: unread > 0 ? '$unread' : null),
            _tile(Icons.help_outline, tx('faqTitle'), () => go('faq')),
            _tile(Icons.description_outlined, tx('legalTitle'), () => go('legal')),
          ]),
          const SizedBox(height: 8),
          _section([
            _tile(Icons.logout, tx('logout'), () => go('logoutConfirm'), danger: true),
          ]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AdBannerWidget(
              ad: const AdEntry(id: 'ad4', title: 'Corporate partner: 10% off for DIFC employees', sponsor: 'DIFC Partnership', grad: ['#6B5CA5', '#0B1F2A']),
              onTap: () {},
            ),
          ),
        ]),
      ),
    );
  }

  Widget _section(List<Widget> tiles) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: cLine)),
      child: Column(children: tiles),
    );
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap, {bool danger = false, String? badge}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(children: [
          Icon(icon, color: danger ? cBrick : cMuted, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: danger ? cBrick : cText, fontSize: 14, fontWeight: FontWeight.w500))),
          if (badge != null) Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: cBrick, borderRadius: BorderRadius.circular(10)),
            child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ) else const Icon(Icons.chevron_right, color: cLine, size: 18),
        ]),
      ),
    );
  }
}
