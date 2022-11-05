import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final scopeRoute = '/';
final bleRoute = '/ble';

class NavigationDrawer extends StatelessWidget {
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
              'BLE',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, bleRoute);
            },
          ),
          ListTile(
            title: Text(
              'SCOPE',
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
