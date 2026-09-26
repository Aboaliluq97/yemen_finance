import '/components/button/button_widget.dart';
import '/components/metric_card/metric_card_widget.dart';
import '/components/transaction_item/transaction_item_widget.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'dashboard_model.dart';
export 'dashboard_model.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  static String routeName = 'Dashboard';
  static String routePath = '/dashboard';

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  late DashboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            print('FAB pressed ...');
          },
          backgroundColor: FlutterFlowTheme.of(context).tertiary,
          icon: Icon(
            Icons.add_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 24,
          ),
          elevation: 0,
          label: Text(
            'إضافة عملية',
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight:
                        FlutterFlowTheme.of(context).labelLarge.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).labelLarge.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  lineHeight: 1.33,
                ),
          ),
        ),
        body: SingleChildScrollView(
          primary: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(24),
                child: Container(
                  child: Align(
                    alignment: AlignmentDirectional(-1, 1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الموازنه والمحفظة',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w900,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w900,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                        lineHeight: 1.25,
                                      ),
                                ),
                                Text(
                                  'لوحة التحكم المالية',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmall
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontStyle,
                                        lineHeight: 1.38,
                                      ),
                                ),
                              ],
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: AlignmentDirectional(0, 0),
                              child: Text(
                                'MA',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .onPrimary,
                                      fontSize: 15.2,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                      lineHeight: 1.38,
                                    ),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  FlutterFlowTheme.of(context).primary,
                                  Color(0xFF004D40)
                                ],
                                stops: [0, 1],
                                begin: AlignmentDirectional(1, 1),
                                end: AlignmentDirectional(-1, -1),
                              ),
                              borderRadius: BorderRadius.circular(24),
                              shape: BoxShape.rectangle,
                            ),
                            child: Stack(
                              alignment: AlignmentDirectional(-1, -1),
                              children: [
                                Opacity(
                                  opacity: 0.1,
                                  child: Align(
                                    alignment: AlignmentDirectional(1, -1),
                                    child: Transform.rotate(
                                      angle: 15 * (math.pi / 180),
                                      alignment: AlignmentDirectional(0, 0),
                                      child: Container(
                                        child: Icon(
                                          Icons.payments_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .onBackground,
                                          size: 180,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'الرصيد المتبقي',
                                            style: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  font: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .onBackground,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleMedium
                                                          .fontStyle,
                                                  lineHeight: 1.35,
                                                ),
                                          ),
                                          Icon(
                                            Icons
                                                .account_balance_wallet_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .onBackground,
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '450,750 YER',
                                            style: FlutterFlowTheme.of(context)
                                                .headlineLarge
                                                .override(
                                                  font: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight: FontWeight.w800,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .headlineLarge
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .onBackground,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w800,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .headlineLarge
                                                          .fontStyle,
                                                  lineHeight: 1.2,
                                                ),
                                          ),
                                          Opacity(
                                            opacity: 0.8,
                                            child: Text(
                                              'أربع مئة وخمسون ألفاً وسبعمئة وخمسون ريالاً',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onBackground,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontStyle,
                                                        lineHeight: 1.27,
                                                      ),
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 4)),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16, 0, 16, 0),
                                        child: Container(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .onPrimary13,
                                              borderRadius:
                                                  BorderRadius.circular(9999),
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(16, 8, 16, 8),
                                              child: Container(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.trending_up_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .onSurface,
                                                      size: 14,
                                                    ),
                                                    Text(
                                                      '+2.5% هذا الشهر',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .override(
                                                                font: GoogleFonts
                                                                    .plusJakartaSans(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .onSurface,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontStyle,
                                                                lineHeight:
                                                                    1.27,
                                                              ),
                                                    ),
                                                  ].divide(SizedBox(width: 4)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: wrapWithModel(
                                model: _model.metricCardModel1,
                                updateCallback: () => safeSetState(() {}),
                                child: MetricCardWidget(
                                  amount: '850,000',
                                  color: FlutterFlowTheme.of(context).success,
                                  icon: Icon(
                                    Icons.arrow_upward_rounded,
                                    color: FlutterFlowTheme.of(context).success,
                                    size: 18,
                                  ),
                                  label: 'إجمالي الدخل',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: wrapWithModel(
                                model: _model.metricCardModel2,
                                updateCallback: () => safeSetState(() {}),
                                child: MetricCardWidget(
                                  amount: '399,250',
                                  color: FlutterFlowTheme.of(context).error,
                                  icon: Icon(
                                    Icons.arrow_downward_rounded,
                                    color: FlutterFlowTheme.of(context).success,
                                    size: 18,
                                  ),
                                  label: 'إجمالي المصروفات',
                                ),
                              ),
                            ),
                          ].divide(SizedBox(width: 16)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(20),
                            shape: BoxShape.rectangle,
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'الإيرادات vs المصروفات',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontStyle,
                                              lineHeight: 1.35,
                                            ),
                                      ),
                                      Container(
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            width: 1,
                                          ),
                                        ),
                                        alignment: AlignmentDirectional(0, 0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12, 0, 12, 0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.check_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                size: 16,
                                              ),
                                              Text(
                                                'آخر 6 أشهر',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          fontSize: 14,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.38,
                                                        ),
                                              ),
                                            ].divide(SizedBox(width: 6)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 200,
                                    child: Container(
                                      height: 200,
                                      child: FlutterFlowBarChart(
                                        barData: [
                                          FFBarChartData(
                                            yData: ([
                                              120.0,
                                              150.0,
                                              110.0,
                                              180.0,
                                              210.0,
                                              190.0
                                            ])!,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          )
                                        ],
                                        xLabels: ([
                                          'يناير',
                                          'فبراير',
                                          'مارس',
                                          'أبريل',
                                          'مايو',
                                          'يونيو'
                                        ])!,
                                        barWidth: 16,
                                        barBorderRadius:
                                            BorderRadius.circular(4),
                                        groupSpace: 12,
                                        alignment:
                                            BarChartAlignment.spaceEvenly,
                                        chartStylingInfo: ChartStylingInfo(
                                          backgroundColor: Colors.transparent,
                                          showGrid: true,
                                          showBorder: false,
                                        ),
                                        axisBounds: AxisBounds(
                                          minY: 0,
                                          maxX: 5,
                                          maxY: 252,
                                        ),
                                        xAxisLabelInfo: AxisLabelInfo(
                                          showLabels: true,
                                          labelTextStyle: FlutterFlowTheme.of(
                                                  context)
                                              .bodySmall
                                              .override(
                                                font:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 10,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                                lineHeight: 1,
                                              ),
                                          reservedSize: 20,
                                        ),
                                        yAxisLabelInfo: AxisLabelInfo(
                                          reservedSize: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 16)),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'آخر العمليات',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                        lineHeight: 1.35,
                                      ),
                                ),
                                wrapWithModel(
                                  model: _model.buttonModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ButtonWidget(
                                    iconPresent: false,
                                    iconEndPresent: false,
                                    content: 'عرض الكل',
                                    variant: 'ghost',
                                    size: 'small',
                                    fullWidth: false,
                                    loading: false,
                                    disabled: false,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                wrapWithModel(
                                  model: _model.transactionItemModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: TransactionItemWidget(
                                    amount: '+150,000',
                                    amountColor:
                                        FlutterFlowTheme.of(context).success,
                                    category: 'دخل',
                                    date: '24 يونيو 2023',
                                    icon: Icon(
                                      Icons.work_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 24,
                                    ),
                                    title: 'إيداع راتب',
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.transactionItemModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: TransactionItemWidget(
                                    amount: '-12,500',
                                    amountColor:
                                        FlutterFlowTheme.of(context).error,
                                    category: 'تسوق',
                                    date: '23 يونيو 2023',
                                    icon: Icon(
                                      Icons.shopping_cart_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 24,
                                    ),
                                    title: 'سوبر ماركت السعيدة',
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.transactionItemModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: TransactionItemWidget(
                                    amount: '-8,200',
                                    amountColor:
                                        FlutterFlowTheme.of(context).error,
                                    category: 'خدمات',
                                    date: '22 يونيو 2023',
                                    icon: Icon(
                                      Icons.electric_bolt_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 24,
                                    ),
                                    title: 'فاتورة الكهرباء',
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.transactionItemModel4,
                                  updateCallback: () => safeSetState(() {}),
                                  child: TransactionItemWidget(
                                    amount: '+45,000',
                                    amountColor:
                                        FlutterFlowTheme.of(context).success,
                                    category: 'إضافي',
                                    date: '20 يونيو 2023',
                                    icon: Icon(
                                      Icons.swap_horiz_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 24,
                                    ),
                                    title: 'تحويل مالي',
                                  ),
                                ),
                              ].divide(SizedBox(height: 4)),
                            ),
                          ].divide(SizedBox(height: 16)),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            await launchURL(
                                'https://wa.meً، تفاصيل السند المالي بالريال اليمني');
                          },
                          text: 'مشاركة ',
                          options: FFButtonOptions(
                            height: 40,
                            padding:
                                EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                            iconPadding:
                                EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                            elevation: 0,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Container(
                          height: 80,
                          decoration: BoxDecoration(),
                        ),
                      ].divide(SizedBox(height: 24)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

