import 'package:cloud_firestore/cloud_firestore.dart';

class Product{

  Product({this.name, this.id, this.description, this.images});

  Product.fromDocument(DocumentSnapshot document){
    id = document.id;
    name = document['name'] as String;
    description = document['description'] as String;
    images = List<String>.from(document.data()['images'] as List<dynamic>);
  }

  String? id;
  String? name;
  String? description;
  List<String>? images;
}