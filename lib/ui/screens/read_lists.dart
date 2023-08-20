import 'package:butler/models/news_model.dart';
import 'package:butler/providers/auth_provider.dart';
import 'package:butler/services/firebase/firebase_storage.dart';
import 'package:butler/services/firebase/firestore_database.dart';
import 'package:butler/services/firebase/realtime_database.dart';
import 'package:butler/ui/screens/expanded_news.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReadLists extends StatefulWidget {
  const ReadLists({super.key});

  @override
  State<ReadLists> createState() => _ReadListsState();
}

class _ReadListsState extends State<ReadLists>
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
          title: const Text("Read lists"),
        ),
        body: FutureBuilder<List<NewsModel>?>(
            future: realtimeDatabase.getReadListNews(authProvider.uid),
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
