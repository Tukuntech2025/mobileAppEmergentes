import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class EnvironmentConfig {
  // Pass env via: flutter run --dart-define=ENV=prod
  static const String _env = String.fromEnvironment('ENV', defaultValue: 'test');

  static String get env => _env;

  static String get baseUrl {
    if (_env == 'prod') {
      return 'http://tukuntech-backend.duckdns.org/api/v1';
    } else {
      // test environment
      if (!kIsWeb && Platform.isAndroid) {
        return 'http://10.0.2.2:8080/api/v1';
      } else {
        return 'http://localhost:8080/api/v1';
      }
    }
  }
}
