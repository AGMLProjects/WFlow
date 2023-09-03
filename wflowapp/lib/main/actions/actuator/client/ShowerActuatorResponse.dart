import 'package:http/http.dart';

class ShowerActuatorResponse {
  final int code;

  ShowerActuatorResponse({required this.code});

  factory ShowerActuatorResponse.fromResponse(Response response) {
    ShowerActuatorResponse res =
        ShowerActuatorResponse(code: response.statusCode);
    return res;
  }
}
