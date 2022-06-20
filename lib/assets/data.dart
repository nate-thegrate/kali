import 'package:flutter/material.dart';
import 'package:kali/assets/content.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'package:kali/assets/globals.dart';
import 'package:kali/assets/structs.dart';

/// handles saving & loading from local storage,
/// and contains all post & dialogue data.
///
/// Also I'm using global variables because fuck you.
abstract class Data {
  /// contains all data to be loaded in when the app launches.
  static final SaveData _settings = launchData;

  /// ```dart
  ///
  /// pronouns[Choices.key1]['key2']
  /// ```
  /// `key1`: player's preferred pronoun (he, she, they, it)<br>
  /// `key2`: conjugation (he, him, his, he's)
  static const Map<Choices, Map<String, String>> _pronouns = {
    Choices.he: {
      'he': 'he',
      'him': 'him',
      'his': 'his',
      'he\'s': 'he\'s',
    },
    Choices.she: {
      'he': 'she',
      'him': 'her',
      'his': 'her',
      'he\'s': 'she\'s',
    },
    Choices.they: {
      'he': 'they',
      'him': 'they',
      'his': 'their',
      'he\'s': 'they\'re',
    },
    Choices.it: {
      'he': 'it',
      'him': 'it',
      'his': 'its',
      'he\'s': 'it\'s',
    },
  };

  static Choices get kaliPronoun {
    for (final choice in choices) {
      if (_pronouns.keys.contains(choice)) return choice;
    }
    throw Exception('Kali\'s preferred pronoun wasn\'t found.');
  }

  /// returns the player's preferred pronoun with the correct conjugation.
  /// ```dart
  /// pronoun = 'they';
  /// he('his') // returns 'their'
  /// ```
  static String he(String pronoun) {
    final String firstLetter = pronoun.substring(0, 1);
    final String result = _pronouns[kaliPronoun]![pronoun.toLowerCase()]!;
    if (firstLetter == firstLetter.toUpperCase()) {
      return result[0].toUpperCase() + result.substring(1);
    }
    return result;
  }

  /// conjugate a verb based on the player's preferred pronoun.
  /// ```dart
  /// he('he') + ' ' + conjugate('wants', 'want');
  /// ```
  /// will be evaluated as "he wants" or "they want", depending on which pronoun the player chose.
  static String conjugate(String he, String they) => (Choices.they.chosen) ? they : he;

  /// the page to load when the app launches.
  static Pages get page => _settings[Settings.page];

  /// an int representing the day of the year.
  ///
  /// The current plan is for [day] to be in the range `[0,366]`
  /// since the in-game year is 2020.
  static int get day => _settings[Settings.day];

  /// advances to the next in-game day.
  static void nextDay() {
    _settings[Settings.day]++;
    for (final content in relevantContentToday[day]!) {
      content.queueThis();
    }
  }

  /// a value invisible to the player,
  /// representing how ethically they've behaved so far.
  static double get karma => _settings[Settings.karma];

  /// the delay (in ms) between letters when displaying dialogue.
  static double get delay => _settings[Settings.dialogueDelay] / 1000;

  /// the name of the social media app.
  static String get company => _settings[Settings.companyName];
  static set company(String name) => _settings[Settings.companyName] = name;

  /// [color]'s hue.
  static double get h => _settings[Settings.colorH];
  static set h(double h) => _settings[Settings.colorH] = h;

  /// [color]'s saturation.
  static double get s => _settings[Settings.colorS];
  static set s(double s) => _settings[Settings.colorS] = s;

  /// [color]'s lightness.
  static double get l => _settings[Settings.colorL];
  static set l(double l) => _settings[Settings.colorL] = l;

  /// the player's "favorite color".
  static MyColor get color => MyColor(h, s, l);
  static set color(MyColor color) {
    h = color.h;
    s = color.s;
    l = color.l;
  }

  /// A lighter version of [color], used in [LightBox].
  static Color get boxColor => MyColor(h, s * .75, 1 - (1 - l) / 3).rgb;

  /// a darker version of [color], used for backgrounds.
  static Color get backgroundColor => MyColor(h, s - s * s / 3, l / 3).rgb;

  /// the color to use for buttons.
  ///
  /// a tiny bit lighter than [color]
  /// to make it more visible with dark backgrounds.
  static Color get buttonColor => MyColor(h, s, .25 + l / 2).rgb;

  /// checks if [color] matches a specified [hue].
  ///
  /// Only a select few can qualify for the `Cyan Clan`.
  static bool hueMatch(int hue) => (h - hue).abs() < 5 && s > 0.25;

  static Set<Content> get postQueue => _settings[Settings.postQueue];
  static Set<Content> get convoQueue => _settings[Settings.convoQueue];

  /// a set of all the major decisions the player has made.
  ///
  /// Exclusively contains the names of [Choices] elements.
  static Set<Choices> get choices => _settings[Settings.choices];

  /// used during startup
  /// when the player decides whether to enable adult language.
  ///
  /// The [fuck] function is used everywhere else.
  static bool get adultLanguage => Choices.profanity.chosen;

  static set adultLanguage(bool fuck) =>
      fuck ? choices.add(Choices.profanity) : choices.remove(Choices.profanity());

  /// used when fancy terminal stats are displayed.
  static int get numProcesses => activeProcesses;

  /// used when fancy terminal stats are displayed.
  static int get activeProcesses => (_settings[Settings.upgradesOwned] as Set<String>).length + 1;

  /// player's position in dialogue.
  static int line = -1;

  /// increments [line].
  ///
  /// Returns `true` if dialogue is done.
  static bool advance() => ++line >= dialogueToday.length;

  /// the [Event] to execute based on the current situation.
  ///
  /// Currently only used in the [Dialogue] class.
  static Event? event;

  // todo: use shared_preferences to save & load
  // void save() {}
  // void load() {}

  /// a [List] containing today's dialogue.
  static Convo dialogueToday = [];

  /// updates [dialogueToday] based on various stuff (most notably [day]).
  ///
  /// [dialogueToday] is returned by this function as well.
  static Convo getDialogueToday() => dialogueToday = Content.popConvo();

  /// a [List] containing today's posts.
  static List<PostPreview> postsToday = [];
  static List<PostPreview> top4 = [];

  static void collapseAllPosts(Function setState) {
    for (int i = 0; i < postsToday.length; i++) {
      if (postsToday[i].expanded) {
        setState(() => postsToday[i].expanded = false);
      }
    }
  }

  /// updates [postsToday] based on [hopefully lots of stuff the player did].
  ///
  /// [postsToday] is returned by this function as well.
  static List<PostPreview> getPostsToday() {
    postsToday = [for (final Post post in Content.popPosts()) PostPreview(post)];
    return postsToday;
  }

  static Upgrades upgrades = Upgrades();

  static Upgrades getUpgrades() {
    for (final category in UpgradeCategory.values) {
      for (final String upgradeName in _settings[category.setting]) {
        if (!upgrades.alreadyHave(upgradeName)) {
          upgrades.addUpgrade(upgradeName, category);
        }
      }
    }

    for (final upgrade in Upgrades.all.values) {
      if (!upgrades.alreadyHave(upgrade.name)) {
        if (true) {
          // use prereqs to determine if upgrade should be listed
          upgrades.displayed[UpgradeCategory.available]!.add(upgrade);
        }
      }
    }
    return upgrades;
  }
}
