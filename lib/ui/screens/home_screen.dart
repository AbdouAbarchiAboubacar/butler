import 'dart:io';

import 'package:butler/main.dart';
import 'package:butler/models/news_model.dart';
import 'package:butler/models/user_model.dart';
import 'package:butler/providers/auth_provider.dart';
import 'package:butler/services/firebase/firebase_storage.dart';
import 'package:butler/services/firebase/firestore_database.dart';
import 'package:butler/services/firebase/realtime_database.dart';
import 'package:butler/ui/screens/expanded_news.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:algolia/algolia.dart';

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
          title: const Text("Bulter News"),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
            ),
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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Material(
                              elevation: 2,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                      height: 150,
                                      width: double.infinity,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20)),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  allNews[index].coverImage!,
                                              fit: BoxFit.fitWidth,
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .dividerTheme
                                                      .color,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              30.0)),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .dividerTheme
                                                      .color,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              30.0)),
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                      Icons.account_circle,
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                              height: 35,
                                              margin: const EdgeInsets.all(4),
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                              ),
                                              child: FutureBuilder<UserModel?>(
                                                  future: firestoreDatabase
                                                      .getUserData(
                                                          allNews[index]
                                                              .authorUid!),
                                                  builder: (context, snapshot) {
                                                    UserModel? author =
                                                        snapshot.data;

                                                    if (snapshot.connectionState ==
                                                            ConnectionState
                                                                .done &&
                                                        author != null) {
                                                      return Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            height: 30,
                                                            width: 30,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          20)),
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: author
                                                                    .photoURL!,
                                                                fit: BoxFit
                                                                    .fitWidth,
                                                                progressIndicatorBuilder:
                                                                    (context,
                                                                            url,
                                                                            downloadProgress) =>
                                                                        Container(
                                                                  height: 40,
                                                                  width: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .dividerTheme
                                                                        .color,
                                                                    borderRadius: const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            30.0)),
                                                                  ),
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Container(
                                                                  height: 40,
                                                                  width: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .dividerTheme
                                                                        .color,
                                                                    borderRadius: const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            30.0)),
                                                                  ),
                                                                  child:
                                                                      const Center(
                                                                    child: Icon(
                                                                        Icons
                                                                            .account_circle,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Text(author
                                                                  .displayName ??
                                                              "")
                                                        ],
                                                      );
                                                    } else if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const CircularProgressIndicator();
                                                    } else {
                                                      return const SizedBox();
                                                    }
                                                  }),
                                            ),
                                          )
                                        ],
                                      )),
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      allNews[index].title ?? "",
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
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
                                        const Spacer(),
                                        StreamBuilder<bool?>(
                                          stream:
                                              realtimeDatabase.isNewsInReadList(
                                                  authProvider.uid,
                                                  allNews[index].id!),
                                          builder: (context, snapshot) {
                                            bool isInList =
                                                snapshot.data ?? false;
                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
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
              return const Text("something went wrong");
            })));
  }

  @override
  bool get wantKeepAlive => true;
}

Future<String?> requestDownloadFolderPathService() async {
  var permissionStatus = await Permission.storage.status;
  if (permissionStatus == PermissionStatus.granted) {
    if (Platform.isAndroid) {
      return "/storage/emulated/0/download";
    } else {
      return (await getApplicationDocumentsDirectory()).path;
    }
  } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
    await openAppSettings();
    // Handle the case when the user does not grant the permission even after opening the app settings.
    // You can show a message or take appropriate action based on the value of isOpened.
  } else {
    await Permission.storage.request();
    PermissionStatus manageStorageStatus =
        await Permission.manageExternalStorage.request();

    if (manageStorageStatus == PermissionStatus.granted) {
      if (Platform.isAndroid) {
        return "/storage/emulated/0/download"; // "/sdcard/download/";
      } else {
        return (await getApplicationDocumentsDirectory()).path;
      }
    } else {
      await openAppSettings();
      // Handle the case when the user denies the permission request.
    }
  }
  return null;
}
