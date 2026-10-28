import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/princess_theme.dart';
import 'dressup_art_data.dart';
import 'dressup_game.dart';
import 'dressup_progress.dart';
import 'dressup_weather.dart';
import 'dressup_widgets.dart';

const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

String longDate(DateTime d) => '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';
String monthName(int month) => _months[month - 1];

/// A simple sum only a grown-up is likely to solve. Returns true when answered right.
Future<bool> askGrownUp(BuildContext context) async {
  final r = Random();
  final a = 6 + r.nextInt(4), b = 3 + r.nextInt(7);
  final ok = await showDialog<bool>(
    context: context,
    barrierColor: PrincessColors.scrim,
    builder: (context) => _GrownUpGate(a: a, b: b),
  );
  return ok ?? false;
}

class _GrownUpGate extends StatefulWidget {
  const _GrownUpGate({required this.a, required this.b});

  final int a;
  final int b;

  @override
  State<_GrownUpGate> createState() => _GrownUpGateState();
}

class _GrownUpGateState extends State<_GrownUpGate> {
  final _answer = TextEditingController();
  bool _wrong = false;

  void _check() {
    if (int.tryParse(_answer.text.trim()) == widget.a + widget.b) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _wrong = true);
      _answer.clear();
    }
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(PrincessSpace.s16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(PrincessSpace.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('For grown-ups', style: PrincessText.sheetTitle.copyWith(color: PrincessColors.ink)),
              const SizedBox(height: PrincessSpace.s8),
              Text('To change settings, answer this sum.', style: PrincessText.bodyText.copyWith(color: PrincessColors.inkMuted)),
              const SizedBox(height: PrincessSpace.s16),
              Text('What is ${widget.a} + ${widget.b}?', style: PrincessText.occasion.copyWith(color: PrincessColors.ink)),
              const SizedBox(height: PrincessSpace.s12),
              TextField(
                controller: _answer,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (_) => _check(),
                decoration: InputDecoration(
                  hintText: 'Answer',
                  errorText: _wrong ? 'That’s not it. Try again.' : null,
                ),
              ),
              const SizedBox(height: PrincessSpace.s20),
              Row(
                children: [
                  Expanded(child: PressButton(label: 'Cancel', onPressed: () => Navigator.of(context).pop(false))),
                  const SizedBox(width: PrincessSpace.s12),
                  Expanded(child: PressButton(label: 'Check', icon: 'check', kind: PressKind.berry, onPressed: _check)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks for the occasion of a special day on [date], then saves it.
Future<void> addSpecialDay(BuildContext context, DressUpProgress progress, DateTime date) async {
  final picked = await showDialog<String>(
    context: context,
    barrierColor: PrincessColors.scrim,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(PrincessSpace.s16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(PrincessSpace.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('What’s on ${longDate(date)}?', style: PrincessText.sheetTitle.copyWith(color: PrincessColors.ink)),
              const SizedBox(height: PrincessSpace.s8),
              Text('It replaces the afternoon outfit that day.', style: PrincessText.bodyText.copyWith(color: PrincessColors.inkMuted)),
              const SizedBox(height: PrincessSpace.s16),
              Wrap(
                spacing: PrincessSpace.s8,
                runSpacing: PrincessSpace.s8,
                children: [
                  for (final o in kSpecialOccasions)
                    ActionChip(
                      avatar: GameIcon(o, size: 22, color: occasionStyle(o).deep),
                      label: Text(kOccasions[o]!.name),
                      backgroundColor: occasionStyle(o).tint,
                      side: BorderSide.none,
                      onPressed: () => Navigator.of(context).pop(o),
                    ),
                ],
              ),
              const SizedBox(height: PrincessSpace.s20),
              PressButton(label: 'Cancel', onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    ),
  );
  if (picked != null) progress.setSpecial(date, picked);
}

/// City for the weather, the child's birthday, and special days. Open it after [askGrownUp].
class GrownUpSettings extends StatefulWidget {
  const GrownUpSettings({super.key, required this.progress, required this.today});

  final DressUpProgress progress;
  final DateTime today;

  @override
  State<GrownUpSettings> createState() => _GrownUpSettingsState();
}

class _GrownUpSettingsState extends State<GrownUpSettings> {
  final _query = TextEditingController();
  List<City> _results = const [];
  bool _searching = false;
  String? _searchError;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _query.text.trim();
    if (q.length < 2) return;
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final found = await widget.progress.weatherService.searchCity(q);
      setState(() {
        _results = found;
        _searchError = found.isEmpty ? 'No city called “$q”. Check the spelling.' : null;
      });
    } catch (_) {
      setState(() => _searchError = 'Couldn’t reach the weather service. Check the internet connection and try again.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _addDay() async {
    final today = widget.today;
    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 1, today.month, today.day),
    );
    if (date != null && mounted) await addSpecialDay(context, widget.progress, date);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.progress;
    return Dialog(
      insetPadding: const EdgeInsets.all(PrincessSpace.s16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListenableBuilder(
          listenable: p,
          builder: (context, _) {
            final upcoming = p.specials.entries.where((e) => e.key.compareTo(dateKey(widget.today)) >= 0).toList()
              ..sort((a, b) => a.key.compareTo(b.key));
            return SingleChildScrollView(
              padding: const EdgeInsets.all(PrincessSpace.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Grown-up settings', style: PrincessText.sheetTitle.copyWith(color: PrincessColors.ink)),
                  _heading('Weather city'),
                  Text(
                    p.city == null ? 'Not set. The game uses pretend nice weather.' : '${p.city!.name}, ${p.city!.region}',
                    style: PrincessText.bodyText.copyWith(color: PrincessColors.ink),
                  ),
                  const SizedBox(height: PrincessSpace.s8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _query,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _search(),
                          decoration: const InputDecoration(hintText: 'City name, e.g. Warsaw'),
                        ),
                      ),
                      const SizedBox(width: PrincessSpace.s8),
                      PressButton(label: _searching ? 'Finding…' : 'Find', onPressed: _search),
                    ],
                  ),
                  if (_searchError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: PrincessSpace.s8),
                      child: Text(_searchError!, style: PrincessText.caption.copyWith(color: PrincessColors.coralDeep)),
                    ),
                  for (final c in _results)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const GameIcon('pin'),
                      title: Text(c.name, style: PrincessText.tab),
                      subtitle: Text(c.region, style: PrincessText.caption),
                      onTap: () {
                        p.setCity(c);
                        setState(() => _results = const []);
                        _query.clear();
                      },
                    ),
                  if (p.city != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(onPressed: () => p.setCity(null), child: const Text('Stop using real weather')),
                    ),
                  _heading('Child’s birthday'),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: p.birthday?.month,
                          hint: const Text('Month'),
                          items: [for (var m = 1; m <= 12; m++) DropdownMenuItem(value: m, child: Text(monthName(m)))],
                          onChanged: (m) => m == null ? null : p.setBirthday(MonthDay(m, (p.birthday?.day ?? 1).clamp(1, _daysIn(m)))),
                        ),
                      ),
                      const SizedBox(width: PrincessSpace.s12),
                      SizedBox(
                        width: 110,
                        child: DropdownButtonFormField<int>(
                          key: ValueKey(p.birthday?.month),
                          initialValue: p.birthday?.day,
                          hint: const Text('Day'),
                          items: [for (var d = 1; d <= _daysIn(p.birthday?.month ?? 1); d++) DropdownMenuItem(value: d, child: Text('$d'))],
                          onChanged: p.birthday == null ? null : (d) => d == null ? null : p.setBirthday(MonthDay(p.birthday!.month, d)),
                        ),
                      ),
                    ],
                  ),
                  if (p.birthday != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(onPressed: () => p.setBirthday(null), child: const Text('Remove birthday')),
                    ),
                  _heading('Special days'),
                  if (upcoming.isEmpty)
                    Text('None yet. Halloween and Christmas are added automatically.', style: PrincessText.caption),
                  for (final e in upcoming)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: GameIcon(e.value, color: occasionStyle(e.value).deep),
                      title: Text(kOccasions[e.value]!.name, style: PrincessText.tab),
                      subtitle: Text(longDate(DateTime.parse(e.key)), style: PrincessText.caption),
                      trailing: IconButton(
                        tooltip: 'Remove',
                        onPressed: () => p.setSpecial(DateTime.parse(e.key), null),
                        icon: const GameIcon('trash'),
                      ),
                    ),
                  const SizedBox(height: PrincessSpace.s8),
                  PressButton(label: 'Add a special day', icon: 'plus', onPressed: _addDay),
                  const SizedBox(height: PrincessSpace.s20),
                  PressButton(label: 'Done', icon: 'check', kind: PressKind.berry, onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static int _daysIn(int month) => DateTime(2024, month + 1, 0).day;

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(top: PrincessSpace.s20, bottom: PrincessSpace.s8),
        child: Text(text.toUpperCase(), style: PrincessText.kicker.copyWith(fontSize: 15, color: PrincessColors.inkMuted)),
      );
}

/// Asks the grown-up question, then opens the settings.
Future<void> openGrownUps(BuildContext context, DressUpProgress progress, DateTime today) async {
  if (!await askGrownUp(context) || !context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierColor: PrincessColors.scrim,
    builder: (_) => GrownUpSettings(progress: progress, today: today),
  );
}
