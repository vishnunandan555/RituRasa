import 'package:sqflite/sqflite.dart';

/// Defines the SQLite table schemas, indexes, and versioned migrations
/// for the authoritative user state database (`riturasa_user.db`).
class UserDatabaseSchema {
  UserDatabaseSchema._();

  static const int currentVersion = 1;

  static const String tableProfile = 'user_profile';
  static const String tablePreferences = 'user_preferences';
  static const String tableCycleHistory = 'cycle_history';
  static const String tableKitchenInventory = 'kitchen_inventory';
  static const String tableDailyIntake = 'daily_intake';
  static const String tableDailyNutrientTotals = 'daily_nutrient_totals';
  static const String tableShoppingList = 'shopping_list';
  static const String tableFavorites = 'favorites';
  static const String tableSyncMetadata = 'sync_metadata';

  /// SQL DDL to create all tables for version 1
  static Future<void> onCreate(Database db, int version) async {
    final batch = db.batch();

    // 1. user_profile
    batch.execute('''
      CREATE TABLE $tableProfile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL DEFAULT 'Ananya Sharma',
        age INTEGER NOT NULL,
        prakriti TEXT NOT NULL DEFAULT 'Pitta-Vata',
        agni TEXT NOT NULL DEFAULT 'Tikshna',
        diet_type TEXT NOT NULL,
        region TEXT NOT NULL,
        cuisine TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. user_preferences
    batch.execute('''
      CREATE TABLE $tablePreferences (
        user_id TEXT PRIMARY KEY,
        preferred_food_ids_json TEXT NOT NULL DEFAULT '[]',
        excluded_food_ids_json TEXT NOT NULL DEFAULT '[]',
        allergies_json TEXT NOT NULL DEFAULT '[]',
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $tableProfile(id) ON DELETE CASCADE
      )
    ''');

    // 3. cycle_history
    batch.execute('''
      CREATE TABLE $tableCycleHistory (
        id TEXT PRIMARY KEY,
        period_start TEXT NOT NULL,
        period_end TEXT,
        cycle_length INTEGER NOT NULL DEFAULT 28,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    batch.execute('''
      CREATE INDEX ix_cycle_history_start ON $tableCycleHistory (period_start DESC)
    ''');

    // 4. kitchen_inventory
    batch.execute('''
      CREATE TABLE $tableKitchenInventory (
        id TEXT PRIMARY KEY,
        food_id TEXT NOT NULL,
        quantity REAL NOT NULL DEFAULT 1.0,
        unit TEXT NOT NULL DEFAULT 'units',
        added_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        expires_at TEXT
      )
    ''');
    batch.execute('''
      CREATE UNIQUE INDEX ix_kitchen_inventory_food_id ON $tableKitchenInventory (food_id)
    ''');

    // 5. daily_intake
    batch.execute('''
      CREATE TABLE $tableDailyIntake (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        food_id TEXT,
        recipe_id TEXT,
        name TEXT NOT NULL,
        quantity REAL NOT NULL DEFAULT 1.0,
        unit TEXT NOT NULL DEFAULT 'serving',
        meal_type TEXT NOT NULL DEFAULT 'other',
        nutrients_json TEXT NOT NULL DEFAULT '{}',
        logged_at TEXT NOT NULL
      )
    ''');
    batch.execute('''
      CREATE INDEX ix_daily_intake_date ON $tableDailyIntake (date DESC)
    ''');
    batch.execute('''
      CREATE INDEX ix_daily_intake_meal_type ON $tableDailyIntake (meal_type)
    ''');

    // 6. daily_nutrient_totals
    batch.execute('''
      CREATE TABLE $tableDailyNutrientTotals (
        date TEXT PRIMARY KEY,
        energy_kcal REAL NOT NULL DEFAULT 0.0,
        protein_g REAL NOT NULL DEFAULT 0.0,
        carbohydrate_g REAL NOT NULL DEFAULT 0.0,
        fat_g REAL NOT NULL DEFAULT 0.0,
        fiber_g REAL NOT NULL DEFAULT 0.0,
        iron_mg REAL NOT NULL DEFAULT 0.0,
        calcium_mg REAL NOT NULL DEFAULT 0.0,
        magnesium_mg REAL NOT NULL DEFAULT 0.0,
        zinc_mg REAL NOT NULL DEFAULT 0.0,
        potassium_mg REAL NOT NULL DEFAULT 0.0,
        sodium_mg REAL NOT NULL DEFAULT 0.0,
        vitamin_c_mg REAL NOT NULL DEFAULT 0.0,
        folate_ug REAL NOT NULL DEFAULT 0.0,
        vitamin_b6_mg REAL NOT NULL DEFAULT 0.0,
        calculated_at TEXT NOT NULL
      )
    ''');

    // 7. shopping_list
    batch.execute('''
      CREATE TABLE $tableShoppingList (
        id TEXT PRIMARY KEY,
        food_id TEXT NOT NULL,
        name TEXT NOT NULL,
        quantity REAL NOT NULL DEFAULT 1.0,
        unit TEXT NOT NULL DEFAULT 'units',
        source_recipe_ids_json TEXT NOT NULL DEFAULT '[]',
        is_checked INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    batch.execute('''
      CREATE INDEX ix_shopping_list_checked ON $tableShoppingList (is_checked)
    ''');

    // 8. favorites
    batch.execute('''
      CREATE TABLE $tableFavorites (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    batch.execute('''
      CREATE UNIQUE INDEX ix_favorites_type_entity ON $tableFavorites (entity_type, entity_id)
    ''');

    // 9. sync_metadata
    batch.execute('''
      CREATE TABLE $tableSyncMetadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await batch.commit(noResult: true);
  }

  /// Versioned schema migrations
  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migrations for future database version bumps
  }

  /// Ensure new columns exist even if user DB was created previously
  static Future<void> onOpen(Database db) async {
    try {
      await db.execute("ALTER TABLE $tableProfile ADD COLUMN name TEXT DEFAULT 'Ananya Sharma'");
    } catch (_) {}
    try {
      await db.execute("ALTER TABLE $tableProfile ADD COLUMN prakriti TEXT DEFAULT 'Pitta-Vata'");
    } catch (_) {}
    try {
      await db.execute("ALTER TABLE $tableProfile ADD COLUMN agni TEXT DEFAULT 'Tikshna'");
    } catch (_) {}
  }
}
