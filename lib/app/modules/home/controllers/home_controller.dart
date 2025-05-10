import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/app_models/airport_model.dart';
import '../providers/home_provider.dart';
import 'dart:convert';

class HomeController extends GetxController {
  final HomeProvider homeProvider = HomeProvider();
  final TextEditingController emailController = TextEditingController();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Airport> allAirports = <Airport>[].obs;
  final RxList<Airport> accessibleAirports = <Airport>[].obs;
  final RxBool isShowingAllAirports = true.obs;

  // Computed variable for the airports to display
  Rx<List<Airport>> get airportsToShow =>
      (isShowingAllAirports.value ? allAirports : accessibleAirports).obs;

  @override
  void onInit() {
    super.onInit();
    fetchDeployedAirports();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  // Fetch all deployed airports
  Future<void> fetchDeployedAirports() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await homeProvider.getDeployedAirports();

      print("=========API Response=======");
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['resultArray'] != null) {
          final List<dynamic> airportsData = data['resultArray'];
          allAirports.value = airportsData
              .map((airportJson) => Airport.fromJson(airportJson))
              .toList();
        } else {
          errorMessage.value = 'No airports found in the response';
        }
      } else {
        errorMessage.value = 'Failed to load airports: ${response.statusCode}';
      }
    } catch (e) {
      print("Error: $e");
      errorMessage.value = 'Error fetching airports: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Check airport access by email domain
  Future<void> checkAccessByEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      errorMessage.value = 'Please enter an email';
      return;
    }

    if (!GetUtils.isEmail(email)) {
      errorMessage.value = 'Please enter a valid email';
      return;
    }

    // Extract domain from email
    final emailParts = email.split('@');
    if (emailParts.length != 2) {
      errorMessage.value = 'Invalid email format';
      return;
    }

    final emailDomain = emailParts[1];

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await homeProvider.getAirportsByEmailDomain(emailDomain);

      // For debugging - print the response
      print('Response from email domain check:');
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['resultArray'] != null) {
          final List<dynamic> domainAccessList = data['resultArray'];

          // New response format handling
          if (domainAccessList.isNotEmpty) {
            final accessInfo = domainAccessList[0];

            if (accessInfo['airportCodes'] != null) {
              final List<dynamic> accessibleCodes = accessInfo['airportCodes'];

              // Filter the allAirports list to get only the accessible ones
              accessibleAirports.value = allAirports
                  .where((airport) => accessibleCodes.contains(airport.airportCode))
                  .toList();

              // Automatically switch to showing accessible airports
              isShowingAllAirports.value = false;

              // If no matching airports were found
              if (accessibleAirports.isEmpty) {
                errorMessage.value = 'No matching airports found for your access codes';
              }
            } else {
              accessibleAirports.clear();
              errorMessage.value = 'No airport codes found in the response';
            }
          } else {
            accessibleAirports.clear();
            errorMessage.value = 'No access information found for this email domain';
          }
        } else {
          accessibleAirports.clear();
          errorMessage.value = 'No access data found in the response';
        }
      } else {
        errorMessage.value = 'Failed to check access: ${response.statusCode}';
      }
    } catch (e) {
      print("Error: $e");
      errorMessage.value = 'Error checking airport access: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle between showing all airports and accessible ones
  void toggleAirportView() {
    isShowingAllAirports.value = !isShowingAllAirports.value;
  }
}