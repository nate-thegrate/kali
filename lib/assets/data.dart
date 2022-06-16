import 'package:flutter/material.dart';
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
  /// pronouns['key1']['key2']
  /// ```
  /// `key1`: player's preferred pronoun (he, she, they, it)<br>
  /// `key2`: conjugation (he, him, his, he's)
  static const Map<String, Map<String, String>> _pronouns = {
    'he': {
      'he': 'he',
      'him': 'him',
      'his': 'his',
      'he\'s': 'he\'s',
    },
    'she': {
      'he': 'she',
      'him': 'her',
      'his': 'her',
      'he\'s': 'she\'s',
    },
    'they': {
      'he': 'they',
      'him': 'they',
      'his': 'their',
      'he\'s': 'they\'re',
    },
    'it': {
      'he': 'it',
      'him': 'it',
      'his': 'its',
      'he\'s': 'it\'s',
    },
  };

  /// returns the player's preferred pronoun with the correct conjugation.
  /// ```dart
  /// pronoun = 'they';
  /// he('his') // returns 'their'
  /// ```
  static String he(String pronoun) {
    final String firstLetter = pronoun.substring(0, 1);
    String preferred = '';
    for (final pronoun in _pronouns.keys) {
      if (choices.contains(pronoun)) {
        preferred = pronoun;
        break;
      }
    }
    final String result = _pronouns[preferred]![pronoun.toLowerCase()]!;
    if (firstLetter == firstLetter.toUpperCase()) {
      return result[0].toUpperCase() + result.substring(1);
    }
    return result;
  }

  /// the page to load when the app launches.
  static String get page => _settings[Settings.page];

  /// an int representing the day of the year.
  ///
  /// The current plan is for [day] to be in the range `[0,366]`
  /// since the in-game year is 2020.
  static int get day => _settings[Settings.day];

  /// advances to the next in-game day.
  static void nextDay() => _settings[Settings.day]++;

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

  /// a list of all the major decisions the player has made.
  ///
  /// Exclusively contains the names of [Choices] elements.
  static List<String> get choices => _settings[Settings.choices];

  /// used during startup
  /// when the player decides whether to enable adult language.
  ///
  /// The [fuck] function is used everywhere else.
  static bool get adultLanguage => Choices.profanity.wasChosen;

  static set adultLanguage(bool fuck) {
    if (fuck) {
      if (!adultLanguage) choices.add(Choices.profanity());
    } else {
      if (adultLanguage) choices.remove(Choices.profanity());
    }
  }

  /// returns [dirty] or [clean] based on whether adult language is enabled.
  static dynamic fuck(dynamic dirty, dynamic clean) => adultLanguage ? dirty : clean;

  /// used when fancy terminal stats are displayed.
  static int get numProcesses => activeProcesses;

  /// used when fancy terminal stats are displayed.
  static int get activeProcesses => (_settings[Settings.upgradesOwned] as List<String>).length + 1;

  /// player's position in dialogue.
  static int line = -1;

  /// increments [line]; returns `true` if dialogue is done.
  static bool advance() => ++line >= dialogueToday.length;

  /// the [Event] to execute based on the current situation.
  ///
  /// Currently only used in the [Dialogue] class.
  static Event? event;

  // todo: use shared_preferences to save & load
  // void save() {}
  // void load() {}

  /// a [List] containing today's dialogue.
  static List<Dialogue> dialogueToday = [];

  /// updates [dialogueToday] based on various stuff (most notably [day]).
  ///
  /// [dialogueToday] is returned by this function as well.
  static List<Dialogue> getDialogueToday() {
    switch (_settings[Settings.day]) {
      case 0:
        dialogueToday = [
          ...[
            const Dialogue(notRegistered, ['All right, it looks good so far', ...ellipsis]),
            const Dialogue(notRegistered, ['And you can understand my voice! ', 'Awesome!']),
            const Dialogue(notRegistered, ['Okay, Kali, it\'s time for you to register a user.']),
            Dialogue(
              registrationInProgress,
              fuck(
                ['', '', '', '', '', '', 'Please,', ' please just fucking work', ...ellipsis],
                ['', '', '', '', '', '', 'Okay, fingers crossed', ...ellipsis],
              ),
              event: const Registration(nate),
            ),
            const Dialogue(nate, ['']),
            const Dialogue(nate, ['Ho ho! Look at that!']),
            const Dialogue(nate, ['Get in here Tony, ', 'Kali\'s up and running!']),
            const Dialogue(notRegistered, ['Oh cool, let\'s see it.']),
            const Dialogue(notRegistered, ['Wow, does it put everything we say on that screen?']),
            const Dialogue(nate, ['Sure does.']),
            const Dialogue(nate, ['I thought it might be nice to show that it understands us.']),
            Dialogue(nate, ['I set it up to show your $company profile pic when you talk, too!']),
            const Dialogue(nate, ['You should be able to just tell Kali to register yourself.']),
            const Dialogue(notRegistered, ['Cool—hey uh, Kali, you should register me now.']),
            const Dialogue(
              registrationInProgress,
              ['', '', '', '', '', '', 'So I just type it in here?'],
              event: Registration(tony),
            ),
            const Dialogue(tony, ['']),
            const Dialogue(tony, ['Hey,', ' that\'s me!']),
            const Dialogue(nate, ['Sweet!']),
            const Dialogue(nate, [
              'Given that this is my 23rd time trying to get Kali to work, '
                  'it\'s nice to finally not have any problems.'
            ]),
            Dialogue(tony, [fuck('Damn.', 'Dang.')]),
            const Dialogue(tony, ['But everything works now?']),
            Dialogue(
              nate,
              ['Yeah, I think so! Kali should be able to run the $company database now.'],
            ),
            const Dialogue(nate, [
              'It also has some social functionality. '
                  'So if you ask Kali a question, it\'ll answer like a person would.'
            ]),
            Dialogue(tony, [fuck('Aw hell yeah!', 'Cool!'), ' Can we ask it something?']),
            const Dialogue(nate, ['Sure.']),
          ],
          Dialogue(
            tony,
            ['All right', ...ellipsis, '  Hey Kali, what are you named after?'],
            event: Question(
              options: {
                '[give the answer]': [
                  const Dialogue(
                    kali,
                    ['I was named after the operating system I\'m running on.'],
                  ),
                  const Dialogue(nate, ['Yeah that\'s right!']),
                  const Dialogue(
                    nate,
                    [
                      'I installed the Kali Linux distro on this machine '
                          'back when I was really into hacking,'
                    ],
                  ),
                  // todo: talk about how Kali is not a great choice for beginners
                  // https://www.kali.org/docs/introduction/should-i-use-kali-linux/
                  Dialogue(nate, ['and I ended up using it to build the AI for $company.']),
                  const Dialogue(
                    nate,
                    ['Apparently "Kali" is also the name of the Hindu doomsday goddess,'],
                  ),
                  const Dialogue(
                    nate,
                    [
                      'and since AI might destroy the world at some point '
                          'I thought it\'d be funny to use that name.'
                    ],
                  ),
                  Dialogue(tony, [
                    fuck(
                      'The fuck is a "Linux distro"?',
                      'Cool. But you lost me at "Linux distro".',
                    )
                  ]),
                  const Dialogue(
                    nate,
                    [
                      'Umm',
                      ...ellipsis,
                      ' it\'s kinda like Windows 11, but better,',
                      ' ',
                      'since you don\'t have to buy it from Microsoft.'
                    ],
                  ),
                  const Dialogue(nate, ['And also since Windows 11 sucks.']),
                  const Dialogue(nate, ['Anyway,', ' ', 'thanks for coming over, Tony.']),
                  const Dialogue(
                    nate,
                    ['We can give Kali official introductions when all 3 of us are here.'],
                  ),
                  const Dialogue(tony, ['Sounds good.', ' ', 'See ya.']),
                  const Dialogue(nate, [
                    'So,',
                    ' ',
                    'Kali',
                    ...ellipsis,
                    ' not to repeat myself, but it\'s sooo nice to have you actually working.'
                  ]),
                  const Dialogue(nate, ['I think we\'re pretty much ready for launch now!']),
                ]
              },
              additional: {
                '[make a dad joke]': [
                  const Dialogue(kali, ['I was named after George Washington.']),
                  const Dialogue(tony, ['Um,', ' ', 'what?']),
                  const Dialogue(kali, [
                    'Washington lived in the 1700s, so there\'s no way my name was decided before his was.'
                  ]),
                  const Dialogue(kali, ['I was definitely named after him.']),
                  const Dialogue(tony, ellipsis),
                  const Dialogue(nate, ellipsis),
                  const Dialogue(nate, ['This is kinda surreal.']),
                  const Dialogue(
                      nate, ['I put thousands of hours into training Kali\'s conversational AI.']),
                  Dialogue(nate, [
                    'I guess I just wasn\'t expecting its first words to be a ${fuck('stupid-ass', 'dumb')} joke.'
                  ]),
                ],
                '[be mad at the question]': [
                  const Dialogue(kali, ['Please don\'t patronize me with a question like this.']),
                  const Dialogue(kali, [
                    'If you want to know why Nate picked the name "Kali" you should just ask him.'
                  ]),
                  Dialogue(tony, [
                    fuck('Well damn,', 'Wow,'),
                    ' ',
                    'Nate,',
                    ' ',
                    'you gave Kali some attitude!'
                  ]),
                  const Dialogue(nate, [
                    'Yeah,',
                    ' ',
                    'like Kali said, this is our first time having a conversation.',
                  ]),
                  const Dialogue(
                    nate,
                    ['I definitely wasn\'t expecting that to happen.'],
                  ),
                ],
                '[say nothing]': [
                  const Dialogue(kali, ellipsis),
                  const Dialogue(
                    nate,
                    ['Hey,', ' ', 'um,', ' ', 'Kali', ...ellipsis, ' can you understand us?'],
                  ),
                  const Dialogue(kali, ellipsis),
                  Dialogue(nate, [fuck('GOD DAMNIT.', 'Well shoot.')]),
                  Dialogue(nate, [
                    '${fuck('I gotta fucking', 'I\'m gonna have to')} go through '
                        'Kali\'s code again and figure out what\'s wrong this time.'
                  ]),
                  const Dialogue(tony, ['Cool, you do that. Hit me up when it\'s working.']),
                  const Dialogue(nate, ['Will do.']),
                  const Dialogue(
                    nate,
                    [
                      'Sorry, Kali, ',
                      'it looks like we\'re gonna have to pull the plug for a bit.'
                    ],
                    event: ShutDown(),
                  ),
                ],
              },
            ),
          ),
          Dialogue(nate, [
            'The only thing we still need is to make sure you\'re '
                'set up to manage the $company database.'
          ]),
          Dialogue(
            nate,
            [
              'I made a cute little UI to watch you curate the $company feed each day,',
              ' ',
              'so let\'s pull that up.',
            ],
            event: const NavigateTo(Pages.curation),
          ),
          const Dialogue(nate, ['this shouldn\'t show up unless we\'re in the curation page.']),
        ];
        break;
      case 1:
        dialogueToday = [
          const Dialogue(
            notRegistered,
            ['So you\'re like a robot who understands us?'],
            event: Question(
              options: {
                '[yes]': [],
                '[no]': [
                  Dialogue(kali, ['No. I\'m not a robot.']),
                  Dialogue(kali, [
                    'I\'m actually just a person who\'s tapping buttons on a screen.',
                  ]),
                ],
              },
            ),
          )
        ];
        break;
      default:
        dialogueToday = [const Dialogue.none()];
    }
    return dialogueToday;
  }

  /// a [List] containing today's posts.
  static List<PostPreview> postsToday = [];
  static List<PostPreview> top10 = [];

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
    final List<Post> posts;
    switch (_settings[Settings.day]) {
      case 0:
        posts = [
          const Post(
            user: nate,
            title: 'Expand me to read more!',
            body: 'Once each day, we\'re going to pull up this screen '
                'so we can see a summary of the posts you\'ve recommended '
                'to users throughout the day.\n\n'
                'The posts listed out on the left are what [your '
                'background process] has identified as having '
                'the potential for engagement. From there, '
                'it\'s up to you (the main process) '
                'to decide what all our daily users see.',
          ),
          Post(
            user: nate,
            title: 'This shows up on the left...',
            body: 'But if it\'s swiped right, that means you '
                'selected it to show up on the $company front page!\n\n'
                'The selected posts can be dragged around '
                'so the absolute best post is on top :)',
          ),
          const Post(user: nate, title: 'boring filler post'),
          const Post(user: nate, title: 'boring filler post 2'),
          const Post(user: nate, title: 'boring filler post 3'),
          const Post(user: nate, title: 'boring filler post 4'),
          const Post(user: nate, title: 'boring filler post 5'),
          const Post(user: nate, title: 'boring filler post 6'),
          const Post(user: nate, title: 'boring filler post 7'),
          const Post(user: nate, title: 'boring filler post 8'),
          const Post(
            user: nate,
            title: 'An abnormally awful post',
            body: 'Aptly accompanied by an atrociously abhorrent addendum.',
          ),
        ];
        break;
      default:
        posts = <Post>[];
        break;
    }
    postsToday = [for (final post in posts) PostPreview(post)];
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
