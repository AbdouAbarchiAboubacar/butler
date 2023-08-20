import 'package:butler/main.dart';
import 'package:butler/models/news_model.dart';
import 'package:butler/providers/auth_provider.dart';
import 'package:butler/services/firebase/firebase_storage.dart';
import 'package:butler/services/firebase/firestore_database.dart';
import 'package:butler/services/firebase/realtime_database.dart';
import 'package:butler/ui/screens/expanded_news.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin {
  final TextEditingController searchController = TextEditingController();
  Algolia algolia = AlgoliaClass.algolia;
  List<NewsModel> newsFounded = [];
  @override
  void initState() {
    super.initState();
  }

  Future<void> startSearch(FirestoreDatabase firestoreDatabase) async {
    AlgoliaQuery query =
        algolia.instance.index('articleSearch').query(searchController.text);
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
    if (snap.nbHits > 0) {
      List<String> newsFoundPaths = [];
      for (var element in snap.hits) {
        newsFoundPaths.add(element.data["path"]);
      }
      List<NewsModel>? foundedNews =
          await firestoreDatabase.getFoundedNewsBySearch(newsFoundPaths);
      setState(() {
        newsFounded = foundedNews ?? [];
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

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
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          onSubmitted: (String val) {
            startSearch(firestoreDatabase);
          },
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            suffixIcon: IconButton(
              onPressed: () {
                startSearch(firestoreDatabase);
              },
              icon: const Icon(
                Icons.search,
                color: Colors.blue,
              ),
            ),
            hintText: "Write search text here",
          ),
        ),
      ),
      body: ListView.builder(
          itemCount: newsFounded.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                firestoreDatabase.distributedCounter(
                    "news/${newsFounded[index].id}", "views");
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        ExpandedNews(news: newsFounded[index])));
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
                        child: newsFounded[index].coverImage != null
                            ? CachedNetworkImage(
                                imageUrl: newsFounded[index].coverImage!,
                                fit: BoxFit.fitWidth,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        Container(
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
                              )
                            : Container(
                                color: Colors.grey,
                              )),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        newsFounded[index].title ?? "",
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        newsFounded[index].content ?? "",
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
                          Text((newsFounded[index].views ?? 0).toString()),
                          const Spacer(),
                          StreamBuilder<bool?>(
                            stream: realtimeDatabase.isNewsInReadList(
                                authProvider.uid!, newsFounded[index].id!),
                            builder: (context, snapshot) {
                              bool isInList = snapshot.data ?? false;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      realtimeDatabase.addNewsToReadList(
                                          authProvider.uid!,
                                          newsFounded[index]);
                                    },
                                    icon: Icon(
                                      Icons.list_alt_rounded,
                                      color:
                                          isInList ? Colors.blue : Colors.grey,
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
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
