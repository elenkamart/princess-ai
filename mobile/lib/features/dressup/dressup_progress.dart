import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dressup_art_data.dart';
import 'dressup_game.dart';
import 'dressup_weather.dart';

/// One day's three outfits, its weather and the best stars earned for each.
class DayRecord {
  DayRecord({required this.plan, this.weather = DayWeather.unknown, List<int>? stars, List<Outfit>? outfits, this.done = false})
      : stars = stars ?? List.filled(plan.length, 0),
        outfits = outfits ?? [for (final _ in plan) <String, String>{}];

  final List<String> plan;
  final DayWeather weather;
  final List<int> stars;
  final List<Outfit> outfits;
  bool done;

  bool get started => stars.any((s) => s > 0);

  Map<String, Object> toJson() => {'plan': plan, 'weather': weather.toJson(), 'stars': stars, 'outfits': outfits, 'done': done};

  static DayRecord? fromJson(Object? json) {
    if (json is! Map) return null;
    try {
      final plan = List<String>.from(json['plan'] as List);
      final stars = List<int>.from(json['stars'] as List);
      final outfits = (json['outfits'] as List).map((o) => Map<String, String>.from(o as Map)).toList();
      if (plan.isEmpty || !plan.every(kOccasions.containsKey) || stars.length != plan.length || outfits.length != plan.length) return null;
      return DayRecord(
        plan: plan,
        weather: DayWeather.fromJson(json['weather']),
        stars: stars,
        outfits: outfits,
        done: json['done'] == true,
      );
    } catch (_) {
      return null;
    }
  }
}

enum WeatherStatus { noCity, loading, ready, failed }

/// Lulu's look, the grown-up settings, the forecast and every day's progress, saved on the device.
class DressUpProgress extends ChangeNotifier {
  DressUpProgress(this._prefs, {WeatherService? weather}) : _weather = weather ?? WeatherService() {
    final raw = _prefs?.getString(_key) ?? _prefs?.getString('princess-dressup-v1');
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      look = Look.fromJson(json['look']);
      city = City.fromJson(json['city']);
      birthday = MonthDay.fromJson(json['birthday']);
      final sp = json['specials'];
      if (sp is Map) {
        for (final e in sp.entries) {
          if (e.value is String && kOccasions.containsKey(e.value)) specials[e.key as String] = e.value as String;
        }
      }
      final fc = json['forecast'];
      if (fc is Map) {
        for (final e in fc.entries) {
          _forecast[e.key as String] = DayWeather.fromJson(e.value);
        }
      }
      final days = json['days'];
      if (days is Map) {
        for (final e in days.entries) {
          final r = DayRecord.fromJson(e.value);
          if (r != null) _days[e.key as String] = r;
        }
      }
    } catch (_) {
      // Unreadable save: start fresh rather than crash a child's game.
    }
    if (city != null && _forecast.isNotEmpty) weatherStatus = WeatherStatus.ready;
  }

  static const _key = 'princess-dressup-v2';

  static Future<DressUpProgress> load() async {
    try {
      return DressUpProgress(await SharedPreferences.getInstance());
    } catch (_) {
      return DressUpProgress(null);
    }
  }

  final SharedPreferences? _prefs;
  final WeatherService _weather;
  final Map<String, DayRecord> _days = {};
  final Map<String, DayWeather> _forecast = {};

  Look look = const Look();
  City? city;
  MonthDay? birthday;
  final Map<String, String> specials = {};
  WeatherStatus weatherStatus = WeatherStatus.noCity;

  WeatherService get weatherService => _weather;

  /// Forecast for [date], or the weather saved with that day.
  DayWeather weatherFor(DateTime date) => _forecast[dateKey(date)] ?? _days[dateKey(date)]?.weather ?? DayWeather.unknown;

  bool isDone(DateTime day) => _days[dateKey(day)]?.done ?? false;

  DayRecord? recordFor(DateTime date) => _days[dateKey(date)];

  List<String> planFor(DateTime date) =>
      _days[dateKey(date)]?.plan ?? dayPlan(date, weather: weatherFor(date).kind, birthday: birthday, specials: specials);

  /// [date]'s record. Until a star is earned it follows the latest weather and special days;
  /// after that the day stays as the child played it.
  DayRecord day(DateTime date) {
    final k = dateKey(date);
    final weather = weatherFor(date);
    final plan = dayPlan(date, weather: weather.kind, birthday: birthday, specials: specials);
    final existing = _days[k];
    // A day saved before days had 5-6 outfits is upgraded even after play has started.
    final oldFormat = existing != null && existing.plan.length == 3;
    if (existing != null && !oldFormat && (existing.started || (listEquals(existing.plan, plan) && existing.weather.kind == weather.kind))) {
      return existing;
    }
    // Keep outfits and stars for any occasion that is still in the new plan.
    int? was(String o) => existing == null || !existing.plan.contains(o) ? null : existing.plan.indexOf(o);
    return _days[k] = DayRecord(
      plan: plan,
      weather: existing != null && existing.started ? existing.weather : weather,
      outfits: [for (final o in plan) was(o) != null ? existing!.outfits[was(o)!] : <String, String>{}],
      stars: [for (final o in plan) was(o) != null ? existing!.stars[was(o)!] : 0],
    );
  }

  int streak(DateTime today) {
    var d = isDone(today) ? today : today.subtract(const Duration(days: 1));
    var n = 0;
    while (isDone(d)) {
      n++;
      d = d.subtract(const Duration(days: 1));
    }
    return n;
  }

  Future<void> refreshWeather() async {
    final c = city;
    if (c == null) {
      weatherStatus = WeatherStatus.noCity;
      notifyListeners();
      return;
    }
    weatherStatus = WeatherStatus.loading;
    notifyListeners();
    try {
      final fc = await _weather.forecast(c);
      _forecast
        ..clear()
        ..addAll(fc);
      weatherStatus = WeatherStatus.ready;
    } catch (_) {
      weatherStatus = _forecast.isEmpty ? WeatherStatus.failed : WeatherStatus.ready;
    }
    _changed();
  }

  void setCity(City? value) {
    city = value;
    _forecast.clear();
    refreshWeather();
  }

  void setBirthday(MonthDay? value) {
    birthday = value;
    _changed();
  }

  void setSpecial(DateTime date, String? occasion) {
    if (occasion == null) {
      specials.remove(dateKey(date));
    } else {
      specials[dateKey(date)] = occasion;
    }
    _changed();
  }

  void setLook(Look value) {
    look = value;
    _changed();
  }

  void setOutfit(DateTime date, int index, Outfit outfit) {
    day(date).outfits[index] = outfit;
    _changed();
  }

  /// Keeps the best stars. Returns true when this check finished the day.
  bool recordStars(DateTime date, int index, int stars) {
    final r = day(date);
    if (stars > r.stars[index]) r.stars[index] = stars;
    final finished = !r.done && r.stars.every((s) => s > 0);
    if (finished) r.done = true;
    _changed();
    return finished;
  }

  void _changed() {
    notifyListeners();
    _prefs?.setString(
      _key,
      jsonEncode({
        'look': look.toJson(),
        'city': city?.toJson(),
        'birthday': birthday?.toJson(),
        'specials': specials,
        'forecast': _forecast.map((k, v) => MapEntry(k, v.toJson())),
        'days': _days.map((k, v) => MapEntry(k, v.toJson())),
      }),
    );
  }
}
