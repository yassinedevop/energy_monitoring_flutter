import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';

class AzuraGauge extends StatelessWidget {
  const AzuraGauge(
      {Key key,
      @required this.initialValue,
      @required this.value,
      @required this.unit,
      this.arcDeg = 260,
      @required this.maxValue})
      : super(key: key);
  final double value;
  final String unit;
  final double maxValue;
  final double arcDeg;
  final double initialValue;
  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(color: Colors.transparent)),
        elevation: 4.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: AnimatedRadialGauge(
            initialValue: initialValue,

            /// The animation duration.
            duration: const Duration(seconds: 4),
            curve: Curves.easeInOutExpo,

            /// Gauge value.
            value: value,
            progressBar: GaugeRoundedProgressBar(
              placement: GaugeProgressPlacement.over,
              gradient: GaugeAxisGradient(
                  tileMode: TileMode.clamp,
                  colorStops: const [0.2, 0.5, 0.8, 0.95],
                  colors: arcDeg > 350
                      ? [
                          const Color.fromARGB(255, 99, 187, 104),
                          const Color.fromARGB(255, 54, 230, 0),
                          Colors.amber,
                          Colors.redAccent
                        ].reversed.toList()
                      : [
                          const Color.fromARGB(255, 99, 187, 104),
                          const Color.fromARGB(255, 54, 230, 0),
                          Colors.amber,
                          Colors.redAccent
                        ]),
            ),

            axis: GaugeAxis(
              min: 0,
              max: maxValue,

              degrees: arcDeg,

              style: const GaugeAxisStyle(
                segmentSpacing: 10.0,
                thickness: 16.0,
                background: Color(0xFFDFE2EC),
                blendColors: true,
              ),

              pointer: NeedlePointer(
                  position: const GaugePointerPosition.surface(),
                  size: const Size(16, 16),
                  borderRadius: 16,
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0)),

              /// Define the pointer that will indicate the progress.
            ),
            builder: (context, child, value) => RadialGaugeLabel(
              labelProvider: GaugeLabelProvider.map(
                  toLabel: (va) => va.toStringAsFixed(2) + unit),
              value: value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));
  }
}
