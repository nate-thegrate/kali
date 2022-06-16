import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kali/assets/data.dart';
import 'package:kali/assets/structs.dart';
import 'package:kali/assets/globals.dart';

class Buffer extends StatelessWidget {
  final double scale;
  const Buffer([this.scale = 1, Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(height: context.buffer * scale);
}

/// this widget is used in place of [Text] pretty much everywhere.
///
/// Has options for size, color, font weight, and alignment.
class KaliText extends StatelessWidget {
  final String txt;
  final double scale;
  final MyColor? color;
  final bool white;
  final bool bold;
  final bool alignLeft;

  const KaliText(
    this.txt, {
    this.scale = 1,
    this.color,
    this.white = false,
    this.bold = false,
    this.alignLeft = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Text(
        txt,
        textAlign: alignLeft ? TextAlign.left : TextAlign.center,
        style: TextStyle(
          fontSize: context.buffer * scale,
          color: color?.rgb ?? (white ? Colors.white : Colors.black),
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      );
}

class ScreenDetector extends StatelessWidget {
  final Color backgroundColor;
  final void Function()? onTap;
  final Widget body;

  /// used in place of [Scaffold].
  ///
  /// Detects taps anywhere on the screen.
  const ScreenDetector({
    required this.backgroundColor,
    this.onTap,
    required this.body,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GestureDetector(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints.expand(),
            color: backgroundColor,
            child: Center(child: body),
          ),
        ),
      );
}

class BetterScroll extends StatelessWidget {
  final ScrollController controller = ScrollController();
  final Widget child;

  int get _direction {
    switch (controller.position.userScrollDirection) {
      case ScrollDirection.forward:
        return 1;
      case ScrollDirection.idle:
        return 0;
      case ScrollDirection.reverse:
        return -1;
    }
  }

  static const int _extraScroll = 80;
  void _scrollBoost() => controller.jumpTo(
        min(
          controller.position.maxScrollExtent,
          max(controller.position.minScrollExtent, controller.offset - _extraScroll * _direction),
        ),
      );

  /// makes mouse wheel scrolling not suck.
  BetterScroll({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.windows) {
      controller.addListener(_scrollBoost);
    }
    return SingleChildScrollView(controller: controller, child: child);
  }
}

/// a button with the color found in `Data.buttoncolor`.
class ColorButton extends StatelessWidget {
  final String txt;
  final Color? color;
  final void Function()? onPressed;

  const ColorButton(
    this.txt, {
    this.color,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? Data.buttonColor;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: c),
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.all(context.buffer / 2),
        child: Opacity(
          opacity: onPressed == null ? 1 / 3 : 1,
          child: KaliText(
            txt,
            white: HSLColor.fromColor(c).lightness < .5,
          ),
        ),
      ),
    );
  }
}

class ClearButton extends StatelessWidget {
  final String txt;
  final void Function()? onPressed;

  const ClearButton(
    this.txt, {
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final overlayColor = MaterialStateProperty.all(Data.buttonColor.withAlpha(85));

    return TextButton(
      style: ButtonStyle(overlayColor: overlayColor),
      onPressed: onPressed,
      child: Opacity(
        opacity: 1 / 3,
        child: KaliText(txt, white: true, scale: .8),
      ),
    );
  }
}

class LightBox extends StatelessWidget {
  final Widget child;
  final bool allRoundedCorners;

  const LightBox({
    required this.child,
    this.allRoundedCorners = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = allRoundedCorners
        ? BorderRadius.all(Radius.circular(context.buffer))
        : BorderRadius.only(
            bottomLeft: Radius.circular(context.buffer),
            bottomRight: Radius.circular(context.buffer),
          );

    return Container(
      constraints: BoxConstraints(maxWidth: context.buffer * 28),
      padding: EdgeInsets.all(context.buffer),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Data.boxColor,
        boxShadow: shadow(context),
      ),
      child: child,
    );
  }
}

class ColorBox extends StatelessWidget {
  final MyColor color;
  final Function setState;
  final bool showingAll;

  /// a colored box used during startup.
  ///
  /// Changes `Data.color` to its color when selected.
  const ColorBox(this.color, this.setState, {this.showingAll = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(context.buffer * (showingAll ? 0.5 : 0.75)),
      decoration: BoxDecoration(
        border: color == Data.color
            ? Border.all(
                width: context.buffer / 2.5,
                color: color.l < 1 ? Colors.white : Colors.black,
              )
            : null,
        boxShadow: const [
          BoxShadow(
            blurRadius: 1,
            color: Colors.black87,
          )
        ],
      ),
      child: Material(
        color: color.rgb,
        child: InkWell(
          onTap: () => setState(() => Data.color = color),
        ),
      ),
    );
  }
}

/// implements sliders for H / S / L during startup.
class ColorSlider extends StatelessWidget {
  final String c;
  final Function(String) update;

  const ColorSlider(
    this.c, {
    required this.update,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double h = Data.color.h;
    final double s = (c == 'S' || c == 'L') ? Data.color.s : 1.0;
    final double l = (c == 'L') ? Data.color.l : .5;
    final Map<String, double> hsl = {'H': h, 'S': s, 'L': l};

    return Row(
      children: [
        KaliText(c, bold: true),
        Flexible(
          child: Slider(
            value: hsl[c]!,
            onChanged: update(c),
            min: 0,
            max: c == 'H' ? 360 : 1,
            thumbColor: MyColor(h, s, l).rgb,
            activeColor: MyColor(h, s, l * 3 / 4).rgb,
            inactiveColor: Colors.black12,
          ),
        ),
      ],
    );
  }
}

class TerminalText extends StatelessWidget {
  final List<TextSpan> children;
  final MyColor color;

  /// gives a list of [TextSpan] widgets the proper formatting
  /// for a terminal aesthetic.
  const TerminalText({
    required this.children,
    this.color = MyColors.terminalText,
    super.key,
  });

  /// applies formatting for the terminal login messages.
  TerminalText.loginMessage(String text, {super.key})
      : children = [TextSpan(text: text)],
        color = MyColors.gray;

  /// creates a very fancy terminal command.
  static TerminalText command({
    required String directory,
    required String command,
    bool root = false,
  }) {
    final TextStyle brackets = TextStyle(
      color: root ? Colors.blue : Colors.green,
    );
    final TextStyle user = TextStyle(
      color: root ? Colors.red : Colors.blue,
      fontWeight: FontWeight.bold,
    );
    return TerminalText(
      children: [
        TextSpan(text: '┌──(', style: brackets),
        TextSpan(
          text: '${root ? 'root' : 'nate'}@kali-system',
          style: user,
        ),
        TextSpan(text: ')─[', style: brackets),
        TextSpan(text: directory),
        TextSpan(text: ']\n└─', style: brackets),
        TextSpan(text: root ? '# ' : '\$ ', style: user),
        TextSpan(text: command),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          style: GoogleFonts.firaCode(
            color: color.rgb,
            fontSize: context.buffer * .8,
          ),
          children: children,
        ),
      );
}
