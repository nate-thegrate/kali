import 'dart:io';
import 'package:flutter/material.dart';

import 'package:kali/assets/data.dart';
import 'package:kali/assets/globals.dart';
import 'package:kali/assets/structs.dart';
import 'package:kali/assets/widgets.dart';

class ImageIndex {
  int index;

  void cycle() => index = (index + 2) % 25;

  /// used for looping through TV static frames.
  ImageIndex(this.index);

  Widget get image => Image.asset(
        'lib/assets/images/static/$index.png',
        scale: .1,
        filterQuality: FilterQuality.none,
      );

  @override
  String toString() => index.toString();
}

/// creates the TV static effect.
class Static {
  bool running = false;
  bool abort = false;
  bool _topLayerVisible = true;
  final ImageIndex _bottom = ImageIndex(0);
  final ImageIndex _top = ImageIndex(1);

  Widget get image => Stack(
        children: [
          _bottom.image,
          Opacity(
            opacity: _topLayerVisible ? 1 : 0,
            child: _top.image,
          ),
        ],
      );

  void animate(Function setState, String name) async {
    running = true;
    (_topLayerVisible) ? _bottom.cycle() : _top.cycle();

    await sleep(1 / 30);
    if (abort || name != '') return;
    setState(() => _topLayerVisible = !_topLayerVisible);

    animate(setState, name);
  }

  void stop() {
    abort = true;
    running = false;
  }
}

class FancyTerminalStats extends StatelessWidget {
  final Map<String, String> stats;

  /// displays stats from the `FancyStats` class.
  const FancyTerminalStats(this.stats, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            for (final stat in stats.entries)
              Row(
                children: [
                  Expanded(flex: 1, child: KaliText(stat.key, scale: .8)),
                  Expanded(flex: 2, child: KaliText(stat.value, scale: .8)),
                ],
              ),
          ],
        ),
      );
}

class FancyStats {
  Map<String, String> stats = {};

  int random = rng.nextInt(4);

  double get cpu => (random + 50) * .75 - Data.karma;
  double get gpu => (random + 30 - Data.karma) * .2;

  String get tasks => '${Data.numProcesses + 1} total, '
      '${Data.activeProcesses} in background, '
      '${Data.numProcesses - Data.activeProcesses} sleeping';

  String get date {
    int day = Data.day;
    final List<int> months = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    int month = 1;
    for (final int days in months) {
      if (day <= days) return [day, month, 2020].join('.');
      month++;
      day -= days;
    }
    return 'something\'s wrong with the date';
  }

  String get time {
    final DateTime now = DateTime.now();
    final List<String> goodFormat = [
      for (final int val in [now.hour, now.minute, now.second]) '${val < 10 ? '0' : ''}$val'
    ];

    return goodFormat.join(':');
  }

  String percent(double value) => '${((value * 100).round().toDouble() / 100)}%';

  void get() {
    random = rng.nextInt(4);
    stats = {
      'datetime': '$date $time',
      'CPU utilization': percent(cpu),
      'GPU utilization': percent(gpu),
      'tasks': tasks,
    };
  }

  Widget get fancyTerminalStats => FancyTerminalStats(stats);

  /// shows stats at the bottom of the terminal.
  ///
  /// They'll update once every second.
  FancyStats() {
    get();
  }
}

