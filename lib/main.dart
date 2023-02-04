import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remote_control/definitions.dart';
import 'package:remote_control/models/screen_model.dart';
import 'package:remote_control/screens/ble_screen.dart';
import 'package:remote_control/screens/scope_screen.dart';

import 'models/graph_data_model.dart';

void main() => runApp(const GraphDataApp());

class GraphDataApp extends StatelessWidget {
  const GraphDataApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScreenModel>(
            create: (context) => ScreenModel()),
        ChangeNotifierProvider<GraphDataModel>(
            create: (context) => GraphDataModel()),
      ],
      child: MaterialApp(
        title: 'Remote Control',
        theme: ThemeData(
          primaryColor: Colors.blue,
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 30.0, fontWeight: FontWeight.normal, color: Colors.white),
            bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.black),
            bodyMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.white),
          ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.lightBlue),
        ),
        initialRoute: controlRoute.route,
        routes: {
          controlRoute.route: (context) => ScopePage(title: controlRoute.name),
          connectRoute.route: (context) => BlePage(title: connectRoute.name),
        },
      ),
    );
  }
}
