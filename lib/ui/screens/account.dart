import 'dart:io';

import 'package:butler/providers/auth_provider.dart';
import 'package:butler/services/firebase/firebase_storage.dart';
import 'package:butler/services/firebase/firestore_database.dart';
import 'package:butler/ui/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> with AutomaticKeepAliveClientMixin {
  final picker = ImagePicker();
  File? _selectedCoverImageFile;
  String? updatedImage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> updateProfileImage(
      AuthProvider authProvider,
      FirestoreDatabase firestoreDatabase,
      BuildContext context,
      FirebaseFileStorage firebaseFileStorage) async {
    String? uploadedCoverImageUrl = await upload(
        _selectedCoverImageFile!.path.split('/').last,
        _selectedCoverImageFile!.path,
        authProvider.uid,
        firebaseFileStorage);
    // authProvider.user!.updatePhotoURL(uploadedCoverImageUrl);
    authProvider.updateProfileImage(uploadedCoverImageUrl!);

    FirebaseFirestore.instance
        .doc("users/${authProvider.uid}")
        .update({"photoURL": uploadedCoverImageUrl}).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 5),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Profile Image updated",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: Colors.white)),
                ],
              ),
            )
          ],
        ),
      ));
      setState(() {
        updatedImage = uploadedCoverImageUrl;
        _selectedCoverImageFile = null;
      });
    });
  }

  void getCoverImage(ImageSource source) async {
    FocusScope.of(context).unfocus();
    final image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedCoverImageFile = File(image.path);
      });
    }
  }

  Future<String?> upload(fileName, filePath, authUid,
      FirebaseFileStorage firebaseFileStorage) async {
    String extension = fileName.toString().split(".").last;
    String resizedFilename =
        "${fileName.toString().split(".")[0]}_200x200.$extension";

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("users")
        .child(authUid)
        .child(fileName);
    final UploadTask uploadTask = storageReference.putFile(
        File(filePath), SettableMetadata(contentType: 'image/$extension'));
    // var fileUrl = await (await uploadTask).ref.getDownloadURL();
    // String url = fileUrl.toString();
    // return url;
    print("//? resizedImage path ==> ${"/users/$authUid/$resizedFilename"} ");
    await Future.delayed(const Duration(seconds: 5));
    String? url = await firebaseFileStorage
        .getDownloadUrlAndFileName("/users/$authUid/$resizedFilename");
    return url;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final firestoreDatabase = Provider.of<FirestoreDatabase>(context);
    final firebaseFileStorage = Provider.of<FirebaseFileStorage>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Account"),
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
                          child: _selectedCoverImageFile == null
                              ? CachedNetworkImage(
                                  imageUrl: updatedImage ??
                                      authProvider.user!.photoURL!,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).dividerTheme.color,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(30.0)),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).dividerTheme.color,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(30.0)),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.account_circle,
                                          color: Colors.grey),
                                    ),
                                  ),
                                )
                              : Image.file(
                                  _selectedCoverImageFile!,
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        authProvider.user!.displayName ?? "",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            getCoverImage(ImageSource.gallery);
                          },
                          child: Text(
                            "Edit profile photo",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        _selectedCoverImageFile != null
                            ? ElevatedButton(
                                onPressed: () {
                                  updateProfileImage(
                                      authProvider,
                                      firestoreDatabase,
                                      context,
                                      firebaseFileStorage);
                                },
                                child: Text(
                                  "Save",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: Colors.white),
                                ),
                              )
                            : const SizedBox(),
                      ],
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
                        String? dir = await requestDownloadFolderPathService();
                        String? profilePDF =
                            await firebaseFileStorage.getDownloadUrlAndFileName(
                                authProvider.uid! + ".pdf");
                        print("//? save dir ===>  $dir");
                        // ==> "/storage/emulated/0/Download"

                        if (dir != null && profilePDF != null) {
                          await FlutterDownloader.enqueue(
                            url: profilePDF,
                            savedDir: dir,
                            fileName: authProvider.uid! + ".pdf",
                            showNotification: true,
                            openFileFromNotification: true,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.black,
                            duration: const Duration(seconds: 8),
                            content: Text(
                                "The download of the profile in pdf has started",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(color: Colors.white)),
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.black,
                            duration: const Duration(seconds: 8),
                            content: Text("something went wrong",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(color: Colors.white)),
                          ));
                        }
                      },
                      child: Text(
                        "Export profile as PDF",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        authProvider.signOut();
                      },
                      child: Text(
                        "log out",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.white),
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
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.white),
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
