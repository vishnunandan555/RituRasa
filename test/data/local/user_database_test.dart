import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:riturasa/data/local/database/user_database_schema.dart';
import 'package:riturasa/data/local/dao/profile_dao.dart';
import 'package:riturasa/data/local/dao/cycle_dao.dart';
import 'package:riturasa/data/local/dao/kitchen_dao.dart';
import 'package:riturasa/data/local/dao/intake_dao.dart';
import 'package:riturasa/data/local/dao/shopping_dao.dart';
import 'package:riturasa/data/local/dao/sync_metadata_dao.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late ProfileDao profileDao;
  late CycleDao cycleDao;
  late KitchenDao kitchenDao;
  late IntakeDao intakeDao;
  late ShoppingDao shoppingDao;
  late SyncMetadataDao syncMetadataDao;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: UserDatabaseSchema.currentVersion,
        onCreate: UserDatabaseSchema.onCreate,
      ),
    );

    profileDao = ProfileDao(db);
    cycleDao = CycleDao(db);
    kitchenDao = KitchenDao(db);
    intakeDao = IntakeDao(db);
    shoppingDao = ShoppingDao(db);
    syncMetadataDao = SyncMetadataDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('User Database & DAOs Unit Tests', () {
    test('ProfileDao: upsert and retrieve profile and preferences', () async {
      final now = DateTime.now().toIso8601String();
      final profileRes = await profileDao.upsertProfile({
        'id': 'user_1',
        'age': 28,
        'diet_type': 'vegetarian',
        'region': 'South India',
        'cuisine': 'South Indian',
        'created_at': now,
        'updated_at': now,
      });
      expect(profileRes.isOk, isTrue);

      final fetched = await profileDao.getProfile();
      expect(fetched.isOk, isTrue);
      expect(fetched.valueOrNull?['id'], equals('user_1'));
      expect(fetched.valueOrNull?['age'], equals(28));
      expect(fetched.valueOrNull?['diet_type'], equals('vegetarian'));

      final prefRes = await profileDao.upsertPreferences({
        'user_id': 'user_1',
        'preferred_food_ids_json': '["ragi", "spinach"]',
        'excluded_food_ids_json': '["mushroom"]',
        'allergies_json': '["peanuts"]',
        'updated_at': now,
      });
      expect(prefRes.isOk, isTrue);

      final fetchedPref = await profileDao.getPreferences('user_1');
      expect(fetchedPref.isOk, isTrue);
      expect(fetchedPref.valueOrNull?['allergies_json'], equals('["peanuts"]'));
    });

    test('CycleDao: insert cycle log and query latest', () async {
      await cycleDao.insertCycleLog({
        'id': 'cycle_1',
        'period_start': '2026-08-10',
        'period_end': '2026-08-15',
        'cycle_length': 28,
        'created_at': '2026-08-10T00:00:00Z',
        'updated_at': '2026-08-10T00:00:00Z',
      });

      await cycleDao.insertCycleLog({
        'id': 'cycle_2',
        'period_start': '2026-09-07',
        'period_end': null,
        'cycle_length': 28,
        'created_at': '2026-09-07T00:00:00Z',
        'updated_at': '2026-09-07T00:00:00Z',
      });

      final allLogs = await cycleDao.getCycleLogs();
      expect(allLogs.isOk, isTrue);
      expect(allLogs.valueOrNull?.length, equals(2));
      expect(allLogs.valueOrNull?.first['id'], equals('cycle_2'));

      final latest = await cycleDao.getLatestCycleLog();
      expect(latest.isOk, isTrue);
      expect(latest.valueOrNull?['period_start'], equals('2026-09-07'));
    });

    test('KitchenDao: add items, remove item, clear pantry', () async {
      final now = DateTime.now().toIso8601String();
      await kitchenDao.addOrUpdateItem({
        'id': 'k_1',
        'food_id': 'ragi',
        'quantity': 500.0,
        'unit': 'g',
        'added_at': now,
        'updated_at': now,
      });

      await kitchenDao.addOrUpdateItem({
        'id': 'k_2',
        'food_id': 'spinach',
        'quantity': 1.0,
        'unit': 'bunch',
        'added_at': now,
        'updated_at': now,
      });

      final inventory = await kitchenDao.getInventory();
      expect(inventory.isOk, isTrue);
      expect(inventory.valueOrNull?.length, equals(2));

      await kitchenDao.removeItem('ragi');
      final afterRemove = await kitchenDao.getInventory();
      expect(afterRemove.valueOrNull?.length, equals(1));
      expect(afterRemove.valueOrNull?.first['food_id'], equals('spinach'));

      await kitchenDao.clearInventory();
      final afterClear = await kitchenDao.getInventory();
      expect(afterClear.valueOrNull?.isEmpty, isTrue);
    });

    test('IntakeDao: log intake, query by date, and save daily totals', () async {
      final now = DateTime.now().toIso8601String();
      await intakeDao.logIntake({
        'id': 'intake_1',
        'date': '2026-09-11',
        'food_id': 'ragi_roti',
        'recipe_id': 'recipe_ragi_roti',
        'name': 'Ragi Roti',
        'quantity': 2.0,
        'unit': 'servings',
        'meal_type': 'breakfast',
        'nutrients_json': '{"iron_mg": 4.5, "calcium_mg": 344.0}',
        'logged_at': now,
      });

      final entries = await intakeDao.getIntakesForDate('2026-09-11');
      expect(entries.isOk, isTrue);
      expect(entries.valueOrNull?.length, equals(1));
      expect(entries.valueOrNull?.first['name'], equals('Ragi Roti'));

      await intakeDao.upsertDailyNutrientTotals({
        'date': '2026-09-11',
        'energy_kcal': 450.0,
        'protein_g': 12.0,
        'carbohydrate_g': 65.0,
        'fat_g': 8.0,
        'fiber_g': 9.0,
        'iron_mg': 4.5,
        'calcium_mg': 344.0,
        'magnesium_mg': 80.0,
        'zinc_mg': 2.5,
        'potassium_mg': 300.0,
        'sodium_mg': 150.0,
        'vitamin_c_mg': 5.0,
        'folate_ug': 40.0,
        'vitamin_b6_mg': 0.3,
        'calculated_at': now,
      });

      final totals = await intakeDao.getDailyNutrientTotals('2026-09-11');
      expect(totals.isOk, isTrue);
      expect(totals.valueOrNull?['iron_mg'], equals(4.5));
      expect(totals.valueOrNull?['calcium_mg'], equals(344.0));
    });

    test('ShoppingDao: upsert, toggle checked, and remove checked', () async {
      final now = DateTime.now().toIso8601String();
      await shoppingDao.upsertItem({
        'id': 'shop_1',
        'food_id': 'sesame_seeds',
        'name': 'Sesame Seeds',
        'quantity': 100.0,
        'unit': 'g',
        'source_recipe_ids_json': '["recipe_sesame_ladoo"]',
        'is_checked': 0,
        'created_at': now,
        'updated_at': now,
      });

      await shoppingDao.upsertItem({
        'id': 'shop_2',
        'food_id': 'jaggery',
        'name': 'Jaggery',
        'quantity': 200.0,
        'unit': 'g',
        'source_recipe_ids_json': '["recipe_sesame_ladoo"]',
        'is_checked': 0,
        'created_at': now,
        'updated_at': now,
      });

      var list = await shoppingDao.getShoppingList();
      expect(list.valueOrNull?.length, equals(2));

      await shoppingDao.toggleChecked('shop_1', true);
      list = await shoppingDao.getShoppingList();
      final checkedItem = list.valueOrNull?.firstWhere((i) => i['id'] == 'shop_1');
      expect(checkedItem?['is_checked'], equals(1));

      await shoppingDao.removeChecked();
      list = await shoppingDao.getShoppingList();
      expect(list.valueOrNull?.length, equals(1));
      expect(list.valueOrNull?.first['id'], equals('shop_2'));
    });

    test('SyncMetadataDao: get and set version metadata', () async {
      await syncMetadataDao.setMetadata('version', '1.0.0');
      final val = await syncMetadataDao.getMetadata('version');
      expect(val.isOk, isTrue);
      expect(val.valueOrNull, equals('1.0.0'));
    });
  });
}
