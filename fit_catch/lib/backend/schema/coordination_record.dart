import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CoordinationRecord extends FirestoreRecord {
  CoordinationRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user" field.
  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  // "Top" field.
  DocumentReference? _top;
  DocumentReference? get top => _top;
  bool hasTop() => _top != null;

  // "Bottom" field.
  DocumentReference? _bottom;
  DocumentReference? get bottom => _bottom;
  bool hasBottom() => _bottom != null;

  // "Accessory" field.
  DocumentReference? _accessory;
  DocumentReference? get accessory => _accessory;
  bool hasAccessory() => _accessory != null;

  // "Outer" field.
  DocumentReference? _outer;
  DocumentReference? get outer => _outer;
  bool hasOuter() => _outer != null;

  // "createdTime" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _user = snapshotData['user'] as DocumentReference?;
    _top = snapshotData['Top'] as DocumentReference?;
    _bottom = snapshotData['Bottom'] as DocumentReference?;
    _accessory = snapshotData['Accessory'] as DocumentReference?;
    _outer = snapshotData['Outer'] as DocumentReference?;
    _createdTime = snapshotData['createdTime'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('coordination');

  static Stream<CoordinationRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CoordinationRecord.fromSnapshot(s));

  static Future<CoordinationRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CoordinationRecord.fromSnapshot(s));

  static CoordinationRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CoordinationRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CoordinationRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CoordinationRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CoordinationRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CoordinationRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCoordinationRecordData({
  DocumentReference? user,
  DocumentReference? top,
  DocumentReference? bottom,
  DocumentReference? accessory,
  DocumentReference? outer,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user': user,
      'Top': top,
      'Bottom': bottom,
      'Accessory': accessory,
      'Outer': outer,
      'createdTime': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class CoordinationRecordDocumentEquality
    implements Equality<CoordinationRecord> {
  const CoordinationRecordDocumentEquality();

  @override
  bool equals(CoordinationRecord? e1, CoordinationRecord? e2) {
    return e1?.user == e2?.user &&
        e1?.top == e2?.top &&
        e1?.bottom == e2?.bottom &&
        e1?.accessory == e2?.accessory &&
        e1?.outer == e2?.outer &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(CoordinationRecord? e) => const ListEquality().hash(
      [e?.user, e?.top, e?.bottom, e?.accessory, e?.outer, e?.createdTime]);

  @override
  bool isValidKey(Object? o) => o is CoordinationRecord;
}
