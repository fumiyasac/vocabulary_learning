import 'package:drift/drift.dart';

// Vocabularyテーブルの定義
// DriftではTableクラスを継承してデータベーステーブルを定義します
// このクラスのgetterがテーブルのカラム（列）になります
class Vocabulary extends Table {
  // IDカラム：各語彙の一意な識別子
  // autoIncrement()：新しいレコードが追加されるたびに自動的に1ずつ増加する
  // これによりプライマリキー（主キー）として機能します
  IntColumn get id => integer().autoIncrement()();

  // wordカラム：語彙の単語を保存
  // withLength(min: 1, max: 255)：文字列の長さを1〜255文字に制限
  // 空文字は許可されず、最大255文字まで保存可能
  TextColumn get word => text().withLength(min: 1, max: 255)();

  // definitionカラム：単語の定義（意味）を保存
  // withLength(min: 1, max: 1000)：1〜1000文字に制限（長い説明も可能）
  TextColumn get definition => text().withLength(min: 1, max: 1000)();

  // exampleSentenceカラム：例文を保存（オプション）
  // nullable()：このカラムはnull（空）を許可する = 例文は必須ではない
  TextColumn get exampleSentence => text().withLength(max: 1000).nullable()();

  // masteredカラム：単語を習得済みかどうかのフラグ
  // boolean()：true/falseの真偽値を保存
  // withDefault(const Constant(false))：デフォルト値はfalse（未習得）
  BoolColumn get mastered => boolean().withDefault(const Constant(false))();

  // categoryIdカラム：この語彙が属するカテゴリのID
  // nullable()：カテゴリは必須ではない（カテゴリなしでも語彙を作成可能）
  // references()：外部キー制約を設定（VCategoryテーブルのidカラムを参照）
  // onDelete: KeyAction.setNull：参照先のカテゴリが削除されたら、このカラムをnullにする
  IntColumn get categoryId => integer().nullable().references(VCategory, #id, onDelete: KeyAction.setNull)();

  // createdAtカラム：レコードが作成された日時を自動保存
  // withDefault(currentDateAndTime)：レコード作成時に現在時刻を自動設定
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // updatedAtカラム：レコードが最後に更新された日時を自動保存
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// VCategoryテーブルの定義（語彙をグループ化するカテゴリ）
// 例：「ビジネス」「旅行」「技術」などのカテゴリを作成できます
class VCategory extends Table {
  // IDカラム：各カテゴリの一意な識別子
  IntColumn get id => integer().autoIncrement()();

  // nameカラム：カテゴリ名
  // withLength(min: 2, max: 100)：最低2文字、最大100文字
  // unique()：同じ名前のカテゴリを複数作成できないようにする（重複を防ぐ）
  TextColumn get name => text().withLength(min: 2, max: 100).unique()();

  // createdAtカラム：カテゴリが作成された日時
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // updatedAtカラム：カテゴリが最後に更新された日時
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}