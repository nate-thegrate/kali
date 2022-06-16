import 'package:flutter/material.dart';
import 'dart:math';

import 'package:kali/assets/structs.dart';

/// the data to load when the app is launched or restarted.
///
/// In production, data should be loaded from the player's device.
SaveData launchData = DataPreset.startup;

/// used to generate random values.
/// ```dart
/// rng.nextInt(int max); // [0, max)
/// rng.nextDouble();     // [0, 1)
/// rng.nextBool();       // true or false
/// ```
final Random rng = Random();

/// basically `null` but with the [Widget] type.
///
/// Won't show anything or take up any space.
const Widget empty = SizedBox.shrink();

/// automatically expands to fill empty space in a [Row] or [Column].
const Widget filler = Expanded(child: empty);

/// duration of quick animations, like expanding a [Post].
const Duration animationDuration = Duration(milliseconds: 250);

/// `easeOutCubic` is the best.
const Curve animationCurve = Curves.easeOutCubic;

/// ```dart
///
/// await sleep(3);
/// ```
/// is just like `time.sleep(3)` in Python.
///
/// Must be called in an `async` function.
Future<void> sleep(double seconds) =>
    Future.delayed(Duration(milliseconds: (seconds * 1000).toInt()));

/// so I don't have to type out a full `List<BoxShadow>` each time.
List<BoxShadow> shadow(BuildContext context, {double scale = .5, bool offset = true}) {
  return [
    BoxShadow(
      blurRadius: context.buffer * scale,
      offset: offset ? Offset(context.buffer * scale, context.buffer * scale) : Offset.zero,
      color: Colors.black54,
    )
  ];
}

extension ContextStuff on BuildContext {
  /// the size of pretty much everything is based on this buffer value.
  ///
  /// This should allow the game to work on any screen.
  double get buffer {
    final Size screenSize = MediaQuery.of(this).size;
    return min(screenSize.height * 2 / 3, screenSize.width) / 30;
  }

  void goto(Pages page) => Navigator.pushReplacementNamed(this, page());
}
