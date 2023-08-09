import 'package:butler/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:clipboard/clipboard.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text("Account"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50,
          ),
          authProvider.user != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                          height: 150,
                          width: 150,
                          child: CachedNetworkImage(
                            imageUrl: authProvider.user!.photoURL!,
                            fit: BoxFit.cover,
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
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        authProvider.user!.displayName ?? "",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        authProvider.user!.phoneNumber ?? "",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        FlutterClipboard.copy(
                            'https://firebasestorage.googleapis.com/v0/b/butler-2bcea.appspot.com/o/M08mh3hvSqTwQroE4CkVnB8A9E9M.pdf?alt=media&token=f1b4fafa-18bf-4692-8fe5-8f6222325f7f');
                        // String? dir = await requestDownloadFolderPathService();
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
                      child: Text(
                        "Export profile as PDF",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        authProvider.signOut();
                      },
                      child: Text(
                        "log out",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        authProvider.deleteUser();
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text(
                        "Delete account",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                )
              : const SizedBox()
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Future<String?> requestDownloadFolderPathService() async {
  var permissionStatus = await Permission.storage.status;
  return "/storage/emulated/0/download";
  String? dirPath;
  if (permissionStatus == PermissionStatus.granted) {
    if (Platform.isAndroid) {
      dirPath = "/sdcard/download/";
      return "/sdcard/download/";
    } else {
      return (await getApplicationDocumentsDirectory()).path;
    }
  } else if (permissionStatus == PermissionStatus.permanentlyDenied ||
      permissionStatus == PermissionStatus.denied) {
    // bool isOpened = await openAppSettings();
    dirPath = "/sdcard/emulated/0";

    // Handle the case when the user does not grant the permission even after opening the app settings.
    // You can show a message or take appropriate action based on the value of isOpened.
  } else {
    await Permission.storage.request();
    PermissionStatus manageStorageStatus =
        await Permission.manageExternalStorage.request();

    if (manageStorageStatus == PermissionStatus.granted) {
      if (Platform.isAndroid) {
        dirPath = "/sdcard/download/";
        return "/storage/emulated/0/download"; // "/sdcard/download/";
      } else {
        return (await getApplicationDocumentsDirectory()).path;
      }
    } else {
      // bool isOpened = await openAppSettings();
      dirPath = "/sdcard/emulated/0";

      // Handle the case when the user denies the permission request.
    }
  }

  return dirPath;
}
