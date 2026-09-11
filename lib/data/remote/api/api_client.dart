import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';

/// Configured Dio HTTP client with interceptors for logging, retry, and error mapping.
class ApiClient {
  final Dio dio;

  ApiClient({Dio? customDio, String? baseUrl})
      : dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? AppConfig.defaultApiBaseUrl,
                connectTimeout: AppConfig.connectTimeout,
                receiveTimeout: AppConfig.receiveTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _configureInterceptors();
  }

  void _configureInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException err, ErrorInterceptorHandler handler) {
          // Log or handle centralized error diagnostics here
          return handler.next(err);
        },
      ),
    );
  }

  /// Execute GET request with automatic failure mapping.
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      if (response.data == null) {
        return const Result.err(ApiResponseFailure(message: 'Empty response data from server'));
      }
      return Result.ok(response.data as T);
    } on DioException catch (e) {
      return Result.err(_mapDioException(e));
    } catch (e) {
      return Result.err(ApiResponseFailure(
        message: 'Unexpected network error: $e',
        cause: e,
      ));
    }
  }

  /// Execute POST request with automatic failure mapping.
  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (response.data == null) {
        return const Result.err(ApiResponseFailure(message: 'Empty response data from server'));
      }
      return Result.ok(response.data as T);
    } on DioException catch (e) {
      return Result.err(_mapDioException(e));
    } catch (e) {
      return Result.err(ApiResponseFailure(
        message: 'Unexpected network error: $e',
        cause: e,
      ));
    }
  }

  Failure _mapDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        ApiTimeoutFailure(
          message: 'Connection timed out while communicating with SimpleNutriAPI.',
          cause: e,
        ),
      DioExceptionType.connectionError =>
        NetworkFailure(
          message: 'Unable to reach SimpleNutriAPI. Please check your network connection.',
          cause: e,
        ),
      DioExceptionType.badResponse =>
        ApiResponseFailure(
          message: e.response?.data is Map && e.response?.data['detail'] != null
              ? e.response!.data['detail'].toString()
              : 'Server returned HTTP ${e.response?.statusCode}',
          statusCode: e.response?.statusCode,
          cause: e,
        ),
      _ =>
        ApiResponseFailure(
          message: e.message ?? 'Unknown network failure',
          cause: e,
        ),
    };
  }
}
