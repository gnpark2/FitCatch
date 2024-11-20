/*
import 'dart:math';

import 'package:collection/collection.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  bool isCoordinationSaved = false;
  Map<String, DocumentReference?>? todayCoordination;
  DocumentReference? savedCoordinationRef;
  List<String?>recommandStyle = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    _loadTodayCoordination();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadTodayCoordination() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCoordination = prefs.getStringList('todayCoordination');
    if (savedCoordination != null) {
      setState(() {
        todayCoordination = {
          'top': FirebaseFirestore.instance.doc(savedCoordination[0]),
          'bottom': FirebaseFirestore.instance.doc(savedCoordination[1]),
          'outer': FirebaseFirestore.instance.doc(savedCoordination[2]),
          'accessory': FirebaseFirestore.instance.doc(savedCoordination[3]),
        };
      });
      await _checkIfCoordinationSaved();
      await _updateRecommandStyle();
    }
  }

  Future<void> _saveTodayCoordination(Map<String, DocumentReference?> coordination) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('todayCoordination', [
      coordination['top']?.path ?? '',
      coordination['bottom']?.path ?? '',
      coordination['outer']?.path ?? '',
      coordination['accessory']?.path ?? '',
    ]);
  }

  Future<void> _checkIfCoordinationSaved() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final querySnapshot = await FirebaseFirestore.instance
        .collection('coordination')
        .where('user', isEqualTo: currentUserReference)
        .where('createdTime', isGreaterThanOrEqualTo: startOfDay)
        .where('createdTime', isLessThanOrEqualTo: endOfDay)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        isCoordinationSaved = true;
        savedCoordinationRef = querySnapshot.docs.first.reference;
      });
    } else {
      setState(() {
        isCoordinationSaved = false;
        savedCoordinationRef = null;
      });
    }
  }

  Future<void> toggleSaveCoordination(Map<String, DocumentReference?> coordination) async {
    if (isCoordinationSaved) {
      // 코디 삭제
      if (savedCoordinationRef != null) {
        await savedCoordinationRef!.delete();
      }
    } else {
      // 코디 저장
      final coordinationRecordData = createCoordinationRecordData(
        user: currentUserReference,
        top: coordination['top'],
        bottom: coordination['bottom'],
        outer: coordination['outer'],
        accessory: coordination['accessory'],
        createdTime: DateTime.now(),
      );

      savedCoordinationRef = await CoordinationRecord.collection.add(coordinationRecordData);
    }

    setState(() {
      isCoordinationSaved = !isCoordinationSaved;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCoordinationSaved ? '코디가 저장되었습니다!' : '코디가 삭제되었습니다!',
        ),
      ),
    );
  }

  Future<void> _updateRecommandStyle() async {
    if (todayCoordination == null) return;

    List<String?> styles = [];
    for (var category in todayCoordination!.keys) {
      var reference = todayCoordination![category];
      if (reference != null) {
        var cloth = await reference.get();
        if (styles.every((style) => style != cloth.get("style"))) {
          styles.add(cloth.get("style"));
        }
      }
    }

    setState(() {
      recommandStyle = styles;
    });
  }

  Map<String, DocumentReference?> getRandomCoordination(List<ClothRecord> clothes) {
    final groupedClothes = groupBy(clothes, (ClothRecord cloth) => cloth.style);
    List<ClothRecord?> coordination = [null, null, null, null];
    List<String> categories = ['Top', 'Bottom', 'Outer', 'Accessory'];

    groupedClothes.forEach((style, clothList) {
      for (int i = 0; i < categories.length; i++) {
        var categoryClothes = clothList.where((cloth) => cloth.category == categories[i]).toList();
        if (categoryClothes.isNotEmpty) {
          coordination[i] = categoryClothes[Random().nextInt(categoryClothes.length)];
        }
      }
    });

    // 카테고리별 옷이 없으면 다른 스타일에서 가져오기
    for (int i = 0; i < coordination.length; i++) {
      if (coordination[i] == null) {
        var otherClothes = clothes.where((cloth) => cloth.category == categories[i]).toList();
        if (otherClothes.isNotEmpty) {
          coordination[i] = otherClothes[Random().nextInt(otherClothes.length)];
        }
      }
    }

    var selectedCoordination = {
      'top': coordination[0]?.reference,
      'bottom': coordination[1]?.reference,
      'outer': coordination[2]?.reference,
      'accessory': coordination[3]?.reference,
    };

    _updateRecommandStyleWithClothes(coordination);

    return selectedCoordination;
  }

  void _updateRecommandStyleWithClothes(List<ClothRecord?> coordination) {
    setState(() {
      recommandStyle = coordination.where((cloth) => cloth != null).map((cloth) => cloth!.style).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ClothRecord>>(
      stream: queryClothRecord(
        queryBuilder: (clothRecord) => clothRecord.where(
          'user',
          isEqualTo: currentUserReference,
        ),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        List<ClothRecord> homePageClothRecordList = snapshot.data!;
        if (todayCoordination == null) {
          todayCoordination = getRandomCoordination(homePageClothRecordList);
          _saveTodayCoordination(todayCoordination!);
        }

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: SafeArea(
              top: true,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: MediaQuery.sizeOf(context).height * 1.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 4.0,
                                            color: Color(0x33000000),
                                            offset: Offset(0.0, 2.0),
                                          )
                                          
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8.0, 8.0, 8.0, 8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '오늘의 데일리 코디 추천',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'Inter',
                                                            color: Color(
                                                                0xFF0F2C59),
                                                            fontSize: 20.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                    Text(
                                                      '날씨와 회원님의 취향을 기반으로 스타일을 추천해드려요',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'Inter',
                                                            color: Color(
                                                                0xFF0F2C59),
                                                            fontSize: 10.0,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 0.5,
                                                        color:
                                                            Color(0x33000000),
                                                        offset: Offset(
                                                          3.0,
                                                          3.0,
                                                        ),
                                                      )
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: FFButtonWidget(
                                                    onPressed: () {
                                                      print(
                                                          'Button pressed ...');
                                                    },
                                                    text: '더보기',
                                                    options: FFButtonOptions(
                                                      height: 32.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  24.0,
                                                                  0.0,
                                                                  24.0,
                                                                  0.0),
                                                      iconPadding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .override(
                                                                fontFamily:
                                                                    'Inter Tight',
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                      elevation: 0.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(8.0, 8.0, 8.0, 0.0),
                                              child: Row(
                                                children: [
                                                  if (todayCoordination!['top'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['top']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(-0.9, -0.8),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 80.0,
                                                            height: 80.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                if (todayCoordination!['bottom'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['bottom']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(-0.8, 0.8),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 80.0,
                                                            height: 80.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                if (todayCoordination!['outer'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['outer']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(0.8, -0.7),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 80.0,
                                                            height: 80.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                if (todayCoordination!['accessory'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['accessory']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(0.9, 0.9),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 80.0,
                                                            height: 80.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 8.0, 0.0, 8.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: recommandStyle.map<Widget>((style) {
                                                  return Padding(
                                                    padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
                                                    child: Text(
                                                      '#$style',
                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                            fontFamily: 'Inter',
                                                            color: Color(0xFF0F2C59),
                                                            letterSpacing: 0.0,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(12.0, 20.0, 12.0, 20.0),
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                                            child: Text(
                                              '오늘의 코디 추천',
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                    fontFamily: 'Inter',
                                                    color: Color(0xFF0F2C59),
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16.0),
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
                                          child: Container(
                                            width: 300.0,
                                            height: 300.0,
                                            child: Stack(
                                              alignment: AlignmentDirectional(0.0, 0.0),
                                              children: [
                                                if (todayCoordination!['top'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['top']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(-0.9, -0.8),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 150.0,
                                                            height: 150.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                if (todayCoordination!['bottom'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['bottom']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(-0.8, 0.8),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 150.0,
                                                            height: 150.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                if (todayCoordination!['outer'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['outer']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(0.8, -0.7),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 150.0,
                                                            height: 150.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                if (todayCoordination!['accessory'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['accessory']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(0.9, 0.9),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 150.0,
                                                            height: 150.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                Align(
                                                  alignment: AlignmentDirectional(1.0, -1.0),
                                                  child: IconButton(
                                                    icon: Icon(
                                                      isCoordinationSaved ? Icons.favorite : Icons.favorite_border,
                                                      color: Colors.red,
                                                      size: 30.0,
                                                    ),
                                                    onPressed: () async {
                                                      await toggleSaveCoordination(todayCoordination!);
                                                      await _checkIfCoordinationSaved();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
*/

