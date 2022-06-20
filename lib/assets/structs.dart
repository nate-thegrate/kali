import 'package:flutter/material.dart';
import 'package:kali/assets/content.dart';

import 'package:kali/assets/data.dart';
import 'package:kali/assets/globals.dart';

/// this lets the app work with the shared_preferences library.
typedef SaveData = Map<Settings, dynamic>;

/// contains a bunch of dummy save Data.
abstract class DataPreset {
  /// the data to be loaded if no save data is found (i.e. first boot)
  static final SaveData startup = {
    Settings.day: -1,
    Settings.karma: 0.0,
    Settings.page: Pages.startup,
    Settings.companyName: '',
    Settings.dialogueDelay: 20,
    Settings.colorH: 0.0,
    Settings.colorS: 0.0,
    Settings.colorL: 0.0,
    Settings.postQueue: <Content>{},
    Settings.convoQueue: <Content>{},
    Settings.upgradesOwned: <String>{},
    Settings.upgradesAvailable: <String>{},
    Settings.upgradesHidden: <String>{},
    Settings.choices: <Choices>{},
  };

  static final SaveData firstDialogue = {
    Settings.day: 0,
    Settings.karma: 0.0,
    Settings.page: Pages.convos,
    Settings.companyName: 'x' * 25,
    Settings.dialogueDelay: 15,
    Settings.colorH: rng.nextDouble() * 360,
    Settings.colorS: rng.nextDouble(),
    Settings.colorL: rng.nextDouble(),
    Settings.postQueue: <Content>{
      const Content(tag: Posts.firstDayFiller, relevance: Relevance.top),
    },
    Settings.convoQueue: <Content>{
      const Content(tag: Convos.firstConvo, relevance: Relevance.top),
    },
    Settings.upgradesOwned: <String>{},
    Settings.upgradesAvailable: <String>{},
    Settings.upgradesHidden: <String>{},
    Settings.choices: rng.nextBool() ? <Choices>{Choices.profanity} : <Choices>{},
  };

  static final SaveData firstCuration = {
    Settings.day: 0,
    Settings.karma: 0.0,
    Settings.page: Pages.curation,
    Settings.companyName: 'x' * 25,
    Settings.dialogueDelay: 15,
    Settings.colorH: rng.nextDouble() * 360,
    Settings.colorS: rng.nextDouble(),
    Settings.colorL: rng.nextDouble(),
    Settings.postQueue: <Content>{
      const Content(tag: Posts.firstDayFiller, relevance: Relevance.top),
    },
    Settings.convoQueue: <Content>{},
    Settings.upgradesOwned: <String>{},
    Settings.upgradesAvailable: <String>{},
    Settings.upgradesHidden: <String>{},
    Settings.choices: rng.nextBool() ? <Choices>{Choices.profanity} : <Choices>{},
  };

  static final SaveData firstUpgrade = {
    Settings.day: 0,
    Settings.karma: 0.0,
    Settings.page: Pages.upgrades,
    Settings.companyName: 'x' * 25,
    Settings.dialogueDelay: 15,
    Settings.colorH: rng.nextDouble() * 360,
    Settings.colorS: rng.nextDouble(),
    Settings.colorL: rng.nextDouble(),
    Settings.postQueue: <Content>{},
    Settings.convoQueue: <Content>{},
    Settings.upgradesOwned: <String>{},
    Settings.upgradesAvailable: <String>{},
    Settings.upgradesHidden: <String>{},
    Settings.choices: rng.nextBool() ? <Choices>{Choices.profanity} : <Choices>{},
  };
}

enum Settings {
  day,
  karma,
  page,
  companyName,
  dialogueDelay,
  colorH,
  colorS,
  colorL,
  postQueue,
  convoQueue,
  upgradesOwned,
  upgradesAvailable,
  upgradesHidden,
  choices,
}

enum Pages {
  convos,
  curation,
  startup,
  terminal,
  upgrades,
  ;

  String call() => name;
}

class MyColor {
  final double h, s, l;

  Color get rgb {
    final double chroma = (1 - (2 * l - 1).abs()) * s;
    final double secondary = chroma * (1 - (((h / 60) % 2) - 1).abs());
    final double match = l - chroma / 2;

    final double r;
    final double g;
    final double b;

    if (h < 60) {
      r = chroma;
      g = secondary;
      b = 0;
    } else if (h < 120) {
      r = secondary;
      g = chroma;
      b = 0;
    } else if (h < 180) {
      r = 0;
      g = chroma;
      b = secondary;
    } else if (h < 240) {
      r = 0;
      g = secondary;
      b = chroma;
    } else if (h < 300) {
      r = secondary;
      g = 0;
      b = chroma;
    } else {
      r = chroma;
      g = 0;
      b = secondary;
    }

    return Color.fromARGB(
      (0xFF),
      ((r + match) * 0xFF).round(),
      ((g + match) * 0xFF).round(),
      ((b + match) * 0xFF).round(),
    );
  }

