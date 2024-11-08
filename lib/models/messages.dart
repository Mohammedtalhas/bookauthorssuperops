import 'package:bookauthors/models/authors.dart';

class Messages {
  final int id;
  final String content;
  final String updated;
  final Author author;
  bool isFavourite;
  Messages({required this.id,required this.content, required this.author,required this.updated, this.isFavourite =false});

  factory Messages.fromJson(Map<String,dynamic> json){
    return Messages(id: json["id"], content: json["content"], author: Author(name: json["author"]["name"], photoUrl: json["author"]["photoUrl"]), updated: json["updated"]);
  }
}