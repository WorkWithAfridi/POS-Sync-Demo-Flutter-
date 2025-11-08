import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:user_sync/data/local/local_storage.dart';
import 'package:user_sync/data/local/local_storage_keys.dart';
import 'package:user_sync/utils/logger.dart';

import '../config/api_endpoints.dart';

enum Method { POST, GET, PUT, DELETE, PATCH }

class NetworkController {
  Dio? _dio;

  static Map<String, String> header() => {"Accept": "application/json", "Content-Type": "application/json"};

  Future<NetworkController> init() async {
    // Just in case you need the directory later (logs, etc.)
    await getTemporaryDirectory();

    _dio = Dio(
      BaseOptions(baseUrl: ApiEndPoints.baseUrl, headers: header(), connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(seconds: 30)),
    );

    initInterceptors();
    return this;
  }

  void initInterceptors() {
    // Add your logger (assuming it’s a Dio interceptor)
    _dio!.interceptors.add(dioLogger);
  }

  Future<Response?> request({
    required String url,
    required Method method,
    dynamic params,
    String? authToken,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
  }) async {
    Response? response;
    authToken ??= localStorageInstance.getString(key: LocalStorageKeys.token);

    try {
      // Combine headers
      final effectiveHeaders = {"Authorization": "Bearer $authToken", ...header(), if (headers != null) ...headers};

      final options = Options(headers: effectiveHeaders, responseType: responseType);

      // Support full URLs (LAN IPs, etc.)
      final isFullUrl = url.startsWith('http');
      final fullUrl = isFullUrl ? url : '${_dio!.options.baseUrl}$url';

      switch (method) {
        case Method.POST:
          response = await _dio!.post(fullUrl, data: params, options: options);
          break;
        case Method.DELETE:
          response = await _dio!.delete(fullUrl, options: options, data: params);
          break;
        case Method.PATCH:
          response = await _dio!.patch(fullUrl, data: params, options: options);
          break;
        case Method.PUT:
          response = await _dio!.put(fullUrl, data: params, options: options);
          break;
        case Method.GET:
          response = await _dio!.get(fullUrl, queryParameters: params, options: options);
          break;
      }

      return response;
    } on DioException catch (e) {
      logger.error("Dio error: ${e.message}, response: ${e.response?.data}");
      return e.response;
    } catch (e) {
      logger.error("Unhandled Error: $e");
      return response;
    }
  }
}

final NetworkController networkControllerInstance = GetIt.I<NetworkController>();
