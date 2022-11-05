import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:remote_control/models/graph_data_model.dart';
import 'package:remote_control/widgets/ble_widgets.dart';
import 'package:remote_control/widgets/navigation_widget.dart';

class BlePage extends StatelessWidget {
  final String title;

  const BlePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Align(
        alignment: Alignment.topCenter,
        child: FindDevicesScreen(),
      ),
      drawer: NavigationDrawer(),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data ?? false) {
            return FloatingActionButton(
              child: const Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: const Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final graphDataModel = Provider.of<GraphDataModel>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          StreamBuilder<List<BluetoothDevice>>(
            stream: Stream.periodic(const Duration(seconds: 2))
                .asyncMap((_) => FlutterBlue.instance.connectedDevices),
            initialData: const [],
            builder: (c, snapshot) => Column(
              children: snapshot.data!
                  .map((d) => ListTile(
                        title: Text(d.name),
                        subtitle: Text(d.id.toString()),
                        trailing: StreamBuilder<BluetoothDeviceState>(
                          stream: d.state,
                          initialData: BluetoothDeviceState.disconnected,
                          builder: (c, snapshot) {
                            if (snapshot.data ==
                                BluetoothDeviceState.connected) {
                              return ElevatedButton(
                                child: const Text('OPEN'),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black),
                                  textStyle: MaterialStateProperty.all<
                                          TextStyle>(
                                      Theme.of(context).textTheme.bodyText2!),
                                ),
                                onPressed: () => {print("opened")},
                              );
                            }
                            return Text(snapshot.data.toString());
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
          StreamBuilder<List<ScanResult>>(
            stream: FlutterBlue.instance.scanResults,
            initialData: const [],
            builder: (c, snapshot) => Column(
              children: snapshot.data!
                  .map(
                    (r) => ScanResultTile(
                      result: r,
                      onTap: () async {
                        graphDataModel.connectBle(r.device);
                      },
                    ),
                  )
                  .toList()
                  .cast(),
            ),
          ),
        ],
      ),
    );
  }
}
