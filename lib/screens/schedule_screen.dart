import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';

class ScheduleScreen extends StatefulWidget {
  final TripConfig trip;
  final RideEntry ride;
  final BookingConfig config;
  final ValueChanged<BookingConfig> onConfigChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String locale;
  final bool isRtl;

  const ScheduleScreen({
    super.key, required this.trip, required this.ride, required this.config,
    required this.onConfigChanged, required this.onBack, required this.onNext,
    required this.locale, required this.isRtl,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String tx(String key, [Map<String, String>? p]) => i18n.t(widget.locale, key, p);

  static const _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  double get _planPrice {
    final r = widget.ride;
    final p = widget.config.plan;
    if (p == 'weekly') return r.priceWeekly;
    if (p == 'monthly') return r.priceMonthly;
    return r.priceDaily;
  }

  void _toggleDay(String d) {
    final days = List<String>.from(widget.config.days);
    if (days.contains(d)) days.remove(d);
    else days.add(d);
    widget.onConfigChanged(widget.config.copyWith(days: days));
  }

  void _resetMonFri() => widget.onConfigChanged(widget.config.copyWith(days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']));

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final ride = widget.ride;
    final color = hexColor(ride.colorHex);

    return Scaffold(
      backgroundColor: cSand,
      appBar: TopBar(title: tx('workingDays'), onBack: widget.onBack, isRtl: widget.isRtl),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route summary card
                  Container(
                    decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: cLine)),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 20, backgroundColor: color, child: Text(ride.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ride.company, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cText)),
                            Text('${ride.from}  →  ${ride.to}', style: const TextStyle(color: cMuted, fontSize: 12)),
                            Text(fmtTime(ride.time), style: const TextStyle(color: cNavy, fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Working days
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tx('workingDays'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cText)),
                      TextButton(
                        onPressed: _resetMonFri,
                        child: Text(tx('resetMonFri'), style: const TextStyle(color: cGold, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _allDays.map((d) {
                      final active = config.days.contains(d);
                      return GestureDetector(
                        onTap: () => _toggleDay(d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: active ? cNavy : cCard,
                            shape: BoxShape.circle,
                            border: Border.all(color: active ? cNavy : cLine),
                          ),
                          child: Center(child: Text(d.substring(0, 2), style: TextStyle(color: active ? Colors.white : cMuted, fontSize: 12, fontWeight: FontWeight.w600))),
                        ),
                      );
                    }).toList(),
                  ),
                  if (config.days.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(tx('pickDay'), style: const TextStyle(color: cBrick, fontSize: 12)),
                    ),
                  const SizedBox(height: 24),
                  // Plan selector
                  Text(tx('plan'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cText)),
                  const SizedBox(height: 10),
                  for (final plan in ['daily', 'weekly', 'monthly'])
                    _planOption(plan, config),
                  const SizedBox(height: 20),
                  // Return trip
                  Container(
                    decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: cLine)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx('eveningReturn'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cText)),
                              Text(ride.returnTimes.isNotEmpty ? ride.returnTimes.join(', ') : '—', style: const TextStyle(color: cMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                        Switch(
                          value: config.addReturn,
                          onChanged: (v) => widget.onConfigChanged(config.copyWith(addReturn: v)),
                          activeColor: cTeal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: cCard,
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: config.days.isEmpty ? null : widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cNavy, foregroundColor: Colors.white,
                    disabledBackgroundColor: cNavy.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${tx('continueBtn')} · AED ${_planPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planOption(String plan, BookingConfig config) {
    final active = config.plan == plan;
    final price = plan == 'daily' ? widget.ride.priceDaily : plan == 'weekly' ? widget.ride.priceWeekly : widget.ride.priceMonthly;
    final subtitle = plan == 'weekly' ? tx('save7') : plan == 'monthly' ? tx('bestValue') : tx('payAsYouRide');
    return GestureDetector(
      onTap: () => widget.onConfigChanged(config.copyWith(plan: plan)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: active ? cNavy : cCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? cNavy : cLine),
        ),
        child: Row(
          children: [
            if (active) const Icon(Icons.check_circle, color: cGold, size: 18) else const Icon(Icons.circle_outlined, color: cLine, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx(plan), style: TextStyle(color: active ? Colors.white : cText, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(subtitle, style: TextStyle(color: active ? Colors.white60 : cMuted, fontSize: 11)),
                ],
              ),
            ),
            Text('AED ${price.toStringAsFixed(0)}', style: TextStyle(color: active ? cGold : cNavy, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
