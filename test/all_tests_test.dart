import 'package:flutter_test/flutter_test.dart';

// 1. Widget Tests
import 'widget_test.dart' as widget_test;

// 2. Unit - Domain Services
import 'unit/services/cycle_service_test.dart' as cycle_service_test;
import 'unit/services/kitchen_matching_service_test.dart' as kitchen_matching_service_test;
import 'unit/services/nutrition_progress_service_test.dart' as nutrition_progress_service_test;
import 'unit/services/shopping_service_test.dart' as shopping_service_test;
import 'unit/result_failure_test.dart' as result_failure_test;

// 3. Data - Local Database & DAOs
import 'data/local/user_database_test.dart' as user_database_test;
import 'data/local/reference_database_test.dart' as reference_database_test;

// 4. Data - Remote DTOs & API Client
import 'data/remote/dto_mappers_test.dart' as dto_mappers_test;
import 'data/remote/api_client_test.dart' as api_client_test;

// 5. Integration Tests
import 'integration/offline_flow_test.dart' as offline_flow_test;
import 'integration/resilient_fallback_test.dart' as resilient_fallback_test;

import 'package:riturasa/core/database/database_manager.dart';

/// Master Test Aggregator
/// Runs all 12 test suites (45+ tests) in a single Dart VM invocation,
/// eliminating the multi-process VM restart overhead and running in 2-3 seconds.
void main() {
  setUpAll(() {
    DatabaseManager.ensureFfiInitialized();
  });

  group('RituRasa Unified Test Suite', () {
    group('[1/5] Widget & UI Tests', () {
      widget_test.main();
    });

    group('[2/5] Domain Services & Core Logic', () {
      cycle_service_test.main();
      kitchen_matching_service_test.main();
      nutrition_progress_service_test.main();
      shopping_service_test.main();
      result_failure_test.main();
    });

    group('[3/5] Local SQLite Databases & DAOs', () {
      user_database_test.main();
      reference_database_test.main();
    });

    group('[4/5] Remote API & Mappers', () {
      dto_mappers_test.main();
      api_client_test.main();
    });

    group('[5/5] End-to-End Integration Flows', () {
      offline_flow_test.main();
      resilient_fallback_test.main();
    });
  });
}