  /// it's the [HSLColor] class, but more simple.
  const MyColor(this.h, this.s, this.l);

  @override
  bool operator ==(Object other) =>
      other is MyColor &&
      other.runtimeType == runtimeType &&
      (other.h == h || s == 0) &&
      other.s == s &&
      other.l == l;

  @override
  int get hashCode => s.hashCode ^ l.hashCode;
}

/// pretty much all the colors I use in the app.
abstract class MyColors {
  static const terminalText = MyColor(0, 0, .8);
  static const terminalBkgd = MyColor(0, 0, .1);
  static const gray = MyColor(0, 0, .5);
  static const kali = MyColor(240, 1, .75);

  // "favorite color" presets:
  static const _black = MyColor(0, 0, 0);
  static const _white = MyColor(0, 0, 1);
  static const _gray1 = MyColor(210, 1 / 6, 1 / 6);
  static const _gray2 = MyColor(210, 1 / 12, 1 / 3);
  static const _gray3 = MyColor(30, 1 / 12, 2 / 3);
  static const _gray4 = MyColor(15, 1 / 24, 5 / 6);
  static const _red = MyColor(0, 1, .5);
  static const _brown = MyColor(40, 2 / 9, 1 / 9);
  static const _cream = MyColor(40, 1 / 9, 8 / 9);
  static const _yellow = MyColor(60, 1, .5);
  static const _army = MyColor(90, .375, .5);
  static const _lime = MyColor(90, 1, 7 / 8);
  static const _green = MyColor(120, 1, .5);
  static const _turquoise = MyColor(160, 5 / 9, 6 / 9);
  static const _lightTurquoise = MyColor(160, 6 / 9, 8 / 9);
  static const _cyan = MyColor(180, 1, .5);
  static const _blue = MyColor(240, 1, 249 / 500);
  static const _kaliGray = MyColor(240, .5, 2 / 3);
  static const _kaliLight = MyColor(240, .5, .95);
  static const _purple = MyColor(270, 1, 1 / 3);
  static const _lightPurple = MyColor(270, 1, 3 / 4);
  static const _magenta = MyColor(300, 1, .5);
  static const _rose = MyColor(345, 23 / 24, 23 / 24);
  static const _maroon = MyColor(345, .75, .2);

  static const someOptions = <MyColor>[
    _black,
    _red,
    _green,
    _blue,
    _white,
    _cyan,
    _magenta,
    _yellow,
  ];
  static const moreOptions = <MyColor>[
    ...[_black, _gray3, _red, _yellow, _green, _cyan, _blue, _magenta],
    ...[_gray1, _gray4, _maroon, _brown, _army, _turquoise, _kaliGray, _purple],
    ...[_gray2, _white, _rose, _cream, _lime, _lightTurquoise, _kaliLight, _lightPurple],
  ];
}

enum Emote {
  laugh,
  contempt,
  nervous,
  cringe,
  jawDrop,
  ;

  String call() => '_' + name;
}

class Dialogue {
  final User user;
  final List<String> body;
  final Emote? emote;
  final Event? event;

  const Dialogue.none()
      : user = nate,
        body = const ['looks like a bug :('],
        emote = Emote.cringe,
        event = null;

  /// dialogue is created in `Data` and shown in `Conversations`.
  const Dialogue(this.user, this.body, {this.emote, this.event});
}

typedef Convo = List<Dialogue>;

/// now I don't have to write out this list every time.
///
/// Conveniently, you can insert this into a [List] using an ellipsis `...`.
const List<String> ellipsis = ['', '.', '.', '.'];

/// data for out-of-the-ordinary stuff that happens.
///
/// The event will be handled by whatever page it pops up in, based on the subclass.
abstract class Event {
  const Event();
}

class Choose extends Event {
  final Choices choice;
  final List<Content> relevantContent;
  const Choose(this.choice, {this.relevantContent = const []});
}

class NavigateTo extends Event {
  final Pages navigateTo;
  const NavigateTo(this.navigateTo);
}

class ShutDown extends Event {
  const ShutDown();
}

class Registration extends Event {
  final User user;
  const Registration(this.user);
}

