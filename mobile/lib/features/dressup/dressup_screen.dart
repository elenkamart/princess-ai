import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/princess_theme.dart';
import 'dressup_art_data.dart';
import 'dressup_game.dart';
import 'dressup_progress.dart';
import 'dressup_widgets.dart';

/// The dress-up game: three occasions a day, Lulu's stage and her closet.
class DressUpScreen extends StatefulWidget {
  const DressUpScreen({super.key});

  @override
  State<DressUpScreen> createState() => _DressUpScreenState();
}

class _DressUpScreenState extends State<DressUpScreen> {
  static const _when = ['Morning', 'Afternoon', 'Evening'];
  static const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  final DateTime _today = DateTime.now();
  DressUpProgress? _progress;
  int _cur = 0;
  String _tab = 'top';
  Mood _mood = Mood.ok;
  String? _message;
  List<String> _wrongIds = const [];
  int _popKey = 0;

  @override
  void initState() {
    super.initState();
    DressUpProgress.load().then((p) {
      if (mounted) setState(() => _progress = p);
    });
  }

  @override
  void dispose() {
    _progress?.dispose();
    super.dispose();
  }

  void _resetTalk() {
    _mood = Mood.ok;
    _message = null;
    _wrongIds = const [];
  }

  void _selectOccasion(int i) => setState(() {
        _cur = i;
        _resetTalk();
      });

  void _tapItem(DressUpItem item) {
    final p = _progress!;
    final outfit = p.day(_today).outfits[_cur];
    final wasOn = outfit[item.slot] == item.id;
    setState(() {
      _wrongIds = _wrongIds.where((id) => id != item.id).toList();
      _mood = Mood.ok;
      _message = wasOn ? null : 'Ooh, the ${item.name.toLowerCase()}!';
    });
    p.setOutfit(_today, _cur, wear(outfit, item));
  }

  void _check() {
    final p = _progress!;
    final r = p.day(_today);
    final res = judge(r.outfits[_cur], r.plan[_cur]);
    final before = r.stars[_cur];
    setState(() {
      _mood = res.mood;
      _message = res.message;
      _wrongIds = res.wrong.map((w) => w.id).toList();
      if (res.wrong.isNotEmpty) _tab = res.wrong.first.slot;
      if (res.stars > before) _popKey++;
    });
    if (p.recordStars(_today, _cur, res.stars)) _showSticker();
  }

