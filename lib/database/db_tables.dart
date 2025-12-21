import 'package:drift/drift.dart';

class Vocabulary extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text().withLength(min: 1, max: 255)();
  TextColumn get definition => text().withLength(min: 1, max: 1000)();
  TextColumn get exampleSentence => text().withLength(max: 1000).nullable()();
  BoolColumn get mastered => boolean().withDefault(const Constant(false))();
  IntColumn get categoryId => integer().nullable().references(VCategory, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class VCategory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 2, max: 100).unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}