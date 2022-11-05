import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:remote_control/widgets/oscilloscope_widget.dart';

const updateInterval = 50;
const timeInterval = 5.0;
const maxDataPoints = ((timeInterval * 1000) / updateInterval);

const telemetryService = "C700";
const readCharacteristic = "C701";
const writeCharacteristic = "C702";
const writeBytes = 3;
const readBytes = 8;

const bleCommandMax = 1000;
const bleCommandMin = -1000;

enum CmdMode {
  idle,
  run
}

class GraphDataModel extends ChangeNotifier {
  int _startTime = 0;
  double elapsedTime = 0;

  final _bleServices = <BluetoothService>[];
  BluetoothCharacteristic? _writeCharacteristic;

  final _bleWriteValues = ByteData(writeBytes);
  final _bleReadValues = ByteData(readBytes);

  bool _bleConnected = false;
  // bool _bleCmdUpdate = false;
  int _bleCommand = 0;
  CmdMode cmdMode = CmdMode.idle;

  int get bleCommand {
    return _bleCommand;
  }

  set bleCommand(value) {
    _bleCommand = value;
    notifyListeners();
  }

  final plotData = PlotData([
    PlotCurve('cmd', maxValue: 6000.0, minValue: -6000.0, color: Colors.red),
    PlotCurve('pos', maxValue: 3.14159, minValue: -3.14159, color: Colors.green),],
      maxSamples: maxDataPoints.toInt(),
      ySegments: 8,
      backgroundColor: Colors.black);

  GraphDataModel() {
    // initialize the start time and start the timer
    _startTime = DateTime.now().millisecondsSinceEpoch;
    Timer.periodic(const Duration(milliseconds: updateInterval), _timerCallback);
  }

  void _timerCallback(Timer t) {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    // find the elapsed time in seconds
    elapsedTime = (currentTime - _startTime).toDouble() / 1000.0;
    plotData.curves[0].value = _bleReadValues.getInt32(0).toDouble();
    plotData.curves[1].value = _bleReadValues.getFloat32(4);

    // uncommented for accelerometer control
    // if(_bleCmdUpdate && _bleConnected) {
    //   writeCmdValue();
    // }
    // _bleCmdUpdate = !_bleCmdUpdate;

    // final radians = (2.0 * pi * elapsedTime) / 10.0;
    // plotData.curves[0].value = sin(radians);
    // plotData.curves[1].value = cos(radians);
    plotData.updateSamples(elapsedTime);
    notifyListeners();
  }

  Future<void> connectBle(BluetoothDevice bleDevice) async {
    await bleDevice.connect();
    final services = await bleDevice.discoverServices();
    _bleServices.clear();
    
    for (var service in services) {
      if(_shortUUID(service.uuid) == telemetryService) {
        _bleServices.add(service);
      }
    }

    for (var ch in _bleServices.first.characteristics) {
      switch(_shortUUID(ch.uuid)) {

        case readCharacteristic:
          initReadCharacteristic(ch);
          break;

        case writeCharacteristic:
          _writeCharacteristic = ch;
          break;
      }
    }

    // uncomment for accelerometer control
    // accelerometerEvents.listen((event) {
    //   bleCommand = -(event.x * 200.0).toInt();
    // });
    _bleConnected = true;
  }

  Future<void> initReadCharacteristic(BluetoothCharacteristic ch) async {
    final bleReadCharacteristic = ch;
    await bleReadCharacteristic.setNotifyValue(true);
    bleReadCharacteristic.value.listen((values) {
      if(values.length == readBytes) {
        for(int i = 0; i < readBytes; i++) {
          _bleReadValues.setUint8(i, values[i]);
        }
      }
    });
  }

  void writeCmdMode() {
    _bleWriteValues.setInt8(0, (cmdMode.index + 1));
    _writeCharacteristic?.write(_bleWriteValues.buffer.asUint8List());
  }

  void writeCmdValue() {
     _bleWriteValues.setInt16(1, bleCommand);
    _writeCharacteristic?.write(_bleWriteValues.buffer.asUint8List());
  }

}

String _shortUUID(Guid uuid) {
  return uuid.toString().substring(4, 8).toUpperCase();
}
