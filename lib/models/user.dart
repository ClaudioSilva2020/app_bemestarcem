import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser{

  AppUser({ this.email, this.password,
    this.confirmPassword, this.name, this.id});

  AppUser.fromDocument(DocumentSnapshot document){
    id = document.id;
    name = document.data()['name'] as String;
    email = document.data()['email'] as String;
  }

  String? id;
  String? email;
  String? password;
  String? name;
  String? confirmPassword;

  DocumentReference get firestoreFef =>
    FirebaseFirestore.instance.doc('users/$id');

  Future<void> saveData() async {
    //this function has a instruction that is the new way of use.
    await firestoreFef.set(toMap());
    print("ID depois do firestore: "+ id!);
  }

  //this MAP is the MAP that will load every data of users.
  Map<String, dynamic> toMap(){
    return{
      'name': name,
      'email': email,
    };
  }

}