import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../i18n.dart';

class OnboardingScreen extends StatefulWidget {
  final Future<void> Function(UserProfile) onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String _err = '';

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      setState(() => _err = 'Please fill in all fields');
      return;
    }
    setState(() { _loading = true; _err = ''; });
    await widget.onDone(UserProfile(name: name, phone: phone));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx = (String key) => t('en', key);
    return Scaffold(
      backgroundColor: cNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(tx('appName'), style: const TextStyle(color: cGold, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text(
                tx('createAccount'),
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx('fullName'), style: const TextStyle(color: cMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        hintText: tx('fullNamePh'),
                        hintStyle: const TextStyle(color: cMuted),
                        filled: true, fillColor: cSand,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      ),
                      style: const TextStyle(color: cText, fontSize: 15),
                    ),
                    const SizedBox(height: 14),
                    Text(tx('phoneNumber'), style: const TextStyle(color: cMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: tx('phonePh'),
                        hintStyle: const TextStyle(color: cMuted),
                        filled: true, fillColor: cSand,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      ),
                      style: const TextStyle(color: cText, fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    if (_err.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(_err, style: const TextStyle(color: cBrick, fontSize: 12)),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cGold, foregroundColor: cNavy,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: cNavy))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(tx('continueBtn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.chevron_right, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(tx('accountNote'), style: const TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
