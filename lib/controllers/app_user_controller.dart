import 'dart:async';
import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:notes_api/model/note.dart';
import 'package:notes_api/model/user.dart';
import 'package:notes_api/utils/app_response.dart';
import 'package:notes_api/utils/app_utils.dart';

class AppUserController extends ResourceController {
  AppUserController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> getProfile(
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(id);

      user!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);
      return AppResponse.ok(
          message: 'Успешное получение профиля', body: user.backing.contents);
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка получения профиля');
    }
  }

  @Operation.post()
  Future<Response> updateProfile(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() User user) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final fUser = await managedContext.fetchObjectWithID<User>(id);
      final qUpdateUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.userName = user.userName ?? fUser!.userName
        ..values.email = user.email ?? fUser!.email;

      await qUpdateUser.updateOne();

      final findUser = await managedContext.fetchObjectWithID<User>(id);

      findUser!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);

      final qNoteHistory = Query<History>(managedContext)
        ..values.contentOfAction =
            'Пользователь ${findUser.id} обновил данные. Логин: ${findUser.userName}, Email: ${findUser.email}.'
        ..values.dateOfAction = DateTime.now().toString();
      await qNoteHistory.insert();

      return AppResponse.ok(
          message: 'Успешное обновление данных',
          body: findUser.backing.contents);
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка обновления данныx');
    }
  }

  @Operation.put()
  Future<Response> updatePassword(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.query('newPassword') String newPassword,
      @Bind.query('oldPassword') String oldPassword) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qFindUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..returningProperties((x) => [x.salt, x.hashPassword]);
      final fUser = await qFindUser.fetchOne();
      final oldHashPassword =
          generatePasswordHash(oldPassword, fUser!.salt ?? "");
      if (oldHashPassword != fUser.hashPassword) {
        return AppResponse.badrequest(message: 'Неверный старый пароль');
      }

      final newHashPassword =
          generatePasswordHash(newPassword, fUser.salt ?? "");
      final qUpdateUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.hashPassword = newHashPassword;

      await qUpdateUser.fetchOne();

      final qHistory = Query<History>(managedContext)
        ..values.contentOfAction = 'Пользователь ${fUser.id} обновил пароль.'
        ..values.dateOfAction = DateTime.now().toString();
      await qHistory.insert();

      return AppResponse.ok(body: 'Пароль успешно обновлён');
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка обновления пароля');
    }
  }
}

// TokenController

class AppTokenController extends Controller {
  @override
  FutureOr<RequestOrResponse?> handle(Request request) {
    try {
      final header = request.raw.headers.value(HttpHeaders.authorizationHeader);
      final token = const AuthorizationBearerParser().parse(header);
      final jwtClaim = verifyJwtHS256Signature(token ?? "", "SECRET_KEY");

      jwtClaim.validate();
      return request;
    } on JwtException catch (e) {
      return AppResponse.serverError(e.message);
    }
  }
}
