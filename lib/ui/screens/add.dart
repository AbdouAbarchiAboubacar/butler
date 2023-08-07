import 'dart:io';

import 'package:butler/models/news_model.dart';
import 'package:butler/providers/auth_provider.dart';
import 'package:butler/services/connexion.dart/connectivity_status.dart';
import 'package:butler/services/firebase/firebase_storage.dart';
import 'package:butler/services/firebase/firestore_database.dart';
import 'package:butler/services/firebase/realtime_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Add extends StatefulWidget {
  final void Function() onNewsUploaded;
  const Add({super.key, required this.onNewsUploaded});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  File? _selectedCoverImageFile;
  String? _title, _content;

  @override
  void initState() {
    super.initState();
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> validateAndSubmit(
      AuthProvider authProvider,
      FirestoreDatabase firestoreDatabase,
      BuildContext context,
      ConnectivityStatus connectivity) async {
    FocusScope.of(context).unfocus();
    if (validateAndSave()) {
      if (connectivity == ConnectivityStatus.offline) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.yellow[700],
          duration: const Duration(seconds: 5),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Oops! It looks like you're offline.🌐📶",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: Colors.black)),
                  ],
                ),
              )
            ],
          ),
        ));
      } else {
        if (_selectedCoverImageFile == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.yellow[700],
            duration: const Duration(seconds: 5),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("cover image can't be empty",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(color: Colors.black)),
                    ],
                  ),
                )
              ],
            ),
          ));
          return;
        }
        String? uploadedCoverImageUrl = await upload(
            _selectedCoverImageFile!.path.split('/').last,
            _selectedCoverImageFile!.path,
            authProvider.uid);
        NewsModel newsModel = NewsModel(
            authorUid: authProvider.uid,
            title: _title,
            content: _content,
            coverImage: uploadedCoverImageUrl);
        await firestoreDatabase.uploadNews(newsModel);
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
                    Text("News Uploaded",
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
          _title = null;
          _content = null;
          _selectedCoverImageFile = null;
          formKey.currentState!.reset();
        });
        widget.onNewsUploaded();
      }
    }
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

  Future<String?> upload(fileName, filePath, authUid) async {
    String extension = fileName.toString().split(".").last;
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("news")
        .child(authUid)
        .child(fileName);
    final UploadTask uploadTask = storageReference.putFile(
        File(filePath), SettableMetadata(contentType: 'image/$extension'));
    var fileUrl = await (await uploadTask).ref.getDownloadURL();
    String url = fileUrl.toString();
    return url;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    //
    final firestoreDatabase = Provider.of<FirestoreDatabase>(context);
    //
    final realtimeDatabase = Provider.of<RealTimeDatabase>(context);
    //
    final firebaseFileStorage = Provider.of<FirebaseFileStorage>(context);
    //
    final connectivity = Provider.of<ConnectivityStatus>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add news"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                validateAndSubmit(
                    authProvider, firestoreDatabase, context, connectivity);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text(
                "upload",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  height: kToolbarHeight * 2,
                  color: Colors.grey,
                  child: coverImageWidget(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(0.0),
                              counterText: "",
                              filled: false,
                              errorStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Colors.red),
                              labelText: "Title",
                              labelStyle:
                                  Theme.of(context).textTheme.headlineSmall),
                          validator: (value) =>
                              value!.isEmpty ? "Title can't be empty" : null,
                          onSaved: (value) => _title = value,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.mic,
                          color: Colors.blue,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          maxLines: 10,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(0.0),
                              counterText: "",
                              filled: true,
                              errorStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Colors.red),
                              labelText: "Content",
                              labelStyle:
                                  Theme.of(context).textTheme.headlineSmall),
                          validator: (value) =>
                              value!.isEmpty ? "Content can't be empty" : null,
                          onSaved: (value) => _content = value,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.mic,
                          color: Colors.blue,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget coverImageWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        _selectedCoverImageFile != null
            ? Expanded(
                child: Image.file(
                  _selectedCoverImageFile!,
                  fit: BoxFit.cover,
                ),
              )
            : Center(
                child: IconButton(
                  onPressed: () {
                    getCoverImage(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.image, size: 30, color: Colors.white),
                ),
              ),
      ],
    );
  }
}
