// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_database.dart';

@DataClassName('ContactCard')
class ContactCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contactId => text().customConstraint(
    'REFERENCES contacts(id) ON DELETE CASCADE UNIQUE NOT NULL',
  )();
  TextColumn get did => text()();
  TextColumn get type => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get organization => text()();
  TextColumn get website => text()();
  TextColumn get email => text()();
  TextColumn get mobile => text()();
  TextColumn get postcode => text()();
  TextColumn get profilePic => text()();
  TextColumn get meetingplaceIdentityCardColor => text()();
}
