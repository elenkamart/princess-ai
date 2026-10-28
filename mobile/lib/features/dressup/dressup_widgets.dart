import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/princess_theme.dart';
import 'dressup_art_data.dart';
import 'dressup_game.dart';

/// A 24px stroke icon from the game's icon set.
class GameIcon extends StatelessWidget {
  const GameIcon(this.name, {super.key, this.size = 24, this.color});

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? DefaultTextStyle.of(context).style.color ?? PrincessColors.ink;
    return SvgPicture.string(iconSvg(name), width: size, height: size, theme: SvgTheme(currentColor: c));
  }
}

class StarIcon extends StatelessWidget {
  const StarIcon({super.key, required this.filled, this.size = 24});

  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.string(starSvg(filled), width: size, height: size);
}

enum PressKind { berry, white, star }

/// Pill button on a solid press edge that drops 4px while pressed.
class PressButton extends StatefulWidget {
  const PressButton({super.key, required this.label, required this.onPressed, this.icon, this.kind = PressKind.white});

  final String label;
  final String? icon;
  final PressKind kind;
  final VoidCallback onPressed;

  @override
  State<PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<PressButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final (fill, edge, text) = switch (widget.kind) {
      PressKind.berry => (PrincessColors.berry, PrincessColors.berryDeep, PrincessColors.onBerry),
      PressKind.star => (PrincessColors.star, PrincessColors.starDeep, PrincessColors.ink),
      PressKind.white => (PrincessColors.surface, PrincessColors.borderStrong, PrincessColors.ink),
    };
    final still = MediaQuery.of(context).disableAnimations;
    return AnimatedContainer(
      duration: still ? Duration.zero : PrincessSizes.press,
      transform: Matrix4.translationValues(0, _down ? 4 : 0, 0),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(PrincessRadius.pill),
        boxShadow: [BoxShadow(color: edge, offset: Offset(0, _down ? 2 : 6))],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: widget.onPressed,
          onHighlightChanged: (v) => setState(() => _down = v),
          focusColor: PrincessColors.sky.withValues(alpha: 0.25),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: PrincessSizes.tap),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: PrincessSpace.s24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[GameIcon(widget.icon!, size: 26, color: text), const SizedBox(width: 10)],
                  Flexible(child: Text(widget.label, style: PrincessText.button.copyWith(color: text), textAlign: TextAlign.center)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

PrincessOccasion occasionStyle(String id) => PrincessOccasion.values.byName(id);

/// One of today's three outfits: time of day, occasion and stars earned.
class OccasionCard extends StatelessWidget {
  const OccasionCard({super.key, required this.when, required this.occasion, required this.stars, required this.selected, required this.onTap});

  final String when;
  final String occasion;
  final int stars;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final o = occasionStyle(occasion);
    return Semantics(
      button: true,
      selected: selected,
      label: '$when: ${o.label}, $stars of 3 stars',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: o.tint,
          borderRadius: BorderRadius.circular(PrincessRadius.r20),
          border: Border.all(color: selected ? o.deep : Colors.transparent, width: 3),
          boxShadow: selected ? PrincessShadows.lift : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(PrincessRadius.r20 - 3),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 78),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: PrincessColors.surface, borderRadius: BorderRadius.circular(PrincessRadius.r16)),
                      alignment: Alignment.center,
                      child: GameIcon(occasion, size: 30, color: o.deep),
                    ),
                    const SizedBox(width: PrincessSpace.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(when.toUpperCase(), style: PrincessText.kicker.copyWith(color: o.deep)),
                          Text(o.label, style: PrincessText.occasion, overflow: TextOverflow.ellipsis),
                          Row(children: [for (var i = 0; i < 3; i++) StarIcon(filled: i < stars, size: 18)]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Monday to Sunday with a sticker on each finished day.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.today, required this.isDone, required this.streak});

  final DateTime today;
  final bool Function(DateTime) isDone;
  final int streak;

  static const _names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    final monday = DateTime(today.year, today.month, today.day - (today.weekday - 1));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PrincessSpace.s12, vertical: PrincessSpace.s8),
      decoration: BoxDecoration(
        color: PrincessColors.surface,
        borderRadius: BorderRadius.circular(PrincessRadius.pill),
        boxShadow: PrincessShadows.pressWhite,
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 0; i < 7; i++) _day(DateTime(monday.year, monday.month, monday.day + i), i),
          if (streak > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: PrincessSpace.s12, vertical: PrincessSpace.s4),
              decoration: BoxDecoration(color: PrincessColors.sandTint, borderRadius: BorderRadius.circular(PrincessRadius.pill)),
              child: Text('$streak days in a row!', style: PrincessText.tab.copyWith(fontSize: 15, color: PrincessColors.sandDeep)),
            ),
        ],
      ),
    );
  }

  Widget _day(DateTime d, int i) {
    final done = isDone(d);
    final k = dateKey(d), t = dateKey(today);
    final isToday = k == t, future = k.compareTo(t) > 0;
    final label = '${_names[i]}${done ? ': sticker earned' : isToday ? ': today' : future ? '' : ': no sticker'}';
    final letter = Text('MTWTFSS'[i], style: PrincessText.tab.copyWith(fontSize: 15, color: isToday ? PrincessColors.berry : PrincessColors.inkMuted));
    Widget child;
    if (done) {
      child = Container(
        decoration: isToday ? BoxDecoration(shape: BoxShape.circle, border: Border.all(color: PrincessColors.berry, width: 3)) : null,
        alignment: Alignment.center,
        child: const StarIcon(filled: true, size: 30),
      );
    } else if (isToday || future) {
      child = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isToday ? PrincessColors.berry : PrincessColors.border, width: isToday ? 3 : 2),
        ),
        alignment: Alignment.center,
        child: letter,
      );
    } else {
      child = CustomPaint(painter: _DashedRing(), child: Center(child: letter));
    }
    return Semantics(label: label, excludeSemantics: true, child: SizedBox(width: 40, height: 40, child: child));
  }
}

