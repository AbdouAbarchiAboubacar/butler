import 'package:butler/models/news_model.dart';
import 'package:butler/models/user_model.dart';
import 'package:butler/providers/auth_provider.dart';
import 'package:butler/services/firebase/firebase_storage.dart';
import 'package:butler/services/firebase/firestore_database.dart';
import 'package:butler/services/firebase/realtime_database.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExpandedNews extends StatefulWidget {
  final NewsModel news;
  const ExpandedNews({super.key, required this.news});

  @override
  State<ExpandedNews> createState() => _ExpandedNewsState();
}

class _ExpandedNewsState extends State<ExpandedNews> {
  final player = AudioPlayer();
  String? audioUrl;
  @override
  void initState() {
    super.initState();
  }

  void listenNews(FirebaseFileStorage firebaseFileStorage) async {
    if (audioUrl == null) {
      String? newsAudioUrl = await firebaseFileStorage
          .getDownloadUrlAndFileName("/news/${widget.news.id}.mp3");
      setState(() {
        audioUrl = newsAudioUrl;
      });
      if (newsAudioUrl != null) {
        await player.setUrl(newsAudioUrl);
        player.play();
      }
    } else {
      await player.setUrl(audioUrl!);
      player.play();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    //
    final firestoreDatabase = Provider.of<FirestoreDatabase>(context);
    //
    final realtimeDatabase = Provider.of<RealTimeDatabase>(context);
    //
    final firebaseFileStorage = Provider.of<FirebaseFileStorage>(context);
    //
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              height: 250,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: widget.news.coverImage!,
                      fit: BoxFit.fitWidth,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerTheme.color,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30.0)),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerTheme.color,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30.0)),
                        ),
                        child: const Center(
                          child: Icon(Icons.account_circle, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                        height: kToolbarHeight,
                        margin: const EdgeInsets.fromLTRB(15, 35, 0, 0),
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        child: IconButton(
                            onPressed: () {
                              player.pause();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back))),
                  )
                ],
              )),
          Container(
            height: 35,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: FutureBuilder<UserModel?>(
                future: firestoreDatabase.getUserData(widget.news.authorUid!),
                builder: (context, snapshot) {
                  UserModel? author = snapshot.data;

                  if (snapshot.connectionState == ConnectionState.done &&
                      author != null) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 30,
                          width: 30,
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            child: CachedNetworkImage(
                              imageUrl: author.photoURL!,
                              fit: BoxFit.fitWidth,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).dividerTheme.color,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0)),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).dividerTheme.color,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0)),
                                ),
                                child: const Center(
                                  child: Icon(Icons.account_circle,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(author.displayName ?? "")
                      ],
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    return const SizedBox();
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(widget.news.title ?? "",
                style: Theme.of(context).textTheme.titleLarge!),
          ),
          const Divider(),
          Expanded(
              child: Scrollbar(
            isAlwaysShown: true,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Content",
                            style: Theme.of(context).textTheme.labelLarge),
                        const Spacer(),
                        IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0)),
                                  ),
                                  isScrollControlled: false,
                                  context: context,
                                  builder: (context) {
                                    return Column(
                                      children: [
                                        Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text("Summarize",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child:
                                              Text(widget.news.summary ?? ""),
                                        )
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(
                              Icons.summarize_rounded,
                              color: Colors.blue,
                            )),
                        StreamBuilder<bool>(
                            stream: player.playingStream,
                            builder: (context, snapshot) {
                              return IconButton(
                                onPressed: () {
                                  if (snapshot.data == true) {
                                    player.pause();
                                  } else {
                                    listenNews(firebaseFileStorage);
                                  }
                                },
                                icon: Icon(
                                  snapshot.data == true
                                      ? Icons.pause
                                      : Icons.volume_up,
                                  color: Colors.blue,
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(widget.news.content ?? "",
                        style: Theme.of(context).textTheme.titleMedium!),
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}
