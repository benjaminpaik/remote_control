import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:remote_control/definitions.dart';
import 'package:remote_control/widgets/oscilloscope_widget.dart';
import 'package:permission_handler/permission_handler.dart';

const updateInterval = 50;
const timeInterval = 5.0;
const maxDataPoints = ((timeInterval * 1000) / updateInterval);

enum CmdMode { idle, run }

class GraphDataModel extends ChangeNotifier {
  int _startTime = 0;
  double _elapsedTime = 0;

  final _ble = FlutterReactiveBle();
  final _bleWriteValues = ByteData(BleSettings.writeBytes);
  final _bleReadValues = ByteData(BleSettings.readBytes);

  StreamSubscription? _scanSubscription;
  final _devices = <DiscoveredDevice>[];

  DiscoveredDevice? _connectedDevice;
  StreamSubscription<ConnectionStateUpdate>? _deviceSubscription;
  QualifiedCharacteristic? _writeCharacteristic;
  QualifiedCharacteristic? _readCharacteristic;

  int _bleCommand = 0;
  CmdMode cmdMode = CmdMode.idle;
  DeviceConnectionState _connectionState = DeviceConnectionState.disconnected;

  DiscoveredDevice? get connectedDevice {
    return _connectedDevice;
  }

  double get elapsedTime {
    return _elapsedTime;
  }

  int get bleCommand {
    return _bleCommand;
  }

  set bleCommand(value) {
    _bleCommand = value;
    notifyListeners();
  }

  final plotData = PlotData([
    PlotCurve('cmd', maxValue: 6000.0, minValue: -6000.0, color: Colors.red),
    PlotCurve('pos',
        maxValue: 3.14159, minValue: -3.14159, color: Colors.green),
  ],
      maxSamples: maxDataPoints.toInt(),
      ySegments: 8,
      backgroundColor: Colors.black);

  GraphDataModel() {
    // initialize the start time and start the timer
    _startTime = DateTime.now().millisecondsSinceEpoch;
    Timer.periodic(
        const Duration(milliseconds: updateInterval), _timerCallback);
  }

  void _timerCallback(Timer t) {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    // find the elapsed time in seconds
    _elapsedTime = (currentTime - _startTime).toDouble() / 1000.0;
    plotData.curves[0].value = _bleReadValues.getInt32(0).toDouble();
    plotData.curves[1].value = _bleReadValues.getFloat32(4);

    // final radians = (2.0 * pi * elapsedTime) / 10.0;
    // plotData.curves[0].value = sin(radians);
    // plotData.curves[1].value = cos(radians);
    plotData.updateSamples(elapsedTime);
    notifyListeners();
  }

  Future<bool> getPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
      ].request();

      if (statuses.values.where((e) => e.isGranted).length == statuses.length) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  void startBleScan() async {
    if (await getPermissions()) {
      _devices.clear();
      _scanSubscription?.cancel();
      _scanSubscription =
          _ble.scanForDevices(withServices: []).listen((device) {
        if (device.name.isNotEmpty) {
          final knownDeviceIndex =
              _devices.indexWhere((d) => d.id == device.id);
          if (knownDeviceIndex >= 0) {
            _devices[knownDeviceIndex] = device;
          } else {
            _devices.add(device);
            notifyListeners();
          }
        }
      }, onError: (Object e) => print('Device scan fails with error: $e'));
    }
  }

  Future<void> stopBleScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  List<DiscoveredDevice> get scannedDevices {
    return _devices;
  }

  bool get scanActive {
    return (_scanSubscription != null);
  }

  DeviceConnectionState get connectionState {
    return _connectionState;
  }

  Future<void> connectBle(String name) async {
    final bleDevice = _devices.where((element) => element.name.contains(name));

    if (bleDevice.isNotEmpty) {
      _connectedDevice = bleDevice.first;
      _deviceSubscription = _ble.connectToDevice(
        id: _connectedDevice!.id,
        connectionTimeout: const Duration(seconds: 10),
      ).listen((connectionStateUpdate) {

        _connectionState = connectionStateUpdate.connectionState;

        if (connectionStateUpdate.connectionState ==
            DeviceConnectionState.connected) {
          _ble.discoverServices(_connectedDevice!.id).then((services) {
            for (final service in services) {
              if (_shortUUID(service.serviceId.toString()) ==
                  BleSettings.customServiceUuid) {
                for (final characteristic in service.characteristicIds) {
                  if (_writeCharacteristic == null &&
                      _shortUUID(characteristic.toString()) ==
                          BleSettings.writeCharacteristicUuid) {
                    _writeCharacteristic = QualifiedCharacteristic(
                        characteristicId: characteristic,
                        serviceId: service.serviceId,
                        deviceId: _connectedDevice!.id);
                  }
                  if (_readCharacteristic == null &&
                      _shortUUID(characteristic.toString()) ==
                          BleSettings.readCharacteristicUuid) {
                    _readCharacteristic = QualifiedCharacteristic(
                        characteristicId: characteristic,
                        serviceId: service.serviceId,
                        deviceId: _connectedDevice!.id);

                    _ble.subscribeToCharacteristic(_readCharacteristic!).listen(
                        (data) {
                      if (data.length == BleSettings.readBytes) {
                        for (int i = 0; i < BleSettings.readBytes; i++) {
                          _bleReadValues.setUint8(i, data[i]);
                        }
                      }
                    }, onError: (dynamic error) {
                      print("error: $error}");
                    });
                  }
                }
                break;
              }
            }
          });
        }
      }, onError: (Object error) {
        print("connection error: ${error.toString()}");
      });
    }
  }

  void disconnectBle() {
    _deviceSubscription?.cancel();
    _connectionState = DeviceConnectionState.disconnected;
    _writeCharacteristic = null;
    _readCharacteristic = null;
    _connectedDevice = null;
  }

  void writeCmdMode() {
    _bleWriteValues.setInt8(0, (cmdMode.index + 1));
    if (_writeCharacteristic != null) {
      _ble.writeCharacteristicWithoutResponse(_writeCharacteristic!,
          value: _bleWriteValues.buffer.asUint8List());
    }
  }

  void writeCmdValue() {
    _bleWriteValues.setInt16(1, bleCommand);
    if (_writeCharacteristic != null) {
      _ble.writeCharacteristicWithResponse(_writeCharacteristic!,
          value: _bleWriteValues.buffer.asUint8List());
    }
  }
}

String _shortUUID(String uuid) {
  return uuid.substring(4, 8).toUpperCase();
}
