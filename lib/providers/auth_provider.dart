import 'package:butler/models/user_model.dart';
import 'package:butler/services/firebase/firestore_database.dart';
import 'package:butler/ui/authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum EnumAuthenticated { none, authenticated, notAuthenticated }

enum Status {
  uinitialized,
  authenticated,
  authenticating,
  authenticatingFinished,
  facebookAuthenticating,
  facebookAuthenticatingFinished,
  googleAuthenticating,
  googleAuthenticatingFinished,
  phoneAuthenticating,
  phoneAuthenticatingFinished,
  phoneVerifying,
  phoneVerifyingFinished,
  emailResetProcess,
  unauthenticated,
  registering,
  registeringFinished,
  passwordProviderIdReauthenticating,
  passwordProviderIdReauthenticatingFinished
}

class AuthProvider extends ChangeNotifier {
  //Firebase Auth object
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthCredential? _authCredential;
  // Google SignIn
  final GoogleSignIn googleSignIn = GoogleSignIn();
  // Initial values
  Status _status = Status.uinitialized;
  String? _uid;
  EnumAuthenticated _authenticationStatus = EnumAuthenticated.none;
  User? _user;
  // Get method
  Status get status => _status;
  Stream<String?>? get streamCurrentUserUid =>
      _auth.authStateChanges().map(_userUidFromFirebase);
  String? get uid => _uid;
  EnumAuthenticated get getAuthenticationStatus => _authenticationStatus;
  User? get user => _user;

  AuthProvider() {
    //* initialise
    _auth.authStateChanges().listen(onAuthStateChanged);
  }

  //* Create user object based on the given FirebaseUser
  String? _userUidFromFirebase(User? user) {
    if (user == null) {
      return null;
    }
    return user.uid;
  }

  //* Method to detect live auth changes such as user sign in and sign out
  Future<void> onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _uid = null;
      _authenticationStatus = EnumAuthenticated.notAuthenticated;
      _status = Status.unauthenticated;
      notifyListeners();
      return;
    } else {
      _uid = firebaseUser.uid;
      _authenticationStatus = EnumAuthenticated.authenticated;
      _user = firebaseUser;
      _status = Status.authenticated;
      notifyListeners();
    }
  }

  //* =======================>   SignIn With Google Methods   <====================================================================================

  //* Methode to handle signIn with google
  Future<dynamic> signInWithGoogle(
      {required BuildContext context,
      required FormType formType,
      required String? phoneNumer}) async {
    try {
      _status = Status.googleAuthenticating;
      _authCredential = null;
      notifyListeners();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _status = Status.unauthenticated;
        notifyListeners();
        return "";
      } else {
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        _authCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        //* notify google Authenticating Finished
        _status = Status.googleAuthenticatingFinished;
        notifyListeners();
        await Future.delayed(const Duration(seconds: 1));
        _status = Status.authenticating;
        notifyListeners();
        await _auth.signInWithCredential(_authCredential!);
        //* Save New User Data
        await registerNewUser(
            user: _auth.currentUser!,
            phoneNumer: phoneNumer,
            verifyIfUserExist: formType == FormType.signUp);
        notifyListeners();
        return;
      }
    } on FirebaseAuthException catch (e) {
      await googleSignIn.signOut();
      print("//? google sign in error ==> $e");
      _status = Status.unauthenticated;
      notifyListeners();
      return;
    }
  }

  //* =======================>   Others Methods <====================================================================================

  //* Method to save new user data
  Future<void> registerNewUser({
    required User user,
    required String? phoneNumer,
    required bool verifyIfUserExist,
  }) async {
    if (!verifyIfUserExist) {
      UserModel userModel = UserModel(uid: user.uid);
      await FirestoreDatabase().setNewUserData(userModel, userModel.uid!);
    } else {
      bool userExist = await FirestoreDatabase().ifUserExist(user.uid);
      if (!userExist) {
        UserModel userModel = UserModel(
          uid: user.uid,
          displayName: user.displayName,
          phoneNumer: phoneNumer,
        );
        await FirestoreDatabase().setNewUserData(userModel, user.uid);
      }
    }
  }

  FirebaseAuth? currentUserAuth() {
    return _auth;
  }

  /// Method to handle user signing out
  Future signOut() async {
    await _auth.signOut();
    await googleSignIn.signOut();
    _status = Status.uinitialized;
    notifyListeners();
  }

  /// Method to delete user
  Future<void> deleteUser() async {
    await _auth.currentUser!.delete().then((value) {
      _uid = null;
      _authenticationStatus = EnumAuthenticated.notAuthenticated;
      _status = Status.uinitialized;
      notifyListeners();
    });
  }
}
