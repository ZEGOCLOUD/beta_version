// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:native_device_orientation/native_device_orientation.dart';

DeviceOrientation deviceOrientationMap(NativeDeviceOrientation nativeValue) {
  final Map<NativeDeviceOrientation, DeviceOrientation> deviceOrientationMap = {
    NativeDeviceOrientation.portraitUp: DeviceOrientation.portraitUp,
    NativeDeviceOrientation.portraitDown: DeviceOrientation.portraitDown,
    NativeDeviceOrientation.landscapeLeft: DeviceOrientation.landscapeLeft,
    NativeDeviceOrientation.landscapeRight: DeviceOrientation.landscapeRight,
    NativeDeviceOrientation.unknown: DeviceOrientation.portraitUp,
  };
  return deviceOrientationMap[nativeValue] ?? DeviceOrientation.portraitUp;
}
