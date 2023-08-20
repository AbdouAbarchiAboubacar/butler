class UserModel {
  final String? uid, displayName, phoneNumer, photoURL;

  UserModel(
      {required this.uid, this.displayName, this.photoURL, this.phoneNumer});
  factory UserModel.fromMap(Map<String?, dynamic> data) {
    String? uid = data['uid'];
    String? displayName = data['displayName'];
    String? phoneNumer = data['phoneNumer'];
    String? photoURL = data['photoURL'];

    return UserModel(
      uid: uid,
      displayName: displayName,
      phoneNumer: phoneNumer,
      photoURL: photoURL,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'phoneNumer': phoneNumer,
      'photoURL': photoURL
    };
  }
}
