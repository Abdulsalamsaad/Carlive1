// ---------------------------------------------------------------------------
// Data models — mirrors the React app's runtime object shapes
// ---------------------------------------------------------------------------

class RideEntry {
  final String id, company, initials, from, to, time, driver, phone, bus;
  final double rating;
  final int duration, seatsLeft, bookings;
  final double priceDaily, priceWeekly, priceMonthly, distanceKm;
  final String colorHex;
  final List<String> stops, returnTimes;
  final List<Map<String, dynamic>> stopPins;

  const RideEntry({
    required this.id, required this.company, required this.initials,
    required this.from, required this.to, required this.time,
    required this.rating, required this.duration, required this.seatsLeft,
    required this.bookings, required this.priceDaily, required this.priceWeekly,
    required this.priceMonthly, required this.distanceKm, required this.colorHex,
    required this.driver, required this.phone, required this.bus,
    required this.stops, required this.returnTimes, required this.stopPins,
  });
}

class CompanyEntry {
  final String id, name, initials, tagline, colorHex;
  final int fleetSize;
  final double rating;
  final int reviewCount;
  final List<RideEntry> routes;

  const CompanyEntry({
    required this.id, required this.name, required this.initials,
    required this.tagline, required this.colorHex, required this.fleetSize,
    required this.rating, required this.reviewCount, required this.routes,
  });
}

class BusSlot {
  final String busNumber, vehicleType, interval;
  final int capacity, seatsAvailable;
  final List<String> timings;
  const BusSlot({
    required this.busNumber, required this.vehicleType, required this.interval,
    required this.capacity, required this.seatsAvailable, required this.timings,
  });
}

class AdEntry {
  final String id, title, sponsor;
  final List<String> grad;
  final String? linkType, companyId, url;
  const AdEntry({
    required this.id, required this.title, required this.sponsor,
    required this.grad, this.linkType, this.companyId, this.url,
  });
}

class UserProfile {
  final String name, phone;
  final String email, emergencyName, emergencyPhone, preferredLanguage;
  const UserProfile({
    required this.name, required this.phone,
    this.email = '', this.emergencyName = '', this.emergencyPhone = '',
    this.preferredLanguage = 'en',
  });

  UserProfile copyWith({
    String? name, String? phone, String? email,
    String? emergencyName, String? emergencyPhone, String? preferredLanguage,
  }) => UserProfile(
    name: name ?? this.name, phone: phone ?? this.phone,
    email: email ?? this.email, emergencyName: emergencyName ?? this.emergencyName,
    emergencyPhone: emergencyPhone ?? this.emergencyPhone,
    preferredLanguage: preferredLanguage ?? this.preferredLanguage,
  );

  Map<String, dynamic> toJson() => {
    'name': name, 'phone': phone, 'email': email,
    'emergencyName': emergencyName, 'emergencyPhone': emergencyPhone,
    'preferredLanguage': preferredLanguage,
  };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    name: j['name'] ?? '', phone: j['phone'] ?? '',
    email: j['email'] ?? '', emergencyName: j['emergencyName'] ?? '',
    emergencyPhone: j['emergencyPhone'] ?? '',
    preferredLanguage: j['preferredLanguage'] ?? 'en',
  );
}

class Subscription {
  final String id, from, to, company, initials, colorHex;
  final String departureLabel, plan, driverName, driverPhone, bus, endDate, paymentMethod;
  final int durationDays;
  final double price;
  final List<String> days;
  final String status;
  final List<Map<String, dynamic>> messages, stopPins;
  final bool hasRated;
  final int ratingGiven;

  const Subscription({
    required this.id, required this.from, required this.to,
    required this.company, required this.initials, required this.colorHex,
    required this.departureLabel, required this.plan, required this.driverName,
    required this.driverPhone, required this.bus, required this.endDate,
    required this.paymentMethod, required this.durationDays, required this.price,
    required this.days, required this.status, required this.messages,
    required this.stopPins, this.hasRated = false, this.ratingGiven = 0,
  });

  Subscription copyWith({
    String? status, List<Map<String, dynamic>>? messages,
    bool? hasRated, int? ratingGiven,
  }) => Subscription(
    id: id, from: from, to: to, company: company, initials: initials,
    colorHex: colorHex, departureLabel: departureLabel, plan: plan,
    driverName: driverName, driverPhone: driverPhone, bus: bus,
    endDate: endDate, paymentMethod: paymentMethod, durationDays: durationDays,
    price: price, days: days, status: status ?? this.status,
    messages: messages ?? this.messages, stopPins: stopPins,
    hasRated: hasRated ?? this.hasRated, ratingGiven: ratingGiven ?? this.ratingGiven,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'from': from, 'to': to, 'company': company, 'initials': initials,
    'colorHex': colorHex, 'departureLabel': departureLabel, 'plan': plan,
    'driverName': driverName, 'driverPhone': driverPhone, 'bus': bus,
    'endDate': endDate, 'paymentMethod': paymentMethod,
    'durationDays': durationDays, 'price': price, 'days': days,
    'status': status, 'messages': messages, 'stopPins': stopPins,
    'hasRated': hasRated, 'ratingGiven': ratingGiven,
  };

