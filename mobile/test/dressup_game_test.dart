import 'package:flutter_test/flutter_test.dart';
import 'package:princess_ai/features/dressup/dressup_art_data.dart';
import 'package:princess_ai/features/dressup/dressup_game.dart';

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

  group('wear', () {
    test('a dress replaces top and bottoms, and tapping again takes it off', () {
      var o = wear({'top': 'tee', 'bottom': 'jeans'}, itemById('sundress')!);
      expect(o, {'dress': 'sundress'});
      o = wear(o, itemById('sundress')!);
      expect(o, isEmpty);
    });
  });

  test('every item suits at least one occasion that has a full outfit', () {
    for (final occ in kOccasions.keys) {
      bool has(String slot) => kItems.any((it) => it.slot == slot && it.fits.contains(occ));
      expect(has('shoes'), isTrue, reason: '$occ needs shoes');
      expect(has('dress') || (has('top') && has('bottom')), isTrue, reason: '$occ needs clothes');
    }
  });

  test('day plans match the web game', () {
    expect(dayPlan(DateTime(2026, 10, 28)), ['school', 'park', 'bedtime']);
    expect(dayPlan(DateTime(2026, 10, 31)), ['park', 'party', 'bedtime']);
  });

  test('character art fills in skin and hair', () {
    final svg = stageSvg('school', const Look(skin: 2, hair: 3), {'top': 'polo'}, Mood.happy);
    expect(svg, contains(kSkins[2]));
    expect(svg, contains(kHairColors[3]));
    expect(svg, isNot(contains(kSkinToken)));
  });
}
