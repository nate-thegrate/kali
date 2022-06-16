import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kali/assets/data.dart';
import 'package:kali/assets/globals.dart';
import 'package:kali/assets/structs.dart';
import 'package:kali/assets/widgets.dart';

class Tabs extends StatelessWidget {
  final List<String> labels;
  final List<Widget> content;
  final Widget? button;
  static const double _tabScale = 2.5;

  const Tabs({required this.labels, required this.content, this.button, super.key});

  @override
  Widget build(BuildContext context) {
    assert(labels.length == content.length);

    return DefaultTabController(
      length: labels.length,
      initialIndex: 1,
      child: Scaffold(
        backgroundColor: Data.backgroundColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(context.buffer * _tabScale + 2),
          child: Material(
            color: Data.boxColor,
            elevation: 5,
            child: SafeArea(
              child: TabBar(
                overlayColor: MaterialStateProperty.all(Data.buttonColor.withAlpha(64)),
                indicatorColor: Data.buttonColor,
                tabs: [
                  for (final label in labels)
                    Container(
                      height: context.buffer * _tabScale,
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        style: GoogleFonts.firaCode(color: Colors.black, fontSize: context.buffer),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(bottom: context.buffer * 5.5),
          child: TabBarView(children: content),
        ),
        floatingActionButton: button == null
            ? null
            : Padding(
                padding: EdgeInsets.only(bottom: context.buffer),
                child: button,
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  final dummy = Data.getUpgrades();
  @override
  Widget build(BuildContext context) {
    return Tabs(
      labels: const ['Owned', 'Available', 'Hidden'],
      content: [
        Column(children: [
          Card(
            color: MyColors.terminalBkgd.rgb,
            child: SizedBox(width: context.buffer * 5, height: context.buffer * 5),
          ),
        ]),
        Column(
          children: [
            filler,
            for (final upgrade in Data.upgrades.available)
              Card(
                color: Data.boxColor,
                elevation: 5,
                child: Container(
                  width: context.buffer * 25,
                  height: context.buffer * 2,
                  alignment: Alignment.center,
                  child: KaliText(upgrade.name, scale: .75),
                ),
              ),
            filler,
          ],
        ),
        Column(children: const [KaliText('Hidden')]),
      ],
      button: ColorButton('Next', onPressed: () {}),
    );
  }
}