/// the [String] goes in the button; the [List] is the conversation that happens when you tap it.
typedef Response = Map<String, Convo>;

class Question extends Event {
  final Response options;
  final Response additional;

  /// a type of [Event] where the player picks a response and triggers its respective dialogue.
  const Question({
    required this.options,
    this.additional = const {},
  });
}

class UpgradeCost {
  /// flavor text, e.g. "25 GB of RAM"
  final String desc;

  /// in US dollars, of course.
  final int price;

  const UpgradeCost({required this.desc, required this.price});
}

class Upgrade {
  final String name, desc;

  /// other upgrade(s) that this upgrade depends on.
  final List<Upgrade> prereqs;

  final UpgradeCost setup, upkeep;

  /// the in-game day this upgrade will be available.
  final int? day;

  /// the upgrade will be added as a feature to this background process.
  ///
  /// `null` if this upgrade is itself a background process.
  final Upgrade? process;

  /// `true` if this upgrade was requested by a user.
  /// `false` if this upgrade came from [nate] or [kali].
  final bool requested;

  const Upgrade({
    required this.name,
    required this.desc,
    required this.prereqs,
    required this.setup,
    required this.upkeep,
    this.day,
    this.process,
  }) : requested = false;

  const Upgrade.request({
    required this.name,
    required this.desc,
    required this.prereqs,
    required this.setup,
    required this.upkeep,
    this.day,
    this.process,
  }) : requested = true;
}

enum UpgradeCategory {
  owned(Settings.upgradesOwned),
  available(Settings.upgradesAvailable),
  hidden(Settings.upgradesHidden),
  ;

  final Settings setting;
  const UpgradeCategory(this.setting);
}

class Upgrades {
  Map<UpgradeCategory, List<Upgrade>> displayed = {};

  Upgrades() {
    for (final category in UpgradeCategory.values) {
      displayed[category] = [];
    }
  }

  List<Upgrade> get available => displayed[UpgradeCategory.available]!;
  List<Upgrade> get owned => displayed[UpgradeCategory.owned]!;
  List<Upgrade> get hidden => displayed[UpgradeCategory.hidden]!;

  void addUpgrade(String name, UpgradeCategory category) => displayed[category]!.add(all[name]!);

  bool alreadyHave(String name) {
    for (final list in displayed.values) {
      for (final upgrade in list) {
        if (upgrade.name == name) return true;
      }
    }
    return false;
  }

  // Processes
  static String get db => Data.company;
  static const String ai = 'Interpersonal AI';
  static const String quantum = 'Quantum Computing';

  // Features
  static const String bgMusic = 'Background Music';
  static const String emote = 'Expressive Dialogue';
  static const String tags = 'Post Tags';
  static const String profiling = 'User Profiling';
  static String get autoFeed => 'Fully Automated $db Feed';
  static const String dissident = 'Dissident Simulation';

  // Requests
  static const String filterReposts = 'Filter Reposts';
  static const String flagMisinformation = 'Flag Misinformation';
  static const String virus = 'Kido Antivirus';

  static Map<String, Upgrade> get all => {
        // Processes
        db: Upgrade(
          name: db,
          desc: 'desc',
          prereqs: [],
          setup: const UpgradeCost(desc: 'desc', price: 0),
          upkeep: const UpgradeCost(desc: 'desc', price: 0),
        ),
        ai: const Upgrade(
          name: ai,
          desc: 'desc',
          prereqs: [],
          setup: UpgradeCost(desc: 'desc', price: 0),
          upkeep: UpgradeCost(desc: 'desc', price: 0),
        ),
        quantum: const Upgrade(
          name: quantum,
          desc: 'desc',
          prereqs: [],
          setup: UpgradeCost(desc: 'desc', price: 0),
          upkeep: UpgradeCost(desc: 'desc', price: 0),
        ),

        // Features
        bgMusic: const Upgrade(
          name: bgMusic,
          desc: 'desc',
          prereqs: [],
          setup: UpgradeCost(desc: 'desc', price: 0),
          upkeep: UpgradeCost(desc: 'desc', price: 0),
        ),
        emote: const Upgrade(
          name: emote,
          desc: 'desc',
          prereqs: [],
          setup: UpgradeCost(desc: 'desc', price: 0),
          upkeep: UpgradeCost(desc: 'desc', price: 0),
        ),
        tags: const Upgrade(
          name: tags,
          desc: 'desc',
          prereqs: [],
          setup: UpgradeCost(desc: 'desc', price: 0),
          upkeep: UpgradeCost(desc: 'desc', price: 0),
        ),
        profiling: const Upgrade(
          name: profiling,
          desc: 'desc',
          prereqs: [],
          setup: UpgradeCost(desc: 'desc', price: 0),
          upkeep: UpgradeCost(desc: 'desc', price: 0),
        ),
        autoFeed: Upgrade(
          name: autoFeed,
          desc: 'desc',
          prereqs: [],
          setup: const UpgradeCost(desc: 'desc', price: 0),
          upkeep: const UpgradeCost(desc: 'desc', price: 0),
        ),
        dissident: const Upgrade(
          name: dissident,
          desc: 'desc',
          prereqs: [],
          setup: UpgradeCost(desc: 'desc', price: 0),
          upkeep: UpgradeCost(desc: 'desc', price: 0),
        ),

        // Requests
        filterReposts: const Upgrade(
          name: filterReposts,
          desc: 'desc',
          prereqs: [],
          setup: UpgradeCost(desc: 'desc', price: 0),
          upkeep: UpgradeCost(desc: 'desc', price: 0),
        ),
        flagMisinformation: const Upgrade(
          name: flagMisinformation,
          desc: 'desc',
          prereqs: [],
          setup: UpgradeCost(desc: 'desc', price: 0),
          upkeep: UpgradeCost(desc: 'desc', price: 0),
        ),
        virus: const Upgrade(
          name: virus,
          desc: 'Created by Melissa & other Kali enthusiasts',
          prereqs: [],
          setup: UpgradeCost(desc: 'desc', price: 0),
          upkeep: UpgradeCost(desc: 'desc', price: 0),
        ),
      };
}

