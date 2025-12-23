import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_db.dart';

// part文：riverpod_generatorが生成したコードを読み込む
part 'database_provider.g.dart';

// databaseProvider：アプリ全体で共有されるデータベースインスタンスを提供するプロバイダー
//
// @Riverpod(keepAlive: true)の意味：
// - keepAlive: true：このプロバイダーは一度作成されたら破棄されない（シングルトンパターン）
// - データベースは1つのインスタンスだけを保持し、アプリ全体で再利用します
// - これによりデータベース接続の無駄な再作成を防ぎ、パフォーマンスを向上させます
//
// Riverpodの仕組み：
// - この関数は最初にアクセスされたときに一度だけ実行されます
// - 返されたAppDbインスタンスはキャッシュされ、以降の呼び出しでは同じインスタンスが返されます
// - ref.watch(databaseProvider)でどこからでもこのデータベースにアクセスできます
@Riverpod(keepAlive: true)
AppDb database(Ref ref) {
  // AppDbのインスタンスを作成して返す
  // このインスタンスはアプリ全体で共有されます
  return AppDb();
}