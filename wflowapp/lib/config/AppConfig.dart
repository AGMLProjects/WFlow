import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static String TOKEN = '';

  static const String BASE_URL =
      'https://f8498739-a374-404b-aa9c-490860d6dda4.mock.pstmn.io';

  static const String ADD_HOUSE_INSTRUCTIONS =
      // ignore: prefer_interpolation_to_compose_strings
      '1. Every house is paired to one "main device".\n' +
          '2. You will find a QR code on the back of the "main device".\n' +
          '3. Click the "scan" button to scan the QR code and add a new house!';
}
