import 'dart:convert';

import 'package:http/http.dart' as http;

/// The five kinds of weather that change what Lulu needs outdoors.
enum WeatherKind {
  nice('Nice day', 'nice'),
  rain('Rainy', 'rain'),
  snow('Snowy', 'snow'),
  cold('Cold', 'cold'),
  hot('Hot', 'hot');

  const WeatherKind(this.label, this.icon);

  final String label;
  final String icon;

  /// What Lulu adds when the occasion is outdoors.
  String get hint => switch (this) {
        WeatherKind.nice => '',
        WeatherKind.rain => 'And it’s raining!',
        WeatherKind.snow => 'And it’s snowing!',
        WeatherKind.cold => 'Brr, it’s cold out.',
        WeatherKind.hot => 'Phew, it’s hot today!',
      };
}

class DayWeather {
  const DayWeather(this.kind, this.maxC, this.minC);

  static const unknown = DayWeather(WeatherKind.nice, null, null);

  final WeatherKind kind;
  final double? maxC;
  final double? minC;

  bool get known => maxC != null;

  String get short => known ? '${kind.label} · ${maxC!.round()}°' : kind.label;

  Map<String, Object?> toJson() => {'kind': kind.name, 'max': maxC, 'min': minC};

  static DayWeather fromJson(Object? json) {
    if (json is! Map) return unknown;
    final kind = WeatherKind.values.where((k) => k.name == json['kind']).firstOrNull ?? WeatherKind.nice;
    return DayWeather(kind, (json['max'] as num?)?.toDouble(), (json['min'] as num?)?.toDouble());
  }
}

class City {
  const City({required this.name, required this.region, required this.lat, required this.lon});

  final String name;

  /// Region and country, for telling cities with the same name apart.
  final String region;
  final double lat;
  final double lon;

  Map<String, Object> toJson() => {'name': name, 'region': region, 'lat': lat, 'lon': lon};

  static City? fromJson(Object? json) {
    if (json is! Map || json['lat'] is! num || json['lon'] is! num) return null;
    return City(
      name: '${json['name'] ?? ''}',
      region: '${json['region'] ?? ''}',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }
}

/// Sorts a day of the Open-Meteo forecast into one of the five kinds.
WeatherKind classify({required int code, required double maxC, int? rainChance}) {
  const snowCodes = {71, 73, 75, 77, 85, 86};
  final rainCode = (code >= 51 && code <= 67) || (code >= 80 && code <= 82) || code >= 95;
  if (snowCodes.contains(code)) return WeatherKind.snow;
  if (rainCode || (rainChance ?? 0) >= 60) return WeatherKind.rain;
  if (maxC >= 26) return WeatherKind.hot;
  if (maxC <= 8) return WeatherKind.cold;
  return WeatherKind.nice;
}

/// Free Open-Meteo services: no account or key needed.
class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<City>> searchCity(String query) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {'name': query.trim(), 'count': '6', 'language': 'en'});
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw WeatherException('City search failed (${res.statusCode})');
    final results = (jsonDecode(res.body) as Map<String, dynamic>)['results'] as List? ?? const [];
    return [
      for (final r in results.cast<Map<String, dynamic>>())
        City(
          name: '${r['name']}',
          region: [r['admin1'], r['country']].whereType<String>().join(', '),
          lat: (r['latitude'] as num).toDouble(),
          lon: (r['longitude'] as num).toDouble(),
        ),
    ];
  }

  /// Up to 16 days of weather, keyed by yyyy-mm-dd in the city's own time zone.
  Future<Map<String, DayWeather>> forecast(City city) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '${city.lat}',
      'longitude': '${city.lon}',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '16',
    });
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw WeatherException('Forecast failed (${res.statusCode})');
    final daily = (jsonDecode(res.body) as Map<String, dynamic>)['daily'] as Map<String, dynamic>;
    final days = (daily['time'] as List).cast<String>();
    final codes = daily['weather_code'] as List;
    final maxes = daily['temperature_2m_max'] as List;
    final mins = daily['temperature_2m_min'] as List;
    final rain = daily['precipitation_probability_max'] as List?;
    final out = <String, DayWeather>{};
    for (var i = 0; i < days.length; i++) {
      final max = (maxes[i] as num?)?.toDouble();
      final code = (codes[i] as num?)?.toInt();
      if (max == null || code == null) continue;
      out[days[i]] = DayWeather(
        classify(code: code, maxC: max, rainChance: (rain?[i] as num?)?.toInt()),
        max,
        (mins[i] as num?)?.toDouble(),
      );
    }
    return out;
  }
}

class WeatherException implements Exception {
  WeatherException(this.message);

  final String message;

  @override
  String toString() => message;
}