class IntegratedTerminal {
  // todo (?): move this back to terminal.dart and implement dialog overlay, add fancystats
  final User user;
  String displayUsername = '';
  List<TextSpan> get content => [
        TextSpan(
          text: 'Kali ',
          style: TextStyle(
            color: MyColors.kali.rgb,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: 'integrated terminal: register user\n\n',
          style: TextStyle(color: MyColors.gray.rgb),
        ),
        TextSpan(
          text: 'Your voice will be linked to this '
              '${Data.company} username:\n\n',
        ),
        const TextSpan(text: '  > '),
        TextSpan(text: displayUsername, style: TextStyle(color: Colors.yellow[200])),
      ];
  List<TextSpan> displayContent = [];
  bool cursorVisible = true;
  String spinny = '';
  List<TextSpan> get cursor => [
        (cursorVisible ? const TextSpan(text: '▂') : const TextSpan(text: '')),
        TextSpan(
          text: spinny,
          style: const TextStyle(color: Colors.orange),
        ),
      ];

  Widget show() => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double maxSize = constraints.maxWidth;

          return Container(
            color: MyColors.terminalBkgd.rgb,
            width: maxSize,
            height: maxSize,
            padding: EdgeInsets.all(context.buffer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TerminalText(
                  children: displayContent,
                ),
              ],
            ),
          );
        },
      );

  void spin() {
    switch (spinny) {
      case '/':
        spinny = '-';
        return;
      case '-':
        spinny = '\\';
        return;
      case '\\':
        spinny = '|';
        return;
      default:
        spinny = '/';
        return;
    }
  }

  Future<void> runTerminal(Function refreshTerminal) async {
    await sleep(0.7);
    refreshTerminal(content.sublist(0, 2));
    await sleep(0.7);
    refreshTerminal();
    for (int i = 0; i < 6; i++) {
      cursorVisible = !cursorVisible;
      refreshTerminal();
      await sleep(.5);
    }
    for (final String c in '${user.username}\n'.split('')) {
      await sleep((rng.nextInt(3) + 1) / 10);
      displayUsername += c;
      refreshTerminal();
    }
    displayUsername = '${user.username} ';
    cursorVisible = false;
    for (int i = 0; i < 18; i++) {
      await sleep(.2);
      spin();
      refreshTerminal();
    }
    spinny = 'found!';
    refreshTerminal();
    await sleep(1.5);
    spinny += '\n\nthis voice will be recognized as user "${user.name}".';
    refreshTerminal();
  }

  IntegratedTerminal.registration(this.user);
}

class ConvoScreen extends StatefulWidget {
  const ConvoScreen({super.key});

  @override
  State<ConvoScreen> createState() => _ConvoScreenState();
}

class _ConvoScreenState extends State<ConvoScreen> {
  Dialogue dialogue = Data.getDialogueToday()[0];
  String displayText = '';
  bool printing = false;
  bool cutscene = false;
  bool ticking = false;
  bool abortTick = false;
  bool inResponse = false;
  bool showAllOptions = false;
  Static static = Static();
  FancyStats fancyStats = FancyStats();
  IntegratedTerminal terminal = IntegratedTerminal.registration(notRegistered);

  /// max number of characters in a line of dialogue.
  ///
  /// Once we reach this, add a `\n`
  /// so we don't print part of the word on the old line.
  static const lineSize = 39;
  int lineBreaks = 0;
  String thisLineText = '';

  // used for fancy stats
  // void tick() async {
  //   ticking = true;
  //   await sleep(.995);
  //   if (abortTick) return;

  //   setState(() => fancyStats.get());
  //   tick();
  // }

  void Function() respond(Convo response) => () {
        dialogue = const Dialogue.none(); // so we don't re-trigger the question
        final Convo subsequent = Data.dialogueToday
            .sublist(Data.line + 1); // everything after the question in dialogueToday
        Data.dialogueToday = response + subsequent;
        Data.line = -1;
        Navigator.pop(context);
        display();
      };

