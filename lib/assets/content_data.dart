import 'package:kali/assets/data.dart';

class Content implements Comparable<Content> {
  final String tag;
  final int priority, expiration;
  int get score => priority * 512 ~/ (expiration - Data.day + 1);

  const Content({required this.tag, required this.priority, required this.expiration});

  static Content fromString(String s) {
    final elements = s.split('-');
    return Content(
      tag: elements[0],
      priority: int.parse(elements[1]),
      expiration: int.parse(elements[2]),
    );
  }

  @override
  String toString() => '$tag-$priority-$expiration';

  @override
  int compareTo(Content other) => score - other.score;

  /// returns the tag of the highest priority item in the queue,
  /// or a [List] of tags if `numToPop > 1`.
  static dynamic pop(Set<String> queue, [int numToPop = 1]) {
    final List<Content> queueList = [];
    for (final item in queue) {
      queueList.add(Content.fromString(item));
    }
    queueList.sort();
    if (numToPop > 1) {
      final List<String> popped = [];
      for (int i = 0; i < numToPop; i++) {
        assert(queue.remove(queueList[i].toString()));
        popped.add(queueList[i].tag);
      }
    }
  }
}

// class PostQueue extends Content {
//   final Post post;

//   /// technically not a queue itself, but one of the items in the post queue.
//   const PostQueue({
//     required this.post,
//     required super.tag,
//     required super.priority,
//     required super.expiration,
//   });
// }

// class ConvoQueue extends Content {
//   final Convo convo;

//   /// technically not a queue itself, but one of the items in the convo queue.
//   const ConvoQueue({
//     required this.convo,
//     required super.tag,
//     required super.priority,
//     required super.expiration,
//   });
// }
