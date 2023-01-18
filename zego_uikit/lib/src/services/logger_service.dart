part of 'uikit_service.dart';

mixin ZegoLoggerService {
  static bool isZegoLoggerInit = false;

  Future<void> initLog() async {
    return await FlutterLogs.initLogs(
            logLevelsEnabled: [
              LogLevel.INFO,
              LogLevel.WARNING,
              LogLevel.ERROR,
              LogLevel.SEVERE
            ],
            timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
            directoryStructure: DirectoryStructure.FOR_DATE,
            logTypesEnabled: ["device", "network", "errors"],
            logFileExtension: LogFileExtension.LOG,
            logsWriteDirectoryName: "ZegoPrebuilt",
            logsExportDirectoryName: "ZegoPrebuilt/Exported",
            debugFileOperations: true,
            isDebuggable: true)
        .then((value) {
      isZegoLoggerInit = true;

      FlutterLogs.setDebugLevel(0);
      FlutterLogs.logInfo(
        "log",
        "init",
        "==========================================" + value,
      );
    });
  }

  Future<void> clearLogs() async {
    FlutterLogs.clearLogs();
  }

  static Future<void> logInfo(
    String logMessage, {
    String tag = "",
    String subTag = "",
  }) async {
    if (!isZegoLoggerInit) {
      debugPrint(
          "[INFO] ${DateTime.now().toString()} [$tag] [$subTag] $logMessage");
      return;
    }

    return FlutterLogs.logInfo(tag, subTag, logMessage);
  }

  static Future<void> logWarn(
    String logMessage, {
    String tag = "",
    String subTag = "",
  }) async {
    if (!isZegoLoggerInit) {
      debugPrint(
          "[WARN] ${DateTime.now().toString()} [$tag] [$subTag] $logMessage");
      return;
    }

    return FlutterLogs.logWarn(tag, subTag, logMessage);
  }

  static Future<void> logError(
    String logMessage, {
    String tag = "",
    String subTag = "",
  }) async {
    if (!isZegoLoggerInit) {
      debugPrint(
          "[ERROR] ${DateTime.now().toString()} [$tag] [$subTag] $logMessage");
      return;
    }

    return FlutterLogs.logError(tag, subTag, logMessage);
  }

  static Future<void> logErrorTrace(
    String logMessage,
    Error e, {
    String tag = "",
    String subTag = "",
  }) async {
    if (!isZegoLoggerInit) {
      debugPrint(
          "[ERROR] ${DateTime.now().toString()} [$tag] [$subTag] $logMessage");
      return;
    }

    return FlutterLogs.logErrorTrace(tag, subTag, logMessage, e);
  }
}
