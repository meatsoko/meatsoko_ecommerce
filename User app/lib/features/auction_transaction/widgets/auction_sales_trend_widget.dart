import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/controller/auction_transaction_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesTrendData {
  final String month;
  final double sales;

  const SalesTrendData({required this.month, required this.sales});
}

class SalesTrendWidget extends StatefulWidget {
  final String? title;

  const SalesTrendWidget({super.key, this.title});

  @override
  State<SalesTrendWidget> createState() => _SalesTrendWidgetState();
}

class _SalesTrendWidgetState extends State<SalesTrendWidget> {
  AuctionReportDateType _selectedType = AuctionReportDateType.allTime;
  AuctionReportDateType _appliedType = AuctionReportDateType.allTime;
  DateTime? _startDate;
  DateTime? _endDate;

  static const _options = [
    (type: AuctionReportDateType.allTime, label: 'All Time'),
    (type: AuctionReportDateType.year,    label: 'This Year'),
    (type: AuctionReportDateType.month,   label: 'This Month'),
    (type: AuctionReportDateType.week,    label: 'This Week'),
    (type: AuctionReportDateType.today,   label: 'Today'),
    (type: AuctionReportDateType.custom,  label: 'Custom Date'),
  ];

  static String _fmt(String raw) {
    final parts = raw.trim().split(' ');
    if (parts.length == 2) {
      final m = parts[0];
      final y = parts[1];
      final cap = m.isNotEmpty ? '${m[0].toUpperCase()}${m.substring(1).toLowerCase()}' : m;
      final yr = y.length >= 4 ? y.substring(2) : y;
      return "$cap'$yr";
    }
    return raw;
  }

  String get _startLabel => _startDate != null ? DateFormat('MM/dd/yyyy').format(_startDate!) : 'mm/dd/yyyy';
  String get _endLabel   => _endDate   != null ? DateFormat('MM/dd/yyyy').format(_endDate!)   : 'mm/dd/yyyy';

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _endDate ?? DateTime.now(),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  void _applyFilter() {
    String? startStr;
    String? endStr;
    if (_selectedType == AuctionReportDateType.custom) {
      if (_startDate == null || _endDate == null) return;
      startStr = DateFormat('yyyy-MM-dd').format(_startDate!);
      endStr   = DateFormat('yyyy-MM-dd').format(_endDate!);
    }
    setState(() => _appliedType = _selectedType);
    context.read<AuctionTransactionController>().getSalesReport(
      dateType: _selectedType,
      startDate: startStr,
      endDate: endStr,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final borderSide = BorderSide(color: primary.withValues(alpha: .4));
    final borderRadius = BorderRadius.circular(Dimensions.radiusDefault);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Text(
                    widget.title ?? getTranslated('sales_trend', context) ?? '',
                    style: titilliumBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Spacer(),

                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(border: Border.all(color: primary.withValues(alpha: .4)), borderRadius: borderRadius),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AuctionReportDateType>(
                        value: _selectedType,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: primary, size: 20),
                        style: titilliumRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                            _selectedType = v;
                            if (v != AuctionReportDateType.custom) {
                              _startDate = null;
                              _endDate = null;
                            }
                          });
                          }
                        },
                        items: _options.map((o) => DropdownMenuItem(
                          value: o.type,
                          child: Text(o.label, overflow: TextOverflow.ellipsis),
                        )).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _applyFilter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: borderRadius),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        elevation: 0,
                      ),
                      child: Text(
                        getTranslated('filter', context) ?? 'Filter',
                        style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              if (_selectedType == AuctionReportDateType.custom)
                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                  child: Row(
                    children: [
                      Expanded(child: _DateInput(label: _startLabel, onTap: _pickStart, borderSide: borderSide, borderRadius: borderRadius)),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(child: _DateInput(label: _endLabel, onTap: _pickEnd, borderSide: borderSide, borderRadius: borderRadius)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Consumer<AuctionTransactionController>(
            builder: (context, controller, _) {
              if (controller.isReportLoading) {
                return SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator(color: primary)),
                );
              }

              final trend = controller.salesReport?.salesTrend;
              if (trend == null || trend.labels.isEmpty) {
                return SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      getTranslated('no_data_found', context) ?? 'No data found',
                      style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  ),
                );
              }

              final List<SalesTrendData> display = List.generate(
                trend.labels.length,
                (i) => SalesTrendData(month: trend.labels[i], sales: trend.data[i]),
              );

              return SizedBox(
                height: 300,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    color: primary,
                    textStyle: titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).cardColor,
                    ),
                    format: 'point.x : point.y',
                  ),
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 0),
                    labelRotation: -90,
                    maximumLabels: _appliedType == AuctionReportDateType.month ? 31 : 12,
                    labelIntersectAction: AxisLabelIntersectAction.none,
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    labelStyle: titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    axisLabelFormatter: _appliedType == AuctionReportDateType.month
                        ? (AxisLabelRenderDetails details) {
                            final day = int.tryParse(details.text);
                            final show = day != null && (day == 1 || day % 5 == 0);
                            return ChartAxisLabel(
                              show ? details.text : '',
                              titilliumRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            );
                          }
                        : null,
                  ),
                  primaryYAxis: NumericAxis(
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                    majorGridLines: MajorGridLines(
                      width: 1,
                      color: Theme.of(context).hintColor.withValues(alpha: .3),
                      dashArray: const <double>[4, 4],
                    ),
                    labelStyle: titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    axisLabelFormatter: (AxisLabelRenderDetails details) {
                      final value = details.value.toDouble();
                      String label;
                      if (value >= 1000) {
                        final k = value / 1000;
                        label = '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}k';
                      } else {
                        label = value.toInt().toString();
                      }
                      return ChartAxisLabel(
                        label,
                        titilliumRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      );
                    },
                  ),
                  series: <CartesianSeries>[
                    SplineAreaSeries<SalesTrendData, String>(
                      dataSource: display,
                      xValueMapper: (d, _) => _fmt(d.month),
                      yValueMapper: (d, _) => d.sales,
                      color: primary.withValues(alpha: .1),
                      borderColor: primary,
                      borderWidth: 2,
                      splineType: SplineType.natural,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DateInput extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final BorderSide borderSide;
  final BorderRadius borderRadius;

  const _DateInput({
    required this.label,
    required this.onTap,
    required this.borderSide,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          border: Border.fromBorderSide(borderSide),
          borderRadius: borderRadius,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: titilliumRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 14, color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );
  }
}
