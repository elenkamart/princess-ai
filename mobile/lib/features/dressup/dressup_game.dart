import 'dressup_art_data.dart';

/// Lulu's face for the current moment: dressing, pleased, or not quite right.
enum Mood { ok, happy, oops }

class Look {
  const Look({this.skin = 1, this.hair = 0, this.style = 0});

  final int skin;
  final int hair;
  final int style;

  Look copyWith({int? skin, int? hair, int? style}) =>
      Look(skin: skin ?? this.skin, hair: hair ?? this.hair, style: style ?? this.style);

  Map<String, int> toJson() => {'skin': skin, 'hair': hair, 'style': style};

  static Look fromJson(Object? json) {
    if (json is! Map) return const Look();
    int pick(String k, int max, int fallback) {
      final v = json[k];
      return v is int && v >= 0 && v < max ? v : fallback;
    }
    return Look(
      skin: pick('skin', kSkins.length, 1),
      hair: pick('hair', kHairColors.length, 0),
      style: pick('style', kHairStyles.length, 0),
    );
  }
}

/// slot id -> item id
typedef Outfit = Map<String, String>;

class Judgement {
  const Judgement({required this.complete, required this.stars, required this.wrong, required this.mood, required this.message});

  final bool complete;
  final int stars;
  final List<DressUpItem> wrong;
  final Mood mood;
  final String message;
}

DressUpItem? itemById(String id) {
  for (final it in kItems) {
    if (it.id == id) return it;
  }
  return null;
}

/// Puts [item] on, or takes it off if Lulu already wears it.
/// A dress replaces a top and bottoms; a top or bottoms replace a dress.
Outfit wear(Outfit outfit, DressUpItem item) {
  final next = Map<String, String>.of(outfit);
  if (next[item.slot] == item.id) {
    next.remove(item.slot);
    return next;
  }
  next[item.slot] = item.id;
  if (item.slot == 'dress') {
    next
      ..remove('top')
      ..remove('bottom');
  }
  if (item.slot == 'top' || item.slot == 'bottom') next.remove('dress');
  return next;
}

Judgement judge(Outfit outfit, String occasionId) {
  final occ = kOccasions[occasionId]!;
  final missing = <String>[
    if (!outfit.containsKey('dress') && !outfit.containsKey('top')) 'a top',
    if (!outfit.containsKey('dress') && !outfit.containsKey('bottom')) 'something for my legs',
    if (!outfit.containsKey('shoes')) 'shoes',
  ];
  if (missing.isNotEmpty) {
    return Judgement(complete: false, stars: 0, wrong: const [], mood: Mood.oops, message: 'I still need ${missing.join(' and ')}!');
  }
  final worn = outfit.values.map(itemById).whereType<DressUpItem>().toList();
  final wrong = worn.where((it) => !it.fits.contains(occasionId)).toList();
  final good = worn.length - wrong.length;
  if (wrong.isEmpty) {
    return good >= 3
        ? Judgement(complete: true, stars: 3, wrong: const [], mood: Mood.happy, message: occ.yay)
        : const Judgement(complete: true, stars: 2, wrong: [], mood: Mood.happy, message: 'Nice! Can you add one more thing?');
  }
  final w = wrong.first;
  final swap = kItems.where((it) => it.slot == w.slot && it.fits.contains(occasionId)).firstOrNull;
  final message = 'The ${w.name.toLowerCase()} ${w.plural ? 'are' : 'is'} not for ${occ.name.toLowerCase()}.'
      '${swap != null ? ' Try the ${swap.name.toLowerCase()}!' : ' Take it off!'}';
  return Judgement(complete: true, stars: 1, wrong: wrong, mood: Mood.oops, message: message);
}

/// Morning, afternoon and evening occasions for [date]. Same seed as the web game.
List<String> dayPlan(DateTime date) {
  final seed = date.year * 372 + (date.month - 1) * 31 + date.day;
  if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
    return [seed.isOdd ? 'beach' : 'park', 'party', 'bedtime'];
  }
  return ['school', seed % 3 == 0 ? 'rainy' : 'park', 'bedtime'];
}

String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/* ---------- SVG assembly ---------- */

String _skin(String svg, Look look) =>
    svg.replaceAll(kSkinToken, kSkins[look.skin]).replaceAll(kHairToken, kHairColors[look.hair]);

/// Lulu's layers in the 240 x 400 character space (no `<svg>` wrapper).
String characterLayers(Look look, Outfit outfit, Mood mood) {
  final worn = <String, DressUpItem>{
    for (final e in outfit.entries)
      if (itemById(e.value) case final it?) e.key: it,
  };
  String layer(String slot, {bool back = false}) {
    final it = worn[slot];
    if (it == null) return '';
    return back ? it.back : it.front;
  }

  final b = StringBuffer()
    ..write(layer('extra', back: true))
    ..write(kHairBack[kHairStyles[look.style]])
    ..write(kBodyLower);
  if (!worn.containsKey('dress') && !worn.containsKey('top')) b.write(kUndershirt);
  if (!worn.containsKey('dress') && !worn.containsKey('bottom')) b.write(kUndershorts);
  b
    ..write(layer('bottom'))
    ..write(layer('top'))
    ..write(layer('dress'))
    ..write(layer('coat'))
    ..write(layer('shoes'))
    ..write(kBodyUpper)
    ..write(kFaces[mood.name])
    ..write(kHairFront)
    ..write(layer('hat'))
    ..write(layer('extra'));
  return _skin(b.toString(), look);
}

String stageSvg(String occasionId, Look look, Outfit outfit, Mood mood) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 440">${kBackdrops[occasionId]}'
    '<g transform="translate(80 34)">${characterLayers(look, outfit, mood)}</g></svg>';

String headSvg(Look look) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="40 6 160 150">${characterLayers(look, const {}, Mood.happy)}</svg>';

String itemSvg(DressUpItem item, Look look) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="${item.viewBox}">${_skin(item.back + item.front, look)}</svg>';

String iconSvg(String name) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" '
    'stroke-linecap="round" stroke-linejoin="round"><path d="${kIconPaths[name]}"/></svg>';

String starSvg(bool filled) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="${kIconPaths['extra']}" '
    'fill="${filled ? '#ffc23d' : '#ffffff'}" stroke="${filled ? '#c98a00' : '#e2c3ab'}" stroke-width="2" stroke-linejoin="round"/></svg>';
