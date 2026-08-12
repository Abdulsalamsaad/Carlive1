import 'package:flutter/material.dart';
import '../constants.dart';

class AppBottomNav extends StatelessWidget {
  final String active;
  final ValueChanged<String> onTap;
  final int ridesCount;
  final int favCount;
  final bool isRtl;
  final Map<String, String> labels;

  const AppBottomNav({
    super.key,
    required this.active,
    required this.onTap,
    this.ridesCount = 0,
    this.favCount = 0,
    this.isRtl = false,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(key: 'home', icon: Icons.home_outlined, activeIcon: Icons.home, label: labels['home'] ?? 'Home'),
      _NavItem(key: 'search', icon: Icons.search_outlined, activeIcon: Icons.search, label: labels['search'] ?? 'Search'),
      _NavItem(key: 'myrides', icon: Icons.confirmation_number_outlined, activeIcon: Icons.confirmation_number, label: labels['myRides'] ?? 'Rides', badge: ridesCount),
      _NavItem(key: 'favorites', icon: Icons.favorite_outline, activeIcon: Icons.favorite, label: labels['favoritesNav'] ?? 'Favorites', badge: favCount),
      _NavItem(key: 'profile', icon: Icons.person_outline, activeIcon: Icons.person, label: labels['profile'] ?? 'Profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: cCard,
        border: Border(top: BorderSide(color: cLine, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: items.map((item) {
              final isActive = active == item.key;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(item.key),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive ? cNavy : cMuted,
                            size: 22,
                          ),
                          if (item.badge > 0)
                            Positioned(
                              right: -6,
                              top: -4,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: cBrick,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    item.badge > 9 ? '9+' : '${item.badge}',
                                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          color: isActive ? cNavy : cMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String key, label;
  final IconData icon, activeIcon;
  final int badge;
  const _NavItem({required this.key, required this.icon, required this.activeIcon, required this.label, this.badge = 0});
}