/// determines the image file extension, as well as how it should be rendered.
enum ImageType {
  pixelArt,
  photo,
  drawing,
  ;

  String get fileExtension => (this == photo) ? '.jpg' : '.png';
  FilterQuality get filterQuality => (this == pixelArt) ? FilterQuality.none : FilterQuality.low;
}

class User {
  final String name;
  final String _username;
  String get username => _username.contains('[') ? _username : '@$_username';

  final bool mainCharacter;
  final ImageType imageType;

  String get _filepath => 'lib/assets/images/${mainCharacter ? 'main_characters' : 'npcs'}/';

  Widget profilePic([Emote? emote]) {
    final String mario;
    if (this is Mario) {
      mario = Mario.current;
    } else {
      mario = '';
    }
    return Image.asset(
      _filepath + name + mario /*+ (emote != null ? emote() : '')*/ + imageType.fileExtension,
      scale: .1, // make image large so size is constrained by parent
      filterQuality: imageType.filterQuality,
    );
  }

  /// every character in the game is represented by this class.
  ///
  /// Used for [Dialogue] and [Post]s.
  const User({
    required this.name,
    this.mainCharacter = false,
    required String username,
    required this.imageType,
  }) : _username = username;
}

/// shows a TV static animation.
const User notRegistered = User(
  name: '',
  username: '[not registered]',
  imageType: ImageType.pixelArt,
);

/// pulls up a terminal for registering a new user.
const User registrationInProgress = User(
  name: '',
  username: '[registration in progress]',
  imageType: ImageType.pixelArt,
);

/// the player :)
const User kali = User(
  name: 'Kali',
  mainCharacter: true,
  username: 'kali',
  imageType: ImageType.pixelArt,
);

/// canonically, this is just me, the game developer, role-playing as an npc.
const User nate = User(
  name: 'Nate',
  mainCharacter: true,
  username: 'nate-thegrate',
  imageType: ImageType.pixelArt,
);

/// * attractive
/// * douchey
/// * cynical
/// * lazy
const User tony = User(
  name: 'Tony',
  mainCharacter: true,
  username: 'madtony7',
  imageType: ImageType.photo,
);

/// * shy
/// * anxious
/// * overweight
/// * baby face
/// * really into music
User get mario => Mario();

class Mario extends User {
  static const String _anime = '_anime';
  static const String _supa = '_supa';
  static const String _drawing = '_drawing';
  static const String _pixelArt = '_pixelArt';

  static String get current {
    if (Data.day < 7) return _anime;
    if (Data.day == 7) return _supa;
    if (Data.day >= 200 && Choices.graphicDesigner.chosen) return _drawing;
    return _pixelArt;
  }

  static ImageType get _imageType {
    switch (current) {
      case _anime:
      case _drawing:
        return ImageType.drawing;
      case _supa:
      case _pixelArt:
        return ImageType.pixelArt;
    }
    throw Exception('unable to get Mario\'s imageType');
  }

  Mario()
      : super(
          name: 'Mario',
          mainCharacter: true,
          username: 'mario',
          imageType: _imageType,
        );
}

