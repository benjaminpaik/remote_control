
import 'package:flutter/material.dart';

const Color textColor = Colors.black;
const double standardFontSize = 15;

class ScreenNames {
  static const connect = "connect";
  static const command = "command";
}

class Command {
  static const max = 1000;
  static const min = -1000;
}

class BleSettings {
  static const customServiceUuid = "C700";
  static const readCharacteristicUuid = "C701";
  static const writeCharacteristicUuid = "C702";
  static const writeBytes = 3;
  static const readBytes = 8;
}
