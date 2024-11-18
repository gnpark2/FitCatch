import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'liked_page_model.dart';
export 'liked_page_model.dart';


class LikedPageWidget extends StatefulWidget {
  const LikedPageWidget({super.key});

  @override
  State<LikedPageWidget> createState() => _LikedPageWidgetState();
}

class _LikedPageWidgetState extends State<LikedPageWidget> {
  late LikedPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LikedPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> deleteCoordination(CoordinationRecord coordination) async {
    final coordinationRef = coordination.reference;
    await coordinationRef.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('코디가 삭제되었습니다!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoordinationRecord>>(
      stream: queryCoordinationRecord(
        queryBuilder: (CoordinationRecord) => CoordinationRecord.where(
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
        List<CoordinationRecord> homePageCoordinationRecordList = snapshot.data!;

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
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    '저장한 컨텐츠',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          color: Color(0xFF0F2C59),
                                          fontSize: 24.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(10.0, 12.0, 10.0, 24.0),
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primaryText,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 4.0,
                                        color: Color(0x33000000),
                                        offset: Offset(
                                          5.0,
                                          8.0,
                                        ),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Text(
                                    '코디 / 룩',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          color: FlutterFlowTheme.of(context).secondaryBackground,
                                          fontSize: 24.0,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: MediaQuery.sizeOf(context).height * 1.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                ),
                                child: StreamBuilder<List<CoordinationRecord>>(
                                  stream: queryCoordinationRecord(
                                    queryBuilder: (coordinationRecord) =>
                                        coordinationRecord.where(
                                      'user',
                                      isEqualTo: currentUserReference,
                                    ),
                                  ),
                                  builder: (context, snapshot) {
                                    // Customize what your widget looks like when it's loading.
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: SizedBox(
                                          width: 50.0,
                                          height: 50.0,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              FlutterFlowTheme.of(context).primary,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    List<CoordinationRecord> staggeredViewCoordinationRecordList = snapshot.data!;

                                    return MasonryGridView.builder(
                                      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                      ),
                                      crossAxisSpacing: 10.0,
                                      mainAxisSpacing: 10.0,
                                      itemCount: staggeredViewCoordinationRecordList.length,
                                      itemBuilder: (context, staggeredViewIndex) {
                                        final staggeredViewCoordinationRecord = staggeredViewCoordinationRecordList[staggeredViewIndex];
                                        return Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: MediaQuery.sizeOf(context).height * 0.3, // 높이를 조절합니다
                                              child: Stack(
                                                children: [
                                                  if (staggeredViewCoordinationRecord.top != null)
                                                    StreamBuilder<ClothRecord>(
                                                      stream: ClothRecord.getDocument(staggeredViewCoordinationRecord.top!),
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
                                                  if (staggeredViewCoordinationRecord.bottom != null)
                                                    StreamBuilder<ClothRecord>(
                                                      stream: ClothRecord.getDocument(staggeredViewCoordinationRecord.bottom!),
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
                                                  if (staggeredViewCoordinationRecord.outer != null)
                                                    StreamBuilder<ClothRecord>(
                                                      stream: ClothRecord.getDocument(staggeredViewCoordinationRecord.outer!),
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
                                                  if (staggeredViewCoordinationRecord.accessory != null)
                                                    StreamBuilder<ClothRecord>(
                                                      stream: ClothRecord.getDocument(staggeredViewCoordinationRecord.accessory!),
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
                                                  Align(
                                                    alignment: AlignmentDirectional(1.0, -1.0),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.favorite,
                                                        color: Colors.red,
                                                        size: 30.0,
                                                      ),
                                                      onPressed: () async {
                                                        await deleteCoordination(staggeredViewCoordinationRecord);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
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