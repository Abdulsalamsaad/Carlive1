import 'package:flutter/material.dart';

// Design tokens — mirrors the React CarliftApp's `C` object
const Color cNavy     = Color(0xFF0B1F2A);
const Color cNavySoft = Color(0xFF132C3A);
const Color cSand     = Color(0xFFF2F6F5);
const Color cCard     = Color(0xFFFFFFFF);
const Color cGold     = Color(0xFFE8A33D);
const Color cGoldDeep = Color(0xFFC6821F);
const Color cTeal     = Color(0xFF16645C);
const Color cBrick    = Color(0xFFC4432B);
const Color cText     = Color(0xFF14202B);
const Color cMuted    = Color(0xFF5C6B70);
const Color cLine     = Color(0xFFE1E7E6);

const List<String> rtlLocales = ['ar', 'ur'];

// Map hex string (from catalog) back to a Color
Color hexColor(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

// Format "HH:MM" (24h) → "H:MM AM/PM"
String fmtTime(String hhmm) {
  final parts = hhmm.split(':');
  final h = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  final period = h >= 12 ? 'PM' : 'AM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} $period';
}

// Minutes since midnight
int minutesFrom(String hhmm) {
  final parts = hhmm.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

// Plan tier from duration days
String planForDuration(int days) {
  if (days <= 6) return 'daily';
  if (days <= 27) return 'weekly';
  return 'monthly';
}

// Interpolate template strings — replaces {{key}} with values
String interpolate(String template, Map<String, String> values) {
  var result = template;
  values.forEach((k, v) { result = result.replaceAll('{{$k}}', v); });
  return result;
}
