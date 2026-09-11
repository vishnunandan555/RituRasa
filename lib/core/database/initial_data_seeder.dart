import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:riturasa/core/database/database_manager.dart';
import 'package:riturasa/data/local/database/user_database_schema.dart';

/// Seeds initial starter records on first application launch if user tables are empty.
/// Guarantees that every screen (Home, Eat, Kitchen, Cart, Profile) displays meaningful
/// live data immediately without cloud dependencies.
class InitialDataSeeder {
  final DatabaseManager databaseManager;

  const InitialDataSeeder(this.databaseManager);

  Future<void> seedIfEmpty() async {
    final res = await databaseManager.getUserDatabase();
    final db = res.valueOrNull;
    if (db == null) return;

    final now = DateTime.now();

    // 1. User Profile
    final profileCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${UserDatabaseSchema.tableProfile}'),
    ) ?? 0;

    if (profileCount == 0) {
      await db.insert(UserDatabaseSchema.tableProfile, {
        'id': 'default_user',
        'name': 'Ananya Sharma',
        'age': 28,
        'prakriti': 'Pitta-Vata',
        'agni': 'Tikshna',
        'diet_type': 'vegetarian',
        'region': 'South Indian',
        'cuisine': 'South Indian',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      await db.insert(UserDatabaseSchema.tablePreferences, {
        'user_id': 'default_user',
        'preferred_food_ids_json': jsonEncode(['F001', 'F002']),
        'excluded_food_ids_json': jsonEncode([]),
        'allergies_json': jsonEncode(['Peanuts']),
        'updated_at': now.toIso8601String(),
      });
    }

    // 2. Cycle Record (initialize to Day 12 of 28 for peak phase)
    final cycleCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${UserDatabaseSchema.tableCycleHistory}'),
    ) ?? 0;

    if (cycleCount == 0) {
      final periodStart = now.subtract(const Duration(days: 11));
      final periodEnd = periodStart.add(const Duration(days: 4));
      await db.insert(UserDatabaseSchema.tableCycleHistory, {
        'id': 'initial_cycle_${now.millisecondsSinceEpoch}',
        'period_start': periodStart.toIso8601String(),
        'period_end': periodEnd.toIso8601String(),
        'cycle_length': 28,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
    }

    // 3. Kitchen Inventory Staples
    final kitchenCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${UserDatabaseSchema.tableKitchenInventory}'),
    ) ?? 0;

    if (kitchenCount == 0) {
      final staples = [
        {'id': 'k_1', 'food_id': 'F001', 'custom_name': 'Fresh Spinach (Palak)', 'quantity': 2.0, 'unit': 'bunches'},
        {'id': 'k_2', 'food_id': 'F002', 'custom_name': 'Yellow Moong Dal (Split)', 'quantity': 500.0, 'unit': 'g'},
        {'id': 'k_3', 'food_id': 'F003', 'custom_name': 'Ragi Flour (Finger Millet)', 'quantity': 1.0, 'unit': 'kg'},
        {'id': 'k_4', 'food_id': 'F004', 'custom_name': 'Desi Cow Ghee', 'quantity': 250.0, 'unit': 'ml'},
        {'id': 'k_5', 'food_id': 'F005', 'custom_name': 'Black Sesame Seeds (Til)', 'quantity': 100.0, 'unit': 'g'},
        {'id': 'k_6', 'food_id': 'F006', 'custom_name': 'Country Tomatoes', 'quantity': 500.0, 'unit': 'g'},
        {'id': 'k_7', 'food_id': 'F007', 'custom_name': 'Jeera (Cumin Seeds)', 'quantity': 100.0, 'unit': 'g'},
        {'id': 'k_8', 'food_id': 'F008', 'custom_name': 'Turmeric Powder (Haldi)', 'quantity': 100.0, 'unit': 'g'},
      ];

      for (final item in staples) {
        await db.insert(UserDatabaseSchema.tableKitchenInventory, {
          ...item,
          'added_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
      }
    }

    // 4. Starter Shopping List Items
    final shoppingCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${UserDatabaseSchema.tableShoppingList}'),
    ) ?? 0;

    if (shoppingCount == 0) {
      final cartItems = [
        {'id': 's_1', 'food_id': 'F020', 'name': 'Fresh Lemon Juice', 'quantity': 100.0, 'unit': 'ml', 'is_checked': 0},
        {'id': 's_2', 'food_id': 'F021', 'name': 'Cold Pressed Mustard Oil', 'quantity': 500.0, 'unit': 'ml', 'is_checked': 0},
        {'id': 's_3', 'food_id': 'F022', 'name': 'Organic Pumpkin Seeds', 'quantity': 200.0, 'unit': 'g', 'is_checked': 1},
      ];

      for (final item in cartItems) {
        await db.insert(UserDatabaseSchema.tableShoppingList, {
          ...item,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
      }
    }

    // 5. Initial Hydration State in Sync Metadata
    final todayStr = now.toIso8601String().substring(0, 10);
    final waterKey = 'hydration_glasses_$todayStr';
    final existingWater = await db.query(
      UserDatabaseSchema.tableSyncMetadata,
      where: 'key = ?',
      whereArgs: [waterKey],
    );
    if (existingWater.isEmpty) {
      await db.insert(UserDatabaseSchema.tableSyncMetadata, {
        'key': waterKey,
        'value': '5',
        'updated_at': now.toIso8601String(),
      });
    }
  }

  /// Cleanly wipe user tables and re-seed defaults (for Reset Data feature).
  Future<void> resetToDefaults() async {
    final res = await databaseManager.getUserDatabase();
    final db = res.valueOrNull;
    if (db == null) return;

    final batch = db.batch();
    batch.delete(UserDatabaseSchema.tableProfile);
    batch.delete(UserDatabaseSchema.tablePreferences);
    batch.delete(UserDatabaseSchema.tableCycleHistory);
    batch.delete(UserDatabaseSchema.tableKitchenInventory);
    batch.delete(UserDatabaseSchema.tableDailyIntake);
    batch.delete(UserDatabaseSchema.tableDailyNutrientTotals);
    batch.delete(UserDatabaseSchema.tableShoppingList);
    batch.delete(UserDatabaseSchema.tableFavorites);
    batch.delete(UserDatabaseSchema.tableSyncMetadata);
    await batch.commit(noResult: true);

    await seedIfEmpty();
  }
}
