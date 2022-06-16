import 'package:flutter/material.dart';
import 'dart:math';

import 'package:kali/assets/data.dart';
import 'package:kali/assets/globals.dart';
import 'package:kali/assets/structs.dart';
import 'package:kali/assets/widgets.dart';

abstract class _CompanyName {
  static const List<String> _companies = [
    'facebook',
    'youtube',
    'whatsapp',
    'messenger',
    'instagram',
    'tiktok',
    'snapchat',
    'pinterest',
    'reddit',
    'twitter',
    'quora',
    'skype',
    'linkedin',
    'discord',
    'twitch',
  ];
  static const List<String> _spicyWords = [
    'onlyfans',
    'only fans',
    'xvideos',
    'x videos',
    'bangbros',
    'bang bros',
    'porn',
    'penis',
    'dick',
    'cock',
    'vagin',
    'cunt',
    'tits',
    'titties',
    'boob',
    'nigg',
    'fag',
    'bitch',
    'shit',
    'fuck',
    'damn',
    'jesus',
  ];
  static String name = '';
  static bool get _tooManyChars => name.length > 25;
  static bool get _copyrightStrike => inList(_companies);
  static bool get _spicy => inList(_spicyWords);
  static bool inList(List<String> list) {
    return list.any((word) => name.toLowerCase().contains(word));
  }

  static String get flavorText => _tooManyChars
      ? 'maybe something more concise.'
      : _copyrightStrike
          ? 'let\'s try to not break copyright law.'
          : _spicy
              ? 'uhh... you sure?'
              : '[Generate one]';
  static bool get invalid =>
      _CompanyName.name.isEmpty || _CompanyName._tooManyChars || _CompanyName._copyrightStrike;

  static int i = -1;
  static String _shuffle(String string) => (string.split('')..shuffle()).join('');
  static List<String> get names => [
        rng.nextBool() ? 'Readr' : 'Readly',
        Data.hueMatch(180)
            ? 'Cyan Clan'
            : Data.hueMatch(300)
                ? 'Magentle'
                : 'Preddict',
        rng.nextBool() ? 'WeTube' : 'expoFeed',
        fuck('shitfuck', 'poop'),
        _shuffle('asdfjkl;'),
      ];
  static void next() {
    i = (i + 1) % names.length;
    name = names[i];
    controller.text = name;
  }

  static bool show = false;
  static const OutlineInputBorder inputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white38, width: 1),
  );
  static TextEditingController controller = TextEditingController();
}

class Startup extends StatefulWidget {
  const Startup({super.key});

  @override
  State<Startup> createState() => _StartupState();
}

class _StartupState extends State<Startup> {
  bool visible = false;
  Duration get animationTime => Duration(milliseconds: visible ? 1500 : 500);
  int progress = -1;
  void advance() async {
    setState(() => visible = false);
    await sleep(.5);
    progress++;
    setState(() => visible = true);
  }

  void autoAdvance(int progress, [double sleepTime = 4]) async {
    await sleep(sleepTime);
    if (this.progress == progress) advance();
  }

  bool showAllColors = false;
  void customizeColor() => setState(() => showAllColors = true);
  Function(double) update(String c) {
    return (newVal) => setState(
          () {
            switch (c) {
              case 'H':
                Data.h = newVal;
                break;
              case 'S':
                Data.s = newVal;
                break;
              case 'L':
                Data.l = newVal;
                break;
            }
          },
        );
  }

