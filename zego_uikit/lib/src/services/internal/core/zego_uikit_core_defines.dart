part of 'zego_uikit_core.dart';

enum ZegoStreamType {
  main,
  media,
  screenSharing,
}

extension ZegoStreamTypeExtension on ZegoStreamType {
  String get text {
    final mapValues = {
      ZegoStreamType.main: 'main',
      ZegoStreamType.media: 'media',
      ZegoStreamType.screenSharing: 'screensharing',
    };

    return mapValues[this]!;
  }
}

const streamExtraInfoCameraKey = 'isCameraOn';
const streamExtraInfoMicrophoneKey = 'isMicrophoneOn';

// user
class ZegoUIKitCoreUser {

  ZegoUIKitCoreUser(this.id, this.name);

  ZegoUIKitCoreUser.fromZego(ZegoUser user) : this(user.userID, user.userName);

  ZegoUIKitCoreUser.empty();

  ZegoUIKitCoreUser.localDefault() {
    camera.value = true;
    microphone.value = true;
  }
  String id = '';
  String name = '';

  ValueNotifier<bool> camera = ValueNotifier<bool>(false);
  ValueNotifier<bool> microphone = ValueNotifier<bool>(false);
  StreamController<double> soundLevel = StreamController<double>.broadcast();
  ValueNotifier<Map<String, String>> inRoomAttributes = ValueNotifier<Map<String, String>>({});

  String streamID = '';
  int viewID = -1;
  ValueNotifier<Widget?> view = ValueNotifier<Widget?>(null);
  ValueNotifier<Size> viewSize = ValueNotifier<Size>(const Size(360, 640));

  String auxStreamID = '';
  int auxViewID = -1;
  ValueNotifier<Widget?> auxView = ValueNotifier<Widget?>(null);
  ValueNotifier<Size> auxViewSize = ValueNotifier<Size>(const Size(360, 640));

  void destroyTextureRenderer({bool isMainStream = true}) {
    if (isMainStream) {
      if (viewID != -1) {
        ZegoExpressEngine.instance.destroyCanvasView(viewID);
      }

      viewID = -1;
      view.value = null;
      viewSize.value = const Size(360, 640);
    } else {
      if (auxViewID != -1) {
        ZegoExpressEngine.instance.destroyCanvasView(auxViewID);
      }

      auxViewID = -1;
      auxView.value = null;
      auxViewSize.value = const Size(360, 640);
    }
  }

  ValueNotifier<ZegoStreamQualityLevel> network =
      ValueNotifier<ZegoStreamQualityLevel>(ZegoStreamQualityLevel.Excellent);

  // only for local
  ValueNotifier<bool> isFrontFacing = ValueNotifier<bool>(true);
  ValueNotifier<ZegoAudioRoute> audioRoute =
      ValueNotifier<ZegoAudioRoute>(ZegoAudioRoute.Receiver);
  ZegoAudioRoute lastAudioRoute = ZegoAudioRoute.Receiver;

  ZegoUIKitUser toZegoUikitUser() => ZegoUIKitUser(
        id: id,
        name: name,
        inRoomAttributes: inRoomAttributes.value,
      );

  ZegoUser toZegoUser() => ZegoUser(id, name);

  @override
  String toString() {
    return 'id:$id, name:$name';
  }
}

String generateStreamID(String userID, String roomID, ZegoStreamType type) {
  return '${roomID}_${userID}_${type.text}';
}

// room

class ZegoUIKitCoreRoom {

  ZegoUIKitCoreRoom(this.id) {
    ZegoLoggerService.logInfo(
      'create $id',
      tag: 'uikit',
      subTag: 'core room',
    );
  }
  String id = '';

  bool isLargeRoom = false;
  bool markAsLargeRoom = false;

  ValueNotifier<ZegoUIKitRoomState> state = ValueNotifier<ZegoUIKitRoomState>(
      ZegoUIKitRoomState(ZegoRoomStateChangedReason.Logout, 0, {}));

  Map<String, RoomProperty> properties = {};
  bool propertiesAPIRequesting = false;
  Map<String, String> pendingProperties = {};

  StreamController<RoomProperty> propertyUpdateStream = StreamController<RoomProperty>.broadcast();
  StreamController<Map<String, RoomProperty>> propertiesUpdatedStream =
      StreamController<Map<String, RoomProperty>>.broadcast();

  void clear() {
    id = '';

    properties.clear();
    propertiesAPIRequesting = false;
    pendingProperties.clear();
  }

  ZegoUIKitRoom toUIKitRoom() {
    return ZegoUIKitRoom(id: id);
  }
}

// video config
class ZegoUIKitVideoConfig {

  ZegoUIKitVideoConfig({
    this.resolution = ZegoVideoConfigPreset.Preset360P,
    this.orientation = DeviceOrientation.portraitUp,
    this.useVideoViewAspectFill = false,
  });
  ZegoVideoConfigPreset resolution;
  DeviceOrientation orientation;
  bool useVideoViewAspectFill;

  bool needUpdateOrientation(ZegoUIKitVideoConfig newConfig) {
    return orientation != newConfig.orientation;
  }

  bool needUpdateVideoConfig(ZegoUIKitVideoConfig newConfig) {
    return (resolution != newConfig.resolution) ||
        (orientation != newConfig.orientation);
  }

  ZegoVideoConfig toZegoVideoConfig() {
    final config = ZegoVideoConfig.preset(resolution);
    if (orientation == DeviceOrientation.landscapeLeft ||
        orientation == DeviceOrientation.landscapeRight) {
      var tmp = config.captureHeight;
      config.captureHeight = config.captureWidth;
      config.captureWidth = tmp;
      tmp = config.encodeHeight;
      config.encodeHeight = config.encodeWidth;
      config.encodeWidth = tmp;
    }
    return config;
  }

  ZegoUIKitVideoConfig copyWith({
    ZegoVideoConfigPreset? resolution,
    DeviceOrientation? orientation,
    bool? useVideoViewAspectFill,
  }) =>
      ZegoUIKitVideoConfig(
        resolution: resolution ?? this.resolution,
        orientation: orientation ?? this.orientation,
        useVideoViewAspectFill:
            useVideoViewAspectFill ?? this.useVideoViewAspectFill,
      );
}

class ZegoUIKitAdvancedConfigKey {
  static const String videoViewMode = 'videoViewMode';
}
