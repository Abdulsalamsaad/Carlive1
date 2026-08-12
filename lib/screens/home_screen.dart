import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../catalog.dart';
import '../i18n.dart' as i18n;
import '../widgets/ad_banner.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile profile;
  final String locale;
  final bool isRtl;
  final int unread;
  final VoidCallback onBell;
  final void Function(CompanyEntry) onOpenCompany;
  final VoidCallback onGoSearch;
  final void Function(AdEntry) onAdClick;
  final VoidCallback onOpenTrending;
  final void Function(RideEntry) onPickTrending;
  final Map<String, CompanyStats> companyStats;
  final bool Function(RideEntry) isRouteFav;
  final void Function(RideEntry) onToggleRouteFav;

  const HomeScreen({
    super.key, required this.profile, required this.locale, required this.isRtl,
    required this.unread, required this.onBell, required this.onOpenCompany,
    required this.onGoSearch, required this.onAdClick, required this.onOpenTrending,
    required this.onPickTrending, required this.companyStats,
    required this.isRouteFav, required this.onToggleRouteFav,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _adIndex = 0;
  late final List<CompanyEntry> _companies;

  @override
  void initState() {
    super.initState();
    _companies = buildCompanies();
    // Auto-advance ad carousel
    Future.delayed(const Duration(seconds: 4), _advanceAd);
  }

  void _advanceAd() {
    if (!mounted) return;
    setState(() => _adIndex = (_adIndex + 1) % homeAds.length);
    Future.delayed(const Duration(seconds: 4), _advanceAd);
  }

  String tx(String key, [Map<String, String>? p]) => i18n.t(widget.locale, key, p);

  @override
  Widget build(BuildContext context) {
    final firstName = widget.profile.name.split(' ').first;
    return Scaffold(
      backgroundColor: cSand,
      body: CustomScrollView(
        slivers: [
          // Dark header
          SliverToBoxAdapter(
            child: Container(
              color: cNavy,
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx('appName'), style: const TextStyle(color: cGold, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                            const SizedBox(height: 4),
                            Text(tx('greeting', {'name': firstName}),
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.25)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onBell,
                        child: Stack(clipBehavior: Clip.none, children: [
                          Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 18)),
                          if (widget.unread > 0)
                            Positioned(right: -3, top: -3, child: Container(
                              width: 14, height: 14,
                              decoration: const BoxDecoration(color: cBrick, shape: BoxShape.circle),
                              child: Center(child: Text('${widget.unread}', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
                            )),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Ad carousel
                  GestureDetector(
                    onTap: () => widget.onAdClick(homeAds[_adIndex]),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _adCard(homeAds[_adIndex], key: ValueKey(_adIndex)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Carousel dots
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    for (int i = 0; i < homeAds.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 4),
                        width: i == _adIndex ? 16 : 6, height: 6,
                        decoration: BoxDecoration(
                          color: i == _adIndex ? cGold : Colors.white30,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ]),
                ],
              ),
            ),
          ),
          // Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(delegate: SliverChildListDelegate([
              // Search shortcut
              GestureDetector(
                onTap: widget.onGoSearch,
                child: Container(
                  margin: const EdgeInsets.only(top: -20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: cCard, borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(children: [
                    const Icon(Icons.search, color: cMuted, size: 20),
                    const SizedBox(width: 10),
                    Text(tx('searchRides'), style: const TextStyle(color: cMuted, fontSize: 14)),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: cMuted, size: 18),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              // Trending section
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(tx('trending'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cText)),
                GestureDetector(onTap: widget.onOpenTrending,
                  child: Text(tx('seeAll'), style: const TextStyle(color: cGold, fontSize: 13, fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 10),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: trending.take(5).length,
                  itemBuilder: (ctx, i) {
                    final r = trending.take(5).toList()[i];
                    final isFav = widget.isRouteFav(r);
                    return GestureDetector(
                      onTap: () => widget.onPickTrending(r),
                      child: Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cCard, borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cLine),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              CircleAvatar(radius: 14, backgroundColor: hexColor(r.colorHex),
                                child: Text(r.initials, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                              const Spacer(),
                              GestureDetector(onTap: () => widget.onToggleRouteFav(r),
                                child: Icon(isFav ? Icons.favorite : Icons.favorite_outline, color: isFav ? cBrick : cMuted, size: 16)),
                            ]),
                            const SizedBox(height: 6),
                            Text(r.company, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: cText), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${r.from} → ${r.to}', style: const TextStyle(color: cMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.access_time, size: 11, color: cMuted),
                              const SizedBox(width: 3),
                              Text(fmtTime(r.time), style: const TextStyle(color: cNavy, fontSize: 11, fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Text('AED ${r.priceMonthly.toStringAsFixed(0)}/mo', style: const TextStyle(color: cTeal, fontSize: 10, fontWeight: FontWeight.w600)),
                            ]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Partner companies
              Text(tx('ourPartners'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cText)),
              const SizedBox(height: 10),
              for (final c in _companies) _companyCard(c),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.verified_user, color: cTeal, size: 14),
                const SizedBox(width: 6),
                Expanded(child: Text(tx('verifiedCompanies'), style: const TextStyle(color: cMuted, fontSize: 12))),
              ]),
            ])),
          ),
        ],
      ),
    );
  }

  Widget _adCard(AdEntry ad, {Key? key}) {
    final c1 = hexColor(ad.grad[0]);
    final c2 = hexColor(ad.grad[1]);
    return Container(
      key: key, height: 72,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(colors: [c1, c2])),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ad.title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(ad.sponsor, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Text(tx('adLearnMore'), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _companyCard(CompanyEntry c) {
    final stats = ratingFor(c.name, widget.companyStats);
    final routeCount = c.routes.length;
    return GestureDetector(
      onTap: () => widget.onOpenCompany(c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: cLine)),
        child: Row(
          children: [
            CircleAvatar(radius: 22, backgroundColor: hexColor(c.colorHex),
              child: Text(c.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cText)),
                Text(c.tagline, style: const TextStyle(color: cMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star, color: cGold, size: 12),
                  const SizedBox(width: 3),
                  Text('${stats.rating} · ${c.fleetSize} ${tx('fleetSize')} · $routeCount ${tx('routesCount')}',
                    style: const TextStyle(color: cMuted, fontSize: 11)),
                ]),
              ]),
            ),
            const Icon(Icons.chevron_right, color: cMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
