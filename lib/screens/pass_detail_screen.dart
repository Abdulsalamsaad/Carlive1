import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';
import '../widgets/ad_banner.dart';

class PassDetailScreen extends StatefulWidget {
  final Subscription sub;
  final VoidCallback onBack;
  final Future<void> Function(String id) onCancel;
  final void Function(String id, List<Map<String, dynamic>> msgs) onUpdateMessages;
  final String locale;
  final bool isRtl;

  const PassDetailScreen({
    super.key, required this.sub, required this.onBack,
    required this.onCancel, required this.onUpdateMessages,
    required this.locale, required this.isRtl,
  });

  @override
  State<PassDetailScreen> createState() => _PassDetailScreenState();
}

class _PassDetailScreenState extends State<PassDetailScreen> {
  bool _showCancelDialog = false;
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  String tx(String key, [Map<String, String>? p]) => i18n.t(widget.locale, key, p);

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  void _sendMsg() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    final msgs = [...widget.sub.messages, {'from': 'passenger', 'text': text, 'ts': DateTime.now().millisecondsSinceEpoch}];
    widget.onUpdateMessages(widget.sub.id, msgs);
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sub;
    final color = hexColor(s.colorHex);
    final isActive = s.status == 'active';

    return Scaffold(
      backgroundColor: cSand,
      appBar: TopBar(title: tx('myPass'), onBack: widget.onBack, isRtl: widget.isRtl),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pass card
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: [color, cNavy], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CircleAvatar(radius: 18, backgroundColor: Colors.white24,
                          child: Text(s.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                        const SizedBox(width: 10),
                        Expanded(child: Text(s.company, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: isActive ? cTeal : Colors.white24, borderRadius: BorderRadius.circular(6)),
                          child: Text(isActive ? tx('active') : tx('cancelledStatus'),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      Row(children: [
                        _statBlock(tx('planLabel'), s.plan.toUpperCase()),
                        const SizedBox(width: 20),
                        _statBlock(tx('daysLabel'), '${s.durationDays}'),
                        const SizedBox(width: 20),
                        _statBlock(tx('departsLabel'), s.departureLabel),
                      ]),
                      const SizedBox(height: 12),
                      Text('${s.from}  →  ${s.to}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(s.days.join(' · '), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Live tracker card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: cLine)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.location_on, color: cTeal, size: 16),
                      const SizedBox(width: 6),
                      Text(tx('liveTracker'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cText)),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(tx('arriving'), style: const TextStyle(color: cTeal, fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(tx('stopsAway'), style: const TextStyle(color: cMuted, fontSize: 12)),
                        Text(tx('seatsFilled'), style: const TextStyle(color: cMuted, fontSize: 12)),
                      ])),
                      Container(width: 80, height: 60, decoration: BoxDecoration(color: cNavy, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.directions_bus, color: cGold, size: 32)),
                    ]),
                    const SizedBox(height: 10),
                    // Stop pins row
                    if (s.stopPins.isNotEmpty)
                      Row(
                        children: s.stopPins.map((pin) => Expanded(child: Column(children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: cGold, shape: BoxShape.circle)),
                          const SizedBox(height: 4),
                          Text(pin['name'] ?? '', style: const TextStyle(color: cMuted, fontSize: 9), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ]))).toList(),
                      ),
                  ]),
                ),
                const SizedBox(height: 16),
                // Driver info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: cLine)),
                  child: Row(children: [
                    CircleAvatar(radius: 22, backgroundColor: hexColor(s.colorHex),
                      child: Text(s.initials.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(tx('driverLabel'), style: const TextStyle(color: cMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                      Text(s.driverName, style: const TextStyle(color: cText, fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('Bus ${s.bus}', style: const TextStyle(color: cMuted, fontSize: 12)),
                    ])),
                    IconButton(icon: const Icon(Icons.phone, color: cTeal, size: 22), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.chat_bubble_outline, color: cNavy, size: 20), onPressed: () {}),
                  ]),
                ),
                const SizedBox(height: 16),
                // Messages
                Text(tx('driverLabel'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cText)),
                const SizedBox(height: 8),
                if (widget.sub.messages.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: cLine)),
                    child: const Text('No messages yet.', style: TextStyle(color: cMuted, fontSize: 13)),
                  )
                else
                  for (final m in widget.sub.messages)
                    Align(
                      alignment: m['from'] == 'passenger' ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: m['from'] == 'passenger' ? cNavy : cCard,
                          borderRadius: BorderRadius.circular(12),
                          border: m['from'] == 'passenger' ? null : Border.all(color: cLine),
                        ),
                        child: Text(m['text'] ?? '', style: TextStyle(color: m['from'] == 'passenger' ? Colors.white : cText, fontSize: 13)),
                      ),
                    ),
                const SizedBox(height: 8),
                // Message input
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: InputDecoration(
                        hintText: 'Message driver…',
                        filled: true, fillColor: cCard,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: cLine)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMsg,
                    child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: cNavy, shape: BoxShape.circle),
                      child: const Icon(Icons.send, color: Colors.white, size: 18)),
                  ),
                ]),
                if (isActive) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => setState(() => _showCancelDialog = true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cBrick, side: const BorderSide(color: cBrick),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(tx('cancelRide'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Cancel dialog overlay
          if (_showCancelDialog)
            GestureDetector(
              onTap: () => setState(() => _showCancelDialog = false),
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
                        Text(tx('confirmCancel', {'plan': widget.sub.plan}),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cText), textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(child: OutlinedButton(
                            onPressed: () => setState(() => _showCancelDialog = false),
                            child: Text(tx('keepPass')),
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: ElevatedButton(
                            onPressed: () { setState(() => _showCancelDialog = false); widget.onCancel(widget.sub.id); },
                            style: ElevatedButton.styleFrom(backgroundColor: cBrick, foregroundColor: Colors.white),
                            child: Text(tx('yesCancel')),
                          )),
                        ]),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statBlock(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600)),
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
  ]);
}
