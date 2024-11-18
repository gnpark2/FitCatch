import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ClothRecord extends FirestoreRecord {
  ClothRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "photo" field.
  String? _photo;
  String get photo => _photo ?? '';
  bool hasPhoto() => _photo != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "style" field.
  String? _style;
  String get style => _style ?? '';
  bool hasStyle() => _style != null;

  // "user" field.
  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _photo = snapshotData['photo'] as String?;
    _category = snapshotData['category'] as String?;
    _style = snapshotData['style'] as String?;
    _user = snapshotData['user'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('cloth');

  static Stream<ClothRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ClothRecord.fromSnapshot(s));

  static Future<ClothRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ClothRecord.fromSnapshot(s));

  static ClothRecord fromSnapshot(DocumentSnapshot snapshot) => ClothRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ClothRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ClothRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ClothRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ClothRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createClothRecordData({
  String? name,
  String? photo,
  String? category,
  String? style,
  DocumentReference? user,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'photo': photo,
      'category': category,
      'style': style,
      'user': user,
    }.withoutNulls,
  );

  return firestoreData;
}

class ClothRecordDocumentEquality implements Equality<ClothRecord> {
  const ClothRecordDocumentEquality();

  @override
  bool equals(ClothRecord? e1, ClothRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.photo == e2?.photo &&
        e1?.category == e2?.category &&
        e1?.style == e2?.style &&
        e1?.user == e2?.user;
  }

  @override
  int hash(ClothRecord? e) => const ListEquality()
      .hash([e?.name, e?.photo, e?.category, e?.style, e?.user]);

  @override
  bool isValidKey(Object? o) => o is ClothRecord;
}