  bool over18 = false;
  void verifyAge() {
    if (over18) {
      setState(() => Data.adultLanguage = !Data.adultLanguage);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: context.buffer * 10,
          color: Data.backgroundColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const KaliText(
                  'Hit this button if you\'re\nat least 18 years old.',
                  white: true,
                ),
                const Buffer(2),
                ColorButton(
                  'turn on adult language',
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      over18 = true;
                      Data.adultLanguage = true;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  late final List<Widget> disclaimer = [
    filler,
    const KaliText(
      'This game has references to real people\nand events.\n\n'
      'However: the people will be misrepresented\n'
      'and the events will be out of order.',
      white: true,
    ),
    filler,
    ColorButton('ok, I\'ll deal with it', color: MyColors.kali.rgb, onPressed: advance),
    filler,
  ];
  static const List<Widget> grabYourAirpods = [
    KaliText('🎧', white: true, scale: 10),
    Buffer(),
    KaliText('There\'s music.', white: true),
    Buffer(),
    KaliText('(grab your airpods)', white: true),
  ];
  static const List<Widget> frequentSaving = [
    KaliText('💾', white: true, scale: 10),
    Buffer(),
    KaliText('Progress is saved frequently.', white: true),
    Buffer(),
    KaliText('Feel free to quit whenever.', white: true),
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [const KaliText('oops', white: true)];

    switch (progress) {
      case -1:
        advance();
        break;
      case 0:
        content = disclaimer;
        break;
      case 1:
        autoAdvance(1);
        content = [filler, ...grabYourAirpods, filler];
        break;
      case 2:
        content = [
          filler,
          const KaliText('Choose your favorite color.', white: true),
          Opacity(
            opacity: .5,
            child: KaliText(
                Data.hueMatch(180)
                    ? '(cyan is my favorite too)'
                    : (Data.hueMatch(240) && Data.s <= 1 - Data.l / 2)
                        ? '(this is a really good choice.)'
                        : '',
                white: true),
          ),
          const Buffer(.5),
          SizedBox(
            height: max(context.buffer * 14 + 111, 290),
            child: LightBox(
              child: Column(
                children: [
                  filler,
                  SizedBox(
                    height: context.buffer * (showAllColors ? 10.4 : 13),
                    child: GridView.count(crossAxisCount: showAllColors ? 8 : 4, children: [
                      if (showAllColors)
                        for (final MyColor c in MyColors.moreOptions)
                          ColorBox(c, setState, showingAll: true)
                      else
                        for (final MyColor c in MyColors.someOptions) ColorBox(c, setState)
                    ]),
                  ),
                  filler,
                  showAllColors
                      ? Column(
                          children: [
                            for (final String c in ['H', 'S', 'L']) ColorSlider(c, update: update)
                          ],
                        )
                      : TextButton(
                          onPressed: customizeColor,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(context.buffer / 2),
                            child: const KaliText('More Options'),
                          ),
                        ),
                ],
              ),
            ),
          ),
          const Buffer(2),
          ColorButton('looks good', onPressed: advance),
          filler,
        ];
        break;
      case 3:
        content = [
          filler,
          const KaliText(
            'Choose whether to display adult language.',
            white: true,
          ),
          filler,
          GestureDetector(
            onTap: verifyAge,
            child: SizedBox(
              width: context.buffer * 22,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  LightBox(
                    child: SizedBox(
                      width: double.infinity,
                      child: KaliText(
                        'Adult Language: ' + fuck('fuck yeah', 'off'),
                        alignLeft: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: context.buffer),
                    child: Switch(
                      activeColor: Data.buttonColor,
                      value: Data.adultLanguage,
                      onChanged: (_) => verifyAge(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          filler,
          ColorButton('Continue', onPressed: advance),
          filler,
        ];
        break;
      case 4:
        autoAdvance(4);
        content = [filler, ...frequentSaving, filler];
        break;
      case 5:
        () async {
          await sleep(3);
          if (!_CompanyName.show) setState(() => _CompanyName.show = true);
        }();
        content = [
          filler,
          const KaliText('One last thing before we start.', white: true),
          filler,
          AnimatedOpacity(
            opacity: _CompanyName.show ? 1 : 0,
            duration: animationTime,
            child: const KaliText(
              'Name of the new social media app:',
              white: true,
            ),
          ),
          const Buffer(),
          AnimatedOpacity(
            opacity: _CompanyName.show ? 1 : 0,
            duration: animationTime,
            child: SizedBox(
              width: context.buffer * 22,
              child: TextField(
                onChanged: (text) => setState(() => _CompanyName.name = text.trim()),
                controller: _CompanyName.controller,
                cursorColor: Colors.white,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: context.buffer, color: Colors.white),
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: _CompanyName.inputBorder,
                  disabledBorder: _CompanyName.inputBorder,
                  errorBorder: _CompanyName.inputBorder,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          ),
          const Buffer(.25),
          SizedBox(
            width: context.buffer * 22,
            height: context.buffer * 1.5,
            child: AnimatedOpacity(
              opacity: _CompanyName.show ? 1 : 0,
              duration: animationTime,
              child: ClearButton(
                _CompanyName.flavorText,
                onPressed: () => setState(_CompanyName.next),
              ),
            ),
          ),
          filler,
          AnimatedOpacity(
            opacity: _CompanyName.show ? 1 : 0,
            duration: animationTime,
            child: ColorButton(
              'begin',
              onPressed: _CompanyName.invalid
                  ? null
                  : () {
                      Data.company = _CompanyName.name;
                      if (_CompanyName._spicy) Choices.spicyName.choose();
                      context.goto(Pages.terminal);
                    },
            ),
          ),
          filler,
        ];
        break;
    }

    return Scaffold(
      backgroundColor: Data.backgroundColor,
      body: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: animationTime,
        child: Center(
          child: SizedBox(
            width: context.buffer * 28,
            child: Column(children: content),
          ),
        ),
      ),
    );
  }
}
