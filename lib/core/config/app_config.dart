import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Firebase Configuration
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAuthDomain =>
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  // Cloudinary Configuration
  static String get cloudinaryCloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get cloudinaryApiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static String get cloudinaryApiSecret =>
      dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
  static String get cloudinaryUploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  // OpenStreetMap Configuration
  static String get osmTileLayerUrl =>
      dotenv.env['OSM_TILE_LAYER_URL'] ??
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'PetMe';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static double get defaultLocationLat =>
      double.tryParse(dotenv.env['DEFAULT_LOCATION_LAT'] ?? '') ?? 0.0;
  static double get defaultLocationLon =>
      double.tryParse(dotenv.env['DEFAULT_LOCATION_LON'] ?? '') ?? 0.0;
  static double get defaultZoomLevel =>
      double.tryParse(dotenv.env['DEFAULT_ZOOM_LEVEL'] ?? '') ?? 13.0;

  static Future<void> initialize() async {
    await dotenv.load();
  }

  static bool get isConfigValid {
    return firebaseApiKey.isNotEmpty &&
        firebaseAuthDomain.isNotEmpty &&
        firebaseProjectId.isNotEmpty &&
        firebaseStorageBucket.isNotEmpty &&
        firebaseMessagingSenderId.isNotEmpty &&
        firebaseAppId.isNotEmpty &&
        cloudinaryCloudName.isNotEmpty &&
        cloudinaryApiKey.isNotEmpty &&
        cloudinaryApiSecret.isNotEmpty &&
        cloudinaryUploadPreset.isNotEmpty;
  }

  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';
}