class _DashedRing extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PrincessColors.borderStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final r = size.shortestSide / 2 - 1;
    const dashes = 14;
    for (var i = 0; i < dashes; i++) {
      final a = i * 2 * math.pi / dashes;
      canvas.drawArc(Rect.fromCircle(center: size.center(Offset.zero), radius: r), a, math.pi / dashes, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRing oldDelegate) => false;
}

/// What Lulu says, with a tail pointing down at her.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.text, required this.oops});

  final String text;
  final bool oops;

  @override
  Widget build(BuildContext context) {
    final bg = oops ? PrincessColors.coralTint : PrincessColors.surfacePink;
    return Semantics(
      liveRegion: true,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: -12,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(width: 24, height: 24, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4))),
            ),
          ),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: PrincessSpace.s12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(PrincessRadius.r20)),
            child: Text(text, style: PrincessText.speech.copyWith(color: PrincessColors.ink)),
          ),
        ],
      ),
    );
  }
}

/// Three stars; newly earned ones pop in when [popKey] changes.
class StarMeter extends StatelessWidget {
  const StarMeter({super.key, required this.stars, required this.popKey});

  final int stars;
  final int popKey;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations;
    return Semantics(
      liveRegion: true,
      label: '$stars of 3 stars',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: i < stars && !still && popKey > 0
                  ? TweenAnimationBuilder<double>(
                      key: ValueKey('$popKey-$i'),
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 500 + i * 120),
                      curve: Interval(i * 0.2, 1, curve: Curves.elasticOut),
                      builder: (_, t, child) => Transform.rotate(
                        angle: (1 - t) * -0.5,
                        child: Transform.scale(scale: 0.2 + 0.8 * t, child: child),
                      ),
                      child: const StarIcon(filled: true, size: PrincessSizes.starMeter),
                    )
                  : StarIcon(filled: i < stars, size: PrincessSizes.starMeter),
            ),
        ],
      ),
    );
  }
}

/// A closet category tab with a dot when Lulu wears something from it.
class CategoryTab extends StatelessWidget {
  const CategoryTab({super.key, required this.slot, required this.selected, required this.wearing, required this.onTap});

  final String slot;
  final bool selected;
  final bool wearing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? PrincessColors.surface : PrincessColors.ink;
    return Semantics(
      selected: selected,
      button: true,
      label: '${kSlotNames[slot]}${wearing ? ', wearing' : ''}',
      excludeSemantics: true,
      child: Material(
        color: selected ? PrincessColors.ink : PrincessColors.surface,
        shape: StadiumBorder(side: BorderSide(color: selected ? PrincessColors.ink : PrincessColors.border, width: 3)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: PrincessSizes.tapMin - 6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: PrincessSpace.s16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GameIcon(slot, color: fg),
                  const SizedBox(width: PrincessSpace.s8),
                  Text(kSlotNames[slot]!, style: PrincessText.tab.copyWith(color: fg)),
                  if (wearing) ...[
                    const SizedBox(width: PrincessSpace.s8),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? PrincessColors.star : PrincessColors.berry),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One piece of clothing in the closet grid.
class ItemTile extends StatelessWidget {
  const ItemTile({super.key, required this.item, required this.look, required this.worn, required this.nope, required this.onTap});

  final DressUpItem item;
  final Look look;
  final bool worn;
  final bool nope;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = nope ? PrincessColors.coralDeep : worn ? PrincessColors.berry : PrincessColors.border;
    final fill = nope ? PrincessColors.coralTint : worn ? PrincessColors.surfacePink : PrincessColors.canvas;
    return Semantics(
      button: true,
      selected: worn,
      label: '${item.name}${nope ? ', not right for now' : worn ? ', wearing' : ''}',
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: fill,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PrincessRadius.r20),
                side: BorderSide(color: borderColor, width: 3),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(PrincessRadius.r20),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
                  child: Column(
                    children: [
                      Expanded(child: SvgPicture.string(itemSvg(item, look), fit: BoxFit.contain)),
                      const SizedBox(height: 6),
                      Text(item.name, style: PrincessText.itemName.copyWith(color: PrincessColors.ink), textAlign: TextAlign.center, maxLines: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (worn)
            Positioned(
              top: -10,
              right: -8,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: nope ? PrincessColors.coralDeep : PrincessColors.berry,
                  boxShadow: nope ? null : const [BoxShadow(color: PrincessColors.berryDeep, offset: Offset(0, 3))],
                ),
                alignment: Alignment.center,
                child: GameIcon(nope ? 'undo' : 'check', size: 20, color: PrincessColors.onBerry),
              ),
            ),
        ],
      ),
    );
  }
}
