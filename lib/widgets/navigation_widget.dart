import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remote_control/models/screen_model.dart';

import '../definitions.dart';

class CustomNavigationDrawer extends StatelessWidget {
  const CustomNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenModel = Provider.of<ScreenModel>(context, listen: false);

    return Selector<ScreenModel, int>(
        selector: (_, selectorModel) => selectorModel.screenIndex,
        builder: (context, screenIndex, child) {
          return NavigationDrawer(
            indicatorColor: Theme.of(context).focusColor,
            onDestinationSelected: (int index) {
              screenModel.screenIndex = index;
              if(index < routeData.length) {
                Navigator.pushReplacementNamed(context, routeData[index].route);
              }
            },
            selectedIndex: screenIndex,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 80, 16, 30),
                child: Text(
                  'Navigation',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              NavigationDrawerDestination(
                icon: const Icon(Icons.bluetooth),
                label: Text(connectRoute.name),
              ),
              NavigationDrawerDestination(
                  icon: const Icon(Icons.auto_graph),
                  label: Text(controlRoute.name)),
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
                child: Divider(),
              ),
            ],
          );
        });
  }
}

/*
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
      ),*/