/// putting all the NPCs into this class so they don't clutter my typing suggestions.
abstract class NPCs {
  static const User trump = User(
    name: 'Donald Trump',
    username: 'realdonaldtrump',
    imageType: ImageType.photo,
  );
}

class Post {
  final User user;
  final String title, body;
  final List<Content> relevantContent;

  /// `true` if the body is empty. (yeah, no shit)
  bool get emptyBody => body.isEmpty;

  /// data for social media posts.
  const Post({
    required this.user,
    required this.title,
    this.body = '',
    this.relevantContent = const [],
  });
}

class PostPreview extends Post {
  /// whether the body of the post is visible
  bool expanded = false;

  /// [PostPreview] exists so we can have the [expanded] property outside of the [Post] class.
  ///
  /// This'll let us use that sexy `const` keyword.
  PostPreview(Post post) : super(user: post.user, title: post.title, body: post.body) {
    assert(title.length <= 28);
  }
}

const List<Post> influentialPosts = [
  Post(
    user: NPCs.trump,
    title: 'MAKE AMERICA GREAT AGAIN!',
  ),
  Post(
    user: notRegistered,
    title: 'Unemployment',
    body: 'Apparently there\'s a "corona virus" disease in China, '
        'and self-driving cars might be an actual thing soon.\n\n'
        'My dad\'s a UPS driver, '
        'so I\'m kinda freaking out about either of those things happening.',
  ),
  Post(
    user: notRegistered,
    title: 'I\'m single',
    body: 'Tinder is a hot pile of garbage with zero depth or accountability.\n'
        'I tried other apps too, but they\'re pretty much just as bad.\n\n'
        'There\'s no way I\'ll find my soul mate at a bar, '
        'and I definitely can\'t try dating someone from work.\n\n'
        'I would literally die before I just start hitting on people in public, '
        'which brings me to the current long-term relationship plan: '
        'being at peace with dying alone.',
  ),
  Post(
    user: notRegistered,
    title: 'normalize "radical"',
    body: 'You really don\'t have to go back too far to find a time '
        'when race and gender equality were "radical" ideas.\n\n'
        'The internet shouldn\'t be a place where we shut down '
        'anything that doesn\'t fit the mainstream: '
        'free speech isn\'t just a constitutional right, '
        'it\'s necessary for society to function.',
  ),
];

enum Karma { low, neutral, high }

enum Choices {
  // misc
  profanity,
  spicyName,
  graphicDesigner,

  // first dialogue question
  dadJoke,
  patronization,
  no5thAmendmentRights,

  // pronouns
  he,
  she,
  they,
  it,

  // influential post
  trump,
  jobs,
  tinder,
  freeSpeech,
  ;

  String call() => name;
  void choose() => Data.choices.add(this);
  bool get chosen => Data.choices.contains(this);
}

class Decisions {
  final Karma? karma;
  final Choices? influentialChoice;

  const Decisions({this.karma, this.influentialChoice});
}

Map<Decisions, List<Post>> get postIdeas => {
      const Decisions(
        karma: Karma.low,
        influentialChoice: Choices.freeSpeech,
      ): [
        Post(
          user: notRegistered,
          title: 'a "free speech" forum',
          body: 'Going on ${Data.company} is like watching a debate, '
              'except the side you don\'t like is on mute. '
              'You only ever hear them when they say something dumb.',
        )
      ],
      const Decisions(
        influentialChoice: Choices.freeSpeech,
      ): const [
        Post(
          user: notRegistered,
          title: 'Decriminalize Drugs',
          body: 'Even banning the "bad" addictive drugs doesn\'t make any sense. '
              'If you have an addiction to gambling, binge eating, or porn, you can go get help—'
              'we wouldn\'t throw you in jail for it.',
        ),
        Post(
          user: notRegistered,
          title: 'Think different.',
          body: 'Y\'all. Steve Jobs said that doing LSD '
              'was one of the most profound experiences in his life. '
              'We have Apple as a literal proof of concept, '
              'yet for some reason it\'s still illegal.',
        ),
        Post(
          user: notRegistered,
          title: 'I found the Steve Jobs quote',
          body: '"Taking LSD was a profound experience, '
              'one of the most important things in my life.\n\n'
              'LSD shows you that there\'s another side to the coin, '
              'and you can\'t remember it when it wears off, but you know it.\n'
              'It reinforced my sense of what was important—'
              'creating great things instead of making money, '
              'putting things back into the stream of history '
              'and of human consciousness as much as I could."',
        ),
      ],
    };
