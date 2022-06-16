import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kali/assets/data.dart';
import 'package:kali/assets/structs.dart';
import 'package:kali/pages/curation.dart';
import 'package:kali/pages/convos.dart';
import 'package:kali/pages/startup.dart';
import 'package:kali/pages/terminal.dart';
import 'package:kali/pages/upgrades.dart';

void main() {
  // todo: load save data here
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Kali',
        theme: ThemeData(textTheme: GoogleFonts.firaCodeTextTheme(Theme.of(context).textTheme)),
        initialRoute: Data.page,
        routes: {
          Pages.convos(): (context) => const ConvoScreen(),
          Pages.curation(): (context) => const Curation(),
          Pages.startup(): (context) => const Startup(),
          Pages.terminal(): (context) => const Terminal(),
          Pages.upgrades(): (context) => const UpgradeScreen(),
        },
      );
}
