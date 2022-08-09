import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide LabelPlacement;
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:intl/intl.dart';

class Sync extends StatefulWidget {
  final data;

  Sync(this.data);

  @override
  State<Sync> createState() => _SyncState();
}

class _SyncState extends State<Sync> {
  List<_ChartData> chartData = [];
  List<_ChartData> chartDatatwo = [];
  List<_ChartData> chartDatathree = [];

  SfRangeValues? _values;
  RangeController? _rangeController;
  var hour_wise = true;

  @override
  void initState() {
    var utc = [], utc_full = [], acc = [], rri = [], steps = [];
    _values = SfRangeValues(DateTime.parse(widget.data['start_hex_datetime']),
        DateTime.parse(widget.data['end_hex_datetime']));
    _rangeController =RangeController(start: _values?.start, end: _values?.end);
    for (var i = 0; i < widget.data['utc_full'].length; i++) {
      utc_full.add(DateTime.parse(widget.data['utc_full'][i]));
      acc.add(widget.data['acc'][i]);
      rri.add(widget.data['rri'][i]);
    }
    for (var i = 0; i < widget.data['utc'].length; i++) {
      utc.add(DateTime.parse(widget.data['utc'][i]));
      steps.add(widget.data['steps'][i]);
    }
    for (int i = 0; i < widget.data['utc_full'].length; i++) {
      if (widget.data['rri'][i] != 0)
        chartData.add(_ChartData(utc_full[i], rri[i]));
    }
    for (int i = 0; i < widget.data['utc_full'].length; i++) {
      chartDatatwo.add(_ChartData(utc_full[i], acc[i]));
    }

    for (int i = 0; i < widget.data['utc'].length; i++) {
      chartDatathree.add(_ChartData(utc[i], steps[i]));
    }
    var start_time = DateTime.parse(widget.data['start_hex_datetime']);
    var end_time = DateTime.parse(widget.data['end_hex_datetime']);
    hour_wise = ((start_time.hour - end_time.hour) >= 2) ? true : false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Plots')),
        backgroundColor: Colors.white,
        leading: TextButton(
          onPressed: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back_outlined,
            color: Colors.green,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: SfRangeSelector(
                      activeColor: Colors.green,
                      min: _rangeController?.start,
                      max: _rangeController?.end,
                      showLabels: true,
                      interval: (hour_wise) ? 2 : 15,
                      dateFormat: DateFormat.jm(),
                      labelPlacement: LabelPlacement.onTicks,
                      dateIntervalType: (hour_wise)
                          ? DateIntervalType.hours
                          : DateIntervalType.minutes,
                      enableTooltip: true,
                      controller: _rangeController,
                      tooltipTextFormatterCallback:
                          (dynamic actualLabel, String formattedText) {
                        return DateFormat.jm().format(actualLabel);
                      },
                      child: Center(),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _rangeController?.start = _values?.start;
                      _rangeController?.end = _values?.end;
                    },
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    icon: Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            Expanded(
                flex: 2,
                child: Graph(title: 'RRI', datasource:chartData, units:'ms', range_controller:_rangeController)),
            Expanded(
                flex: 2,
                child: Graph(title: 'ACC', datasource: chartDatatwo, units: 'd m/s2', range_controller: _rangeController)),
            Expanded(
                flex: 2,
                child: Graph(title: 'STEPS', datasource:chartDatathree, range_controller: _rangeController)),
          ],
        ),
      ),
    );
  }
}

class Graph extends StatefulWidget {
  final title, datasource, units, range_controller;

  Graph({required this.title, required this.datasource, this.units, required this.range_controller});
  @override
  State<Graph> createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SfCartesianChart(
      enableAxisAnimation: true,
      legend:
          Legend(isVisible: true, overflowMode: LegendItemOverflowMode.scroll),
      primaryXAxis:
      DateTimeAxis(
          rangeController: widget.range_controller,
          visibleMinimum: widget.range_controller.start,
          visibleMaximum: widget.range_controller.end,
          dateFormat: DateFormat.Hms(),
          interval: 10,
          majorGridLines: const MajorGridLines(width: 1)),
      primaryYAxis: NumericAxis(
          title: AxisTitle(
              text: widget.units == null
                  ? '${widget.title}'
                  : '${widget.title} (${widget.units})',
              textStyle: TextStyle(fontSize: 12)),
          labelFormat: '{value}',
          axisLine: const AxisLine(width: 1),
          majorTickLines: const MajorTickLines(color: Colors.transparent)),
      series: <LineSeries<_ChartData, DateTime>>[
        LineSeries<_ChartData, DateTime>(
            animationDuration: 2500,
            dataSource: widget.datasource,
            xValueMapper: (_ChartData sales, _) => sales.x,
            yValueMapper: (_ChartData sales, _) => sales.y,
            width: 2,
            name: widget.title,
            color: Colors.green),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    ));
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final DateTime x;
  final int y;
}
