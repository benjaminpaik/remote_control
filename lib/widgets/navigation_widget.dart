import 'package:flutter/material.dart';

import '../definitions.dart';

const scopeRoute = '/';
const bleRoute = '/ble';

class CustomNavigationDrawer extends StatelessWidget {
  const CustomNavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Text(
              'Menu',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          ListTile(
            title: Text(
              ScreenNames.connect.toUpperCase(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, bleRoute);
            },
          ),
          ListTile(
            title: Text(
              ScreenNames.command.toUpperCase(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, scopeRoute);
            },
          ),
        ],
      ),
    );
  }
}
