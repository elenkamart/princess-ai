import 'dressup_art_data.dart';
import 'dressup_weather.dart';

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

/// A month and day that repeats every year, like a birthday.
class MonthDay {
  const MonthDay(this.month, this.day);

  final int month;
  final int day;

  bool matches(DateTime d) => d.month == month && d.day == day;

  Map<String, int> toJson() => {'month': month, 'day': day};

  static MonthDay? fromJson(Object? json) {
    if (json is! Map || json['month'] is! int || json['day'] is! int) return null;
    return MonthDay(json['month'] as int, json['day'] as int);
  }
}

/// slot id -> item id
typedef Outfit = Map<String, String>;

/// Occasions a grown-up can put on a calendar day.
const kSpecialOccasions = ['party', 'birthday', 'sleepover', 'sports', 'swimming', 'ballet', 'halloween', 'christmas'];

/// Labels for each outfit of a day, by how many outfits the day has.
List<String> timesOfDay(int count) => switch (count) {
      3 => const ['Morning', 'Afternoon', 'Evening'],
      6 => const ['Morning', 'Midday', 'Afternoon', 'Late afternoon', 'Dinner time', 'Night'],
      _ => const ['Morning', 'Midday', 'Afternoon', 'Dinner time', 'Night'],
    };

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

enum _Fit { ok, notFor, tooHot, tooCold }

_Fit _fit(DressUpItem it, String occasionId, WeatherKind weather) {
  final outdoor = kOccasions[occasionId]!.outdoor;
  final chilly = weather == WeatherKind.cold || weather == WeatherKind.snow;
  if (outdoor && weather == WeatherKind.hot && it.tags.contains('warm')) return _Fit.tooHot;
  if (outdoor && chilly && it.tags.contains('cool')) return _Fit.tooCold;
  if (it.fits.contains(occasionId)) return _Fit.ok;
  if (outdoor && weather == WeatherKind.rain && it.tags.contains('rain')) return _Fit.ok;
  if (outdoor && chilly && it.tags.contains('warm')) return _Fit.ok;
  if (outdoor && weather == WeatherKind.hot && it.tags.contains('cool')) return _Fit.ok;
  return _Fit.notFor;
}

/// Whether [item] suits [occasionId] in [weather].
bool suits(DressUpItem item, String occasionId, WeatherKind weather) => _fit(item, occasionId, weather) == _Fit.ok;

/// A piece some occasions can't do without, or null when it is there.
String? _occasionNeed(Iterable<DressUpItem> worn, String occasionId) {
  bool wearing(String id) => worn.any((it) => it.id == id);
  return switch (occasionId) {
    'kitchen' when !wearing('apron') => 'I need an apron so I don’t get messy!',
    'sleepover' when !wearing('sleepingbag') => 'Don’t forget my sleeping bag!',
    _ => null,
  };
}

/// What the weather still asks for, or null when the outfit is ready for it.
String? _weatherNeed(Iterable<DressUpItem> worn, String occasionId, WeatherKind weather) {
  if (!kOccasions[occasionId]!.outdoor) return null;
  bool has(String tag, [String? slot]) => worn.any((it) => it.tags.contains(tag) && (slot == null || it.slot == slot));
  return switch (weather) {
    WeatherKind.rain when !has('rain') => 'It’s raining! I need something to keep me dry.',
    WeatherKind.snow when !(has('warm', 'coat') && has('warm', 'shoes')) => 'Brr, it’s snowing! I need a warm coat and snow boots.',
    WeatherKind.cold when !has('warm') => 'Brr, it’s cold! I need something warm.',
    _ => null,
  };
}