  void display() async {
    final Event? event = dialogue.event;
    if (event is Question) {
      final Widget bufferBox = SizedBox(height: context.buffer);
      await showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AnimatedSize(
            duration: animationDuration,
            curve: animationCurve,
            child: ColoredBox(
              color: Data.backgroundColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  bufferBox,
                  for (final response in event.options.entries)
                    ColorButton(
                      response.key,
                      onPressed: respond(response.value),
                    ),
                  if (showAllOptions)
                    for (final response in event.additional.entries) ...[
                      bufferBox,
                      ColorButton(
                        response.key,
                        onPressed: respond(response.value),
                      )
                    ]
                  else if (event.additional.isNotEmpty) ...[
                    bufferBox,
                    ClearButton(
                      'generate other responses',
                      onPressed: () => setState(() => showAllOptions = true),
                    )
                  ],
                  bufferBox,
                ],
              ),
            ),
          ),
        ),
      );
    } else if (event is NavigateTo) {
      static.stop();
      context.goto(event.navigateTo);
      return;
    } else if (event is ShutDown) {
      Choices.no5thAmendmentRights.choose();
      exit(0);
    } else {
      if (Data.advance()) {
        static.stop();
        context.goto(Pages.curation);
        return;
      }

      dialogue = Data.dialogueToday[Data.line];
      Data.event = dialogue.event;

      final List<String> text = dialogue.body;
      setState(() => displayText = '');
      printing = true;
      for (final String snippet in text) {
        for (int i = 0; i < snippet.length; i++) {
          await sleep(Data.delay);
          final bool shouldAddLineBreak =
              thisLineText != '' && thisLineText.length + wordLengthAtIndex(i, snippet) > lineSize;
          if (shouldAddLineBreak) {
            assert(++lineBreaks <= 2);
            displayText += '\n';
            thisLineText = '';
          }
          thisLineText += snippet[i];
          setState(() => displayText += snippet[i]);
        }
        if (snippet != text[text.length - 1]) {
          await sleep(Data.delay * 2 + .1);
        }
      }
      thisLineText = '';
      lineBreaks = 0;
      setState(() => printing = false);
    }
  }

  /// if `snippet[i]` is the first letter of a word,
  /// returns the length of the word.
  int wordLengthAtIndex(int i, String snippet) {
    if (i > 0 && snippet[i - 1] != ' ') return 0;

    final List<String> words = snippet.split(' ');
    if (i == 0) return words[0].length;

    final int wordIndex = snippet.substring(0, i).split(' ').length - 1;
    return words[wordIndex].length;
  }

  void refreshTerminal([List<TextSpan>? content]) {
    setState(() => terminal.displayContent = content ?? terminal.content + terminal.cursor);
  }

  Widget get image {
    final Event? event = Data.event;
    if (event is Registration) {
      if (!ticking) {
        ticking = true;
        cutscene = true;
        static.stop();
        terminal = IntegratedTerminal.registration(event.user);
        terminal.runTerminal(refreshTerminal).then((_) async {
          await sleep(2.5);
          display();
          await sleep(1.4);
          display();
          static.abort = false;
          static.running = false;
          ticking = false;
          cutscene = false;
        });
      }
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double maxSize = constraints.maxWidth;

          return Container(
            color: MyColors.terminalBkgd.rgb,
            width: maxSize,
            height: maxSize,
            padding: EdgeInsets.all(context.buffer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TerminalText(
                  children: terminal.displayContent,
                ),
              ],
            ),
          );
        },
      );
    }
    return (dialogue.user == notRegistered) ? static.image : dialogue.user.profilePic();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainBox = LightBox(
        allRoundedCorners: false,
        child: Column(
          children: [
            image,
            const Buffer(),
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  KaliText(
                    dialogue.user.name,
                    scale: 1.5,
                    bold: true,
                  ),
                  SizedBox(width: dialogue.user.name.isNotEmpty ? context.buffer * .8 : 0),
                  Opacity(
                    opacity: 1 / 3,
                    child: KaliText(
                      dialogue.user.username,
                      scale: .8,
                      bold: true,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.buffer),
              child: KaliText(displayText, alignLeft: true),
            ),
          ],
        ));

    if (dialogue.user == notRegistered) {
      static.abort = false;
      if (!static.running) static.animate(setState, dialogue.user.name);
    } else {
      static.stop();
    }

    return ScreenDetector(
      backgroundColor: Data.backgroundColor,
      onTap: (printing || cutscene) ? null : display,
      body: Column(
        children: [
          const Buffer(),
          // ColorButton('Background Processes', onPressed: () => goto(Pages.terminal)),
          SizedBox(
            height: (MediaQuery.of(context).size.height - context.buffer * 33) / 3,
          ),
          mainBox,
        ],
      ),
    );
  }
}
