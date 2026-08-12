import 'package:flutter/material.dart';
import 'constants.dart';
import 'models.dart';
import 'catalog.dart';
import 'storage.dart';
import 'i18n.dart' as i18n;
import 'widgets/bottom_nav.dart';
import 'widgets/marquee_ticker.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/results_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/my_rides_screen.dart';
import 'screens/pass_detail_screen.dart';
import 'screens/company_detail_screen.dart';
import 'screens/trending_screen.dart';
import 'screens/promo_detail_screen.dart';
import 'screens/profile_home_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/language_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/legal_screen.dart';
import 'screens/logout_confirm_screen.dart';

class CarliftApp extends StatefulWidget {
  const CarliftApp({super.key});
  @override
  State<CarliftApp> createState() => _CarliftAppState();
}

class _CarliftAppState extends State<CarliftApp> {
  // ── App state ──────────────────────────────────────────────────────────────
  bool _loading = true;
  UserProfile? _profile;
  List<Subscription> _subs = [];
  List<FavoriteEntry> _favorites = [];
  List<NotificationEntry> _notifications = [];
  Map<String, CompanyStats> _companyStats = {};

  // ── Navigation ─────────────────────────────────────────────────────────────
  String _screen = 'home';
  String _scheduleBackTo = 'results';
  String? _favoritesBackTo;

  // ── Selected objects ──────────────────────────────────────────────────────
  String? _selectedSubId;
  CompanyEntry? _selectedCompany;
  AdEntry? _selectedAd;
  Subscription? _ratingSub;

  // ── Trip / booking state ──────────────────────────────────────────────────
  TripConfig _trip = const TripConfig();
  RideEntry? _ride;
  BookingConfig _config = const BookingConfig();

  // ── Toast ─────────────────────────────────────────────────────────────────
  String _toast = '';

  String get _locale => _profile?.preferredLanguage ?? 'en';
  bool get _isRtl => rtlLocales.contains(_locale);
  String tx(String key, [Map<String, String>? p]) => i18n.t(_locale, key, p);

