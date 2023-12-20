import 'dart:convert';

import 'package:bpe_smart_water_fountain/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          appBarTheme: AppBarTheme(color: Color(0xff181B31))),
      home: SplashScreen(),
    );
  }
}

class BLEScanner extends StatefulWidget {
  @override
  _BLEScannerState createState() => _BLEScannerState();
}

class _BLEScannerState extends State<BLEScanner> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isScanning = false;
  Set<String> uniqueDeviceNames = {};
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? monitoredCharacteristic;
  List<BluetoothService>? services;

  String characteristicData = "No Data";
  int TDS = 0;
  int waterTemp = 0;
  int airTemp = 0;
  String waterStatus = "No Data";
  int filterChangeRemaining = 0;
  String dateCycle = "dd/mm/yyyy";

  @override
  void initState() {
    super.initState();
  }

  void startScan() {
    uniqueDeviceNames.clear();
    setState(() {
      isScanning = true;
    });
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.name == "BPE Smart Water Fountain" &&
            uniqueDeviceNames.add(result.device.name)) {
          connectToDevice(result.device);
        }
      }
    });
  }

  void toggleConnectDisconnect() {
    if (connectedDevice != null) {
      disconnectFromDevice();
    } else {
      startScan();
    }
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        connectedDevice = device;
      });
      discoverServices(device);
    } catch (e) {
      print(e);
    }
  }

  void discoverServices(BluetoothDevice device) async {
    services = await device.discoverServices();
    services?.forEach((service) {
      service.characteristics.forEach((characteristic) {
        // Assuming you want to monitor a specific characteristic
        if (characteristic.uuid.toString() ==
            "94bedc82-1bc3-44a8-88bd-17318eb59a44") {
          monitorCharacteristic(characteristic);
        }
      });
    });
  }

  void monitorCharacteristic(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);
    characteristic.value.listen((value) {
      // Handle the received data
      if (value.isNotEmpty) {
        print('Received data: ${String.fromCharCodes(value)}');
        setState(() {
          List<String> parsedData = String.fromCharCodes(value).split('#');
          if (parsedData.length >= 3) {
            TDS = int.tryParse(parsedData[0]) ?? 0;
            waterTemp = int.tryParse(parsedData[1]) ?? 0;
            airTemp = int.tryParse(parsedData[2]) ?? 0;
            filterChangeRemaining = int.tryParse(parsedData[3]) ?? 0;
            waterStatus = parsedData[4];
          }
        });
      }
    });
    setState(() {
      monitoredCharacteristic = characteristic;
    });
  }

  void disconnectFromDevice() async {
    try {
      await connectedDevice?.disconnect();
      setState(() {
        connectedDevice = null;
        monitoredCharacteristic = null;
      });
    } catch (e) {
      print(e);
    }
  }

  void writeData(String data) async {
    // List<BluetoothService> services = await connectedDevice.discoverServices();
    services?.forEach((service) {
      service.characteristics.forEach((characteristic) {
        // Assuming you want to monitor a specific characteristic
        if (characteristic.uuid.toString() ==
            "94bedc82-1bc3-44a8-88bd-17318eb59a44") {
          List<int> bytes =
              utf8.encode(data); // Convert the string to UTF-8 bytes
          characteristic.write(bytes);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff2B3253),
        appBar: AppBar(
          title: Text("BPE Smart Water Fountain"),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Color(0xff181B31)),
              onPressed: () {
                toggleConnectDisconnect();
              },
              child: Text(connectedDevice != null ? 'Disconnect' : 'Connect'),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text("KONTOL"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GridItem(TDS, 'Water\nTDS', "ppm"),
                  GridItem(waterTemp, 'Water Temperature', "°C"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GridItem(airTemp, 'Air Temperature ', "°C"),
                  GridItem(filterChangeRemaining, 'Filter Replacement', "Days"),
                ],
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xff181B31),
                        borderRadius: BorderRadius.all(Radius.circular(7))),
                    height: 250,
                    padding: EdgeInsets.all(47),
                    margin: EdgeInsets.all(8),
                    // color: Color(0xff181B31),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Water Status",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            waterStatus,
                            softWrap: true,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xff181B31),
                        borderRadius: BorderRadius.all(Radius.circular(7))),
                    height: 250,
                    padding: EdgeInsets.all(45),
                    margin: EdgeInsets.all(8),
                    // color: Color(0xff181B31),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Change Filter",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 90,
                            child: TextFormField(
                              initialValue: dateCycle,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white))),
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "00/00/0000";
                                }
                                return null;
                              },
                              onChanged: (value) => dateCycle = value,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                print(dateCycle);
                                writeData(dateCycle);
                              },
                              child: Text("Apply"))
                        ]),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}

class GridItem extends StatelessWidget {
  final int number;
  final String title;
  final String units;

  GridItem(this.number, this.title, this.units);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: 180,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(40.0),
      // color: Color(0xff181B31),
      decoration: const BoxDecoration(
          color: Color(0xff181B31),
          borderRadius: BorderRadius.all(Radius.circular(7))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            number.toString(),
            style: TextStyle(
                color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 15),
          Text(
            units,
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          Container(
            width: 80,
            decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.white, width: 3))),
            child: SizedBox(
              height: 15,
            ),
          )
        ],
      ),
    );
  }
}
