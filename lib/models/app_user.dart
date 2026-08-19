import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  AppUser({this.id, this.name, this.email, this.password, this.confirmPassword});

  AppUser.fromDocument(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    id = document.id;
    name = data['name'] as String?;
    email = data['email'] as String?;
  }

  String? id;
  String? name;
  String? email;
  String? password;
  String? confirmPassword;

  DocumentReference get firestoreRef =>
      FirebaseFirestore.instance.doc('users/$id');

  Future<void> saveData() async {
    await firestoreRef.set(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }
}
