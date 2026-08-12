import 'models.dart';
import 'constants.dart';

// ---------------------------------------------------------------------------
// Ride catalog — mirrors CATALOG in CarliftApp.tsx
// ---------------------------------------------------------------------------
const List<RideEntry> catalog = [
  RideEntry(
    id: 'r1', company: 'Arabia Transit', initials: 'AR', rating: 4.8,
    from: 'Satwa', to: 'Dubai Marina', time: '07:15', duration: 35,
    stops: ['Satwa Rbt', 'Al Wasl Rd', 'Marina Mall'], seatsLeft: 4,
    priceDaily: 15, priceWeekly: 70, priceMonthly: 250,
    colorHex: '#16645C', driver: 'Ahmed R.', phone: '+971 50 123 4567',
    bus: '-114', returnTimes: ['17:00', '17:30', '18:00'], bookings: 340, distanceKm: 1.2,
    stopPins: [{'name':'Satwa Rbt','x':12,'y':68},{'name':'Al Wasl Rd','x':48,'y':40},{'name':'Marina Mall','x':86,'y':22}],
  ),
  RideEntry(
    id: 'r1b', company: 'Arabia Transit', initials: 'AR', rating: 4.8,
    from: 'Satwa', to: 'Dubai Marina', time: '08:30', duration: 35,
    stops: ['Satwa Rbt', 'Al Wasl Rd', 'Marina Mall'], seatsLeft: 6,
    priceDaily: 15, priceWeekly: 70, priceMonthly: 250,
    colorHex: '#16645C', driver: 'Ahmed R.', phone: '+971 50 123 4567',
    bus: '-114', returnTimes: ['17:30', '18:00'], bookings: 205, distanceKm: 1.2,
    stopPins: [{'name':'Satwa Rbt','x':12,'y':68},{'name':'Al Wasl Rd','x':48,'y':40},{'name':'Marina Mall','x':86,'y':22}],
  ),
  RideEntry(
    id: 'r2', company: 'Nawaz Carlift', initials: 'NW', rating: 4.6,
    from: 'Satwa', to: 'Dubai Marina', time: '07:45', duration: 40,
    stops: ['Satwa Sq', 'Jumeirah Rd', 'JBR Walk'], seatsLeft: 2,
    priceDaily: 14, priceWeekly: 65, priceMonthly: 235,
    colorHex: '#E8A33D', driver: 'Yousef K.', phone: '+971 52 987 6543',
    bus: '-207', returnTimes: ['17:15', '18:15'], bookings: 512, distanceKm: 2.4,
    stopPins: [{'name':'Satwa Sq','x':10,'y':72},{'name':'Jumeirah Rd','x':52,'y':46},{'name':'JBR Walk','x':90,'y':18}],
  ),
  RideEntry(
    id: 'r3', company: 'Anazik Mobility', initials: 'AZ', rating: 4.9,
    from: 'Satwa', to: 'Dubai Marina', time: '08:00', duration: 30,
    stops: ['Satwa Metro', 'Marina Mall'], seatsLeft: 9,
    priceDaily: 16, priceWeekly: 75, priceMonthly: 260,
    colorHex: '#C4432B', driver: 'Rashid M.', phone: '+971 55 456 7890',
    bus: '-332', returnTimes: ['17:00', '17:45', '18:30'], bookings: 618, distanceKm: 0.8,
    stopPins: [{'name':'Satwa Metro','x':14,'y':64},{'name':'Marina Mall','x':88,'y':20}],
  ),
  RideEntry(
    id: 'r4', company: 'Nawaz Carlift', initials: 'NW', rating: 4.6,
    from: 'Karama', to: 'JBR', time: '07:30', duration: 42,
    stops: ['Karama Centre', 'Sheikh Zayed Rd', 'JBR Beach'], seatsLeft: 5,
    priceDaily: 17, priceWeekly: 78, priceMonthly: 270,
    colorHex: '#E8A33D', driver: 'Yousef K.', phone: '+971 52 987 6543',
    bus: '-208', returnTimes: ['17:30'], bookings: 148, distanceKm: 3.1,
    stopPins: [{'name':'Karama Centre','x':15,'y':70},{'name':'Sheikh Zayed Rd','x':50,'y':45},{'name':'JBR Beach','x':88,'y':24}],
  ),
];

const Map<String, List<BusSlot>> fleetData = {
  'Arabia Transit': [
    BusSlot(busNumber: 'AR-114', vehicleType: 'Coaster', capacity: 14, seatsAvailable: 4, timings: ['07:15', '08:30', '17:00', '17:30'], interval: '45–75 min'),
    BusSlot(busNumber: 'AR-119', vehicleType: 'Minibus', capacity: 10, seatsAvailable: 7, timings: ['07:45', '16:45'], interval: 'Twice daily'),
    BusSlot(busNumber: 'AR-122', vehicleType: 'Coaster', capacity: 14, seatsAvailable: 2, timings: ['06:45', '18:00'], interval: 'Peak hours only'),
  ],
  'Nawaz Carlift': [
    BusSlot(busNumber: 'NW-207', vehicleType: 'Minibus', capacity: 12, seatsAvailable: 2, timings: ['07:45', '17:15', '18:15'], interval: '30–60 min'),
    BusSlot(busNumber: 'NW-208', vehicleType: 'Coaster', capacity: 14, seatsAvailable: 5, timings: ['07:30', '17:30'], interval: 'Twice daily'),
  ],
  'Anazik Mobility': [
    BusSlot(busNumber: 'AZ-332', vehicleType: 'Coaster', capacity: 14, seatsAvailable: 9, timings: ['08:00', '17:00', '17:45', '18:30'], interval: '30–45 min'),
    BusSlot(busNumber: 'AZ-340', vehicleType: 'Minibus', capacity: 10, seatsAvailable: 6, timings: ['06:30', '16:30'], interval: 'Twice daily'),
    BusSlot(busNumber: 'AZ-345', vehicleType: 'Coaster', capacity: 14, seatsAvailable: 10, timings: ['09:00', '15:00'], interval: 'Off-peak'),
  ],
};

