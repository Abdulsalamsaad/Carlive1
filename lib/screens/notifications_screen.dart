import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';

class NotificationsScreen extends StatelessWidget {
  final List<NotificationEntry> notifications;
  final VoidCallback onBack;
  final void Function(String) onMarkRead;
  final VoidCallback onMarkAll;
  final String locale;
  final bool isRtl;

  const NotificationsScreen({
    super.key, required this.notifications, required this.onBack,
    required this.onMarkRead, required this.onMarkAll,
    required this.locale, required this.isRtl,
  });

  String tx(String key) => i18n.t(locale, key);

  @override
  Widget build(BuildContext context) {
    final hasUnread = notifications.any((n) => !n.isRead);
    return Scaffold(
      backgroundColor: cSand,
      appBar: TopBar(
        title: tx('notificationsTitle'),
        onBack: onBack,
        isRtl: isRtl,
        trailing: hasUnread ? TextButton(
          onPressed: onMarkAll,
          child: Text(tx('markAllRead'), style: const TextStyle(color: cGold, fontSize: 12, fontWeight: FontWeight.w600)),
        ) : null,
      ),
      body: notifications.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.notifications_none, size: 56, color: cLine),
              const SizedBox(height: 14),
              Text(tx('noNotifications'), style: const TextStyle(fontWeight: FontWeight.w600, color: cText)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: notifications.length,
              itemBuilder: (ctx, i) {
                final n = notifications[i];
                return GestureDetector(
                  onTap: () => onMarkRead(n.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: n.isRead ? cCard : cGold.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: n.isRead ? cLine : cGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: n.type == 'promo' ? cGold.withOpacity(0.15) : cNavy.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            n.type == 'promo' ? Icons.local_offer : Icons.notifications,
                            color: n.type == 'promo' ? cGoldDeep : cNavy, size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(n.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cText,
                            fontStyle: n.isRead ? FontStyle.normal : FontStyle.normal)),
                          const SizedBox(height: 3),
                          Text(n.body, style: const TextStyle(color: cMuted, fontSize: 13)),
                        ])),
                        if (!n.isRead) Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: cGold, shape: BoxShape.circle)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
