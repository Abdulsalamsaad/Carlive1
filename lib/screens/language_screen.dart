import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';

class LanguageScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onBack;
  final Future<void> Function(UserProfile) onUpdate;
  final String locale;
  final bool isRtl;

  const LanguageScreen({
    super.key, required this.profile, required this.onBack,
    required this.onUpdate, required this.locale, required this.isRtl,
  });

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selected;

  static const _langs = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'ar', 'name': 'Arabic', 'native': 'العربية'},
    {'code': 'ur', 'name': 'Urdu', 'native': 'اردو'},
    {'code': 'ne', 'name': 'Nepali', 'native': 'नेपाली'},
    {'code': 'tl', 'name': 'Filipino', 'native': 'Filipino'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.profile.preferredLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final tx = (String key) => i18n.t(widget.locale, key);
    return Scaffold(
      backgroundColor: cSand,
      appBar: TopBar(title: tx('language'), onBack: widget.onBack, isRtl: widget.isRtl),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _langs.length,
        itemBuilder: (ctx, i) {
          final lang = _langs[i];
          final active = _selected == lang['code'];
          return GestureDetector(
            onTap: () async {
              setState(() => _selected = lang['code']!);
              await widget.onUpdate(widget.profile.copyWith(preferredLanguage: lang['code']));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: active ? cNavy : cCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: active ? cNavy : cLine),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(lang['name']!, style: TextStyle(color: active ? Colors.white : cText, fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(lang['native']!, style: TextStyle(color: active ? Colors.white60 : cMuted, fontSize: 13)),
                ])),
                if (active) const Icon(Icons.check_circle, color: cGold, size: 20),
              ]),
            ),
          );
        },
      ),
    );
  }
}
