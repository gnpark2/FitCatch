
import 'package:fit_catch/backend/schema/cloth_record.dart';
import 'package:fit_catch/backend/schema/coordination_record.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'liked_detail_page_model.dart';
export 'liked_detail_page_model.dart';

class LikedDetailPageWidget extends StatefulWidget {
  const LikedDetailPageWidget({
    Key? key,
    required this.coordinationRecord,
  }) : super(key: key);

  final CoordinationRecord coordinationRecord;

  @override
  State<LikedDetailPageWidget> createState() => _LikedDetailPageWidgetState();
}

class _LikedDetailPageWidgetState extends State<LikedDetailPageWidget> {
  late LikedDetailPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LikedDetailPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
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
                                            '저장한 코디',
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Inter',
                                                  color: Color(0xFF0F2C59),
                                                  fontSize: 18.0,
                                                  letterSpacing: 0.0,
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
                                              if (widget.coordinationRecord.top != null)
                                                StreamBuilder<ClothRecord>(
                                                  stream: ClothRecord.getDocument(widget.coordinationRecord.top!),
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
                                              if (widget.coordinationRecord.bottom != null)
                                                StreamBuilder<ClothRecord>(
                                                  stream: ClothRecord.getDocument(widget.coordinationRecord.bottom!),
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
                                              if (widget.coordinationRecord.outer != null)
                                                StreamBuilder<ClothRecord>(
                                                  stream: ClothRecord.getDocument(widget.coordinationRecord.outer!),
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
                                              if (widget.coordinationRecord.accessory != null)
                                                StreamBuilder<ClothRecord>(
                                                  stream: ClothRecord.getDocument(widget.coordinationRecord.accessory!),
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
                  ],
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                          child: Row(
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
                        ),
                        MasonryGridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: [
                            widget.coordinationRecord.top,
                            widget.coordinationRecord.bottom,
                            widget.coordinationRecord.outer,
                            widget.coordinationRecord.accessory
                          ].where((item) => item != null).length,
                          itemBuilder: (context, index) {
                            final items = [
                              widget.coordinationRecord.top,
                              widget.coordinationRecord.bottom,
                              widget.coordinationRecord.outer,
                              widget.coordinationRecord.accessory
                            ];
                            final item = items[index];
                            return StreamBuilder<ClothRecord>(
                              stream: ClothRecord.getDocument(item!),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container();
                                }
                                final clothRecord = snapshot.data!;
                                return InkWell(
                                  onTap: () async {
                                              context.pushNamed(
                                                'clothDetailPage',
                                                queryParameters: {
                                                  'clothDetail': serializeParam(
                                                    clothRecord
                                                        .reference,
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
                                          clothRecord.photo,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
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
                                );
                              },
                            );
                          },
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
    );
  }
}