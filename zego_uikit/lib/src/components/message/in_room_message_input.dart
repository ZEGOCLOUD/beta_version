// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/components/widgets/widgets.dart';
import 'package:zego_uikit/src/services/services.dart';

class ZegoInRoomMessageInput extends StatefulWidget {
  const ZegoInRoomMessageInput({
    Key? key,
    this.placeHolder = "Say something...",
    this.backgroundColor,
    this.inputBackgroundColor,
    this.textColor,
    this.textHintColor,
    this.cursorColor,
    this.buttonColor,
    this.borderRadius,
    this.enabled = true,
    this.autofocus = true,
    this.onSubmit,
    this.valueNotifier,
    this.focusNotifier,
  }) : super(key: key);

  final String placeHolder;
  final Color? backgroundColor;
  final Color? inputBackgroundColor;
  final Color? textColor;
  final Color? textHintColor;
  final Color? cursorColor;
  final Color? buttonColor;
  final double? borderRadius;
  final bool enabled;
  final bool autofocus;
  final VoidCallback? onSubmit;
  final ValueNotifier<String>? valueNotifier;
  final ValueNotifier<bool>? focusNotifier;

  @override
  State<ZegoInRoomMessageInput> createState() => _ZegoInRoomMessageInputState();
}

class _ZegoInRoomMessageInputState extends State<ZegoInRoomMessageInput> {
  final TextEditingController textController = TextEditingController();
  ValueNotifier<bool> isEmptyNotifier = ValueNotifier(true);
  var focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    focusNode.addListener(onFocusChange);

    if (widget.valueNotifier != null) {
      textController.text = widget.valueNotifier!.value;

      isEmptyNotifier.value = textController.text.isEmpty;
    }
  }

  @override
  void dispose() {
    super.dispose();

    focusNode.removeListener(onFocusChange);
    focusNode.dispose();
  }

  void onFocusChange() {
    widget.focusNotifier?.value = focusNode.hasFocus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 15.r),
      color: widget.backgroundColor ?? const Color(0xff222222).withOpacity(0.8),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 90.r,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 10.r),
            messageInput(),
            SizedBox(width: 10.r),
            sendButton(),
            SizedBox(width: 10.r),
          ],
        ),
      ),
    );
  }

  Widget messageInput() {
    var messageSendBgColor = widget.buttonColor ?? const Color(0xff3e3e3d);
    var messageSendCursorColor = widget.cursorColor ?? const Color(0xffA653ff);
    var messageSendHintStyle = TextStyle(
      color: widget.textHintColor ?? const Color(0xffa4a4a4),
      fontSize: 28.r,
      fontWeight: FontWeight.w400,
    );
    var messageSendInputStyle = TextStyle(
      color: widget.textColor ?? Colors.white,
      fontSize: 28.r,
      fontWeight: FontWeight.w400,
    );

    return Expanded(
      child: Container(
        height: 78.r,
        decoration: BoxDecoration(
          color: widget.inputBackgroundColor ?? messageSendBgColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: TextField(
          enabled: widget.enabled,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: null,
          autofocus: widget.autofocus,
          focusNode: focusNode,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(400)
          ],
          controller: textController,
          onChanged: (String inputMessage) {
            widget.valueNotifier?.value = inputMessage;

            bool valueIsEmpty = inputMessage.isEmpty;
            if (valueIsEmpty != isEmptyNotifier.value) {
              isEmptyNotifier.value = valueIsEmpty;
            }
          },
          textInputAction: TextInputAction.send,
          onSubmitted: (message) => send(),
          cursorColor: messageSendCursorColor,
          cursorHeight: 30.r,
          cursorWidth: 3.r,
          style: messageSendInputStyle,
          onTap: () {},
          decoration: InputDecoration(
            hintText: widget.placeHolder,
            hintStyle: messageSendHintStyle,
            contentPadding: EdgeInsets.only(
              left: 20.r,
              top: -5.r,
              right: 20.r,
              bottom: 15.r,
            ),
            // isDense: true,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget sendButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: isEmptyNotifier,
      builder: (context, bool isEmpty, Widget? child) {
        return ZegoTextIconButton(
          onPressed: () {
            if (!isEmpty) send();
          },
          icon: ButtonIcon(
            icon: isEmpty
                ? UIKitImage.asset(StyleIconUrls.iconSendDisable)
                : UIKitImage.asset(StyleIconUrls.iconSend),
            backgroundColor: widget.buttonColor,
          ),
          iconSize: Size(68.r, 68.r),
          buttonSize: Size(72.r, 72.r),
        );
      },
    );
  }

  void send() {
    if (textController.text.isEmpty) {
      ZegoLoggerService.logInfo(
        "message is empty",
        tag: "uikit",
        subTag: "in room message input",
      );
      return;
    }

    ZegoUIKit().sendInRoomMessage(textController.text);
    textController.clear();

    widget.valueNotifier?.value = "";

    widget.onSubmit?.call();
  }
}
