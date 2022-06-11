import 'package:bemestarcem/helpers/firebase_erros.dart';
import 'package:bemestarcem/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


class UserManager extends ChangeNotifier{

  UserManager(){
    _loadCurrentUser();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore app_firestore = FirebaseFirestore.instance;

  // User? user = null; // O ? é porque o user é null.

  AppUser? user;

  bool _loading = false;
  bool get loading => _loading;
  bool get isLoggedIn => user != null; // Retorna se o usuário está logado.

  void signOut(){
    auth.signOut();
    user = null;
    notifyListeners();
  }

  set loading(bool value){
    _loading = value;
    notifyListeners();
  }

  bool get isLoggedId => user !=null;


  Future<void> signIn({required AppUser user, required Function onFail,
    required Function onSuccess}) async {
    loading = true;
    try{
      final UserCredential credential = await auth.signInWithEmailAndPassword(
          email: user.email, password: user.password);

      await _loadCurrentUser(firebaseUser: credential.user);


      onSuccess();
    } on PlatformException catch (e){
      onFail(getErrorString(e.code));
    }
    loading = false;
  }

  Future<void> signUp({required AppUser user, required Function onFail,
    required Function onSucess}) async {
    loading = true;
    try {
      final UserCredential credential = await auth
          .createUserWithEmailAndPassword(
          email: user.email, password: user.password);
      // this.user = credential.user;

      user.id = credential.user.uid;
      this.user = user;
      await user.saveData();

      onSucess();

    } on PlatformException catch (e){
      onFail (getErrorString(e.code));
    }
    loading = false;
  }


  Future<void> _loadCurrentUser({User? firebaseUser}) async {
    final User currentUser = firebaseUser ?? await auth.currentUser;
    if(currentUser != null){
      final DocumentSnapshot docUser = await app_firestore.collection('users')
          .doc(currentUser.uid).get();
      user = AppUser.fromDocument(docUser);
      notifyListeners();
    }
  }

}