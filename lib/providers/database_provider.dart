import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_db.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDb database(Ref ref) {
  return AppDb();
}
