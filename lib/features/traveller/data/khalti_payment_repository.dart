import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:drive/features/auth/data/user_session.dart';
import 'package:drive/config.dart';

class KhaltiPaymentRepository {
  static const String _baseUrl =
      '${AppConfig.backendBaseUrl}/api/payments/khalti'; // Updated as per backend doc

  /// Initiates a Khalti payment and returns the pidx and payment_url
  static Future<Map<String, dynamic>> initiatePayment({
    required int amount,
    required String orderId,
    required String orderName,
    required String returnUrl,
    required Map<String, dynamic> customerInfo,
    required List<Map<String, dynamic>> amountBreakdown,
    required List<Map<String, dynamic>> productDetails,
  }) async {
    final uri = Uri.parse('$_baseUrl/initiate');
    final token = UserSession.token;
    final requestBody = {
      'amount': amount,
      'purchase_order_id': orderId,
      'purchase_order_name': orderName,
      'return_url': returnUrl,
      'customer_info': customerInfo,
      'amount_breakdown': amountBreakdown,
      'product_details': productDetails,
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to initiate Khalti payment: ${response.body}');
    }
  }

  /// Looks up a payment status by pidx
  static Future<String> lookupPayment({
    required String pidx,
    required dynamic tripId,
    required List<String> seatLabels,
    String caller = 'unknown',
  }) async {
    final token = UserSession.token;
    final url = Uri.parse('$_baseUrl/lookup');
    final requestBody = {
      'pidx': pidx,
      'tripId': tripId,
      'seatLabels': seatLabels,
    };
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return response.body;
    } else {
      throw Exception(
        'Failed to lookup Khalti payment: status=${response.statusCode}, body=${response.body}',
      );
    }
  }
}
