import 'package:flutter/material.dart';

import '../../core/theme/princess_theme.dart';
import 'dressup_art_data.dart';
import 'dressup_game.dart';
import 'dressup_grownups.dart';
import 'dressup_progress.dart';
import 'dressup_widgets.dart';

/// A month of stickers, special days and the forecast. Tapping a day shows its outfits.
class DressUpCalendar extends StatefulWidget {
  const DressUpCalendar({super.key, required this.progress, required this.today});

  final DressUpProgress progress;
  final DateTime today;

  @override
  State<DressUpCalendar> createState() => _DressUpCalendarState();
}

class _DressUpCalendarState extends State<DressUpCalendar> {
  static const _when = ['Morning', 'Afternoon', 'Evening'];
  late DateTime _month = DateTime(widget.today.year, widget.today.month);
  late DateTime _selected = DateTime(widget.today.year, widget.today.month, widget.today.day);

  void _shiftMonth(int delta) => setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final p = widget.progress;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        leading: IconButton(tooltip: 'Back to the game', onPressed: () => Navigator.of(context).pop(), icon: const GameIcon('left', size: 28)),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: p,
          builder: (context, _) => LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth >= 880;
              final grid = _monthPanel(p);
              final details = _dayPanel(p);
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(PrincessSpace.s16, 0, PrincessSpace.s16, PrincessSpace.s32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: wide
                        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(flex: 6, child: grid),
                            const SizedBox(width: PrincessSpace.s16),
                            Expanded(flex: 5, child: details),
                          ])
                        : Column(children: [grid, const SizedBox(height: PrincessSpace.s16), details]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  BoxDecoration get _panel => BoxDecoration(
        color: PrincessColors.surface,
        borderRadius: BorderRadius.circular(PrincessRadius.r28),
        boxShadow: PrincessShadows.lift,
      );

  Widget _monthPanel(DressUpProgress p) {
    final first = DateTime(_month.year, _month.month);
    final lead = first.weekday - 1;
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final cells = lead + days;
    return Container(
      decoration: _panel,
      padding: const EdgeInsets.all(PrincessSpace.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(tooltip: 'Previous month', onPressed: () => _shiftMonth(-1), icon: const GameIcon('left', size: 28)),
              Expanded(
                child: Text('${monthName(_month.month)} ${_month.year}', textAlign: TextAlign.center, style: PrincessText.panelTitle.copyWith(color: PrincessColors.ink)),
              ),
              IconButton(tooltip: 'Next month', onPressed: () => _shiftMonth(1), icon: const GameIcon('right', size: 28)),
            ],
          ),
          const SizedBox(height: PrincessSpace.s12),
          Row(
            children: [
              for (final l in 'MTWTFSS'.split(''))
                Expanded(child: Text(l, textAlign: TextAlign.center, style: PrincessText.kicker.copyWith(fontSize: 15, color: PrincessColors.inkMuted))),
            ],
          ),
          const SizedBox(height: PrincessSpace.s8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 0.82),
            itemCount: (cells / 7).ceil() * 7,
            itemBuilder: (_, i) {
              final n = i - lead + 1;
              if (n < 1 || n > days) return const SizedBox.shrink();
              return _dayCell(p, DateTime(_month.year, _month.month, n));
            },
          ),
        ],
      ),
    );
  }

  Widget _dayCell(DressUpProgress p, DateTime d) {
    final t = widget.today;
    final isToday = dateKey(d) == dateKey(t);
    final selected = dateKey(d) == dateKey(_selected);
    final done = p.isDone(d);
    final special = specialFor(d, birthday: p.birthday, specials: p.specials);
    final weather = p.weatherFor(d);
    final label = '${longDate(d)}${done ? ', sticker earned' : ''}${special != null ? ', ${kOccasions[special]!.name}' : ''}${weather.known ? ', ${weather.kind.label}' : ''}';
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? PrincessColors.surfacePink : PrincessColors.canvas,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PrincessRadius.r16),
          side: BorderSide(color: isToday ? PrincessColors.berry : selected ? PrincessColors.berry.withValues(alpha: 0.5) : PrincessColors.border, width: isToday ? 3 : 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(PrincessRadius.r16),
          onTap: () => setState(() => _selected = d),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                Text('${d.day}', style: PrincessText.tab.copyWith(fontSize: 15, color: isToday ? PrincessColors.berry : PrincessColors.ink)),
                const Spacer(),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 2,
                  children: [
                    if (done) const StarIcon(filled: true, size: 18),
                    if (special != null) GameIcon(special, size: 18, color: occasionStyle(special).deep),
                    if (weather.known && !done) GameIcon(weather.kind.icon, size: 18, color: PrincessColors.inkMuted),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dayPanel(DressUpProgress p) {
    final d = _selected;
    final t = widget.today;
    final isToday = dateKey(d) == dateKey(t);
    final past = dateKey(d).compareTo(dateKey(t)) < 0;
    final record = p.recordFor(d);
    final plan = p.planFor(d);
    final weather = record?.weather.known == true ? record!.weather : p.weatherFor(d);
    final custom = p.specials[dateKey(d)];
    return Container(
      decoration: _panel,
      padding: const EdgeInsets.all(PrincessSpace.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(isToday ? 'Today' : longDate(d), style: PrincessText.panelTitle.copyWith(color: PrincessColors.ink)),
          if (isToday) Text(longDate(d), style: PrincessText.caption),
          const SizedBox(height: PrincessSpace.s12),
          Row(
            children: [
              GameIcon(weather.kind.icon, color: PrincessColors.inkMuted),
              const SizedBox(width: PrincessSpace.s8),
              Expanded(
                child: Text(
                  weather.known
                      ? '${weather.short}${weather.minC != null ? ' (low ${weather.minC!.round()}°)' : ''}'
                      : p.city == null
                          ? 'No weather yet. A grown-up can set the city.'
                          : past
                              ? 'No weather saved for this day.'
                              : 'The forecast only goes 16 days ahead.',
                  style: PrincessText.bodyText.copyWith(color: PrincessColors.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: PrincessSpace.s12),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: PrincessSpace.s8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: PrincessSpace.s12, vertical: 10),
                decoration: BoxDecoration(color: occasionStyle(plan[i]).tint, borderRadius: BorderRadius.circular(PrincessRadius.r20)),
                child: Row(
                  children: [
                    GameIcon(plan[i], size: 28, color: occasionStyle(plan[i]).deep),
                    const SizedBox(width: PrincessSpace.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_when[i].toUpperCase(), style: PrincessText.kicker.copyWith(color: occasionStyle(plan[i]).deep)),
                          Text(kOccasions[plan[i]]!.name, style: PrincessText.occasion.copyWith(color: PrincessColors.ink)),
                        ],
                      ),
                    ),
                    if (record != null) for (var s = 0; s < 3; s++) StarIcon(filled: s < record.stars[i], size: 20),
                  ],
                ),
              ),
            ),
          if (record?.done == true)
            Padding(
              padding: const EdgeInsets.only(bottom: PrincessSpace.s8),
              child: Row(children: [
                const StarIcon(filled: true, size: 28),
                const SizedBox(width: PrincessSpace.s8),
                Text('Sticker earned!', style: PrincessText.tab.copyWith(color: PrincessColors.sandDeep)),
              ]),
            ),
          const SizedBox(height: PrincessSpace.s8),
          if (isToday) PressButton(label: 'Play today', icon: 'check', kind: PressKind.berry, onPressed: () => Navigator.of(context).pop()),
          if (!isToday && !past)
            Text('Come back on this day to dress Lulu.', style: PrincessText.caption, textAlign: TextAlign.center),
          if (!past) ...[
            const SizedBox(height: PrincessSpace.s16),
            if (custom == null)
              PressButton(
                label: 'Add a special day',
                icon: 'lock',
                onPressed: () async {
                  if (await askGrownUp(context) && mounted) await addSpecialDay(context, p, d);
                },
              )
            else
              PressButton(
                label: 'Remove ${kOccasions[custom]!.name.toLowerCase()}',
                icon: 'lock',
                onPressed: () async {
                  if (await askGrownUp(context)) p.setSpecial(d, null);
                },
              ),
          ],
        ],
      ),
    );
  }
}
