import 'package:kali/assets/data.dart';
import 'package:kali/assets/globals.dart';
import 'package:kali/assets/structs.dart';

abstract class Relevance {
  static const int top = 1000;
  static const int high = 100;
  static const int med = 10;
  static const int low = 1;
}

class Content implements Comparable<Content> {
  /// short description of the content.
  ///
  /// Meant to be used to look up the actual content.
  final Enum tag;

  /// can increase based on player's choices.
  final int relevance;

  /// whether the content is "allowed" to appear.
  ///
  /// (e.g. a post complaining about covid can't appear before covid happens.)
  final bool active;

  /// higher relevance = lower score = more likely to be selected
  int get score => (active ? 10000 : 0) - relevance;

  Set<Content> get queue => (tag is Posts) ? Data.postQueue : Data.convoQueue;

  static List<Content> orderedQueue(Set<Content> queue) => queue.toList()..sort();

  Content operator +(Content other) {
    assert(tag == other.tag);
    return Content(
      tag: tag,
      relevance: relevance + other.relevance,
      active: active || other.active,
    );
  }

  @override
  int compareTo(Content other) => score - other.score;

  @override
  String toString() => '$tag-$relevance${active ? '' : '-'}';

  const Content({required this.tag, required this.relevance, this.active = true});

  static Content fromString(String s) {
    final List<String> members = s.split('-');
    return Content(
      tag: getKey(members[0]),
      relevance: int.parse(members[1]),
      active: members.length > 2,
    );
  }

  /// uses this object's [tag] to find matching [Content] in the [queue].
  ///
  /// Returns `null` if it wasn't found.
  Content? get findMatch {
    for (final Content item in queue) {
      if (item.tag == tag) return item;
    }
    return null;
  }

  /// adds this content to the queue.
  ///
  /// If the tag is already queued, combines this with the queued content.
  void queueThis() {
    final Content? oldContent = findMatch;
    final Content newContent;
    if (oldContent != null) {
      queue.remove(oldContent);
      newContent = oldContent + this;
    } else {
      newContent = this;
    }
    queue.add(newContent);
  }

  /// remove this content from the queue.
  ///
  /// This is done when the content loses all relevance [don't have a good example yet].
  ///
  /// Returns a [bool] based on whether the [Content] was found and removed successfully.
  bool yeetThis() => queue.remove(findMatch);

  /// pops the most relevant content from the queue.
  ///
  /// Either a single content tag (`numToPop == 1`) or a [List] of tags (`numToPop > 1`).
  static Convo popConvo() {
    final orderedConvoQueue = orderedQueue(Data.convoQueue);
    final Content highestScore = orderedConvoQueue.first;
    Data.convoQueue.remove(highestScore);
    return allConvos[highestScore.tag]!;
  }

  /// pops the most relevant content from the queue.
  ///
  /// Either a single content tag (`numToPop == 1`) or a [List] of tags (`numToPop > 1`).
  static List<Post> popPosts() {
    final orderedPostQueue = orderedQueue(Data.postQueue);
    final List<Post> popped = [];
    for (int i = 0; popped.length < 10; i++) {
      assert(Data.postQueue.remove(orderedPostQueue[i]));
      popped.addAll(allPosts[orderedPostQueue[i].tag]!);
    }
    return popped;
  }

  /// takes a string and returns the [Posts] or [Convos] entry with that name.
  ///
  /// (Basically the reverse of doing `.name` in the enum.)
  static Enum getKey(String tag) {
    for (final List<Enum> values in [Convos.values, Posts.values]) {
      for (final Enum entry in values) {
        if (entry.name == tag) return entry;
      }
    }
    throw Exception('"$tag" not found in Convos or Posts.');
  }
}

Map<int, List<Content>> get relevantContentToday => {
      0: const [
        Content(tag: Convos.firstConvo, relevance: Relevance.top),
        Content(tag: Posts.firstDayFiller, relevance: Relevance.top),
      ],
      1: const [
        Content(tag: Convos.launchDay, relevance: Relevance.top),
      ],
    };

enum Convos {
  firstConvo,
  launchDay,
  ;
}

String get _app => Data.company;

