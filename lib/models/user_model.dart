class UserModel {
  final String? uid, displayName, phoneNumer;

  UserModel({required this.uid, this.displayName, this.phoneNumer});
  factory UserModel.fromMap(Map<String?, dynamic> data) {
    String? uid = data['uid'];
    String? displayName = data['displayName'];
    String? phoneNumer = data['phoneNumer'];

    return UserModel(
      uid: uid,
      displayName: displayName,
      phoneNumer: phoneNumer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'phoneNumer': phoneNumer,
    };
  }
}
