
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remote_control/definitions.dart';
import 'package:remote_control/models/screen_model.dart';
import 'package:remote_control/screens/ble_screen.dart';
import 'package:remote_control/screens/scope_screen.dart';

import 'models/graph_data_model.dart';

void main() => runApp(const GraphDataApp());

class GraphDataApp extends StatelessWidget {
  const GraphDataApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: Colors.black,
      primary: Colors.white,
      onPrimary: Colors.black,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScreenModel>(create: (context) => ScreenModel()),
        ChangeNotifierProvider<GraphDataModel>(
            create: (context) => GraphDataModel()),
      ],
      child: MaterialApp(
        title: 'Remote Control',
        theme: ThemeData(
          colorScheme: colorScheme,
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
