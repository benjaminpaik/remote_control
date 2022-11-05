import 'dart:math';
import 'package:flutter/material.dart';

const int _minPoints = 2;

class PlotData {
  final _xTickTimes = <double>[];
  final List<PlotCurve> curves;
  final int maxSamples;
  int _selectedIndex = 0;

  Color backgroundColor;
  int xSegments;
  int ySegments;
  int tickWidth;
  double tickLength;
  bool freezePlots = false;

  TextPainter textPainter =
      TextPainter(textAlign: TextAlign.left, textDirection: TextDirection.ltr);

  PlotData(this.curves,
      {this.backgroundColor = Colors.white,
      this.maxSamples = 100,
      this.xSegments = 4,
      this.ySegments = 4,
      this.tickWidth = 1,
      this.tickLength = 4});

  set displaySelected(bool displayed) {
    curves[_selectedIndex].displayed = displayed;
  }

  bool get displaySelected {
    return curves[_selectedIndex].displayed;
  }

  set selectedState(String name) {
    final curveNames = curves.map((e) => e._name).toList();
    final curveIndex = curveNames.indexOf(name);

    if (curveIndex >= 0) {
      _selectedIndex = curveIndex;
    }
  }

  String get selectedState {
    return curves[_selectedIndex].name;
  }

  void resetSamples() {
    for (var element in curves) {
      element._resetSamples();
    }
  }

  void updateSamples(double time) {
    for (var element in curves) {
      element._updateSample(maxSamples, time);
    }
  }

  void saveSamples() {
    for (var element in curves) {
      element._saveSamples();
    }
  }

  void saveXTickTimes(Size size, PlotCurve state) {
    _xTickTimes.clear();
    for (int i = 1; i <= xSegments; i++) {
      final xTickIncrement = size.width / xSegments;
      final xTick = xTickIncrement * i;
      _xTickTimes.add(state._getTickTime(size.width, xTick));
    }
  }
}

class PlotCurve {
  final String _name;
  final _points = <Point<double>>[];
  var _savedPoints = <Point<double>>[];
  double maxValue;
  double minValue;
  double dataRange = 2;
  double _timeSpan = 1.0;
  double _timeReference = 0.0;

  double _value = 0;
  bool displayed = true;

  final Paint _paint = Paint()
    ..color = Colors.red
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  PlotCurve(this._name,
      {this.maxValue = 1, this.minValue = -1, Color color = Colors.red}) {
    dataRange = maxValue - minValue;
    _paint.color = color;
  }

  set color(Color color) {
    _paint.color = color;
  }

  set strokeWidth(double width) {
    _paint.strokeWidth = width;
  }

  set value(double value) {
    _value = value;
  }

  String get name {
    return _name;
  }

  void updateTimeSpan(List<Point<double>> points) {
    _timeReference = points.first.x;
    _timeSpan = points.last.x - _timeReference;
  }

  double _getTickTime(double width, double x) {
    return ((x / width) * _timeSpan) + _timeReference;
  }

  double _getTickValue(double height, double y) {
    return (((height - y) / height) * dataRange) + minValue;
  }

  double _getScaledTime(double width, double time) {
    return ((time - _timeReference) / _timeSpan) * width;
  }

  double _getScaledValue(double height, double value) {
    return ((maxValue - value) / (maxValue - minValue)) * height;
  }

  void _updateSample(int maxSamples, double time) {
    _points.add(Point<double>(time, _value));
    if (_points.length > maxSamples) {
      _points.removeAt(0);
    }
  }

  void _saveSamples() {
    _savedPoints = List<Point<double>>.from(_points);
  }

  void _resetSamples() {
    _points.clear();
  }
}

class Oscilloscope extends StatefulWidget {
  final PlotData plotData;

  const Oscilloscope({required key, required this.plotData}) : super(key: key);

  @override
  _OscilloscopeState createState() => _OscilloscopeState();
}

class _OscilloscopeState extends State<Oscilloscope>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails _) {
        widget.plotData.freezePlots = !widget.plotData.freezePlots;
        widget.plotData.saveSamples();
      },
      child: Container(
          color: widget.plotData.backgroundColor,
          child: CustomPaint(
            painter: _PlotPainter(widget.plotData),
            child: Container(),
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.plotData.resetSamples();
    }
  }
}

class _PlotPainter extends CustomPainter {
  final PlotData _plotData;

  _PlotPainter(this._plotData);

  void generateXTicks(Canvas canvas, Path path, Size size, PlotCurve state) {
    final xTickIncrement = size.width / _plotData.xSegments;
    final yTickStart = (size.height - _plotData.tickLength) / 2;
    final yTickEnd = yTickStart + _plotData.tickLength;

    if (!_plotData.freezePlots) {
      _plotData.saveXTickTimes(size, state);
    }

    for (int i = 0; i < _plotData.xSegments; i++) {
      double xTick = xTickIncrement * (i + 1);
      path.moveTo(xTick, yTickStart);
      path.lineTo(xTick, yTickEnd);

      canvas.save();
      _plotData.textPainter.text = TextSpan(
          style: TextStyle(color: state._paint.color),
          text: _plotData._xTickTimes[i].toStringAsFixed(1));

      canvas.translate(xTick, yTickStart);
      canvas.rotate(pi / 2);
      _plotData.textPainter.layout();
      _plotData.textPainter.paint(canvas, const Offset(20, 0));
      canvas.restore();
    }
  }

  void generateYTicks(Canvas canvas, Path path, Size size, PlotCurve state) {
    final yTickIncrement = size.height / _plotData.ySegments;

    for (int i = 1; i < _plotData.ySegments; i++) {
      double yTick = yTickIncrement * i;
      path.moveTo(0, yTick);
      path.lineTo(_plotData.tickLength, yTick);

      _plotData.textPainter.text = TextSpan(
          style: TextStyle(color: state._paint.color),
          text: state._getTickValue(size.height, yTick).toStringAsFixed(2));
      _plotData.textPainter.layout();
      _plotData.textPainter.paint(canvas, Offset(10, yTick));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final series = _plotData.curves;
    if (series.isNotEmpty) {
      if (series.first._points.length >= _minPoints) {
        // add each data series
        for (var state in series) {
          if (state.displayed) {
            final path = Path();
            final points =
                _plotData.freezePlots ? state._savedPoints : state._points;
            state.updateTimeSpan(points);

            // initialize the first data point
            final startTime =
                state._getScaledTime(size.width, points.first.x);
            final startSample =
                state._getScaledValue(size.height, points.first.y);
            double previousSample = startSample;
            path.moveTo(startTime, startSample);

            // add remaining data points
            points.sublist(1, points.length).forEach((dataPoint) {
              final scaledTime = state._getScaledTime(size.width, dataPoint.x);
              final scaledValue =
                  state._getScaledValue(size.height, dataPoint.y);

              if (scaledValue > size.height) {
                if (previousSample < size.height) {
                  path.lineTo(scaledTime, size.height);
                }
                path.moveTo(scaledTime, size.height);
              } else if (scaledValue < 0) {
                if (previousSample > 0) {
                  path.lineTo(scaledTime, 0);
                }
                path.moveTo(scaledTime, 0);
              } else {
                path.lineTo(scaledTime, scaledValue);
              }
              previousSample = scaledValue;
            });

            if (state == _plotData.curves[_plotData._selectedIndex]) {
              generateXTicks(canvas, path, size, state);
              generateYTicks(canvas, path, size, state);
            }
            // render the data on the canvas
            canvas.drawPath(path, state._paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