Judgement judge(Outfit outfit, String occasionId, [WeatherKind weather = WeatherKind.nice]) {
  final occ = kOccasions[occasionId]!;
  final missing = <String>[
    if (!outfit.containsKey('dress') && !outfit.containsKey('top')) 'a top',
    if (!outfit.containsKey('dress') && !outfit.containsKey('bottom')) 'something for my legs',
    if (!outfit.containsKey('shoes') && !_barefoot.contains(occasionId)) 'shoes',
  ];
  if (missing.isNotEmpty) {
    return Judgement(complete: false, stars: 0, wrong: const [], mood: Mood.oops, message: 'I still need ${missing.join(' and ')}!');
  }
  final worn = outfit.values.map(itemById).whereType<DressUpItem>().toList();
  final fits = {for (final it in worn) it: _fit(it, occasionId, weather)};
  final wrong = worn.where((it) => fits[it] != _Fit.ok).toList();

  if (wrong.isNotEmpty) {
    final w = wrong.first;
    final verb = w.plural ? 'are' : 'is';
    final name = w.name.toLowerCase();
    final message = switch (fits[w]!) {
      _Fit.tooHot => 'Phew! The $name $verb too hot today.',
      _Fit.tooCold => 'Brr! The $name $verb too cold today.',
      _ => () {
          final swap = kItems.where((it) => it.slot == w.slot && suits(it, occasionId, weather)).firstOrNull;
          return 'The $name $verb not for ${occ.name.toLowerCase()}.${swap != null ? ' Try the ${swap.name.toLowerCase()}!' : ' Take it off!'}';
        }(),
    };
    return Judgement(complete: true, stars: 1, wrong: wrong, mood: Mood.oops, message: message);
  }
  final need = _occasionNeed(worn, occasionId) ?? _weatherNeed(worn, occasionId, weather);
  if (need != null) {
    return Judgement(complete: true, stars: 1, wrong: const [], mood: Mood.oops, message: need);
  }
  if (worn.length >= 3) {
    return Judgement(complete: true, stars: 3, wrong: const [], mood: Mood.happy, message: occ.yay);
  }
  final idea = _addIdea(outfit, occasionId, weather);
  return Judgement(
    complete: true,
    stars: 2,
    wrong: const [],
    mood: Mood.happy,
    message: idea == null ? 'Nice! Can you add one more thing?' : 'Nice! Can you add the ${idea.name.toLowerCase()}?',
  );
}

/// Occasions Lulu goes to in bare feet or socks: shoes are optional there.
const _barefoot = {'bedtime', 'sleepover'};

/// A piece in a free slot that suits the occasion, extras and hats first.
DressUpItem? _addIdea(Outfit outfit, String occasionId, WeatherKind weather) {
  for (final slot in const ['extra', 'hat', 'shoes', 'coat']) {
    if (outfit.containsKey(slot)) continue;
    final it = kItems.where((it) => it.slot == slot && suits(it, occasionId, weather)).firstOrNull;
    if (it != null) return it;
  }
  return null;
}

/// The special occasion on [date], if any: a grown-up's entry wins, then the birthday, then holidays.
String? specialFor(DateTime date, {MonthDay? birthday, Map<String, String> specials = const {}}) {
  final custom = specials[dateKey(date)];
  if (custom != null && kOccasions.containsKey(custom)) return custom;
  if (birthday != null && birthday.matches(date)) return 'birthday';
  if (date.month == 10 && date.day == 31) return 'halloween';
  if (date.month == 12 && (date.day == 24 || date.day == 25)) return 'christmas';
  return null;
}

/// The day's occasions, morning to night: 5, or 6 on lesson days. Every day ends with the
/// kitchen at dinner time and bed (a sleepover on Fridays). A special day takes the slot
/// before dinner; a special sleepover takes the night.
List<String> dayPlan(DateTime date, {WeatherKind weather = WeatherKind.nice, MonthDay? birthday, Map<String, String> specials = const {}}) {
  final outside = weather == WeatherKind.snow ? 'snowplay' : 'park';
  final sunny = weather == WeatherKind.hot ? 'beach' : outside;
  final plan = switch (date.weekday) {
    DateTime.monday => ['school', 'playground', outside],
    DateTime.tuesday => ['school', 'sports', 'playground', outside],
    DateTime.wednesday => ['school', 'ballet', 'playground', outside],
    DateTime.thursday => ['school', 'swimming', 'playground', outside],
    DateTime.friday => ['school', 'playground', outside],
    DateTime.saturday => [sunny, 'playground', 'party'],
    _ => ['swimming', sunny, 'playground'],
  };
  final special = specialFor(date, birthday: birthday, specials: specials);
  // Friday's sleepover gives way to a holiday or birthday, which ends at home.
  var night = date.weekday == DateTime.friday && special == null ? 'sleepover' : 'bedtime';
  if (special == 'sleepover') {
    night = 'sleepover';
  } else if (special != null) {
    plan[plan.length - 1] = special;
  }
  return [...plan, 'kitchen', night];
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

String stageSvg(String occasionId, Look look, Outfit outfit, Mood mood, [WeatherKind weather = WeatherKind.nice]) {
  final overlay = kOccasions[occasionId]!.outdoor ? kWeatherOverlays[weather.name] ?? '' : '';
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 440">${kBackdrops[occasionId]}$overlay'
      '<g transform="translate(80 34)">${characterLayers(look, outfit, mood)}</g></svg>';
}

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
