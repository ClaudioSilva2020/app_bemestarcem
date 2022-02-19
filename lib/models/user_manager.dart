import 'package:bemestarcem/helpers/firebase_erros.dart';
import 'package:bemestarcem/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


class UserManager extends ChangeNotifier{

  UserManager(){
    _loadCurrentUser();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  User? user = null; // O ? é porque o user é null.

  bool _loading = false;
  bool get loading => _loading;
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

      this.user = credential.user;

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
      this.user = credential.user;

      onSucess();

    } on PlatformException catch (e){
      onFail (getErrorString(e.code));
    }
    loading = false;
  }


  Future<void> _loadCurrentUser() async {
    final User currentUser = await auth.currentUser;
    if(currentUser != null){
      user = currentUser;
      print("User UID: " + user!.uid); //O caractere ! serve para usar var null
    }
    notifyListeners();
  }

}