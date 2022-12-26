import 'package:flutter/material.dart';

import '../definitions.dart';

const scopeRoute = '/';
const bleRoute = '/ble';

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

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
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
          ListTile(
            title: Text(
              ScreenNames.connect.toUpperCase(),
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, bleRoute);
            },
          ),
          ListTile(
            title: Text(
              ScreenNames.command.toUpperCase(),
              style: Theme.of(context).textTheme.bodyText1,
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
