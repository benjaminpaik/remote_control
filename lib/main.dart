import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remote_control/screens/ble_screen.dart';
import 'package:remote_control/screens/scope_screen.dart';
import 'package:remote_control/widgets/navigation_widget.dart';

import 'models/graph_data_model.dart';

void main() => runApp(const GraphDataApp());

class GraphDataApp extends StatelessWidget {
  const GraphDataApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GraphDataModel>(
            create: (context) => GraphDataModel()),
      ],
      child: MaterialApp(
        title: 'Remote Control',
        theme: ThemeData(
          primaryColor: Colors.blue,
          textTheme: const TextTheme(
            headline1: TextStyle(fontSize: 30.0, fontWeight: FontWeight.normal, color: Colors.white),
            bodyText1: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black),
            bodyText2: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.white),
          ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.lightBlue),
        ),
        initialRoute: scopeRoute,
        routes: {
          scopeRoute: (context) => const ScopePage(title: 'SCOPE',),
          bleRoute: (context) => const BlePage(title: 'BLE',),
        },
      ),
    );
  }
}
