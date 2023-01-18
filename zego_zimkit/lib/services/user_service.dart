part of 'services.dart';

mixin ZIMKitUserService {
  Future<int> connectUser(
      {required String id, String name = '', String token = ''}) async {
    return ZIMKitCore.instance.connectUser(id: id, name: name, token: token);
  }

  Future<void> disconnectUser() async {
    return ZIMKitCore.instance.disconnectUser();
  }

  ZIMUserFullInfo? currentUser() {
    return ZIMKitCore.instance.currentUser;
  }

  Future<ZIMUserFullInfo> queryUser(String id) async {
    return ZIMKitCore.instance.queryUser(id);
  }
}
