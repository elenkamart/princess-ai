import 'package:flutter_test/flutter_test.dart';
import 'package:princess_ai/features/dressup/dressup_art_data.dart';
import 'package:princess_ai/features/dressup/dressup_game.dart';
import 'package:princess_ai/features/dressup/dressup_weather.dart';

void main() {
  group('judge', () {
    test('a full party outfit gets 3 stars and Lulu is happy', () {
      final r = judge({'dress': 'partydress', 'shoes': 'partyshoes', 'hat': 'crown'}, 'party');
      expect(r.stars, 3);
      expect(r.mood, Mood.happy);
    });

    test('two fitting pieces get 2 stars and a nudge for one more', () {
      final r = judge({'dress': 'pajamas', 'shoes': 'slippers'}, 'bedtime');
      expect(r.stars, 2);
      expect(r.message, 'Nice! Can you add one more thing?');
    });

    test('a piece that does not suit gets 1 star and a swap hint', () {
      final r = judge({'top': 'tee', 'bottom': 'jeans', 'shoes': 'sandals'}, 'school');
      expect(r.stars, 1);
      expect(r.wrong.single.id, 'sandals');
      expect(r.message, 'The sandals are not for school. Try the sneakers!');
    });

    test('a missing piece is named and earns nothing', () {
      final r = judge({'top': 'tee'}, 'school');
      expect(r.complete, isFalse);
      expect(r.stars, 0);
      expect(r.message, 'I still need something for my legs and shoes!');
    });
  });

  group('weather', () {
    test('rain at school asks for rain gear, and a raincoat fixes it', () {
      final dry = {'top': 'polo', 'bottom': 'jeans', 'shoes': 'sneakers'};
      expect(judge(dry, 'school', WeatherKind.rain).message, 'It’s raining! I need something to keep me dry.');
      expect(judge({...dry, 'coat': 'raincoat'}, 'school', WeatherKind.rain).stars, 3);
    });

    test('rain gear does not count indoors', () {
      expect(judge({'dress': 'partydress', 'shoes': 'partyshoes', 'coat': 'raincoat'}, 'party', WeatherKind.rain).stars, 1);
    });

    test('a warm coat is too hot on a hot day', () {
      final r = judge({'top': 'tee', 'bottom': 'jeans', 'shoes': 'sneakers', 'coat': 'jacket'}, 'park', WeatherKind.hot);
      expect(r.stars, 1);
      expect(r.message, 'Phew! The denim jacket is too hot today.');
    });

    test('shorts are too cold on a cold day, and a sweater is needed', () {
      expect(judge({'top': 'tee', 'bottom': 'shorts', 'shoes': 'sneakers'}, 'park', WeatherKind.cold).message, 'Brr! The shorts are too cold today.');
      expect(judge({'top': 'tee', 'bottom': 'jeans', 'shoes': 'sneakers'}, 'park', WeatherKind.cold).message, 'Brr, it’s cold! I need something warm.');
      expect(judge({'top': 'sweater', 'bottom': 'jeans', 'shoes': 'sneakers'}, 'park', WeatherKind.cold).stars, 3);
    });

    test('a snow day needs a warm coat and snow boots', () {
      final r = judge({'top': 'sweater', 'bottom': 'snowpants', 'shoes': 'snowboots', 'coat': 'puffer', 'hat': 'beanie'}, 'snowplay', WeatherKind.snow);
      expect(r.stars, 3);
      expect(judge({'top': 'sweater', 'bottom': 'snowpants', 'shoes': 'snowboots'}, 'snowplay', WeatherKind.snow).message,
          'Brr, it’s snowing! I need a warm coat and snow boots.');
    });

    test('forecast codes sort into the five kinds', () {
      expect(classify(code: 73, maxC: -2), WeatherKind.snow);
      expect(classify(code: 61, maxC: 14), WeatherKind.rain);
      expect(classify(code: 2, maxC: 14, rainChance: 70), WeatherKind.rain);
      expect(classify(code: 0, maxC: 30), WeatherKind.hot);
      expect(classify(code: 3, maxC: 4), WeatherKind.cold);
      expect(classify(code: 1, maxC: 18), WeatherKind.nice);
    });
  });

  group('day plan', () {
    test('weekdays follow the lesson timetable', () {
      expect(dayPlan(DateTime(2026, 10, 27)), ['school', 'sports', 'bedtime']);
      expect(dayPlan(DateTime(2026, 10, 28)), ['school', 'ballet', 'bedtime']);
      expect(dayPlan(DateTime(2026, 10, 29)), ['school', 'swimming', 'bedtime']);
    });

    test('weather changes outdoor play', () {
      expect(dayPlan(DateTime(2026, 10, 26), weather: WeatherKind.snow), ['school', 'snowplay', 'bedtime']);
      expect(dayPlan(DateTime(2026, 11, 7), weather: WeatherKind.hot), ['beach', 'party', 'bedtime']);
    });

    test('special days take the afternoon', () {
      expect(dayPlan(DateTime(2026, 10, 31)), ['park', 'halloween', 'bedtime']);
      expect(dayPlan(DateTime(2026, 12, 25)), ['school', 'christmas', 'bedtime']);
      expect(dayPlan(DateTime(2026, 11, 3), birthday: const MonthDay(11, 3)), ['school', 'birthday', 'bedtime']);
      expect(dayPlan(DateTime(2026, 11, 4), specials: {'2026-11-04': 'party'}), ['school', 'party', 'bedtime']);
    });
  });

  test('a dress replaces top and bottoms, and tapping again takes it off', () {
    var o = wear({'top': 'tee', 'bottom': 'jeans'}, itemById('sundress')!);
    expect(o, {'dress': 'sundress'});
    o = wear(o, itemById('sundress')!);
    expect(o, isEmpty);
  });

  test('every occasion can be dressed for in every weather', () {
    for (final occ in kOccasions.keys) {
      for (final w in WeatherKind.values) {
        bool has(String slot) => kItems.any((it) => it.slot == slot && suits(it, occ, w));
        expect(has('shoes'), isTrue, reason: '$occ in ${w.name} needs shoes');
        expect(has('dress') || (has('top') && has('bottom')), isTrue, reason: '$occ in ${w.name} needs clothes');
      }
    }
  });

  test('character art fills in skin and hair and shows the weather outdoors', () {
    final svg = stageSvg('school', const Look(skin: 2, hair: 3), {'top': 'polo'}, Mood.happy, WeatherKind.snow);
    expect(svg, contains(kSkins[2]));
    expect(svg, contains(kHairColors[3]));
    expect(svg, isNot(contains(kSkinToken)));
    expect(svg, contains(kWeatherOverlays['snow']!));
    expect(stageSvg('party', const Look(), {}, Mood.ok, WeatherKind.snow), isNot(contains(kWeatherOverlays['snow']!)));
  });
}