  // ── Boot ──────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final results = await Future.wait([
      AppStorage.get('user:profile'),
      AppStorage.get('subscriptions:list'),
      AppStorage.get('favorites:list'),
      AppStorage.get('notifications:list'),
      AppStorage.get('company:stats'),
    ]);
    final p = results[0];
    final s = results[1];
    final f = results[2];
    final n = results[3];
    final cs = results[4];

    UserProfile? profile;
    if (p != null) profile = UserProfile.fromJson(Map<String, dynamic>.from(p));
    final subs = s != null ? (s as List).map((e) => Subscription.fromJson(Map<String, dynamic>.from(e))).toList() : <Subscription>[];
    final favs = f != null ? (f as List).map((e) => FavoriteEntry.fromJson(Map<String, dynamic>.from(e))).toList() : <FavoriteEntry>[];
    final stats = cs != null ? Map<String, CompanyStats>.fromEntries((cs as Map).entries.map((e) => MapEntry(e.key as String, CompanyStats.fromJson(Map<String, dynamic>.from(e.value))))) : <String, CompanyStats>{};

    List<NotificationEntry> notifs = [];
    if (n != null) {
      notifs = (n as List).map((e) => NotificationEntry.fromJson(Map<String, dynamic>.from(e))).toList();
    } else if (profile != null) {
      final lg = profile.preferredLanguage;
      notifs = [
        NotificationEntry(id: 'n1', type: 'system', title: i18n.t(lg, 'welcomeNotifTitle'), body: i18n.t(lg, 'welcomeNotifBody'), isRead: false),
        NotificationEntry(id: 'n2', type: 'promo', title: i18n.t(lg, 'promoNotifTitle'), body: i18n.t(lg, 'promoNotifBody'), isRead: false),
      ];
      await AppStorage.set('notifications:list', notifs.map((n) => n.toJson()).toList());
    }

    setState(() {
      _profile = profile;
      _subs = subs;
      _favorites = favs;
      _notifications = notifs;
      _companyStats = stats;
      _loading = false;
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _flash(String msg) {
    setState(() => _toast = msg);
    Future.delayed(const Duration(milliseconds: 1800), () { if (mounted) setState(() => _toast = ''); });
  }

  void _go(String screen) => setState(() => _screen = screen);

  bool _isRouteFav(RideEntry r) => _favorites.any((f) => f.type == 'route' && f.rideId == r.id);
  bool _isCompanyFav(String companyId) => _favorites.any((f) => f.type == 'company' && f.companyId == companyId);

  // ── Handlers ──────────────────────────────────────────────────────────────
  Future<void> _handleOnboardDone(UserProfile p) async {
    final notifs = [
      NotificationEntry(id: 'n1', type: 'system', title: i18n.t('en', 'welcomeNotifTitle'), body: i18n.t('en', 'welcomeNotifBody'), isRead: false),
      NotificationEntry(id: 'n2', type: 'promo', title: i18n.t('en', 'promoNotifTitle'), body: i18n.t('en', 'promoNotifBody'), isRead: false),
    ];
    await Future.wait([
      AppStorage.set('user:profile', p.toJson()),
      AppStorage.set('notifications:list', notifs.map((n) => n.toJson()).toList()),
    ]);
    setState(() { _profile = p; _notifications = notifs; });
  }

  Future<void> _handlePaid(String method) async {
    final ride = _ride!;
    final endDate = DateTime.now().add(Duration(days: _trip.durationDays)).toIso8601String();
    final price = _config.plan == 'weekly' ? ride.priceWeekly : _config.plan == 'monthly' ? ride.priceMonthly : ride.priceDaily;
    final newSub = Subscription(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      from: _trip.from, to: _trip.to,
      company: ride.company, initials: ride.initials, colorHex: ride.colorHex,
      departureLabel: fmtTime(ride.time), plan: _config.plan,
      driverName: ride.driver, driverPhone: ride.phone, bus: ride.bus,
      endDate: endDate, paymentMethod: method,
      durationDays: _trip.durationDays, price: price,
      days: _config.days, status: 'active',
      messages: [], stopPins: ride.stopPins.map((p) => Map<String, dynamic>.from(p)).toList(),
    );
    final next = [newSub, ..._subs];
    await AppStorage.set('subscriptions:list', next.map((s) => s.toJson()).toList());
    setState(() { _subs = next; _selectedSubId = newSub.id; _screen = 'detail'; });
  }

  Future<void> _handleCancel(String id) async {
    final next = _subs.map((s) => s.id == id ? s.copyWith(status: 'cancelled') : s).toList();
    await AppStorage.set('subscriptions:list', next.map((s) => s.toJson()).toList());
    setState(() { _subs = next; _screen = 'myrides'; });
  }

  void _handleUpdateMessages(String id, List<Map<String, dynamic>> msgs) async {
    final next = _subs.map((s) => s.id == id ? s.copyWith(messages: msgs) : s).toList();
    await AppStorage.set('subscriptions:list', next.map((s) => s.toJson()).toList());
    setState(() => _subs = next);
  }

  Future<void> _submitRating(String subId, int stars) async {
    final sub = _subs.firstWhere((s) => s.id == subId);
    if (sub.hasRated) return;
    final nextSubs = _subs.map((s) => s.id == subId ? s.copyWith(hasRated: true, ratingGiven: stars) : s).toList();
    await AppStorage.set('subscriptions:list', nextSubs.map((s) => s.toJson()).toList());
    final current = ratingFor(sub.company, _companyStats);
    final newCount = current.reviewCount + 1;
    final newRating = ((current.rating * current.reviewCount + stars) / newCount * 10).round() / 10;
    final nextStats = {..._companyStats, sub.company: CompanyStats(rating: newRating, reviewCount: newCount)};
    await AppStorage.set('company:stats', nextStats.map((k, v) => MapEntry(k, v.toJson())));
    setState(() { _subs = nextSubs; _companyStats = nextStats; _ratingSub = null; });
    _flash(tx('ratingSubmitted'));
  }

  Future<bool> _handleProfileUpdate(UserProfile p) async {
    setState(() => _profile = p);
    return await AppStorage.set('user:profile', p.toJson());
  }

  Future<void> _handleLogout() async {
    await Future.wait([
      AppStorage.remove('user:profile'),
      AppStorage.remove('subscriptions:list'),
      AppStorage.remove('favorites:list'),
      AppStorage.remove('notifications:list'),
    ]);
    setState(() { _profile = null; _subs = []; _favorites = []; _notifications = []; _screen = 'home'; });
  }

  Future<void> _toggleRouteFavorite(RideEntry r) async {
    final exists = _favorites.where((f) => f.type == 'route' && f.rideId == r.id).isNotEmpty;
    final next = exists
        ? _favorites.where((f) => !(f.type == 'route' && f.rideId == r.id)).toList()
        : [FavoriteEntry(id: 'fav_${DateTime.now().millisecondsSinceEpoch}', type: 'route', rideId: r.id, from: r.from, to: r.to, company: r.company, initials: r.initials, colorHex: r.colorHex, time: r.time), ..._favorites];
    await AppStorage.set('favorites:list', next.map((f) => f.toJson()).toList());
    setState(() => _favorites = next);
  }

  Future<void> _toggleCompanyFavorite(CompanyEntry c) async {
    final exists = _favorites.where((f) => f.type == 'company' && f.companyId == c.id).isNotEmpty;
    final next = exists
        ? _favorites.where((f) => !(f.type == 'company' && f.companyId == c.id)).toList()
        : [FavoriteEntry(id: 'fav_${DateTime.now().millisecondsSinceEpoch}_c', type: 'company', companyId: c.id, name: c.name, initials: c.initials, colorHex: c.colorHex, tagline: c.tagline), ..._favorites];
    await AppStorage.set('favorites:list', next.map((f) => f.toJson()).toList());
    setState(() => _favorites = next);
  }

  Future<void> _removeFavorite(String id) async {
    final next = _favorites.where((f) => f.id != id).toList();
    await AppStorage.set('favorites:list', next.map((f) => f.toJson()).toList());
    setState(() => _favorites = next);
  }

  Future<void> _markNotifRead(String id) async {
    final next = _notifications.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
    await AppStorage.set('notifications:list', next.map((n) => n.toJson()).toList());
    setState(() => _notifications = next);
  }

  Future<void> _markAllNotifRead() async {
    final next = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    await AppStorage.set('notifications:list', next.map((n) => n.toJson()).toList());
    setState(() => _notifications = next);
  }

  void _openCompany(CompanyEntry c) => setState(() { _selectedCompany = c; _screen = 'companyDetail'; });

  void _openCompanyFromFavorite(FavoriteEntry fav) {
    final full = buildCompanies().where((c) => c.id == fav.companyId).firstOrNull;
    if (full != null) _openCompany(full);
  }

  void _pickRouteFromCompany(RideEntry r) {
    setState(() {
      _trip = _trip.copyWith(from: r.from, to: r.to, time: r.time);
      _ride = r;
      _config = _config.copyWith(plan: _trip.frequency);
      _scheduleBackTo = 'companyDetail';
      _screen = 'schedule';
    });
  }

  void _pickTrending(RideEntry r) {
    setState(() {
      _trip = _trip.copyWith(from: r.from, to: r.to, time: r.time);
      _ride = r;
      _config = _config.copyWith(plan: _trip.frequency);
      _scheduleBackTo = 'trending';
      _screen = 'schedule';
    });
  }

  void _handleAdClick(AdEntry ad) {
    if (ad.linkType == 'company' && ad.companyId != null) {
      final c = buildCompanies().where((co) => co.id == ad.companyId).firstOrNull;
      if (c != null) { _openCompany(c); return; }
    }
    setState(() { _selectedAd = ad; _screen = 'promoDetail'; });
  }

  void _bookAgainFromFavorite(FavoriteEntry f) {
    final r = catalog.where((x) => x.id == f.rideId).firstOrNull ?? catalog.first;
    setState(() {
      _trip = _trip.copyWith(from: f.from ?? r.from, to: f.to ?? r.to, time: f.time ?? r.time);
      _ride = r;
      _config = _config.copyWith(plan: _trip.frequency);
      _scheduleBackTo = 'favorites';
      _screen = 'schedule';
    });
  }

  // ── Computed ──────────────────────────────────────────────────────────────
  int get _activeCount => _subs.where((s) => s.status == 'active').length;
  int get _unreadCount => _notifications.where((n) => !n.isRead).length;
  Subscription? get _selectedSub => _subs.where((s) => s.id == _selectedSubId).firstOrNull;

  bool get _showNav => _profile != null && ['home', 'search', 'myrides', 'favorites', 'profile'].contains(_screen);

  Map<String, String> get _navLabels => {
    'home': tx('home'), 'search': tx('search'), 'myRides': tx('myRides'),
    'favoritesNav': tx('favoritesNav'), 'profile': tx('profile'),
  };

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: cNavy,
        body: Center(child: CircularProgressIndicator(color: cGold)),
      );
    }

    Widget body = _buildBody();

    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: cSand,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(child: body),
                // Ticker always above bottom nav on main tabs
                if (_showNav) MarqueeTicker(text: tx('tickerText')),
                if (_showNav) AppBottomNav(
                  active: _screen, onTap: _onNavTap,
                  ridesCount: _activeCount, favCount: _favorites.length,
                  isRtl: _isRtl, labels: _navLabels,
                ),
              ],
            ),
            // Toast overlay
            if (_toast.isNotEmpty)
              Positioned(
                bottom: _showNav ? 120 : 40,
                left: 24, right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: cNavy, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12)]),
                  child: Text(_toast, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                ),
              ),
            // Rating modal overlay
            if (_ratingSub != null) _ratingModal(_ratingSub!),
          ],
        ),
      ),
    );
  }

  void _onNavTap(String key) {
    setState(() {
      _screen = key;
      if (key != 'detail') _selectedSubId = null;
      if (key == 'favorites') _favoritesBackTo = null;
    });
  }

  Widget _buildBody() {
    if (_profile == null) {
      return OnboardingScreen(onDone: _handleOnboardDone);
    }

    final profile = _profile!;

    switch (_screen) {
      case 'home':
        return HomeScreen(
          profile: profile, locale: _locale, isRtl: _isRtl,
          unread: _unreadCount, onBell: () => _go('notifications'),
          onOpenCompany: _openCompany, onGoSearch: () => _go('search'),
          onAdClick: _handleAdClick, onOpenTrending: () => _go('trending'),
          onPickTrending: _pickTrending, companyStats: _companyStats,
          isRouteFav: _isRouteFav, onToggleRouteFav: _toggleRouteFavorite,
        );

      case 'companyDetail':
        if (_selectedCompany == null) { WidgetsBinding.instance.addPostFrameCallback((_) => _go('home')); return const SizedBox(); }
        return CompanyDetailScreen(
          company: _selectedCompany!, companyStats: _companyStats,
          onBack: () => _go('home'), onPickRoute: _pickRouteFromCompany,
          locale: _locale, isRtl: _isRtl,
          isCompanyFav: _isCompanyFav(_selectedCompany!.id),
          onToggleCompanyFav: () => _toggleCompanyFavorite(_selectedCompany!),
          isRouteFav: _isRouteFav, onToggleRouteFav: _toggleRouteFavorite,
        );

      case 'trending':
        return TrendingScreen(
          companyStats: _companyStats, onBack: () => _go('home'),
          onPick: _pickTrending, isFav: _isRouteFav, onToggleFav: _toggleRouteFavorite,
          locale: _locale, isRtl: _isRtl,
        );

      case 'promoDetail':
        if (_selectedAd == null) { WidgetsBinding.instance.addPostFrameCallback((_) => _go('home')); return const SizedBox(); }
        return PromoDetailScreen(ad: _selectedAd!, onBack: () => _go('home'), locale: _locale, isRtl: _isRtl);

      case 'search':
        return SearchScreen(
          trip: _trip, onTripChanged: (t) => setState(() => _trip = t),
          onSearch: () => _go('results'),
          profile: profile, locale: _locale, isRtl: _isRtl,
          unread: _unreadCount, onBell: () => _go('notifications'),
        );

      case 'results':
        return ResultsScreen(
          trip: _trip, onBack: () => _go('search'),
          onSelect: (r) { setState(() { _ride = r; _config = _config.copyWith(plan: _trip.frequency); _scheduleBackTo = 'results'; _screen = 'schedule'; }); },
          favorites: _favorites, onToggleFavorite: _toggleRouteFavorite,
          companyStats: _companyStats, locale: _locale, isRtl: _isRtl,
        );

      case 'schedule':
        if (_ride == null) { WidgetsBinding.instance.addPostFrameCallback((_) => _go('search')); return const SizedBox(); }
        return ScheduleScreen(
          trip: _trip, ride: _ride!, config: _config,
          onConfigChanged: (c) => setState(() => _config = c),
          onBack: () => _go(_scheduleBackTo), onNext: () => _go('checkout'),
          locale: _locale, isRtl: _isRtl,
        );

      case 'checkout':
        if (_ride == null) { WidgetsBinding.instance.addPostFrameCallback((_) => _go('search')); return const SizedBox(); }
        return CheckoutScreen(
          trip: _trip, ride: _ride!, config: _config,
          onBack: () => _go('schedule'), onPaid: _handlePaid,
          locale: _locale, isRtl: _isRtl,
        );

      case 'myrides':
        return MyRidesScreen(
          subs: _subs, locale: _locale, isRtl: _isRtl,
          onOpen: (s) => setState(() { _selectedSubId = s.id; _screen = 'detail'; }),
          onRate: (s) => setState(() => _ratingSub = s),
        );

      case 'detail':
        if (_selectedSub == null) { WidgetsBinding.instance.addPostFrameCallback((_) => _go('myrides')); return const SizedBox(); }
        return PassDetailScreen(
          sub: _selectedSub!, onBack: () => _go('myrides'),
          onCancel: _handleCancel,
          onUpdateMessages: _handleUpdateMessages,
          locale: _locale, isRtl: _isRtl,
        );

      case 'favorites':
        return FavoritesScreen(
          favorites: _favorites, locale: _locale, isRtl: _isRtl,
          onBack: _favoritesBackTo == 'profile' ? () => _go('profile') : null,
          onBookAgain: _bookAgainFromFavorite,
          onRemove: _removeFavorite,
          onOpenCompany: _openCompanyFromFavorite,
        );

      case 'profile':
        return ProfileHomeScreen(
          profile: profile, ridesCount: _subs.length,
          unread: _unreadCount, locale: _locale, isRtl: _isRtl,
          go: _go,
          onOpenFavorites: () => setState(() { _favoritesBackTo = 'profile'; _screen = 'favorites'; }),
        );

      case 'editProfile':
        return EditProfileScreen(
          profile: profile, onBack: () => _go('profile'),
          onUpdate: _handleProfileUpdate, locale: _locale, isRtl: _isRtl,
        );

      case 'language':
        return LanguageScreen(
          profile: profile, onBack: () => _go('profile'),
          onUpdate: (p) async { await _handleProfileUpdate(p); _go('profile'); },
          locale: _locale, isRtl: _isRtl,
        );

      case 'notifications':
        return NotificationsScreen(
          notifications: _notifications,
          onBack: () => _go(profile != null ? 'home' : 'search'),
          onMarkRead: _markNotifRead, onMarkAll: _markAllNotifRead,
          locale: _locale, isRtl: _isRtl,
        );

      case 'faq':
        return FaqScreen(onBack: () => _go('profile'), locale: _locale, isRtl: _isRtl);

      case 'legal':
        return LegalScreen(onBack: () => _go('profile'), locale: _locale, isRtl: _isRtl);

      case 'logoutConfirm':
        return LogoutConfirmScreen(
          onBack: () => _go('profile'), onLogout: _handleLogout,
          locale: _locale, isRtl: _isRtl,
        );

      default:
        return HomeScreen(
          profile: profile, locale: _locale, isRtl: _isRtl,
          unread: _unreadCount, onBell: () => _go('notifications'),
          onOpenCompany: _openCompany, onGoSearch: () => _go('search'),
          onAdClick: _handleAdClick, onOpenTrending: () => _go('trending'),
          onPickTrending: _pickTrending, companyStats: _companyStats,
          isRouteFav: _isRouteFav, onToggleRouteFav: _toggleRouteFavorite,
        );
    }
  }

  Widget _ratingModal(Subscription sub) {
    int _stars = 5;
    return StatefulBuilder(builder: (ctx, setSt) {
      return GestureDetector(
        onTap: () => setState(() => _ratingSub = null),
        child: Container(
          color: Colors.black54,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(20)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(tx('rateThisRide'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: cText)),
                  const SizedBox(height: 6),
                  Text('${sub.company} · ${sub.from} → ${sub.to}', style: const TextStyle(color: cMuted, fontSize: 13)),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    for (int i = 1; i <= 5; i++)
                      GestureDetector(
                        onTap: () => setSt(() => _stars = i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(i <= _stars ? Icons.star : Icons.star_outline, color: cGold, size: 36),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: OutlinedButton(
                      onPressed: () => setState(() => _ratingSub = null),
                      child: const Text('Cancel'),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(
                      onPressed: () => _submitRating(sub.id, _stars),
                      style: ElevatedButton.styleFrom(backgroundColor: cGold, foregroundColor: cNavy),
                      child: Text(tx('submitRating')),
                    )),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      );
    });
  }
}