const Map<String, Map<String, dynamic>> companyRatingDefaults = {
  'Arabia Transit': {'rating': 4.8, 'reviewCount': 142},
  'Nawaz Carlift': {'rating': 4.6, 'reviewCount': 98},
  'Anazik Mobility': {'rating': 4.9, 'reviewCount': 210},
};

CompanyStats ratingFor(String companyName, Map<String, CompanyStats> stats) {
  if (stats.containsKey(companyName)) return stats[companyName]!;
  final d = companyRatingDefaults[companyName];
  if (d != null) return CompanyStats(rating: (d['rating'] as num).toDouble(), reviewCount: d['reviewCount'] as int);
  return const CompanyStats(rating: 0, reviewCount: 0);
}

List<CompanyEntry> buildCompanies() => [
  CompanyEntry(
    id: 'arabia', name: 'Arabia Transit', initials: 'AR', colorHex: '#16645C',
    fleetSize: 22, tagline: 'Satwa · Karama · Bur Dubai corridors',
    rating: 4.8, reviewCount: 142,
    routes: catalog.where((r) => r.company == 'Arabia Transit').toList(),
  ),
  CompanyEntry(
    id: 'nawaz', name: 'Nawaz Carlift', initials: 'NW', colorHex: '#E8A33D',
    fleetSize: 15, tagline: 'Karama · JBR · JLT corridors',
    rating: 4.6, reviewCount: 98,
    routes: catalog.where((r) => r.company == 'Nawaz Carlift').toList(),
  ),
  CompanyEntry(
    id: 'anazik', name: 'Anazik Mobility', initials: 'AZ', colorHex: '#C4432B',
    fleetSize: 30, tagline: 'Satwa · Marina express routes',
    rating: 4.9, reviewCount: 210,
    routes: catalog.where((r) => r.company == 'Anazik Mobility').toList(),
  ),
];

List<RideEntry> get trending => [...catalog]..sort((a, b) => b.bookings.compareTo(a.bookings));

const Map<String, AdEntry> ads = {
  'home_hero': AdEntry(id: 'ad1', title: 'Ramadan fares — 15% off monthly passes', sponsor: 'Dubai Carlift', grad: ['#16645C', '#0B1F2A']),
  'search_results': AdEntry(id: 'ad2', title: 'Arabia Transit — 20% off your first month', sponsor: 'Arabia Transit', grad: ['#E8A33D', '#C6821F']),
  'ticket_screen': AdEntry(id: 'ad3', title: 'Add Tabby to any plan, split in 4', sponsor: 'Tabby', grad: ['#132C3A', '#16645C']),
  'passenger_profile': AdEntry(id: 'ad4', title: 'Corporate partner: 10% off for DIFC employees', sponsor: 'DIFC Partnership', grad: ['#6B5CA5', '#0B1F2A']),
};

const List<AdEntry> homeAds = [
  AdEntry(id: 'ad1', title: 'Ramadan fares — 15% off monthly passes', sponsor: 'Dubai Carlift', grad: ['#16645C', '#0B1F2A'], linkType: 'external', url: 'https://example.com/promo/ramadan-fares'),
  AdEntry(id: 'ad1b', title: 'Anazik Mobility — new Marina Express route now live', sponsor: 'Anazik Mobility', grad: ['#C4432B', '#6B5CA5'], linkType: 'company', companyId: 'anazik'),
  AdEntry(id: 'ad1c', title: 'Refer a friend, get 1 week free', sponsor: 'Dubai Carlift', grad: ['#E8A33D', '#C6821F'], linkType: 'external', url: 'https://example.com/promo/referral'),
  AdEntry(id: 'ad1d', title: 'Nawaz Carlift — now serving JLT & Business Bay', sponsor: 'Nawaz Carlift', grad: ['#132C3A', '#16645C'], linkType: 'company', companyId: 'nawaz'),
];

const List<String> pickupZones = ['Satwa', 'Karama', 'Bur Dubai', 'Deira', 'Al Quoz', 'Al Barsha', 'Jumeirah'];
const List<String> destZones = ['Dubai Marina', 'JBR', 'JLT', 'DIFC', 'Business Bay', 'Downtown', 'Dubai Hills'];

String? closestReturnTime(RideEntry ride, String requestedHHMM) {
  if (ride.returnTimes.isEmpty) return null;
  final target = minutesFrom(requestedHHMM);
  String? best;
  int bestDiff = 999999;
  for (final rt in ride.returnTimes) {
    final diff = (minutesFrom(rt) - target).abs();
    if (diff < bestDiff) { bestDiff = diff; best = rt; }
  }
  return bestDiff <= 90 ? best : null;
}
