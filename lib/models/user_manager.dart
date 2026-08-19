import 'package:bemestarcem/helpers/firebase_errors.dart';
import 'package:bemestarcem/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserManager extends ChangeNotifier {
  UserManager() {
    _loadCurrentUser();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? user;

  bool _loading = false;
  bool get loading => _loading;

  bool get isLoggedIn => user != null;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> signIn({
    required AppUser user,
    required Function onFail,
    required Function onSuccess,
  }) async {
    loading = true;
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: user.email!, password: user.password!);
      await _loadCurrentUser(firebaseUser: credential.user);
      onSuccess();
    } on FirebaseAuthException catch (e) {
      onFail(getErrorString(e.code));
    }
    loading = false;
  }

  Future<void> signUp({
    required AppUser user,
    required Function onFail,
    required Function onSuccess,
  }) async {
    loading = true;
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
              email: user.email!, password: user.password!);
      user.id = credential.user!.uid;
      this.user = user;
      await user.saveData();
      onSuccess();
    } on FirebaseAuthException catch (e) {
      onFail(getErrorString(e.code));
    }
    loading = false;
  }

  Future<void> resetPassword({
    required String email,
    required Function onFail,
    required Function onSuccess,
  }) async {
    loading = true;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      onSuccess();
    } on FirebaseAuthException catch (e) {
      onFail(getErrorString(e.code));
    }
    loading = false;
  }

  void signOut() {
    _auth.signOut();
    user = null;
    notifyListeners();
  }

  Future<void> _loadCurrentUser({User? firebaseUser}) async {
    final User? currentUser = firebaseUser ?? _auth.currentUser;
    if (currentUser != null) {
      final DocumentSnapshot docUser =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (docUser.exists) {
        user = AppUser.fromDocument(docUser);
      } else {
        user = AppUser(id: currentUser.uid, email: currentUser.email);
      }
      notifyListeners();
    }
  }
}
