import 'package:conduit/conduit.dart';
import 'package:notes_api/controllers/app_auth_controller.dart';
import 'package:notes_api/controllers/app_category_controller.dart';
import 'package:notes_api/controllers/app_note_controller.dart';
import 'package:notes_api/controllers/app_user_controller.dart';
import 'dart:io';
import 'package:notes_api/model/user.dart';
import 'package:notes_api/model/note.dart';
import 'package:notes_api/model/category.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  @override
  Future prepare() {
    final persistentStore = _initDatabase();

    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);

    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route('token/[:refresh]').link(() => AppAuthController(managedContext))
    ..route('history')
        .link(AppTokenController.new)!
        .link(() => AppHistoryController(managedContext))
    ..route('category/[:id]')
        .link(AppTokenController.new)!
        .link(() => AppCategoryController(managedContext))
    ..route('note/[:id]')
        .link(AppTokenController.new)!
        .link(() => AppNoteController(managedContext))
    ..route('user')
        .link(AppTokenController.new)!
        .link(() => AppUserController(managedContext));

  PersistentStore _initDatabase() {
    final username = Platform.environment['DB_USERNAME'] ?? 'postgres';
    final password = Platform.environment['DB_PASSWORD'] ?? '225577';
    final host = Platform.environment['DB_HOST'] ?? '127.0.0.1';
    final port = int.parse(Platform.environment['DB_PORT'] ?? '5432');
    final databaseName = Platform.environment['DB_NAME'] ?? 'notes';
    return PostgreSQLPersistentStore(
        username, password, host, port, databaseName);
  }
}