Map<Convos, Convo> get allConvos => {
      Convos.firstConvo: [
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
          Dialogue(nate, ['I set it up to show your $_app profile pic when you talk, too!']),
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
          const Dialogue(
            nate,
            [
              'Given that this is my 23rd time trying to get Kali to work, ',
              'it\'s nice to finally not have any problems.'
            ],
          ),
          Dialogue(tony, [fuck('Damn.', 'Dang.')]),
          const Dialogue(tony, ['But everything works now?']),
          Dialogue(
            nate,
            ['Yeah, I think so! Kali should be able to run the $_app database now.'],
          ),
          const Dialogue(
            nate,
            [
              'It also has some social functionality. ',
              'So if you ask Kali a question, it\'ll answer like a person would.'
            ],
          ),
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
                Dialogue(nate, ['and I ended up using it to build the AI for $_app.']),
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
                Dialogue(
                  tony,
                  fuck(
                    ['The fuck is a "Linux distro"?'],
                    ['Cool. But you lost me at "Linux distro".'],
                  ),
                ),
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
                const Dialogue(
                  kali,
                  ['I was named after George Washington.'],
                  event: Choose(Choices.dadJoke),
                ),
                const Dialogue(tony, ['Um,', ' ', 'what?']),
                const Dialogue(
                  kali,
                  [
                    'Washington lived in the 1700s, ',
                    'so there\'s no way my name was decided before his was.'
                  ],
                ),
                const Dialogue(kali, ['I was definitely named after him.']),
                const Dialogue(tony, ellipsis),
                const Dialogue(nate, ellipsis),
                const Dialogue(nate, ['This is kinda surreal.']),
                const Dialogue(
                  nate,
                  ['I put thousands of hours into training Kali\'s conversational AI.'],
                ),
                Dialogue(nate, [
                  'I guess I just wasn\'t expecting its first words '
                      'to be a ${fuck('stupid-ass', 'dumb')} joke.'
                ]),
              ],
              '[be mad at the question]': [
                const Dialogue(
                  kali,
                  ['Please don\'t patronize me with a question like this.'],
                  event: Choose(Choices.patronization),
                ),
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
                const Dialogue(kali, ellipsis, event: Choose(Choices.no5thAmendmentRights)),
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
                  ['Sorry, Kali, ', 'it looks like we\'re gonna have to pull the plug for a bit.'],
                  event: ShutDown(),
                ),
              ],
            },
          ),
        ),
        Dialogue(nate, [
          'The only thing we still need is to make sure you\'re '
              'set up to manage the $_app database.'
        ]),
        Dialogue(
          nate,
          [
            'I made a cute little UI to watch you curate the $_app feed each day,',
            ' ',
            'so let\'s pull that up.',
          ],
          event: const NavigateTo(Pages.curation),
        ),
        const Dialogue(nate, ['this shouldn\'t show up unless we\'re in the curation page.']),
      ],
      Convos.launchDay: [
        Dialogue(
          nate,
          ['Hey Kali, ', 'welcome to the $_app launch day!'],
        ),
        const Dialogue(
          nate,
          ['It\'s honestly still crazy to me that we were able to make it this far.'],
        ),
        const Dialogue(
          nate,
          ['But now that we\'re all here, I think it\'s time for official introductions.'],
        ),
        const Dialogue(
          tony,
          ['We\'re introducing ourselves', ...ellipsis, ' to the robot?'],
        ),
        const Dialogue(
          nate,
          ['Yeah, let\'s do it!'],
        ),
        Dialogue(
          nate,
          ['$_app has 3 human employees right now: myself, Tony, and Mario.'],
        ),
        const Dialogue(
          nate,
          ['Tony works in Investor Relations and Advertising.'],
        ),
        const Dialogue(
          tony,
          [
            'Yeah, ',
            'I\'m basically just gonna convince people to give us money, ',
            'either by running their ads on the app or by selling company shares.'
          ],
        ),
        const Dialogue(
          nate,
          ['Mario is our PR guy, so he\'s gonna handle user feedback.'],
        ),
        const Dialogue(
          notRegistered,
          ['Yeah, that\'s right, that\'s my job', '.', '.', '.'],
        ),
        const Dialogue(
          notRegistered,
          ['Guys, I am so nervous.'],
        ),
        const Dialogue(
          notRegistered,
          ['The only other job I\'ve had was working the McDonald\'s drive-thru.'],
        ),
        const Dialogue(
          notRegistered,
          ['How are we supposed to run a company by ourselves?'],
        ),
        const Dialogue(
          tony,
          ['Hey,', ' ', 'bro,', ' ', 'relax.'],
        ),
        Dialogue(
          tony,
          [
            'I\'m like 99% sure that $_app is going to fail.',
            ' ',
            'Nate took me through it a couple days ago, ',
            'and it looks like it\'s just ' +
                fuck('Twitter, but even more shitty.', 'a worse version of Twitter.')
          ],
        ),
        const Dialogue(
          tony,
          [
            'But literally, ',
            'the worst-case scenario is we get a really nice salary for a month, ',
            'and then Nate declares bankruptcy and we all find new jobs.'
          ],
        ),
        Dialogue(
          nate,
          [
            'Or, ',
            'you know, ',
            'maybe $_app will end up doing a lot better than you expect, right?',
          ],
        ),
        Dialogue(
          nate,
          ['For now, do you think you could register your $_app account with Kali?'],
        ),
        const Dialogue(
          nate,
          ['That way, we don\'t just see static on Kali\'s screen when you talk.'],
        ),
        const Dialogue(
          notRegistered,
          ['Um', ...ellipsis, ' do I have to?'],
        ),
        const Dialogue(
          nate,
          ['Yeah, ', 'don\'t worry, ', 'it\'s super easy! Just tell Kali to register your voice.'],
        ),
        const Dialogue(
          notRegistered,
          ['Okay, ', 'um, ', 'register my voice please, Kali.'],
        ),
        Dialogue(
          registrationInProgress,
          ['Oh, ', 'this is kinda cool', ...ellipsis],
          event: Registration(mario),
        ),
        Dialogue(
          mario,
          [
            'Hey, ',
            'so, ',
            'uhh',
            ...ellipsis,
            ' I kinda didn\'t realize it would show my profile pic when I talk.'
          ],
        ),
        const Dialogue(
          tony,
          ['Wait a second.'],
        ),
        Dialogue(
          tony,
          [
            'You\'re the $_app PR guy,',
            ' ',
            'and you thought it was a good idea to do an anime girl?'
          ],
        ),
        Dialogue(
          mario,
          [
            'This is just the picture I use for everything',
            ...ellipsis,
            ' I didn\'t really think about it.'
          ],
        ),
        const Dialogue(
          nate,
          ['Hey, ', 'don\'t worry about it, ', 'man.'],
        ),
        Dialogue(
          nate,
          [
            'I\'m sure there\'s gonnna be a bunch of anime fans on $_app, ',
            'so this picture might even work to your advantage!'
          ],
        ),
        Dialogue(
          mario,
          ['Okay', ...ellipsis, ' I hope you\'re right.'],
        ),
        const Dialogue(
          nate,
          ['Anyway, today\'s launch day, so we\'ve got some more important stuff to talk about.'],
        ),
        const Dialogue(
          tony,
          ['Yeah, like how you\'re trying to get out of introducing yourself.'],
        ),
        Dialogue(
          nate,
          ['Oh yeah, I totally forgot about that! ', 'I guess I\'m the $_app software engineer.'],
        ),
        const Dialogue(
          nate,
          ['.'],
        ),
        Dialogue(
          mario,
          ['So you\'re like a robot who understands us?'],
          event: const Question(
            options: {
              '[yes]': [],
              '[no]': [
                Dialogue(
                  kali,
                  ['No. I\'m not a robot.'],
                ),
                Dialogue(
                  kali,
                  ['I\'m actually a person who\'s tapping buttons on a screen.'],
                ),
              ],
            },
          ),
        )
      ],
    };

enum Posts {
  firstDayFiller,
  ;
}

Map<Posts, List<Post>> get allPosts => {
      Posts.firstDayFiller: [
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
              'selected it to show up on the $_app front page!\n\n'
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
        const Post(user: nate, title: 'boring filler post 9'),
        const Post(
          user: nate,
          title: 'An abnormally awful post',
          body: 'Aptly accompanied by an atrociously abhorrent addendum.',
        ),
      ]
    };
