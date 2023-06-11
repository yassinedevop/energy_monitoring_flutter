import 'dart:convert';

import 'package:http/http.dart' as http;

class PZEM {
  final int timeStamp;
  final double current;
  final double energy;
  final double frequency;
  final double power;
  final double powerFactor;
  final double voltage;
  int switchState;

  PZEM({
    this.current,
    this.energy,
    this.timeStamp,
    this.voltage,
    this.power,
    this.switchState,
    this.powerFactor,
    this.frequency,
  });
  factory PZEM.fromJson(Map<String, dynamic> json) {
    return PZEM(
        timeStamp: json['timeStamp'],
        current: json['current'],
        voltage: json['voltage'],
        power: json['power'],
        energy: json['energy'],
        frequency: json['frequency'],
        switchState: json['switchState'],
        powerFactor: json['pf']);
  }

  factory PZEM.zero() {
    return PZEM(
        timeStamp: 0,
        current: 0.0,
        voltage: 0.0,
        frequency: 0.0,
        power: 0.0,
        powerFactor: 0.0,
        switchState: 0,
        energy: 0.0);
  }
  String toJson() {
    return jsonEncode({
      'timeStamp': timeStamp,
      'current': current,
      'voltage': voltage,
      'power': power,
      'energy': energy,
      'frequency': frequency,
      'switchState': switchState,
      'pf': powerFactor
    });
  }

  static Future<PZEM> fetchData() async {
    final http.Response response = await http.get(Uri.parse(
        "https://pzem004t-esp12f-default-rtdb.europe-west1.firebasedatabase.app/pzem.json"));
    if (response.statusCode == 200) {
      return PZEM.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data from database');
    }
  }

  static Future<void> putData(PZEM pzem) async {
    final http.Response response = await http.put(
        Uri.parse(
            "https://pzem004t-esp12f-default-rtdb.europe-west1.firebasedatabase.app/pzem.json"),
        body: pzem.toJson());
    if (response.statusCode != 200) {
      throw Exception('Failed to update data to database');
    }
    return;
  }

  bool propsChanged(PZEM pzem) {
    if (pzem.current != current ||
        pzem.energy != energy ||
        pzem.frequency != frequency ||
        pzem.power != power ||
        pzem.powerFactor != powerFactor ||
        pzem.switchState != switchState ||
        pzem.voltage != voltage ||
        pzem.timeStamp != timeStamp) {
      return true;
    }
    return false;
  }
}
