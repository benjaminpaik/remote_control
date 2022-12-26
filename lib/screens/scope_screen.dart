import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remote_control/models/graph_data_model.dart';
import 'package:remote_control/widgets/navigation_widget.dart';
import 'package:remote_control/widgets/oscilloscope_widget.dart';

import '../definitions.dart';

class ScopePage extends StatelessWidget {
  final String title;

  const ScopePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenOrientation = MediaQuery.of(context).orientation;
    final portrait = (screenOrientation == Orientation.portrait);

    final children = <Widget>[
      const OscilloscopePlots(),
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: OscilloscopeControls(portrait),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const NavigationDrawer(),
      body: portrait
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: children,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: children,
            ),
    );
  }
}

class OscilloscopeControls extends StatelessWidget {
  final bool portrait;

  const OscilloscopeControls(this.portrait, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final graphDataModel = Provider.of<GraphDataModel>(context, listen: false);

    final cmdScrollBar = Selector<GraphDataModel, int>(
        selector: (_, selectorModel) => selectorModel.bleCommand,
        builder: (context, bleCommand, child) {
          return RotatedBox(
            quarterTurns: portrait ? 0 : -1,
            child: Slider(
              onChanged: (value) {
                graphDataModel.bleCommand = value.round();
              },
              onChangeEnd: (value) {
                graphDataModel.writeCmdValue();
              },
              min: Command.min.toDouble(),
              max: Command.max.toDouble(),
              divisions: (Command.max - Command.min),
              value: bleCommand.toDouble(),
              label: bleCommand.toString(),
              activeColor: Colors.black,
              inactiveColor: Colors.grey,
            ),
          );
        });

    final cmdModeMenu = Selector<GraphDataModel, CmdMode>(
        selector: (_, selectorModel) => selectorModel.cmdMode,
        builder: (context, cmdMode, child) {
          return DropdownButton<CmdMode>(
            value: graphDataModel.cmdMode,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.grey),
            onChanged: (CmdMode? newValue) {
              graphDataModel.cmdMode = newValue ?? CmdMode.idle;
              graphDataModel.writeCmdMode();
            },
            items:
                CmdMode.values.map<DropdownMenuItem<CmdMode>>((CmdMode mode) {
              return DropdownMenuItem<CmdMode>(
                value: mode,
                child: Text(mode.toString().split('.').last),
              );
            }).toList(),
          );
        });

    final stateControls = Row(
      children: [
        Selector<GraphDataModel, String>(
          selector: (_, selectorModel) => selectorModel.plotData.selectedState,
          builder: (context, selectedState, child) {
            return DropdownButton<String>(
              value: selectedState,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.grey),
              onChanged: (String? newValue) {
                graphDataModel.plotData.selectedState = newValue!;
              },
              items: graphDataModel.plotData.curves
                  .map<DropdownMenuItem<String>>((PlotCurve curve) {
                return DropdownMenuItem<String>(
                  value: curve.name,
                  child: Text(curve.name),
                );
              }).toList(),
            );
          },
        ),
        Selector<GraphDataModel, bool>(
            selector: (_, selectorModel) =>
                selectorModel.plotData.displaySelected,
            builder: (context, selectedState, child) {
              return Checkbox(
                  value: graphDataModel.plotData.displaySelected,
                  onChanged: (value) {
                    graphDataModel.plotData.displaySelected = value!;
                  });
            })
      ],
    );

    return portrait
        ? Column(
            children: [
              cmdScrollBar,
              Row(
                children: [
                  stateControls,
                  const Spacer(),
                  cmdModeMenu,
                ],
              ),
            ],
          )
        : Column(children: [
            stateControls,
            Expanded(child: cmdScrollBar),
            cmdModeMenu,
          ]);
  }
}

class OscilloscopePlots extends StatelessWidget {

  const OscilloscopePlots({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final graphDataModel = Provider.of<GraphDataModel>(context, listen: false);
    return Expanded(
      child: Selector<GraphDataModel, double>(
        selector: (_, selectorModel) => selectorModel.elapsedTime,
        builder: (context, selectorTuple, child) {
          return Oscilloscope(key: key, plotData: graphDataModel.plotData);
        },
      ),
    );
  }
}
