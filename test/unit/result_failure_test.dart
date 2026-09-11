import 'package:flutter_test/flutter_test.dart';
import 'package:riturasa/core/errors/failure.dart';
import 'package:riturasa/core/utils/result.dart';

void main() {
  group('Result & Failure Unit Tests', () {
    test('Ok result contains value and maps correctly', () {
      const result = Result.ok('apple');
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.valueOrNull, equals('apple'));
      expect(result.failureOrNull, isNull);

      final mapped = result.map((v) => v.toUpperCase());
      expect(mapped.valueOrNull, equals('APPLE'));

      final folded = result.fold(
        onOk: (v) => 'Success: $v',
        onErr: (f) => 'Failed: ${f.message}',
      );
      expect(folded, equals('Success: apple'));
    });

    test('Err result contains failure and folds to onErr', () {
      const failure = NetworkFailure(message: 'No internet connection');
      const Result<String> result = Result.err(failure);

      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, equals(failure));

      final mapped = result.map((v) => v.toUpperCase());
      expect(mapped.isErr, isTrue);
      expect(mapped.failureOrNull, equals(failure));

      final folded = result.fold(
        onOk: (v) => 'Success: $v',
        onErr: (f) => f.code ?? 'UNKNOWN',
      );
      expect(folded, equals('NETWORK_UNAVAILABLE'));
    });

    test('Failure equality and props work as expected', () {
      const f1 = NotFoundFailure(message: 'Recipe not found', code: 'NOT_FOUND');
      const f2 = NotFoundFailure(message: 'Recipe not found', code: 'NOT_FOUND');
      const f3 = DatabaseFailure(message: 'Disk error');

      expect(f1, equals(f2));
      expect(f1 == f3, isFalse);
    });
  });
}
