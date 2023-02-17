import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:notes_api/model/category.dart';
import 'package:notes_api/model/model_response.dart';
import 'package:notes_api/model/note.dart';
import 'package:notes_api/utils/app_response.dart';
import 'package:notes_api/utils/app_utils.dart';

class AppNoteController extends ResourceController {
  AppNoteController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.post()
  Future<Response> createNote(
      @Bind.header(HttpHeaders.authorizationHeader)
          String header,
      @Bind.body(require: ["name", "content", "idCategory"])
          Note createdNote) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final Category category = Category();
      category.id = createdNote.idCategory;
      final qCreateNote = Query<Note>(managedContext)
        ..values.name = createdNote.name
        ..values.content = createdNote.content
        // ..values.dateCreate = createdDate
        ..values.user!.id = id
        ..values.isDeleted = false
        ..values.category = category;

      await qCreateNote.insert();

      final qHistory = Query<History>(managedContext)
        ..values.contentOfAction =
            'Создана заметка номер: ${qCreateNote.values.id} название: ${createdNote.name}, содержание: ${createdNote.content}, категория: ${createdNote.idCategory}. Пользователь: $id'
        ..values.dateOfAction = DateTime.now().toString();
      await qHistory.insert();

      return AppResponse.ok(message: 'Успешное создание заметки');
    } catch (error) {
      return AppResponse.serverError(error, message: 'Ошибка создания заметки');
    }
  }

  @Operation.get()
  Future<Response> getNotes(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      {@Bind.query('pageLimit') int pageLimit = 0,
      @Bind.query('skipRows') int skipRows = 0}) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final qCreateNote = Query<Note>(managedContext)
        ..fetchLimit = pageLimit
        ..offset = pageLimit * skipRows
        ..where((x) => x.isDeleted).equalTo(false)
        ..where((x) => x.user!.id).equalTo(id);

      final List<Note> list = await qCreateNote.fetch();

      if (list.isEmpty) {
        return Response.notFound(
            body: ModelResponse(data: [], message: "Заметок не найдено"));
      }

      return Response.ok(list);
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.get("id")
  Future<Response> getNote(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id) async {
    try {
      final currentUserId = AppUtils.getIdFromHeader(header);
      final note = await managedContext.fetchObjectWithID<Note>(id);

      if (note == null) {
        return AppResponse.ok(message: "Заметка не найдена");
      }
      if (note.user?.id != currentUserId) {
        return AppResponse.ok(message: "Нет доступа к заметке");
      }
      note.backing.removeProperty("user");
      final qNote = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..join(object: (x) => x.user)
            .returningProperties((x) => [x.id, x.userName])
        ..join(object: (x) => x.category);
      final currentNote = await qNote.fetchOne();

      return Response.ok(currentNote);
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка");
    }
  }

  @Operation.put('id')
  Future<Response> updateNote(
      @Bind.header(HttpHeaders.authorizationHeader)
          String header,
      @Bind.path("id")
          int id,
      @Bind.body(require: ["name", "content", "idCategory"])
          Note bodyNote) async {
    try {
      final currentUserId = AppUtils.getIdFromHeader(header);
      final note = await managedContext.fetchObjectWithID<Note>(id);

      if (note == null) {
        return AppResponse.ok(message: "Заметка не найдена");
      }
      if (note.user?.id != currentUserId) {
        return AppResponse.ok(message: "Нет доступа к редактированию заметки");
      }
      final Category category = Category();
      category.id = bodyNote.idCategory;
      final qUpdateNote = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.name = bodyNote.name
        ..values.content = bodyNote.content
        ..values.isDeleted = false
        ..values.category = category;

      await qUpdateNote.update();

      final qHistory = Query<History>(managedContext)
        ..values.contentOfAction =
            'Изменена заметка номер: ${note.id}. Предыдущее название: ${note.name}, предыдущее содержание: ${note.content}, предыдущая категория: ${note.category}. Новое название: ${qUpdateNote.values.name}, новое содержание: ${qUpdateNote.values.content}, новая категория: ${qUpdateNote.values.idCategory}. Пользователь: $currentUserId'
        ..values.dateOfAction = DateTime.now().toString();
      await qHistory.insert();

      return AppResponse.ok(message: 'Заметка $id успешно обновлена');
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.delete("id")
  Future<Response> deleteNote(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id,
      {@Bind.query("physicalDeleting") bool physicalDeleting = false}) async {
    try {
      final currentUserId = AppUtils.getIdFromHeader(header);

      final note = await (Query<Note>(managedContext)
            ..where((x) => x.id).equalTo(id))
          .fetchOne();

      if (note == null) {
        return AppResponse.ok(message: "Заметка не найдена");
      }
      if (note.user?.id != currentUserId) {
        return AppResponse.ok(
            message: "Нельзя удалить замтеку другого пользователя");
      }

      final qDeleteNote = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id);
      if (physicalDeleting == true) {
        await qDeleteNote.delete();

        final qHistory = Query<History>(managedContext)
          ..values.contentOfAction =
              'На физическом уровне удалена заметка номер: ${note.id}. Название: ${note.name}, содержание: ${note.content}, категория: ${note.category}. Пользователь: $currentUserId'
          ..values.dateOfAction = DateTime.now.toString();
        await qHistory.insert();

        return AppResponse.ok(
            message: "Заметка $id удалена на физическом уровне");
      } else {
        qDeleteNote.values.isDeleted = true;
        await qDeleteNote.updateOne();

        final qHistory = Query<History>(managedContext)
          ..values.contentOfAction =
              'На логическом уровне удалена заметка номер: ${note.id}. Название: ${note.name}, содержание: ${note.content}, категория: ${note.category}. Пользователь: $currentUserId'
          ..values.dateOfAction = DateTime.now().toString();
        await qHistory.insert();

        return AppResponse.ok(
            message: "Заметка $id удалена на логическом уровне");
      }
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка удаления заметки");
    }
  }

  @Operation.post("id")
  Future<Response> recoverNote(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id) async {
    try {
      final currentUserId = AppUtils.getIdFromHeader(header);
      final note = await managedContext.fetchObjectWithID<Note>(id);

      if (note == null) {
        return AppResponse.ok(message: "Заметка не найдена");
      }
      if (note.user?.id != currentUserId) {
        return AppResponse.ok(
            message: "Нельзя восстановить заметку другого пользователя");
      }
      if (note.isDeleted == false) {
        return AppResponse.badrequest(message: "Заметка не удалена");
      }

      final qRecoverNote = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.isDeleted = false;
      await qRecoverNote.updateOne();

      final qHistory = Query<History>(managedContext)
        ..values.contentOfAction =
            'Восстановлена заметка номер: ${note.id}. Название: ${note.name}, содержание: ${note.content}, категория: ${note.category}. Пользователь: $currentUserId'
        ..values.dateOfAction = DateTime.now().toString();
      await qHistory.insert();

      return AppResponse.ok(message: "Заметка $id восстановлена");
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }
}

class AppHistoryController extends ResourceController {
  AppHistoryController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> getHistory() async {
    try {
      final qHistory = Query<History>(managedContext);
      final List<History> list = await qHistory.fetch();

      if (list.isEmpty) {
        return Response.notFound(
            body: ModelResponse(data: [], message: "История действий пуста"));
      }

      return Response.ok(list);
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }
}
