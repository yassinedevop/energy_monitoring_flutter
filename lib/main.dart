import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:energy_monitoring_azura/dashboard.dart';
import 'package:energy_monitoring_azura/widgets/realtime_chart.dart';
import 'package:flutter/material.dart';

import 'package:energy_monitoring_azura/model/pzem.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Energy Monitoring',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: EasySplashScreen(
            logo: Image.asset('assets/icons/logo_ensa.png'),
            navigator:
                const DefaultTabController(length: 3, child: MyHomePage())));
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
            title: const Text("Energy Monitoring Azura"),
            bottom: const TabBar(tabs: [
              Tab(
                icon: Icon(Icons.dashboard),
                text: "Dashboard",
              ),
              Tab(
                icon: Icon(Icons.bar_chart),
                text: "Power Chart",
              ),
              Tab(
                icon: Icon(Icons.settings),
                text: "Relay Control",
              )
            ])),
        body: FutureBuilder<PZEM>(
            future: PZEM.fetchData(),
            builder: (context, snapshot) {
              return snapshot.data is! PZEM
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(children: [
                      MyDashboard(pzem: snapshot.data),
                      Center(
                        child: RealTimeChart(power: snapshot.data.power),
                      ),
                      RelayController(switchState: snapshot.data.switchState)
                    ]);
            }));
  }
}

class RelayController extends StatefulWidget {
  final int switchState;
  const RelayController({
    Key key,
    @required this.switchState,
  }) : super(key: key);

  @override
  State<RelayController> createState() => _RelayControllerState();
}

const undefined = -1;

class _RelayControllerState extends State<RelayController> {
  int _isOn = undefined;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PZEM.fetchData(),
        builder: (context, snapshot) {
          if (_isOn == undefined &&
              snapshot.connectionState == ConnectionState.done) {
            _isOn = snapshot.data.switchState;
          }
          return Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                  color: _isOn == 1 ? Colors.white : Colors.grey[300],
                  shape: BoxShape.circle),
              width: _isOn == 1 ? 100 : 80,
              height: _isOn == 1 ? 100 : 80,
              child: IconButton(
                icon: Icon(
                  _isOn == 1
                      ? Icons.light_mode_rounded
                      : Icons.light_mode_outlined,
                  color: _isOn == 1 ? Colors.amber : Colors.grey,
                ),
                onPressed: () async {
                  setState(() {
                    if (_isOn == 0) {
                      _isOn = 1;
                    } else if (_isOn == 1) {
                      _isOn = 0;
                    }
                  });
                  await PZEM.fetchData().then((value) async {
                    value.switchState = (_isOn == 1 ? 1 : 0);
                    await PZEM.putData(value);
                  });
                },
              ),
            ),
          );
        });
  }
}
