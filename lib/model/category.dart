
import 'package:conduit/conduit.dart';
import 'package:notes_api/model/note.dart';

class Category extends ManagedObject<_Category> implements _Category {}

class _Category {
  @primaryKey
  int? id;

  @Column(unique: true, indexed: true)
  String? name;

  ManagedSet<Note>? noteList;
}