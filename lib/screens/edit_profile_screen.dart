import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onBack;
  final Future<bool> Function(UserProfile) onUpdate;
  final String locale;
  final bool isRtl;

  const EditProfileScreen({
    super.key, required this.profile, required this.onBack,
    required this.onUpdate, required this.locale, required this.isRtl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name, _phone, _email, _eName, _ePhone;
  bool _saving = false, _saved = false;

  String tx(String key) => i18n.t(widget.locale, key);

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _name = TextEditingController(text: p.name);
    _phone = TextEditingController(text: p.phone);
    _email = TextEditingController(text: p.email);
    _eName = TextEditingController(text: p.emergencyName);
    _ePhone = TextEditingController(text: p.emergencyPhone);
  }

  @override
  void dispose() { for (final c in [_name, _phone, _email, _eName, _ePhone]) c.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _saving = true);
    final updated = widget.profile.copyWith(
      name: _name.text.trim(), phone: _phone.text.trim(),
      email: _email.text.trim(), emergencyName: _eName.text.trim(),
      emergencyPhone: _ePhone.text.trim(),
    );
    await widget.onUpdate(updated);
    setState(() { _saving = false; _saved = true; });
    Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _saved = false); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cSand,
      appBar: TopBar(
        title: tx('editProfile'),
        onBack: widget.onBack,
        isRtl: widget.isRtl,
        trailing: _saved ? const Padding(
          padding: EdgeInsets.only(right: 8),
          child: Text('Saved ✓', style: TextStyle(color: cGold, fontSize: 13, fontWeight: FontWeight.w600)),
        ) : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(children: [
          _card(tx('profile'), [
            _field(tx('fullName'), _name),
            const SizedBox(height: 12),
            _field(tx('phoneNumber'), _phone, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _field(tx('email'), _email, keyboardType: TextInputType.emailAddress),
          ]),
          const SizedBox(height: 14),
          _card(tx('emergencyContact'), [
            _field(tx('emergencyName'), _eName),
            const SizedBox(height: 12),
            _field(tx('emergencyPhone'), _ePhone, keyboardType: TextInputType.phone),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: cNavy, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(tx('saveChanges'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _card(String title, List<Widget> children) => Container(
    decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: cLine)),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cText)),
      const SizedBox(height: 12),
      ...children,
    ]),
  );

  Widget _field(String label, TextEditingController ctrl, {TextInputType? keyboardType}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: cMuted, fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl, keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true, fillColor: cSand,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
        style: const TextStyle(color: cText, fontSize: 15),
      ),
    ],
  );
}
