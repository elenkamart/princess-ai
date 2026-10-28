import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dressup_game.dart';

/// One day's three outfits and the best stars earned for each.
class DayRecord {
  DayRecord({required this.plan, List<int>? stars, List<Outfit>? outfits, this.done = false})
      : stars = stars ?? [0, 0, 0],
        outfits = outfits ?? [{}, {}, {}];

  final List<String> plan;
  final List<int> stars;
  final List<Outfit> outfits;
  bool done;

  Map<String, Object> toJson() => {'plan': plan, 'stars': stars, 'outfits': outfits, 'done': done};

  static DayRecord? fromJson(Object? json) {
    if (json is! Map) return null;
    try {
      return DayRecord(
        plan: List<String>.from(json['plan'] as List),
        stars: List<int>.from(json['stars'] as List),
        outfits: (json['outfits'] as List).map((o) => Map<String, String>.from(o as Map)).toList(),
        done: json['done'] == true,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Lulu's look and every day's progress, saved on the device.
class DressUpProgress extends ChangeNotifier {
  DressUpProgress(this._prefs) {
    final raw = _prefs?.getString(_key);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      look = Look.fromJson(json['look']);
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
  }

  static const _key = 'princess-dressup-v1';

  static Future<DressUpProgress> load() async {
    try {
      return DressUpProgress(await SharedPreferences.getInstance());
    } catch (_) {
      return DressUpProgress(null);
    }
  }

  final SharedPreferences? _prefs;
  final Map<String, DayRecord> _days = {};
  Look look = const Look();

  bool isDone(DateTime day) => _days[dateKey(day)]?.done ?? false;

  /// Today's record, recreated if the plan rules changed since it was saved.
  DayRecord day(DateTime date) {
    final plan = dayPlan(date);
    final k = dateKey(date);
    final existing = _days[k];
    if (existing != null && listEquals(existing.plan, plan)) return existing;
    return _days[k] = DayRecord(plan: plan);
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
    _prefs?.setString(_key, jsonEncode({'look': look.toJson(), 'days': _days.map((k, v) => MapEntry(k, v.toJson()))}));
  }
}
