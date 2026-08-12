import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../catalog.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';
import '../widgets/ad_banner.dart';

class SearchScreen extends StatefulWidget {
  final TripConfig trip;
  final ValueChanged<TripConfig> onTripChanged;
  final VoidCallback onSearch;
  final UserProfile profile;
  final String locale;
  final bool isRtl;
  final int unread;
  final VoidCallback onBell;

  const SearchScreen({
    super.key,
    required this.trip,
    required this.onTripChanged,
    required this.onSearch,
    required this.profile,
    required this.locale,
    required this.isRtl,
    required this.unread,
    required this.onBell,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? _pickerOpen; // 'from' | 'to' | null

  String tx(String key) => i18n.t(widget.locale, key);

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final sameZone = trip.from == trip.to;

    return Scaffold(
      backgroundColor: cSand,
      body: Column(
        children: [
          // Ticker is shown in app.dart above BottomNav
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _header()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(delegate: SliverChildListDelegate([
                    const SizedBox(height: -20), // overlaps header
                    _card(trip, sameZone),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: sameZone ? null : widget.onSearch,
                        icon: const Icon(Icons.search, size: 17),
                        label: Text(tx('searchRides'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cGold, foregroundColor: cNavy,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          disabledBackgroundColor: cGold.withOpacity(0.4),
                        ),
                      ),
                    ),
                    if (sameZone)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(tx('zonesSame'), style: const TextStyle(color: cBrick, fontSize: 11), textAlign: TextAlign.center),
                      ),
                    const SizedBox(height: 12),
                    AdBannerWidget(ad: const AdEntry(id: 'ad1', title: 'Ramadan fares — 15% off monthly passes', sponsor: 'Dubai Carlift', grad: ['#16645C', '#0B1F2A']), onTap: () {}),
                    const SizedBox(height: 12),
                    Row(children: [const Icon(Icons.verified_user, color: cTeal, size: 14), const SizedBox(width: 6), Text(tx('verifiedCompanies'), style: const TextStyle(color: cMuted, fontSize: 12))]),
                  ])),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      color: cNavy,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i18n.t(widget.locale, 'appName'), style: const TextStyle(color: cGold, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(
                  i18n.t(widget.locale, 'greeting', {'name': widget.profile.name.split(' ').first}),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.25),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onBell,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 18),
                ),
                if (widget.unread > 0)
                  Positioned(
                    right: -3, top: -3,
                    child: Container(
                      width: 14, height: 14,
                      decoration: const BoxDecoration(color: cBrick, shape: BoxShape.circle),
                      child: Center(child: Text('${widget.unread}', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(TripConfig trip, bool sameZone) {
    return Container(
      margin: const EdgeInsets.only(top: -20),
      decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // From
          _zoneRow(Icons.location_on, cTeal, '#EAF3F2', tx('origin'), trip.from, 'from'),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Row(
              children: [
                Container(width: 2, height: 24, color: cLine, margin: const EdgeInsets.only(left: 10)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, size: 18, color: cNavy),
                  onPressed: () => widget.onTripChanged(trip.copyWith(from: trip.to, to: trip.from)),
                  style: IconButton.styleFrom(backgroundColor: cSand, minimumSize: const Size(32, 32)),
                ),
              ],
            ),
          ),
          // To
          _zoneRow(Icons.location_on, cGoldDeep, '#FBF0DE', tx('destination'), trip.to, 'to'),
          // Zone picker dropdown
          if (_pickerOpen != null) _zonePicker(trip),
          // Trip type
          const Divider(height: 24, color: cLine),
          Row(
            children: [
              Expanded(child: _typeBtn(tx('oneWay'), 'oneway', trip.tripType, () => widget.onTripChanged(trip.copyWith(tripType: 'oneway')))),
              const SizedBox(width: 8),
              Expanded(child: _typeBtn(tx('roundTrip'), 'roundtrip', trip.tripType, () => widget.onTripChanged(trip.copyWith(tripType: 'roundtrip')))),
            ],
          ),
          const SizedBox(height: 12),
          // Departure time
          Row(
            children: [
              const Icon(Icons.access_time, color: cMuted, size: 16),
              const SizedBox(width: 8),
              Text(tx('departureTime'), style: const TextStyle(color: cMuted, fontSize: 13)),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final parts = trip.time.split(':');
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
                  );
                  if (picked != null) {
                    widget.onTripChanged(trip.copyWith(time: '${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}'));
                  }
                },
                child: Text(fmtTime(trip.time), style: const TextStyle(color: cNavy, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          if (trip.tripType == 'roundtrip') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, color: cGoldDeep, size: 16),
                const SizedBox(width: 8),
                Text(tx('returnTime'), style: const TextStyle(color: cMuted, fontSize: 13)),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final parts = trip.returnTime.split(':');
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
                    );
                    if (picked != null) {
                      widget.onTripChanged(trip.copyWith(returnTime: '${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}'));
                    }
                  },
                  child: Text(fmtTime(trip.returnTime), style: const TextStyle(color: cGoldDeep, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ],
          // Duration
          const Divider(height: 24, color: cLine),
          Row(
            children: [
              Text(tx('planDuration'), style: const TextStyle(color: cMuted, fontSize: 11)),
              const Spacer(),
              Text('${trip.durationDays} ${tx('daysUnit')}', style: const TextStyle(color: cNavy, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(activeTrackColor: cGold, thumbColor: cGold, inactiveTrackColor: cLine, overlayColor: cGold.withOpacity(0.15), trackHeight: 3),
            child: Slider(
              value: trip.durationDays.toDouble(), min: 1, max: 90,
              onChanged: (v) {
                final days = v.round();
                widget.onTripChanged(trip.copyWith(durationDays: days, frequency: planForDuration(days)));
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final f in ['daily', 'weekly', 'monthly'])
                _planBtn(tx(f), f, trip.frequency, () {
                  int days = trip.durationDays;
                  if (f == 'daily') days = days.clamp(1, 6);
                  else if (f == 'weekly') days = days.clamp(7, 27);
                  else days = days < 28 ? 28 : days;
                  widget.onTripChanged(trip.copyWith(frequency: f, durationDays: days));
                }),
            ],
          ),
          const SizedBox(height: 4),
          Text('${tx('suggestedPlan')}: ${tx(planForDuration(trip.durationDays))}', style: const TextStyle(color: cMuted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _zoneRow(IconData icon, Color iconColor, String bg, String label, String value, String field) {
    return GestureDetector(
      onTap: () => setState(() => _pickerOpen = _pickerOpen == field ? null : field),
      child: Row(
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: hexColor(bg), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 16)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: cMuted, fontSize: 11, fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(color: cText, fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _zonePicker(TripConfig trip) {
    final zones = _pickerOpen == 'from' ? pickupZones : destZones;
    final current = _pickerOpen == 'from' ? trip.from : trip.to;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: zones.map((z) => GestureDetector(
          onTap: () {
            if (_pickerOpen == 'from') widget.onTripChanged(trip.copyWith(from: z));
            else widget.onTripChanged(trip.copyWith(to: z));
            setState(() => _pickerOpen = null);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: z == current ? cNavy : cSand,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: z == current ? cNavy : cLine),
            ),
            child: Text(z, style: TextStyle(color: z == current ? Colors.white : cText, fontSize: 13)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _typeBtn(String label, String value, String current, VoidCallback onTap) {
    final active = value == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? cNavy : cSand,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(label, style: TextStyle(color: active ? Colors.white : cMuted, fontSize: 12, fontWeight: FontWeight.w600))),
      ),
    );
  }

  Widget _planBtn(String label, String value, String current, VoidCallback onTap) {
    final active = value == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? cNavy : cSand,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : cMuted, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
