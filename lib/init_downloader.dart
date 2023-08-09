import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: slash_for_doc_comments
/**
 * initialize flutter downloader on app launch
 * */

class FlutterDownloaderInitializer {
  final ReceivePort _receivePort = ReceivePort();
  static downloadingCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? sendPort =
        IsolateNameServer.lookupPortByName("downloading");
    sendPort!.send([id, status, progress]);
  }

  void initializeDownloader(BuildContext context) {
    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, "downloading");
    _receivePort.listen((dynamic data) {
      String? id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (status.toString() == "DownloadTaskStatus(3)" &&
          progress == 100 &&
          id != null) {
        Fluttertoast.showToast(
            msg: "download Completed",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Theme.of(context).buttonTheme.colorScheme!.primary,
            textColor: Theme.of(context).buttonTheme.colorScheme!.onPrimary,
            fontSize: 14.0);
      }
      if (status.toString() == "DownloadTaskStatus(4)") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.yellow[700],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8.0),
          content: Text("getting Error While Download File",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: Colors.black)),
          duration: const Duration(seconds: 10),
        ));
      }
    });
    FlutterDownloader.registerCallback(downloadingCallback);
  }

  void dispose() {
    IsolateNameServer.removePortNameMapping('downloading');
  }
}
