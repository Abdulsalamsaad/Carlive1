import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../catalog.dart';
import '../i18n.dart' as i18n;
import '../widgets/top_bar.dart';

class FavoritesScreen extends StatelessWidget {
  final List<FavoriteEntry> favorites;
  final String locale;
  final bool isRtl;
  final VoidCallback? onBack;
  final void Function(FavoriteEntry) onBookAgain;
  final void Function(String) onRemove;
  final void Function(FavoriteEntry) onOpenCompany;

  const FavoritesScreen({
    super.key, required this.favorites, required this.locale, required this.isRtl,
    this.onBack, required this.onBookAgain, required this.onRemove, required this.onOpenCompany,
  });

  String tx(String key) => i18n.t(locale, key);

  @override
  Widget build(BuildContext context) {
    final companies = favorites.where((f) => f.type == 'company').toList();
    final routes = favorites.where((f) => f.type == 'route').toList();

    return Scaffold(
      backgroundColor: cSand,
      appBar: onBack != null ? TopBar(title: tx('favorites'), onBack: onBack, isRtl: isRtl) : null,
      body: favorites.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.favorite_outline, size: 56, color: cLine),
              const SizedBox(height: 14),
              Text(tx('noFavorites'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: cText)),
              const SizedBox(height: 6),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(tx('noFavoritesSub'), style: const TextStyle(color: cMuted, fontSize: 13), textAlign: TextAlign.center)),
            ]))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (onBack == null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Text(tx('favorites'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: cText)),
                    ),
                  ],
                  if (companies.isNotEmpty) ...[
                    Text(tx('favCompaniesTitle'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cText)),
                    const SizedBox(height: 8),
                    for (final f in companies) _companyTile(f),
                    const SizedBox(height: 16),
                  ],
                  if (routes.isNotEmpty) ...[
                    Text(tx('favRoutesTitle'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cText)),
                    const SizedBox(height: 8),
                    for (final f in routes) _routeTile(f),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _companyTile(FavoriteEntry f) {
    final color = f.colorHex != null ? hexColor(f.colorHex!) : cTeal;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: cLine)),
      child: Row(children: [
        CircleAvatar(radius: 20, backgroundColor: color,
          child: Text(f.initials ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(f.name ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cText)),
          if (f.tagline != null) Text(f.tagline!, style: const TextStyle(color: cMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 14, color: cMuted), onPressed: () => onOpenCompany(f)),
        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: cMuted), onPressed: () => onRemove(f.id)),
      ]),
    );
  }

  Widget _routeTile(FavoriteEntry f) {
    final color = f.colorHex != null ? hexColor(f.colorHex!) : cTeal;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: cLine)),
      child: Row(children: [
        CircleAvatar(radius: 20, backgroundColor: color,
          child: Text(f.initials ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${f.from ?? ''} → ${f.to ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cText)),
          Text(f.company ?? '', style: const TextStyle(color: cMuted, fontSize: 12)),
          if (f.time != null) Text(fmtTime(f.time!), style: const TextStyle(color: cNavy, fontSize: 11, fontWeight: FontWeight.w600)),
        ])),
        Column(children: [
          IconButton(icon: const Icon(Icons.bookmark, size: 18, color: cGold), onPressed: () => onBookAgain(f)),
          IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: cMuted), onPressed: () => onRemove(f.id), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ]),
      ]),
    );
  }
}
