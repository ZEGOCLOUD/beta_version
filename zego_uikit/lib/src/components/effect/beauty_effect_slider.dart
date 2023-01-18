// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

class ZegoBeautyEffectSlider extends StatefulWidget {
  final BeautyEffectType effectType;
  final int defaultValue;

  final double? thumpHeight;
  final double? trackHeight;
  final String Function(int)? labelFormatFunc;

  const ZegoBeautyEffectSlider({
    Key? key,
    required this.effectType,
    required this.defaultValue,
    this.thumpHeight,
    this.trackHeight,
    this.labelFormatFunc,
  }) : super(key: key);

  @override
  State<ZegoBeautyEffectSlider> createState() => _ZegoBeautyEffectSliderState();
}

class _ZegoBeautyEffectSliderState extends State<ZegoBeautyEffectSlider> {
  var valueNotifier = ValueNotifier<int>(50);

  @override
  void initState() {
    super.initState();

    valueNotifier.value = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    valueNotifier.value = widget.defaultValue;

    var thumpHeight = widget.thumpHeight ?? 32.h;
    return SizedBox(
      width: 480.w,
      height: thumpHeight,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          valueIndicatorTextStyle: TextStyle(
            color: const Color(0xff1B1A1C),
            fontSize: 30.r,
            fontWeight: FontWeight.w400,
          ),
          valueIndicatorColor: Colors.white.withOpacity(0.5),
          activeTrackColor: Colors.white,
          inactiveTrackColor: const Color(0xff000000).withOpacity(0.3),
          trackHeight: widget.trackHeight ?? 6.0.r,
          thumbColor: Colors.white,
          thumbShape:
              RoundSliderThumbShape(enabledThumbRadius: thumpHeight / 2.0),
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: valueNotifier,
          builder: (context, value, _) {
            return Slider(
              value: value.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              label: widget.labelFormatFunc == null
                  ? value.toDouble().round().toString()
                  : widget.labelFormatFunc?.call(value),
              onChanged: (double defaultValue) {
                valueNotifier.value = defaultValue.toInt();

                ZegoUIKit()
                    .setBeautifyValue(defaultValue.toInt(), widget.effectType);
              },
            );
          },
        ),
      ),
    );
  }
}
