import 'dart:async';
import 'package:energy_monitoring_azura/model/pzem.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class RealTimeChart extends StatefulWidget {
  final double power;

  const RealTimeChart({Key key, this.power}) : super(key: key);
  @override
  _RealTimeChartState createState() => _RealTimeChartState();
}

class _RealTimeChartState extends State<RealTimeChart> {
  Timer timer;
  int count = 0;
  int yValue;
  List<_ChartData> chartData = <_ChartData>[];
  ChartSeriesController seriesController;
  StreamController streamController =
      StreamController<List<_ChartData>>.broadcast();
  StreamController dataStreamController = StreamController<int>.broadcast();

  StreamSink<int> get dataStreamSink => dataStreamController.sink;
  Stream<int> get dataStream => dataStreamController.stream;
  StreamSink<List<_ChartData>> get streamSink => streamController.sink;
  Stream<List<_ChartData>> get stream => streamController.stream;

  Future<void> _updateData() async {
    var pzem = await PZEM.fetchData();
    yValue = pzem.power.toInt();

    dataStreamSink.add(yValue);
  }

  Future<void> _updateDataSource(Timer timer) async {
    if (count >= 59) {
      count = 0;
    }
    await _updateData();
    chartData.add(_ChartData(DateTime.now(), yValue));

    if (chartData.length == 20) {
      chartData.removeAt(0);
    }
    streamSink.add(chartData);

    count = count + 1;
  }

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _updateDataSource(timer);
    });
    super.initState();
  }

  @override
  void dispose() {
    streamController.close();
    dataStreamController.close();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(color: Colors.transparent)),
        elevation: 4.0,
        child: Container(
            padding: const EdgeInsets.all(16.0), child: _showChart()));
  }

  Widget _showChart() {
    return StreamBuilder(
        stream: dataStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError) {
            return StreamBuilder(
                stream: stream,
                builder: (context, snapshot) {
                  Widget widget;
                  if (snapshot.hasData && !snapshot.hasError) {
                    widget = SfCartesianChart(
                        title: ChartTitle(
                            text: "Power Chart",
                            textStyle:
                                Theme.of(context).textTheme.headlineMedium),
                        primaryYAxis: NumericAxis(minimum: 0, maximum: 300),
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          shouldAlwaysShow: true,
                          header: "Power",
                          duration: 4.0,
                        ),
                        primaryXAxis:
                            DateTimeAxis(dateFormat: DateFormat.Hms()),
                        series: <LineSeries<_ChartData, DateTime>>[
                          LineSeries<_ChartData, DateTime>(
                              onRendererCreated:
                                  (ChartSeriesController controller) {
                                seriesController = controller;
                              },
                              animationDuration: 0,
                              dataSource: chartData,
                              xValueMapper: (_ChartData data, _) => data.x,
                              yValueMapper: (_ChartData data, _) => data.y1)
                        ]);
                  } else {
                    widget = const Center(child: CircularProgressIndicator());
                  }

                  return widget;
                });
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

class _ChartData {
  _ChartData(this.x, this.y1);
  final DateTime x;
  final int y1;
}
