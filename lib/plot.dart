import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
  @override
  void initState() {

    var utc=[],utc_full=[],acc=[],rri=[],steps=[];
    for(var i=0;i<widget.data['utc_full'].length;i++)
    {
      utc_full.add(DateTime.parse(widget.data['utc_full'][i]));
      acc.add(widget.data['acc'][i]);
      rri.add(widget.data['rri'][i]);
    }
    for(var i=0;i<widget.data['utc'].length;i++)
    {
      utc.add(DateTime.parse(widget.data['utc'][i]));
      steps.add(widget.data['steps'][i]);
    }
    for (int i = 0; i < widget.data['utc_full'].length; i++) {
      if (widget.data['rri'][i] != 0)
        chartData.add(_ChartData(utc_full[i],rri[i]));
    }
    for (int i = 0; i < widget.data['utc_full'].length ; i++) {
        chartDatatwo.add(_ChartData(utc_full[i], acc[i]));
    }

    for (int i = 0; i < widget.data['utc'].length ; i++) {
      chartDatathree.add(_ChartData(utc[i],steps[i]));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Graph('RRI',chartData,'ms')),
          Expanded(child: Graph('ACC',chartDatatwo,'d m/s2')),
          Expanded(child: Graph('STEPS',chartDatathree,'')),
        ],
      ),
    );
  }
}

class Graph extends StatelessWidget {
  final  title,datasource,units;
  Graph(this.title,this.datasource,this.units);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SfCartesianChart(
          enableAxisAnimation: true,
          plotAreaBorderWidth: 0,
          title: ChartTitle(text:title),
          legend: Legend(
              isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
          primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat.Hm(),
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              interval:5,
              majorGridLines: const MajorGridLines(width: 1)),
          primaryYAxis: NumericAxis(
              labelFormat: '{value}$units',
              axisLine: const AxisLine(width: 1),
              majorTickLines:
              const MajorTickLines(color: Colors.transparent)),
          series: <LineSeries<_ChartData, DateTime>>[
            LineSeries<_ChartData, DateTime>(
              animationDuration: 2500,
              dataSource: datasource,
              xValueMapper: (_ChartData sales, _) =>sales.x,
              yValueMapper: (_ChartData sales, _) => sales.y,
              width:  2,
              name: title,
              color: Colors.green
            ),
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
