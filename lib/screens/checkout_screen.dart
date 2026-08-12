import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';
import '../widgets/ad_banner.dart';

class CheckoutScreen extends StatefulWidget {
  final TripConfig trip;
  final RideEntry ride;
  final BookingConfig config;
  final VoidCallback onBack;
  final Future<void> Function(String method) onPaid;
  final String locale;
  final bool isRtl;

  const CheckoutScreen({
    super.key, required this.trip, required this.ride, required this.config,
    required this.onBack, required this.onPaid, required this.locale, required this.isRtl,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _method = 'card';
  bool _processing = false;

  String tx(String key) => i18n.t(widget.locale, key);

  double get _total {
    final r = widget.ride;
    final p = widget.config.plan;
    if (p == 'weekly') return r.priceWeekly;
    if (p == 'monthly') return r.priceMonthly;
    return r.priceDaily;
  }

  Future<void> _pay() async {
    setState(() => _processing = true);
    await widget.onPaid(_method);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cSand,
      appBar: TopBar(title: tx('checkout'), onBack: widget.onBack, isRtl: widget.isRtl),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order summary
                  _section(tx('reserveSeat'), [
                    _row(tx('planLabel'), tx(widget.config.plan)),
                    _row('${tx('from')} → ${tx('to')}', '${widget.trip.from} → ${widget.trip.to}'),
                    _row(tx('driverLabel'), widget.ride.driver),
                    _row(tx('departsLabel'), fmtTime(widget.ride.time)),
                    _row(tx('daysLabel'), widget.config.days.join(', ')),
                    const Divider(color: cLine, height: 20),
                    _row('Total', 'AED ${_total.toStringAsFixed(0)}', bold: true),
                  ]),
                  const SizedBox(height: 16),
                  // Payment method
                  Text(tx('paymentMethod'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cText)),
                  const SizedBox(height: 10),
                  for (final m in ['tabby', 'card', 'cash'])
                    _methodTile(m),
                  const SizedBox(height: 16),
                  if (_method == 'tabby')
                    _section(tx('tabby'), [
                      Text(tx('splitPayments'), style: const TextStyle(color: cText, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(tx('firstPaymentNote'), style: const TextStyle(color: cMuted, fontSize: 12)),
                    ]),
                  if (_method == 'card')
                    _section(tx('card'), [
                      _field(tx('cardNumber'), '•••• •••• •••• ••••'),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _field(tx('expiry'), 'MM/YY')),
                        const SizedBox(width: 10),
                        Expanded(child: _field(tx('cvc'), '•••')),
                      ]),
                    ]),
                  const SizedBox(height: 16),
                  AdBannerWidget(
                    ad: const AdEntry(id: 'ad3', title: 'Add Tabby to any plan, split in 4', sponsor: 'Tabby', grad: ['#132C3A', '#16645C']),
                    onTap: () {},
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
                  onPressed: _processing ? null : _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cGold, foregroundColor: cNavy,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _processing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: cNavy))
                      : Text('${tx('pay')} ${_total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _methodTile(String m) {
    final active = _method == m;
    final icons = {'tabby': Icons.splitscreen, 'card': Icons.credit_card, 'cash': Icons.payments};
    return GestureDetector(
      onTap: () => setState(() => _method = m),
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
            Icon(icons[m] ?? Icons.payment, color: active ? cGold : cMuted, size: 20),
            const SizedBox(width: 12),
            Text(i18n.t(widget.locale, m), style: TextStyle(color: active ? Colors.white : cText, fontWeight: FontWeight.w600, fontSize: 14)),
            const Spacer(),
            if (active) const Icon(Icons.check_circle, color: cGold, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: cLine)),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cText)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: cMuted, fontSize: 13)),
          Text(value, style: TextStyle(color: cText, fontSize: 13, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _field(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: cMuted, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(color: cSand, borderRadius: BorderRadius.circular(8)),
          child: Text(hint, style: const TextStyle(color: cMuted, fontSize: 14)),
        ),
      ],
    );
  }
}

// Helper to get 'from' and 'to' keys safely
extension on String { String get from => 'from'; String get to => 'to'; }
