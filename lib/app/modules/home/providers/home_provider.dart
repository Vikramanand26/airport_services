import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeProvider extends GetConnect {
  @override
  void onInit() {
    super.onInit();
  }

  /// Get all deployed airports
  Future<Response<dynamic>> getDeployedAirports() async {
    var request = http.Request('GET', Uri.parse('https://api.dev.ostrumtech.com/ref-code/airport-deployed'));
    http.StreamedResponse streamedResponse = await request.send();

    final responseBody = await streamedResponse.stream.bytesToString();

    return Response(
      statusCode: streamedResponse.statusCode,
      body: responseBody,
    );
  }

  /// Get airports accessible by an email domain
  Future<Response<dynamic>> getAirportsByEmailDomain(String emailDomain) async {
    // Try with a regular POST request instead of MultipartRequest
    var uri = Uri.parse('https://api.dev.ostrumtech.com/ref-code/getAirportListByEmailDomain');

    // Send the request as JSON, which is more commonly expected by APIs
    var response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({"emailDomain": emailDomain}),
    );

    return Response(
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}