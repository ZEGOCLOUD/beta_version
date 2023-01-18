part of '../zego_signaling_plugin_interface.dart';

mixin ZegoSignalingPluginRoomAPI {
  /// join room
  Future<ZegoSignalingPluginJoinRoomResult> joinRoom({
    required String roomID,
    required String roomName,
    Map<String, String> roomAttributes = const {},
    int roomDestroyDelayTime = 0,
  });

  /// leave room
  Future<ZegoSignalingPluginLeaveRoomResult> leaveRoom({
    required String roomID,
  });

  /// begin room properties batch operation
  void beginRoomPropertiesBatchOperation({
    required String roomID,
    required bool isForce,
    required bool isDeleteAfterOwnerLeft,
    required bool isUpdateOwner,
  });

  /// update room properties
  Future<ZegoSignalingPluginRoomPropertiesOperationResult>
      updateRoomProperties({
    required String roomID,
    required bool isForce,
    required bool isDeleteAfterOwnerLeft,
    required bool isUpdateOwner,
    required Map<String, String> roomProperties,
  });

  /// delete room properties
  Future<ZegoSignalingPluginRoomPropertiesOperationResult>
      deleteRoomProperties({
    required String roomID,
    required List<String> keys,
    required bool isForce,
  });

  /// end room properties batch operation
  Future<ZegoSignalingPluginEndRoomBatchOperationResult>
      endRoomPropertiesBatchOperation({
    required String roomID,
  });

  /// query room properties
  Future<ZegoSignalingPluginQueryRoomPropertiesResult> queryRoomProperties({
    required String roomID,
  });

  /// query users in room attributes
  Future<ZegoSignalingPluginQueryUsersInRoomAttributesResult>
      queryUsersInRoomAttributes({
    required String roomID,
    int count = 100,
    String nextFlag = '',
  });

  /// set users in room attributes
  Future<ZegoSignalingPluginSetUsersInRoomAttributesResult>
      setUsersInRoomAttributes({
    required String roomID,
    required List<String> userIDs,
    required Map<String, String> setAttributes,
    bool isDeleteAfterOwnerLeft = true,
  });
}

mixin ZegoSignalingPluginRoomEvent {
  Stream<ZegoSignalingPluginRoomPropertiesUpdatedEvent>
      getRoomPropertiesUpdatedEventStream();

  Stream<ZegoSignalingPluginRoomPropertiesBatchUpdatedEvent>
      getRoomPropertiesBatchUpdatedEventStream();

  Stream<ZegoSignalingPluginRoomStateChangedEvent>
      getRoomStateChangedEventStream();

  Stream<ZegoSignalingPluginUsersInRoomAttributesUpdatedEvent>
      getUsersInRoomAttributesUpdatedEventStream();

  Stream<ZegoSignalingPluginRoomMemberJoinedEvent>
      getRoomMemberJoinedEventStream();

  Stream<ZegoSignalingPluginRoomMemberLeftEvent> getRoomMemberLeftEventStream();
}
