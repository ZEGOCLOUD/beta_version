// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

enum BeautyEffectType {
  whiten,
  rosy,
  smooth,
  sharpen,
  none,
}

extension BeautyEffectTypeExtension on BeautyEffectType {
  String get text {
    var mapValues = {
      BeautyEffectType.whiten: "Skin Tone",
      BeautyEffectType.rosy: "Blusher",
      BeautyEffectType.smooth: "Smoothing",
      BeautyEffectType.sharpen: "Sharpening",
      BeautyEffectType.none: "None",
    };

    return mapValues[this]!;
  }
}

enum VoiceChangerType {
  none,
  littleBoy,
  littleGirl,
  ethereal,
  female,
  male,
  robot,
  optimusPrime,
  deep,
  crystalClear,
  cMajor,
  aMajor,
  harmonicMinor,
}

extension VoiceChangerTypeExtension on VoiceChangerType {
  String get text {
    var mapValues = {
      VoiceChangerType.none: "None",
      VoiceChangerType.littleBoy: "Little boy",
      VoiceChangerType.littleGirl: "Little girl",
      VoiceChangerType.deep: "Deep",
      VoiceChangerType.crystalClear: "Crystal-clear",
      VoiceChangerType.robot: "Robot",
      VoiceChangerType.ethereal: "Ethereal",
      VoiceChangerType.female: "Female",
      VoiceChangerType.male: "Male",
      VoiceChangerType.optimusPrime: "Optimus Prime",
      VoiceChangerType.cMajor: "C major",
      VoiceChangerType.aMajor: "A major",
      VoiceChangerType.harmonicMinor: "Harmonic minor",
    };

    return mapValues[this]!;
  }

  ZegoVoiceChangerPreset get key {
    var mapValues = {
      VoiceChangerType.none: ZegoVoiceChangerPreset.None,
      VoiceChangerType.littleBoy: ZegoVoiceChangerPreset.MenToChild,
      VoiceChangerType.littleGirl: ZegoVoiceChangerPreset.WomenToChild,
      VoiceChangerType.deep: ZegoVoiceChangerPreset.MaleMagnetic,
      VoiceChangerType.crystalClear: ZegoVoiceChangerPreset.FemaleFresh,
      VoiceChangerType.robot: ZegoVoiceChangerPreset.Android,
      VoiceChangerType.ethereal: ZegoVoiceChangerPreset.Ethereal,
      VoiceChangerType.female: ZegoVoiceChangerPreset.MenToWomen,
      VoiceChangerType.male: ZegoVoiceChangerPreset.WomenToMen,
      VoiceChangerType.optimusPrime: ZegoVoiceChangerPreset.OptimusPrime,
      VoiceChangerType.cMajor: ZegoVoiceChangerPreset.MajorC,
      VoiceChangerType.aMajor: ZegoVoiceChangerPreset.MinorA,
      VoiceChangerType.harmonicMinor: ZegoVoiceChangerPreset.HarmonicMinor,
    };

    return mapValues[this]!;
  }
}

enum ReverbType {
  none,
  ktv,
  hall,
  concert,
  rock,
  smallRoom,
  largeRoom,
  valley,
  recordingStudio,
  basement,
  popular,
  gramophone,
}

extension ReverbTypeExtension on ReverbType {
  String get text {
    var mapValues = {
      ReverbType.none: "None",
      ReverbType.ktv: "Karaoke",
      ReverbType.hall: "Hall",
      ReverbType.concert: "Concert",
      ReverbType.rock: "Rock",
      ReverbType.smallRoom: "Small room",
      ReverbType.largeRoom: "Large room",
      ReverbType.valley: "Valley",
      ReverbType.recordingStudio: "Recording studio",
      ReverbType.basement: "Basement",
      ReverbType.popular: "Pop",
      ReverbType.gramophone: "Gramophone",
    };

    return mapValues[this]!;
  }

  ZegoReverbPreset get key {
    var mapValues = {
      ReverbType.ktv: ZegoReverbPreset.KTV,
      ReverbType.hall: ZegoReverbPreset.ConcertHall,
      ReverbType.concert: ZegoReverbPreset.VocalConcert,
      ReverbType.rock: ZegoReverbPreset.Rock,
      ReverbType.none: ZegoReverbPreset.None,
      ReverbType.smallRoom: ZegoReverbPreset.SoftRoom,
      ReverbType.largeRoom: ZegoReverbPreset.LargeRoom,
      ReverbType.valley: ZegoReverbPreset.Valley,
      ReverbType.recordingStudio: ZegoReverbPreset.RecordingStudio,
      ReverbType.basement: ZegoReverbPreset.Basement,
      ReverbType.popular: ZegoReverbPreset.Popular,
      ReverbType.gramophone: ZegoReverbPreset.GramoPhone,
    };

    return mapValues[this]!;
  }
}
