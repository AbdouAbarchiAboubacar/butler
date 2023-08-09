import 'package:butler/models/news_model.dart';
import 'package:butler/providers/auth_provider.dart';
import 'package:butler/services/firebase/firebase_storage.dart';
import 'package:butler/services/firebase/firestore_database.dart';
import 'package:butler/services/firebase/realtime_database.dart';
import 'package:butler/ui/screens/account.dart';
import 'package:butler/ui/screens/expanded_news.dart';
import 'package:clipboard/clipboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    //
    final firestoreDatabase = Provider.of<FirestoreDatabase>(context);
    //
    final realtimeDatabase = Provider.of<RealTimeDatabase>(context);
    //
    final firebaseFileStorage = Provider.of<FirebaseFileStorage>(context);
    //
    return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          actions: [
            IconButton(
                onPressed: () async {
                  FlutterClipboard.copy(
                      'https://firebasestorage.googleapis.com/v0/b/butler-2bcea.appspot.com/o/M08mh3hvSqTwQroE4CkVnB8A9E9M.pdf?alt=media&token=f1b4fafa-18bf-4692-8fe5-8f6222325f7f');
                  // realtimeDatabase.testLimitChildNode();
                  // String? dir = await requestDownloadFolderPathService();
                  // print("//? save dir ===>  $dir");
                  // if (dir != null) {
                  //   await FlutterDownloader.enqueue(
                  //     url:
                  //         "https://firebasestorage.googleapis.com/v0/b/butler-2bcea.appspot.com/o/M08mh3hvSqTwQroE4CkVnB8A9E9M.pdf?alt=media&token=f1b4fafa-18bf-4692-8fe5-8f6222325f7f",
                  //     savedDir: dir,
                  //     fileName: "",
                  //     showNotification: true,
                  //     openFileFromNotification: true,
                  //   );
                  // }
                },
                icon: Icon(Icons.add))
          ],
        ),
        body: FutureBuilder<List<NewsModel>?>(
            future: firestoreDatabase.getAllNews(),
            builder: ((context, snapshot) {
              List<NewsModel>? allNews = snapshot.data;
              if (snapshot.connectionState == ConnectionState.done &&
                  allNews != null) {
                if (allNews.isNotEmpty) {
                  return ListView.builder(
                      itemCount: allNews.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            firestoreDatabase.distributedCounter(
                                "news/${allNews[index].id}", "views");
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ExpandedNews(news: allNews[index])));
                          },
                          child: Card(
                            margin: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                    height: 150,
                                    width: double.infinity,
                                    child: CachedNetworkImage(
                                      imageUrl: allNews[index].coverImage!,
                                      fit: BoxFit.fitWidth,
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .dividerTheme
                                              .color,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(30.0)),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .dividerTheme
                                              .color,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(30.0)),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.account_circle,
                                              color: Colors.grey),
                                        ),
                                      ),
                                    )),
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    allNews[index].title ?? "",
                                    maxLines: 1,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    allNews[index].content ?? "",
                                    maxLines: 2,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(color: Colors.grey),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.remove_red_eye,
                                        size: 15,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text((allNews[index].views ?? 0)
                                          .toString()),
                                      Spacer(),
                                      StreamBuilder<bool?>(
                                        stream:
                                            realtimeDatabase.isNewsInReadList(
                                                authProvider.uid!,
                                                allNews[index].id!),
                                        builder: (context, snapshot) {
                                          bool isInList =
                                              snapshot.data ?? false;
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(isInList.toString()),
                                              IconButton(
                                                onPressed: () {
                                                  realtimeDatabase
                                                      .addNewsToReadList(
                                                          authProvider.uid!,
                                                          allNews[index]);
                                                },
                                                icon: Icon(
                                                  Icons.list_alt_rounded,
                                                  color: isInList
                                                      ? Colors.blue
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      });
                } else {
                  return const Center(
                    child: Text("empty"),
                  );
                }
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Text("something went wrong");
            })));
  }

  @override
  bool get wantKeepAlive => true;
}
