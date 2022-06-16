import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kali/assets/structs.dart';
import 'package:kali/assets/globals.dart';
import 'package:kali/assets/widgets.dart';

class FirstBoot {
  bool cursor = false;

  final List<String> paths = [
    '~',
    '~/kali/main_process/',
    '/home/nate/kali/main_process/',
  ];
  final List<String> commands = ['cd kali/main_process/', 'sudo su', './kali'];
  List<String> displayCommands = ['', '', ''];

  final String kaliArt = '\n'
      '                   ▙\n'
      '                   █▙\n'
      '                 ▟███████████████▙\n'
      '                 ████ ▐█████ ▐████\n'
      '               ▐█████ ▐█████ ▐█████▌\n'
      '               ▝▀████▄▟█████▄▟████▀▘\n'
      '                 █████████████████\n'
      '                 ▝▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▘\n';
  String launching = '                    launching ';
  String spinny = '/';
  String kaliDisplay = '';
  String kaliLaunch = '';

  RichText kaliArt2(double buffer) => RichText(
        text: TextSpan(
          text: kaliDisplay + kaliLaunch,
          style: GoogleFonts.firaCode(
            color: MyColors.kali.rgb,
            fontSize: buffer * .8,
          ),
        ),
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
      case '|':
        spinny = '/';
        return;
    }
  }
}

class Terminal extends StatefulWidget {
  const Terminal({super.key});

  @override
  State<Terminal> createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  FirstBoot f = FirstBoot();
  bool running = false;
  bool abort = false;
  List<Widget> displayText = [];

  @override
  Widget build(BuildContext context) {
    void firstBoot() async {
      running = true;
      await sleep(1);
      setState(() => displayText.add(
            TerminalText.loginMessage('Kali GNU/Linux Rolling kali tty3\n\n'),
          ));
      await sleep(2);
      setState(() => displayText.add(
          TerminalText.loginMessage('The programs included with the Kali GNU/Linux system are\n'
              'free software; the exact distribution terms for each\n'
              'program are described in the individual files in\n'
              '/usr/share/doc/*/copyright.\n\n'
              'Kali GNU/Linux comes with ABSOLUTELY NO WARRANTY,\n'
              'to the extent permitted by applicable law.\n')));
      await sleep(1);

      void refresh(int i) => setState(
            () => displayText[i + 2] = TerminalText.command(
              directory: f.paths[i],
              command: f.displayCommands[i] + (f.cursor ? '▂' : ''),
              root: i == 2,
            ),
          );

      void cursor(bool visible, int i) {
        f.cursor = visible;
        refresh(i);
      }

      void refreshKali({bool launching = false}) {
        if (launching) f.kaliLaunch = f.launching + f.spinny;
        setState(() => displayText[5] = f.kaliArt2(context.buffer));
      }

      for (int i = 0; i < 3; i++) {
        setState(() => displayText.add(TerminalText.command(
              directory: f.paths[i],
              command: f.displayCommands[i] + (f.cursor ? '▂' : ''),
              root: i == 2,
            )));
        for (int j = 0; j < 3 - i; j++) {
          cursor(true, i);
          await sleep(.5);
          cursor(false, i);
          await sleep(.5);
        }
        cursor(true, i);
        for (final c in f.commands[i].split('')) {
          await sleep((rng.nextInt(10) + 5) / 100);
          f.displayCommands[i] += c;
          refresh(i);
        }
        await sleep(.5);
        cursor(false, i);
        await sleep(.5);
        cursor(true, i);
        await sleep(.2);
        f.displayCommands[i] += '\n';
        refresh(i);
        await sleep(.25);
        cursor(false, i);
      }
      setState(() => displayText.add(f.kaliArt2(context.buffer)));
      for (final c in f.kaliArt.split('')) {
        f.kaliDisplay += c;
        refreshKali();
        await sleep(.01);
      }
      await sleep(.5);
      for (int i = 0; i < 25; i++) {
        refreshKali(launching: true);
        f.spin();
        await sleep(.2);
      }

      f.spinny = '';
      f.launching = '\n                   -- ready! --';
      refreshKali(launching: true);
      await sleep(1.5);
      abort = true;
      context.goto(Pages.convos);
    }

    if (!running) firstBoot();

    return Scaffold(
      backgroundColor: MyColors.terminalBkgd.rgb,
      body: Container(
        margin: EdgeInsets.all(context.buffer),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: displayText,
            ),
            filler,
          ],
        ),
      ),
    );
  }
}
