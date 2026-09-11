import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riturasa/core/errors/failure.dart';
import 'package:riturasa/data/remote/api/api_client.dart';
import 'package:riturasa/data/remote/api/simple_nutri_api_service.dart';
import 'package:riturasa/data/remote/dto/cycle_dto.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late ApiClient apiClient;
  late SimpleNutriApiService apiService;

  setUp(() {
    mockDio = MockDio();
    when(() => mockDio.interceptors).thenReturn(Interceptors());
    apiClient = ApiClient(customDio: mockDio);
    apiService = SimpleNutriApiService(apiClient);
  });

  group('ApiClient & SimpleNutriApiService Network Tests', () {
    test('fetchHealth returns HealthCheckDto on 200 OK', () async {
      when(() => mockDio.get<Map<String, dynamic>>('/health')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/health'),
          statusCode: 200,
          data: {'status': 'ok', 'version': '1.0.0', 'dataset_version': '1.0.0'},
        ),
      );

      final result = await apiService.fetchHealth();
      expect(result.isOk, isTrue);
      expect(result.valueOrNull?.status, equals('ok'));
    });

    test('Maps timeout DioException to ApiTimeoutFailure', () async {
      when(() => mockDio.get<Map<String, dynamic>>('/health')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/health'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await apiService.fetchHealth();
      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<ApiTimeoutFailure>());
    });

    test('Maps connection error DioException to NetworkFailure', () async {
      when(() => mockDio.get<Map<String, dynamic>>('/health')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/health'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await apiService.fetchHealth();
      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });

    test('estimateCyclePhase POST sends request and returns CyclePhaseResponseDto', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            '/api/v1/cycle/estimate',
            data: any(named: 'data'),
            options: any(named: 'options'),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/cycle/estimate'),
          statusCode: 200,
          data: {
            'estimated_cycle_day': 14,
            'phase_id': 'ovulatory',
            'phase_name': 'Ovulatory Phase',
            'description': 'Estrogen peak.',
            'priority_nutrient_names': ['Zinc', 'Fiber'],
            'target_tags': ['fiber', 'zinc'],
            'nutrition_focus': ['fiber'],
            'nutrition_context': ['Support hormone balance.'],
          },
        ),
      );

      final result = await apiService.estimateCyclePhase(
        const CycleEstimateRequestDto(lastPeriodStart: '2026-08-28', cycleLengthDays: 28),
      );

      expect(result.isOk, isTrue);
      expect(result.valueOrNull?.phaseId, equals('ovulatory'));
    });
  });
}