  void _showSticker() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const StarIcon(filled: true, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('You earned today’s sticker!', style: PrincessText.occasion.copyWith(color: PrincessColors.surface)),
                  Text('Come back tomorrow for new outfits.', style: PrincessText.caption.copyWith(color: PrincessColors.surface)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startOver() {
    setState(_resetTalk);
    _progress!.setOutfit(_today, _cur, {});
  }

  void _next() => _selectOccasion(_cur + 1);

  Future<void> _openLook() => showDialog<void>(
        context: context,
        barrierColor: PrincessColors.scrim,
        builder: (_) => _LookSheet(progress: _progress!),
      );

  @override
  Widget build(BuildContext context) {
    final p = _progress;
    if (p == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: p,
          builder: (context, _) => LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth >= 880;
              final narrow = box.maxWidth < 560;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(PrincessSpace.s16, PrincessSpace.s16, PrincessSpace.s16, PrincessSpace.s32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _header(p, narrow),
                        const SizedBox(height: PrincessSpace.s16),
                        _plan(p, narrow),
                        const SizedBox(height: PrincessSpace.s16),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: _stagePanel(p)),
                              const SizedBox(width: PrincessSpace.s16),
                              Expanded(flex: 6, child: _closetPanel(p, narrow)),
                            ],
                          )
                        else ...[
                          _stagePanel(p),
                          const SizedBox(height: PrincessSpace.s16),
                          _closetPanel(p, narrow),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _header(DressUpProgress p, bool narrow) {
    final date = '${_weekdays[_today.weekday - 1]} ${_today.day} ${_months[_today.month - 1]}';
    return Wrap(
      spacing: PrincessSpace.s20,
      runSpacing: PrincessSpace.s12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const StarIcon(filled: true, size: 48),
            const SizedBox(width: PrincessSpace.s12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text('Princess AI Dress-Up', style: PrincessText.gameTitle.copyWith(color: PrincessColors.ink, fontSize: narrow ? 24 : 30)),
                ),
                Text(date, style: PrincessText.caption),
              ],
            ),
          ],
        ),
        WeekStrip(today: _today, isDone: p.isDone, streak: p.streak(_today)),
        PressButton(label: 'Change look', icon: 'palette', onPressed: _openLook),
      ],
    );
  }

  Widget _plan(DressUpProgress p, bool narrow) {
    final r = p.day(_today);
    final cards = [
      for (var i = 0; i < 3; i++)
        OccasionCard(when: _when[i], occasion: r.plan[i], stars: r.stars[i], selected: i == _cur, onTap: () => _selectOccasion(i)),
    ];
    if (narrow) {
      return Column(children: [for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: PrincessSpace.s8), child: c)]);
    }
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: PrincessSpace.s12),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }

  BoxDecoration get _panel => BoxDecoration(
        color: PrincessColors.surface,
        borderRadius: BorderRadius.circular(PrincessRadius.r28),
        boxShadow: PrincessShadows.lift,
      );

  Widget _stagePanel(DressUpProgress p) {
    final r = p.day(_today);
    final occ = r.plan[_cur];
    final occText = kOccasions[occ]!;
    final maxStage = MediaQuery.sizeOf(context).height * 0.58;
    final buttons = <Widget>[
      PressButton(label: 'Check my outfit', icon: 'check', kind: PressKind.berry, onPressed: _check),
      if (r.stars[_cur] > 0 && _cur < 2) PressButton(label: 'Next: ${kOccasions[r.plan[_cur + 1]]!.name}', kind: PressKind.star, onPressed: _next),
      PressButton(label: 'Start over', icon: 'undo', onPressed: _startOver),
    ];
    return Container(
      decoration: _panel,
      padding: const EdgeInsets.all(PrincessSpace.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SpeechBubble(text: _message ?? occText.hello, oops: _mood == Mood.oops),
          const SizedBox(height: 14),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxStage),
              child: AspectRatio(
                aspectRatio: 400 / 440,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(PrincessRadius.r20),
                  child: SvgPicture.string(
                    stageSvg(occ, p.look, r.outfits[_cur], _mood),
                    fit: BoxFit.cover,
                    semanticsLabel: 'Lulu dressed for ${occText.name}',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          StarMeter(stars: r.stars[_cur], popKey: _popKey),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, box) => box.maxWidth >= 420
                ? Row(
                    children: [
                      for (var i = 0; i < buttons.length; i++) ...[
                        if (i > 0) const SizedBox(width: PrincessSpace.s12),
                        Expanded(child: buttons[i]),
                      ],
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < buttons.length; i++) ...[
                        if (i > 0) const SizedBox(height: PrincessSpace.s16),
                        buttons[i],
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _closetPanel(DressUpProgress p, bool narrow) {
    final outfit = p.day(_today).outfits[_cur];
    final items = kItems.where((it) => it.slot == _tab).toList();
    final minTile = narrow ? 100.0 : PrincessSizes.itemTileMin;
    return Container(
      decoration: _panel,
      padding: const EdgeInsets.all(PrincessSpace.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('Lulu’s closet', style: PrincessText.panelTitle.copyWith(color: PrincessColors.ink)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 2),
              itemCount: kSlots.length,
              separatorBuilder: (_, i) => const SizedBox(width: PrincessSpace.s8),
              itemBuilder: (_, i) => CategoryTab(
                slot: kSlots[i],
                selected: kSlots[i] == _tab,
                wearing: outfit.containsKey(kSlots[i]),
                onTap: () => setState(() => _tab = kSlots[i]),
              ),
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, box) {
              final cols = ((box.maxWidth + 12) / (minTile + 12)).floor().clamp(2, 8);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 10, right: 8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: PrincessSpace.s12,
                  mainAxisSpacing: PrincessSpace.s12 + 4,
                  mainAxisExtent: 150,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final it = items[i];
                  final on = outfit[it.slot] == it.id;
                  return ItemTile(item: it, look: p.look, worn: on, nope: on && _wrongIds.contains(it.id), onTap: () => _tapItem(it));
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Skin tone, hair color and hairstyle for Lulu.
class _LookSheet extends StatelessWidget {
  const _LookSheet({required this.progress});

  final DressUpProgress progress;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(PrincessSpace.s16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListenableBuilder(
          listenable: progress,
          builder: (context, _) {
            final look = progress.look;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(PrincessSpace.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Change Lulu’s look', style: PrincessText.sheetTitle.copyWith(color: PrincessColors.ink)),
                  _label('Skin'),
                  _swatches(kSkins, look.skin, 'Skin tone', (i) => progress.setLook(look.copyWith(skin: i))),
                  _label('Hair color'),
                  _swatches(kHairColors, look.hair, 'Hair color', (i) => progress.setLook(look.copyWith(hair: i))),
                  _label('Hairstyle'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var i = 0; i < kHairStyles.length; i++)
                        _choice(
                          selected: look.style == i,
                          label: const ['Puffs', 'Long hair', 'Short hair'][i],
                          onTap: () => progress.setLook(look.copyWith(style: i)),
                          child: Container(
                            width: 96,
                            height: 96,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: look.style == i ? PrincessColors.surfacePink : PrincessColors.canvas,
                              borderRadius: BorderRadius.circular(PrincessRadius.r20),
                              border: Border.all(color: look.style == i ? PrincessColors.berry : PrincessColors.border, width: 3),
                            ),
                            child: SvgPicture.string(headSvg(look.copyWith(style: i))),
                          ),
                        ),
                    ],
                  ),
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 10),
        child: Text(text.toUpperCase(), style: PrincessText.kicker.copyWith(fontSize: 16, color: PrincessColors.inkMuted)),
      );

  Widget _swatches(List<String> colors, int selected, String name, ValueChanged<int> onPick) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < colors.length; i++)
            _choice(
              selected: selected == i,
              label: '$name ${i + 1}',
              onTap: () => onPick(i),
              child: Container(
                width: PrincessSizes.tapMin,
                height: PrincessSizes.tapMin,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(int.parse('ff${colors[i].substring(1)}', radix: 16)),
                  border: Border.all(color: PrincessColors.surface, width: 4),
                  boxShadow: [BoxShadow(color: selected == i ? PrincessColors.berry : PrincessColors.border, spreadRadius: selected == i ? 4 : 3)],
                ),
              ),
            ),
        ],
      );

  Widget _choice({required bool selected, required String label, required VoidCallback onTap, required Widget child}) => Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: child),
      );
}
