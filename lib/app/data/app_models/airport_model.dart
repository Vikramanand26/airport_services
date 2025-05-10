import 'dart:convert';

class Airport {
  final String airportCode;
  final String airportName;
  final String airportLogo;

  Airport({
    required this.airportCode,
    required this.airportName,
    required this.airportLogo,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      airportCode: json['airportCode'] ?? '',
      airportName: json['airportName'] ?? '',
      airportLogo: json['airportLogo'] ?? '',
    );
  }

  factory Airport.fromCode(String code, {String name = '', String logo = ''}) {
    return Airport(
      airportCode: code,
      airportName: name.isEmpty ? 'Airport $code' : name,
      airportLogo: logo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airportCode': airportCode,
      'airportName': airportName,
      'airportLogo': airportLogo,
    };
  }
}

// Model for handling the email domain access response
class EmailDomainAccess {
  final String emailDomain;
  final List<String> airportCodes;

  EmailDomainAccess({
    required this.emailDomain,
    required this.airportCodes,
  });

  factory EmailDomainAccess.fromJson(Map<String, dynamic> json) {
    return EmailDomainAccess(
      emailDomain: json['emailDomain'] ?? '',
      airportCodes: json['airportCodes'] != null
          ? List<String>.from(json['airportCodes'])
          : [],
    );
  }
}