  factory Subscription.fromJson(Map<String, dynamic> j) => Subscription(
    id: j['id'] ?? '', from: j['from'] ?? '', to: j['to'] ?? '',
    company: j['company'] ?? '', initials: j['initials'] ?? '',
    colorHex: j['colorHex'] ?? '#0B1F2A',
    departureLabel: j['departureLabel'] ?? '', plan: j['plan'] ?? 'daily',
    driverName: j['driverName'] ?? '', driverPhone: j['driverPhone'] ?? '',
    bus: j['bus'] ?? '', endDate: j['endDate'] ?? '',
    paymentMethod: j['paymentMethod'] ?? '', durationDays: j['durationDays'] ?? 1,
    price: (j['price'] ?? 0).toDouble(),
    days: List<String>.from(j['days'] ?? []),
    status: j['status'] ?? 'active',
    messages: List<Map<String, dynamic>>.from(j['messages'] ?? []),
    stopPins: List<Map<String, dynamic>>.from(j['stopPins'] ?? []),
    hasRated: j['hasRated'] ?? false, ratingGiven: j['ratingGiven'] ?? 0,
  );
}

class FavoriteEntry {
  final String id, type;
  // route
  final String? rideId, from, to, time;
  // company
  final String? companyId, tagline;
  // shared
  final String? company, name, initials, colorHex;

  const FavoriteEntry({
    required this.id, required this.type,
    this.rideId, this.from, this.to, this.time,
    this.companyId, this.tagline,
    this.company, this.name, this.initials, this.colorHex,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'rideId': rideId, 'from': from, 'to': to,
    'time': time, 'companyId': companyId, 'tagline': tagline,
    'company': company, 'name': name, 'initials': initials, 'colorHex': colorHex,
  };

  factory FavoriteEntry.fromJson(Map<String, dynamic> j) => FavoriteEntry(
    id: j['id'] ?? '', type: j['type'] ?? 'route',
    rideId: j['rideId'], from: j['from'], to: j['to'], time: j['time'],
    companyId: j['companyId'], tagline: j['tagline'],
    company: j['company'], name: j['name'], initials: j['initials'],
    colorHex: j['colorHex'],
  );
}

class NotificationEntry {
  final String id, type, title, body;
  final bool isRead;

  const NotificationEntry({
    required this.id, required this.type,
    required this.title, required this.body, required this.isRead,
  });

  NotificationEntry copyWith({bool? isRead}) =>
    NotificationEntry(id: id, type: type, title: title, body: body, isRead: isRead ?? this.isRead);

  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'title': title, 'body': body, 'isRead': isRead};

  factory NotificationEntry.fromJson(Map<String, dynamic> j) => NotificationEntry(
    id: j['id'] ?? '', type: j['type'] ?? 'system',
    title: j['title'] ?? '', body: j['body'] ?? '', isRead: j['isRead'] ?? false,
  );
}

class CompanyStats {
  final double rating;
  final int reviewCount;
  const CompanyStats({required this.rating, required this.reviewCount});
  Map<String, dynamic> toJson() => {'rating': rating, 'reviewCount': reviewCount};
  factory CompanyStats.fromJson(Map<String, dynamic> j) =>
    CompanyStats(rating: (j['rating'] ?? 0).toDouble(), reviewCount: j['reviewCount'] ?? 0);
}

class TripConfig {
  final String from, to, time, frequency, tripType, returnTime;
  final int durationDays;
  const TripConfig({
    this.from = 'Satwa', this.to = 'Dubai Marina',
    this.time = '07:15', this.frequency = 'monthly',
    this.tripType = 'oneway', this.returnTime = '17:00',
    this.durationDays = 28,
  });
  TripConfig copyWith({
    String? from, String? to, String? time, String? frequency,
    String? tripType, String? returnTime, int? durationDays,
  }) => TripConfig(
    from: from ?? this.from, to: to ?? this.to, time: time ?? this.time,
    frequency: frequency ?? this.frequency, tripType: tripType ?? this.tripType,
    returnTime: returnTime ?? this.returnTime, durationDays: durationDays ?? this.durationDays,
  );
}

class BookingConfig {
  final List<String> days;
  final String plan;
  final bool addReturn;
  const BookingConfig({
    this.days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    this.plan = 'monthly', this.addReturn = false,
  });
  BookingConfig copyWith({List<String>? days, String? plan, bool? addReturn}) =>
    BookingConfig(
      days: days ?? this.days, plan: plan ?? this.plan,
      addReturn: addReturn ?? this.addReturn,
    );
}
