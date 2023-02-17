import 'package:conduit/conduit.dart';
import 'package:notes_api/model/category.dart';
import 'package:notes_api/model/user.dart';

class Note extends ManagedObject<_Note> implements _Note {}

class _Note {
  @primaryKey
  int? id;
  @Column(unique: true, indexed: true)
  String? name;
  @Column(unique: true, indexed: true)
  String? content;
  @Serialize(input: true, output: false)
  DateTime? dateCreate = DateTime.now();
  @Column()
  bool? isDeleted;

  @Serialize(input: true, output: false)
  int? idCategory;

  @Relate(#notes)
  User? user;

  @Relate(#noteList, isRequired: true, onDelete: DeleteRule.cascade)
  Category? category;
}

class History extends ManagedObject<_History> implements _History {}

class _History {
  @Column(primaryKey: true)
  String? dateOfAction;

  @Column(indexed: true)
  String? contentOfAction;
}