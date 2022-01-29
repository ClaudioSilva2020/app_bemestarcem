import 'package:bemestarcem/helpers/firebase_erros.dart';
import 'package:bemestarcem/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


class UserManager extends ChangeNotifier{

  final FirebaseAuth  auth = FirebaseAuth.instance;
  bool loading = false;
  Future<void> signIn({required AppUser user, required Function onFail,
    required Function onSuccess}) async {
    setLoading(true);
    try{
      final UserCredential credential = await auth.signInWithEmailAndPassword(
          email: user.email, password: user.password);

      onSuccess();
    } on PlatformException catch (e){
      onFail(getErrorString(e.code));
    }
    setLoading(false);
  }
  void setLoading(bool value){
    loading = value;
    notifyListeners();
  }

}