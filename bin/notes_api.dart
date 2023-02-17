import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:notes_api/notes_api.dart';

void main() async {
    final port = int.parse(Platform.environment["PORT"] ?? '4448');
  final service = Application<AppService>()
    ..options.port = port;
  await service.start(numberOfInstances: 3, consoleLogging: true);
}
