import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'package:zego_zimkit/zego_zimkit.dart';

import 'package:zego_zimkit_demo/home_page_popup.dart';

class ZIMKitDemoHomePage extends StatelessWidget {
  const ZIMKitDemoHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conversations'),
          actions: const [HomePagePopupMenuButton()],
        ),
        body: ZIMKitConversationListView(
          onPressed: (context, conversation, defaultAction) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return ZIMKitMessageListPage(
                  conversationID: conversation.id,
                  conversationType: conversation.type,
                  appBarActions: appBarActions(conversation),
                );
              },
            ));
          },
        ),
      ),
    );
  }

  List<Widget> appBarActions(ZIMKitConversation conversation) {
    if (conversation.type == ZIMConversationType.peer) {
      return [
        // video call button
        ZegoSendCallInvitationButton(
          isVideoCall: true,
          invitees: [
            ZegoUIKitUser(
              id: conversation.id,
              name: conversation.name,
            ),
          ],
        ),
        // audio call button
        ZegoSendCallInvitationButton(
          isVideoCall: false,
          invitees: [
            ZegoUIKitUser(
              id: conversation.id,
              name: conversation.name,
            ),
          ],
        )
      ];
    } else {
      return [];
    }
  }
}
