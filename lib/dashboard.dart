import 'dart:async';

import 'package:energy_monitoring_azura/model/pzem.dart';
import 'package:energy_monitoring_azura/widgets/azura_gauge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MyDashboard extends StatefulWidget {
  MyDashboard({
    Key key,
    @required this.pzem,
  }) : super(key: key);

  PZEM pzem;

  @override
  State<MyDashboard> createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  Timer timer;
  PZEM oldpzem = PZEM.zero();
  Future<void> updateData() async {
    var pzem = await PZEM.fetchData();
    if (widget.pzem.propsChanged(pzem)) {
      setState(() {
        oldpzem = widget.pzem;
        widget.pzem = pzem;
      });
    }
  }

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await updateData();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "last update :  ${DateTime.fromMillisecondsSinceEpoch(widget.pzem.timeStamp * 1000).toString()}",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  .copyWith(color: Colors.white),
            ),
          ),
        );
        return await updateData();
      },
      child: GridView.custom(
        gridDelegate: SliverQuiltedGridDelegate(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          repeatPattern: QuiltedGridRepeatPattern.inverted,
          pattern: [
            const QuiltedGridTile(2, 2),
            const QuiltedGridTile(1, 1),
            const QuiltedGridTile(1, 1),
            const QuiltedGridTile(1, 2),
            const QuiltedGridTile(2, 2)
          ],
        ),
        childrenDelegate: SliverChildListDelegate(
          [
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 2,
              child: AzuraGauge(
                initialValue: oldpzem.voltage,
                value: widget.pzem.voltage,
                maxValue: 260,
                unit: "V",
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 1,
              child: AzuraGauge(
                initialValue: oldpzem.current,
                value: widget.pzem.current,
                maxValue: 10,
                unit: "A",
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: AzuraGauge(
                initialValue: oldpzem.powerFactor,
                value: widget.pzem.powerFactor,
                maxValue: 1.0,
                arcDeg: 360,
                unit: "%",
              ),
            ),
            StaggeredGridTile.count(
                crossAxisCellCount: 1,
                mainAxisCellCount: 1,
                child: AzuraGauge(
                  initialValue: oldpzem.frequency,
                  value: widget.pzem.frequency,
                  maxValue: 60,
                  unit: "Hz",
                )),
          ],
        ),
      ),
    );
  }
}
