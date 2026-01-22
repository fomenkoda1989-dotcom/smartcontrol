import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/receipt.dart';
import '../models/monthly_stats.dart';

/// Service class for communicating with the backend API
class ApiService {
  // Backend API base URL
  // Change this to your backend server address
  static const String baseUrl = 'http://localhost:5001';

  /// Upload a receipt image file
  ///
  /// Returns the newly created Receipt with parsed data
  Future<Receipt> uploadReceipt(String filename, Uint8List fileBytes) async {
    try {
      final uri = Uri.parse('$baseUrl/receipt/upload');

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add file to request
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: filename,
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Receipt.fromDetailJson(json);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('Failed to upload receipt: $e');
    }
  }

  /// Get list of all receipts
  ///
  /// Returns simplified receipt data (without full item lists)
  Future<List<Receipt>> getReceipts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/receipts'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List;
        return jsonList
            .map((json) => Receipt.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load receipts');
      }
    } catch (e) {
      throw Exception('Failed to load receipts: $e');
    }
  }

  /// Get detailed information for a specific receipt
  ///
  /// Returns full receipt data including all items
  Future<Receipt> getReceiptDetail(String receiptId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/receipts/$receiptId'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Receipt.fromDetailJson(json);
      } else if (response.statusCode == 404) {
        throw Exception('Receipt not found');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load receipt');
      }
    } catch (e) {
      throw Exception('Failed to load receipt detail: $e');
    }
  }

  /// Get monthly spending statistics
  ///
  /// Returns statistics for the current month
  Future<MonthlyStats> getMonthlyStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats/month'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return MonthlyStats.fromJson(json);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load stats');
      }
    } catch (e) {
      throw Exception('Failed to load monthly stats: $e');
    }
  }

  /// Health check endpoint
  ///
  /// Returns true if backend is reachable
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
