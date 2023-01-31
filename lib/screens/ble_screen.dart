import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:remote_control/definitions.dart';
import 'package:remote_control/models/graph_data_model.dart';
import 'package:remote_control/widgets/navigation_widget.dart';

class BlePage extends StatelessWidget {
  final String title;

  const BlePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final graphDataModel = Provider.of<GraphDataModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Align(
        alignment: Alignment.topCenter,
        child: FindDevicesScreen(),
      ),
      drawer: const CustomNavigationDrawer(),
      floatingActionButton: FloatingActionButton(
          child: Selector<GraphDataModel, bool>(
            selector: (_, selectorModel) => selectorModel.scanActive,
            builder: (context, scanActive, child) {
              return scanActive
                  ? const Icon(Icons.stop)
                  : const Icon(Icons.search);
            },
          ),
          onPressed: () {
            if (graphDataModel.scanActive) {
              graphDataModel.stopBleScan();
            } else {
              graphDataModel.startBleScan();
            }
          }),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final graphDataModel = Provider.of<GraphDataModel>(context, listen: false);

    return Selector<GraphDataModel, int>(
      selector: (_, selectorModel) => selectorModel.scannedDevices.length,
      builder: (context, listLength, child) {
        return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.all(5.0),
            itemCount: listLength,
            itemBuilder: (context, index) {
              return BleDeviceTile(
                  deviceName: graphDataModel.scannedDevices[index].name);
            });
      },
    );
  }
}

class BleDeviceTile extends StatelessWidget {
  const BleDeviceTile({
    Key? key,
    required this.deviceName,
  }) : super(key: key);

  final String deviceName;

  @override
  Widget build(BuildContext context) {
    final graphDataModel = Provider.of<GraphDataModel>(context, listen: false);

    final deviceNameText = Text(
      deviceName,
      style: const TextStyle(color: textColor, fontSize: standardFontSize),
    );

    final connectionStatusText =
        Selector<GraphDataModel, DeviceConnectionState>(
      selector: (_, selectorModel) => selectorModel.connectionState,
      builder: (context, _, child) {
        String status = (deviceName == graphDataModel.connectedDevice?.name)
            ? "status: ${graphDataModel.connectionState.name}"
            : "";
        return Text(
          status,
          style: const TextStyle(color: textColor, fontSize: standardFontSize),
        );
      },
    );

    final connectButton = ElevatedButton(
      child: Selector<GraphDataModel, DeviceConnectionState>(
        selector: (_, selectorModel) => selectorModel.connectionState,
        builder: (context, connectionState, child) {
          if ((deviceName == graphDataModel.connectedDevice?.name) &&
              connectionState == DeviceConnectionState.connected) {
            return const Text("disconnect");
          } else {
            return const Text("connect");
          }
        },
      ),
      onPressed: () {
        graphDataModel.stopBleScan();
        if (graphDataModel.connectionState ==
            DeviceConnectionState.disconnected) {
          graphDataModel.connectBle(deviceName);
        } else {
          graphDataModel.disconnectBle();
        }
      },
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Column(
                children: [
                  deviceNameText,
                  connectionStatusText,
                ],
              ),
              const Spacer(
                flex: 5,
              ),
              SizedBox(
                child: connectButton,
                width: 120,
              ),
            ],
          ),
        ),
        const Divider(thickness: 1.0),
      ],
    );
  }
}
