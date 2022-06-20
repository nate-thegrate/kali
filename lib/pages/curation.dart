import 'package:flutter/material.dart';
import 'package:kali/assets/content.dart';

import 'package:kali/assets/data.dart';
import 'package:kali/assets/globals.dart';
import 'package:kali/assets/structs.dart';
import 'package:kali/assets/widgets.dart';

class DisplayPost extends StatelessWidget {
  final PostPreview post;
  final bool inTop4;
  final void Function()? onRemove;

  const DisplayPost(this.post, {super.key})
      : onRemove = null,
        inTop4 = false;

  const DisplayPost.top4(this.post, {required this.onRemove, super.key}) : inTop4 = true;

  @override
  Widget build(BuildContext context) {
    final double buffer = context.buffer;
    final double postHeight = buffer * 3.34;
    return Stack(
      children: [
        LightBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                width: double.infinity,
                duration: animationDuration,
                curve: animationCurve,
                margin: EdgeInsets.only(left: buffer * (post.expanded ? 5 : 3.2)),
                child: KaliText(
                  post.title,
                  alignLeft: true,
                  bold: true,
                ),
              ),
              AnimatedContainer(
                margin: EdgeInsets.only(
                  left: buffer * (post.expanded ? 5 : 3),
                  top: post.expanded ? buffer / 3 : 0,
                ),
                duration: animationDuration,
                curve: animationCurve,
                child: AnimatedSize(
                  duration: animationDuration,
                  curve: animationCurve,
                  alignment: Alignment.topLeft,
                  child: post.expanded
                      ? Opacity(
                          opacity: 1 / 3,
                          child: KaliText(
                            post.user.username,
                            bold: true,
                            scale: .8,
                          ),
                        )
                      : empty,
                ),
              ),
              AnimatedSize(
                duration: animationDuration,
                curve: animationCurve,
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (post.expanded)
                      post.body.isEmpty
                          ? const Buffer(.3)
                          : Padding(
                              padding: EdgeInsets.only(top: buffer * 2.25),
                              child: KaliText(
                                post.body,
                                alignLeft: true,
                              ),
                            ),
                    if (inTop4) const Buffer(2.25)
                  ],
                ),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: animationDuration,
          curve: animationCurve,
          width: post.expanded ? buffer * 5 : postHeight,
          child: AnimatedContainer(
            duration: animationDuration,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 1),
              ],
              borderRadius: post.expanded
                  ? BorderRadius.only(
                      topLeft: Radius.circular(buffer),
                      bottomLeft:
                          post.body.isEmpty && !inTop4 ? Radius.circular(buffer) : Radius.zero,
                    )
                  : BorderRadius.all(Radius.circular(buffer)),
            ),
            clipBehavior: Clip.antiAlias,
            child: post.user.profilePic(),
          ),
        ),
        Positioned.fill(
          child: post.body.isEmpty || post.expanded
              ? empty
              : Container(
                  margin: EdgeInsets.only(right: buffer * .8),
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: buffer * 1.5,
                  ),
                ),
        ),
        AnimatedContainer(
          duration: animationDuration,
          curve: animationCurve,
          margin: EdgeInsets.only(top: post.expanded ? buffer * 5 : postHeight),
          color: Colors.black.withAlpha(
            inTop4 || post.expanded && post.body.isNotEmpty ? 255 : 0,
          ),
          width: buffer * 28,
          height: 0.5,
        ),
        if (inTop4)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.red.withAlpha(32)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(buffer),
                        bottomRight: Radius.circular(buffer),
                      ),
                    ),
                  ),
                ),
                onPressed: onRemove,
                child: SizedBox(
                  height: buffer * 2.25,
                  child: Opacity(
                    opacity: 2 / 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close,
                          color: Colors.red,
                          size: buffer * 1.5,
                        ),
                        SizedBox(width: buffer / 2),
                        const KaliText('remove from selected posts', scale: .8),
                        SizedBox(width: buffer * 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class Top4 extends StatelessWidget {
  final Post? post;

  const Top4({this.post, super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
          right: context.buffer / 2,
          bottom: context.buffer / 2,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Data.backgroundColor,
            border: Border.all(
              color: Data.boxColor,
              width: post == null ? 1 : 0,
            ),
            boxShadow: shadow(context, scale: .2),
          ),
          clipBehavior: Clip.antiAlias,
          child: post?.user.profilePic() ??
              SizedBox(
                width: context.buffer * 4 - 5,
                height: context.buffer * 4 - 5,
              ),
        ),
      );
}

class Curation extends StatefulWidget {
  const Curation({super.key});

  @override
  State<Curation> createState() => _CurationState();
}

class _CurationState extends State<Curation> {
  final List<Post> dummy = Data.getPostsToday();

  void reorder(oldIndex, newIndex) {
    if (newIndex > oldIndex) newIndex--;
    setState(() => Data.top4.insert(newIndex, Data.top4.removeAt(oldIndex)));
  }

  @override
  Widget build(BuildContext context) {
    final double buffer = context.buffer;
    Widget allPosts = Expanded(
      child: Column(
        children: [
          Expanded(
            child: BetterScroll(
              child: Column(
                children: [
                  for (final PostPreview post in Data.postsToday)
                    GestureDetector(
                      onTap: () {
                        Data.collapseAllPosts(setState);
                        setState(() => post.expanded = true);
                      },
                      child: Dismissible(
                        direction: DismissDirection.startToEnd,
                        key: Key(post.title),
                        confirmDismiss: (direction) async => Data.top4.length < 4,
                        onDismissed: (direction) {
                          Data.postsToday.removeWhere((element) => element == post);
                          setState(() => Data.top4.add(post));
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            buffer * .8,
                            buffer / 2,
                            buffer,
                            buffer / 2,
                          ),
                          child: DisplayPost(post),
                        ),
                      ),
                    ),
                  const Buffer(),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: animationDuration,
            curve: animationCurve,
            child: Data.top4.length == 4
                ? Padding(
                    padding: EdgeInsets.only(bottom: buffer * 2),
                    child: ColorButton(
                      'Finished',
                      onPressed: () {
                        // todo: activate/boost relevant content
                        for (final Post post in Data.top4) {
                          for (final Content content in post.relevantContent) {
                            content.queueThis();
                          }
                        }
                        context.goto(Pages.upgrades);
                      },
                    ),
                  )
                : empty,
          ),
        ],
      ),
    );
    Widget selectedPosts = SizedBox(
      width: buffer * 4.3,
      child: Column(
        children: [
          filler,
          ReorderableList(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final PostPreview post = Data.top4[index];
              return ReorderableDragStartListener(
                key: ValueKey(post.title),
                // maybe switch this widget to delayed listener
                index: index,
                child: GestureDetector(
                    onTap: () {
                      post.expanded = true;
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Center(
                              child: DisplayPost.top4(
                            post,
                            onRemove: () {
                              Navigator.pop(context);
                              post.expanded = false;
                              setState(() {
                                Data.top4.remove(post);
                                Data.postsToday.insert(0, post);
                              });
                            },
                          ));
                        },
                      );
                    },
                    child: Top4(post: post)),
              );
            },
            itemCount: Data.top4.length,
            onReorder: reorder,
          ),
          for (int i = 0; i < 4 - Data.top4.length; i++) const Top4(),
          filler,
        ],
      ),
    );

    return ScreenDetector(
      backgroundColor: Data.backgroundColor,
      onTap: () => Data.collapseAllPosts(setState),
      body: Row(
        children: [
          allPosts,
          selectedPosts,
        ],
      ),
    );
  }
}