import 'dart:math';

import 'package:collection/collection.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  bool isCoordinationSaved = false;
  Map<String, DocumentReference?>? todayCoordination;
  DocumentReference? savedCoordinationRef;
  List<String?>recommandStyle = [];
  bool isExpanded = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    _loadTodayCoordination();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadTodayCoordination() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCoordination = prefs.getStringList('todayCoordination');
    if (savedCoordination != null) {
      setState(() {
        todayCoordination = {
          'top': FirebaseFirestore.instance.doc(savedCoordination[0]),
          'bottom': FirebaseFirestore.instance.doc(savedCoordination[1]),
          'outer': FirebaseFirestore.instance.doc(savedCoordination[2]),
          'accessory': FirebaseFirestore.instance.doc(savedCoordination[3]),
        };
      });
      await _checkIfCoordinationSaved();
      await _updateRecommandStyle();
    }
  }

  Future<void> _saveTodayCoordination(Map<String, DocumentReference?> coordination) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('todayCoordination', [
      coordination['top']?.path ?? '',
      coordination['bottom']?.path ?? '',
      coordination['outer']?.path ?? '',
      coordination['accessory']?.path ?? '',
    ]);
  }

  Future<void> _checkIfCoordinationSaved() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final querySnapshot = await FirebaseFirestore.instance
        .collection('coordination')
        .where('user', isEqualTo: currentUserReference)
        .where('createdTime', isGreaterThanOrEqualTo: startOfDay)
        .where('createdTime', isLessThanOrEqualTo: endOfDay)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        isCoordinationSaved = true;
        savedCoordinationRef = querySnapshot.docs.first.reference;
      });
    } else {
      setState(() {
        isCoordinationSaved = false;
        savedCoordinationRef = null;
      });
    }
  }

  Future<void> toggleSaveCoordination(Map<String, DocumentReference?> coordination) async {
    if (isCoordinationSaved) {
      // 코디 삭제
      if (savedCoordinationRef != null) {
        await savedCoordinationRef!.delete();
      }
    } else {
      // 코디 저장
      final coordinationRecordData = createCoordinationRecordData(
        user: currentUserReference,
        top: coordination['top'],
        bottom: coordination['bottom'],
        outer: coordination['outer'],
        accessory: coordination['accessory'],
        createdTime: DateTime.now(),
      );

      savedCoordinationRef = await CoordinationRecord.collection.add(coordinationRecordData);
    }

    setState(() {
      isCoordinationSaved = !isCoordinationSaved;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCoordinationSaved ? '코디가 저장되었습니다!' : '코디가 삭제되었습니다!',
        ),
      ),
    );
  }

  Future<void> _updateRecommandStyle() async {
    if (todayCoordination == null) return;

    List<String?> styles = [];
    for (var category in todayCoordination!.keys) {
      var reference = todayCoordination![category];
      if (reference != null) {
        var cloth = await reference.get();
        if (styles.every((style) => style != cloth.get("style"))) {
          styles.add(cloth.get("style"));
        }
      }
    }

    setState(() {
      recommandStyle = styles;
    });
  }

  Map<String, DocumentReference?> getRandomCoordination(List<ClothRecord> clothes) {
    final groupedClothes = groupBy(clothes, (ClothRecord cloth) => cloth.style);
    List<ClothRecord?> coordination = [null, null, null, null];
    List<String> categories = ['Top', 'Bottom', 'Outer', 'Accessory'];

    groupedClothes.forEach((style, clothList) {
      for (int i = 0; i < categories.length; i++) {
        var categoryClothes = clothList.where((cloth) => cloth.category == categories[i]).toList();
        if (categoryClothes.isNotEmpty) {
          coordination[i] = categoryClothes[Random().nextInt(categoryClothes.length)];
        }
      }
    });

    // 카테고리별 옷이 없으면 다른 스타일에서 가져오기
    for (int i = 0; i < coordination.length; i++) {
      if (coordination[i] == null) {
        var otherClothes = clothes.where((cloth) => cloth.category == categories[i]).toList();
        if (otherClothes.isNotEmpty) {
          coordination[i] = otherClothes[Random().nextInt(otherClothes.length)];
        }
      }
    }

    var selectedCoordination = {
      'top': coordination[0]?.reference,
      'bottom': coordination[1]?.reference,
      'outer': coordination[2]?.reference,
      'accessory': coordination[3]?.reference,
    };

    _updateRecommandStyleWithClothes(coordination);

    return selectedCoordination;
  }

  void _updateRecommandStyleWithClothes(List<ClothRecord?> coordination) {
    setState(() {
      recommandStyle = coordination.where((cloth) => cloth != null).map((cloth) => cloth!.style).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ClothRecord>>(
      stream: queryClothRecord(
        queryBuilder: (clothRecord) => clothRecord.where(
          'user',
          isEqualTo: currentUserReference,
        ),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        List<ClothRecord> homePageClothRecordList = snapshot.data!;
        if (todayCoordination == null) {
          todayCoordination = getRandomCoordination(homePageClothRecordList);
          _saveTodayCoordination(todayCoordination!);
        }

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: SafeArea(
              top: true,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: MediaQuery.sizeOf(context).height * 1.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 4.0,
                                            color: Color(0x33000000),
                                            offset: Offset(0.0, 2.0),
                                          )
                                          
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8.0, 8.0, 8.0, 8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '오늘의 데일리 코디 추천',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'Inter',
                                                            color: Color(
                                                                0xFF0F2C59),
                                                            fontSize: 20.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                    Text(
                                                      '날씨와 회원님의 취향을 기반으로 스타일을 추천해드려요',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'Inter',
                                                            color: Color(
                                                                0xFF0F2C59),
                                                            fontSize: 10.0,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 0.5,
                                                        color:
                                                            Color(0x33000000),
                                                        offset: Offset(
                                                          3.0,
                                                          3.0,
                                                        ),
                                                      )
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: FFButtonWidget(
                                                    onPressed: () {
                                                      setState(() {
                                                        isExpanded = !isExpanded;
                                                      });
                                                      print(
                                                          'Button pressed ...');
                                                    },
                                                    text: isExpanded ? "접기" : "더보기",
                                                    options: FFButtonOptions(
                                                      height: 32.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  24.0,
                                                                  0.0,
                                                                  24.0,
                                                                  0.0),
                                                      iconPadding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .override(
                                                                fontFamily:
                                                                    'Inter Tight',
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                      elevation: 0.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (!isExpanded)
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(8.0, 8.0, 8.0, 0.0),
                                              child: Row(
                                                children: [
                                                  if (todayCoordination!['top'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['top']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(-0.9, -0.8),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 80.0,
                                                            height: 80.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                if (todayCoordination!['bottom'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['bottom']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(-0.8, 0.8),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 80.0,
                                                            height: 80.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                if (todayCoordination!['outer'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['outer']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(0.8, -0.7),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 80.0,
                                                            height: 80.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                if (todayCoordination!['accessory'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['accessory']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(0.9, 0.9),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 80.0,
                                                            height: 80.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if(!isExpanded)
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 8.0, 0.0, 8.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: recommandStyle.map<Widget>((style) {
                                                  return Padding(
                                                    padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
                                                    child: Text(
                                                      '#$style',
                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                            fontFamily: 'Inter',
                                                            color: Color(0xFF0F2C59),
                                                            letterSpacing: 0.0,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),//
                                            if (isExpanded)
                                              Container(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 8.0),
                                                              child:Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              '날씨 API',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily: 'Inter',
                                                                    color: Color(
                                                                        0xFF0F2C59),
                                                                    fontSize: 20.0,
                                                                    letterSpacing: 0.0,
                                                                    fontWeight:
                                                                        FontWeight.w600,
                                                                  ),
                                                            ),
                                                            Text(
                                                              '날씨에 대해 column으로 묶고 Text 작성',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily: 'Inter',
                                                                    color: Color(
                                                                        0xFF0F2C59),
                                                                    fontSize: 10.0,
                                                                    letterSpacing: 0.0,
                                                                  ),
                                                            ),
                                                          ],
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 8.0),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: FlutterFlowTheme.of(context).secondaryBackground,
                                                        ),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.max,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                                                                  child: Text(
                                                                    '오늘의 코디 추천',
                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                          fontFamily: 'Inter',
                                                                          color: Color(0xFF0F2C59),
                                                                          fontSize: 18.0,
                                                                          fontWeight: FontWeight.w600,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(16.0),
                                                                shape: BoxShape.rectangle,
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
                                                                child: Container(
                                                                  width: 300.0,
                                                                  height: 300.0,
                                                                  child: Stack(
                                                                    alignment: AlignmentDirectional(0.0, 0.0),
                                                                    children: [
                                                                      if (todayCoordination!['top'] != null)
                                                                        StreamBuilder<ClothRecord>(
                                                                          stream: ClothRecord.getDocument(todayCoordination!['top']!),
                                                                          builder: (context, snapshot) {
                                                                            if (!snapshot.hasData) {
                                                                              return Container();
                                                                            }
                                                                            return Align(
                                                                              alignment: AlignmentDirectional(-0.9, -0.8),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                child: Image.network(
                                                                                  snapshot.data!.photo,
                                                                                  width: 150.0,
                                                                                  height: 150.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      if (todayCoordination!['bottom'] != null)
                                                                        StreamBuilder<ClothRecord>(
                                                                          stream: ClothRecord.getDocument(todayCoordination!['bottom']!),
                                                                          builder: (context, snapshot) {
                                                                            if (!snapshot.hasData) {
                                                                              return Container();
                                                                            }
                                                                            return Align(
                                                                              alignment: AlignmentDirectional(-0.8, 0.8),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                child: Image.network(
                                                                                  snapshot.data!.photo,
                                                                                  width: 150.0,
                                                                                  height: 150.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      if (todayCoordination!['outer'] != null)
                                                                        StreamBuilder<ClothRecord>(
                                                                          stream: ClothRecord.getDocument(todayCoordination!['outer']!),
                                                                          builder: (context, snapshot) {
                                                                            if (!snapshot.hasData) {
                                                                              return Container();
                                                                            }
                                                                            return Align(
                                                                              alignment: AlignmentDirectional(0.8, -0.7),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                child: Image.network(
                                                                                  snapshot.data!.photo,
                                                                                  width: 150.0,
                                                                                  height: 150.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      if (todayCoordination!['accessory'] != null)
                                                                        StreamBuilder<ClothRecord>(
                                                                          stream: ClothRecord.getDocument(todayCoordination!['accessory']!),
                                                                          builder: (context, snapshot) {
                                                                            if (!snapshot.hasData) {
                                                                              return Container();
                                                                            }
                                                                            return Align(
                                                                              alignment: AlignmentDirectional(0.9, 0.9),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                child: Image.network(
                                                                                  snapshot.data!.photo,
                                                                                  width: 150.0,
                                                                                  height: 150.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      Align(
                                                                        alignment: AlignmentDirectional(1.0, -1.0),
                                                                        child: IconButton(
                                                                          icon: Icon(
                                                                            isCoordinationSaved ? Icons.favorite : Icons.favorite_border,
                                                                            color: Colors.red,
                                                                            size: 30.0,
                                                                          ),
                                                                          onPressed: () async {
                                                                            await toggleSaveCoordination(todayCoordination!);
                                                                            await _checkIfCoordinationSaved();
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 0.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            children: [
                                                              Text(
                                                                '이 코디를 구성하는 아이템',
                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                      fontFamily: 'Inter',
                                                                      color: Color(0xFF0F2C59),
                                                                      fontSize: 18.0,
                                                                      letterSpacing: 0.0,
                                                                      fontWeight: FontWeight.w600,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsetsDirectional
                                                                .fromSTEB(8.0, 8.0, 8.0, 0.0),
                                                            child: Row(
                                                              children: [
                                                                if (todayCoordination!['top'] != null)
                                                                StreamBuilder<ClothRecord>(
                                                                  stream: ClothRecord.getDocument(todayCoordination!['top']!),
                                                                  builder: (context, snapshot) {
                                                                    if (!snapshot.hasData) {
                                                                      return Container();
                                                                    }
                                                                    final clothRecord = snapshot.data!;
                                                                    return Align(
                                                                      alignment: AlignmentDirectional(-0.9, -0.8),
                                                                      child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(8.0),
                                                                        child:InkWell(
                                                                          splashColor: Colors.transparent,
                                                                          focusColor: Colors.transparent,
                                                                          hoverColor: Colors.transparent,
                                                                          highlightColor: Colors.transparent,
                                                                          onTap: () async {
                                                                            context.pushNamed(
                                                                              'clothDetailPage',
                                                                              queryParameters: {
                                                                                'clothDetail': serializeParam(
                                                                                  clothRecord.reference,
                                                                                  ParamType.DocumentReference,
                                                                                ),
                                                                              }.withoutNulls,
                                                                            );
                                                                          },
                                                                          child: Column(
                                                                            mainAxisSize: MainAxisSize.max,
                                                                            children: [
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                child: Image.network(
                                                                                snapshot.data!.photo,
                                                                                width: 80.0,
                                                                                height: 80.0,
                                                                                fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsets.fromLTRB(0.0, 0.8, 0.0, 0.0),
                                                                                child: Text(
                                                                                  clothRecord.name,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: 'Inter',
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              if (todayCoordination!['bottom'] != null)
                                                                StreamBuilder<ClothRecord>(
                                                                  stream: ClothRecord.getDocument(todayCoordination!['bottom']!),
                                                                  builder: (context, snapshot) {
                                                                    if (!snapshot.hasData) {
                                                                      return Container();
                                                                    }
                                                                    final clothRecord = snapshot.data!;
                                                                    return Align(
                                                                      alignment: AlignmentDirectional(-0.8, 0.8),
                                                                      child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(8.0),
                                                                        child:InkWell(
                                                                          splashColor: Colors.transparent,
                                                                          focusColor: Colors.transparent,
                                                                          hoverColor: Colors.transparent,
                                                                          highlightColor: Colors.transparent,
                                                                          onTap: () async {
                                                                            context.pushNamed(
                                                                              'clothDetailPage',
                                                                              queryParameters: {
                                                                                'clothDetail': serializeParam(
                                                                                  clothRecord.reference,
                                                                                  ParamType.DocumentReference,
                                                                                ),
                                                                              }.withoutNulls,
                                                                            );
                                                                          },
                                                                          child: Column(
                                                                            mainAxisSize: MainAxisSize.max,
                                                                            children: [
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                child: Image.network(
                                                                                snapshot.data!.photo,
                                                                                width: 80.0,
                                                                                height: 80.0,
                                                                                fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsets.fromLTRB(0.0, 0.8, 0.0, 0.0),
                                                                                child: Text(
                                                                                  clothRecord.name,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: 'Inter',
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              if (todayCoordination!['outer'] != null)
                                                                StreamBuilder<ClothRecord>(
                                                                  stream: ClothRecord.getDocument(todayCoordination!['outer']!),
                                                                  builder: (context, snapshot) {
                                                                    if (!snapshot.hasData) {
                                                                      return Container();
                                                                    }
                                                                    final clothRecord = snapshot.data!;
                                                                    return Align(
                                                                      alignment: AlignmentDirectional(0.8, -0.7),
                                                                      child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(8.0),
                                                                        child:InkWell(
                                                                          splashColor: Colors.transparent,
                                                                          focusColor: Colors.transparent,
                                                                          hoverColor: Colors.transparent,
                                                                          highlightColor: Colors.transparent,
                                                                          onTap: () async {
                                                                            context.pushNamed(
                                                                              'clothDetailPage',
                                                                              queryParameters: {
                                                                                'clothDetail': serializeParam(
                                                                                  clothRecord.reference,
                                                                                  ParamType.DocumentReference,
                                                                                ),
                                                                              }.withoutNulls,
                                                                            );
                                                                          },
                                                                          child: Column(
                                                                            mainAxisSize: MainAxisSize.max,
                                                                            children: [
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                child: Image.network(
                                                                                snapshot.data!.photo,
                                                                                width: 80.0,
                                                                                height: 80.0,
                                                                                fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsets.fromLTRB(0.0, 0.8, 0.0, 0.0),
                                                                                child: Text(
                                                                                  clothRecord.name,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: 'Inter',
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              if (todayCoordination!['accessory'] != null)
                                                                StreamBuilder<ClothRecord>(
                                                                  stream: ClothRecord.getDocument(todayCoordination!['accessory']!),
                                                                  builder: (context, snapshot) {
                                                                    if (!snapshot.hasData) {
                                                                      return Container();
                                                                    }
                                                                    final clothRecord = snapshot.data!;
                                                                    return Align(
                                                                      alignment: AlignmentDirectional(0.9, 0.9),
                                                                      child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(8.0),
                                                                        child:InkWell(
                                                                          splashColor: Colors.transparent,
                                                                          focusColor: Colors.transparent,
                                                                          hoverColor: Colors.transparent,
                                                                          highlightColor: Colors.transparent,
                                                                          onTap: () async {
                                                                            context.pushNamed(
                                                                              'clothDetailPage',
                                                                              queryParameters: {
                                                                                'clothDetail': serializeParam(
                                                                                  clothRecord.reference,
                                                                                  ParamType.DocumentReference,
                                                                                ),
                                                                              }.withoutNulls,
                                                                            );
                                                                          },
                                                                          child: Column(
                                                                            mainAxisSize: MainAxisSize.max,
                                                                            children: [
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                child: Image.network(
                                                                                snapshot.data!.photo,
                                                                                width: 80.0,
                                                                                height: 80.0,
                                                                                fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsets.fromLTRB(0.0, 0.8, 0.0, 0.0),
                                                                                child: Text(
                                                                                  clothRecord.name,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: 'Inter',
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ),
                                              //
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if(!isExpanded)
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(12.0, 20.0, 12.0, 20.0),
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                                            child: Text(
                                              '오늘의 코디 추천',
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                    fontFamily: 'Inter',
                                                    color: Color(0xFF0F2C59),
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16.0),
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
                                          child: Container(
                                            width: 300.0,
                                            height: 300.0,
                                            child: Stack(
                                              alignment: AlignmentDirectional(0.0, 0.0),
                                              children: [
                                                if (todayCoordination!['top'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['top']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(-0.9, -0.8),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 150.0,
                                                            height: 150.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                if (todayCoordination!['bottom'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['bottom']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(-0.8, 0.8),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 150.0,
                                                            height: 150.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                if (todayCoordination!['outer'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['outer']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(0.8, -0.7),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 150.0,
                                                            height: 150.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                if (todayCoordination!['accessory'] != null)
                                                  StreamBuilder<ClothRecord>(
                                                    stream: ClothRecord.getDocument(todayCoordination!['accessory']!),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Container();
                                                      }
                                                      return Align(
                                                        alignment: AlignmentDirectional(0.9, 0.9),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.network(
                                                            snapshot.data!.photo,
                                                            width: 150.0,
                                                            height: 150.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                Align(
                                                  alignment: AlignmentDirectional(1.0, -1.0),
                                                  child: IconButton(
                                                    icon: Icon(
                                                      isCoordinationSaved ? Icons.favorite : Icons.favorite_border,
                                                      color: Colors.red,
                                                      size: 30.0,
                                                    ),
                                                    onPressed: () async {
                                                      await toggleSaveCoordination(todayCoordination!);
                                                      await _checkIfCoordinationSaved();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}