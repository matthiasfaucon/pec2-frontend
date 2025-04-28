import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/platform_utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiResponse<T> {
  final T? data;
  final String? error;
  final int statusCode;
  final bool success;

  ApiResponse({
    required this.statusCode,
    required this.success,
    this.data,
    this.error,
  });
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  
  factory ApiService() => _instance;
  
  ApiService._internal();
  
  String get baseUrl => PlatformUtils.getApiBaseUrl();
  
  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (withAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  Future<dynamic> request({
    required String method,
    required String endpoint,
    dynamic body,
    bool withAuth = true,
    Map<String, String>? queryParams,
  }) async {
    final headers = await _getHeaders(withAuth: withAuth);
    
    var uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }
    
    http.Response response;
    
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiResponse> uploadMultipart({
    required String endpoint,
    required Map<String, String> fields,
    required http.MultipartFile file,
    bool withAuth = true,
    required String method
  }) async {
    var uri = Uri.parse('$baseUrl$endpoint');

    var request = http.MultipartRequest(method.toUpperCase(), uri);

    request.fields.addAll(fields);
    request.files.add(file);

    if (withAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur d\'envoi multipart : $e');
    }
  }


  ApiResponse _handleResponse(http.Response response) {
    try {
      final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          statusCode: response.statusCode,
          success: true,
          data: decoded,
        );
      } else {
        final message = decoded?['error'] ?? decoded?['message'] ?? response.reasonPhrase;
        return ApiResponse(
          statusCode: response.statusCode,
          success: false,
          error: message,
        );
      }
    } catch (e) {
      return ApiResponse(
        statusCode: response.statusCode,
        success: false,
        error: "Erreur de parsing JSON: $e",
      );
    }
  }
} 