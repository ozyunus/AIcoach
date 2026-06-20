import 'package:flutter/foundation.dart';

abstract final class AppRuntimeConfig {
  static const bool _autoPreviewEnabled = bool.fromEnvironment(
    'AICOACH_AUTO_PREVIEW',
    defaultValue: true,
  );

  static bool get autoPreviewSignIn => kDebugMode && _autoPreviewEnabled;
}
