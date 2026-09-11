# RituRasa — Backend Contract Freeze (v1.0.0)

This document formalizes the typed public interface between the **RituRasa Local Application Backend** and the future **Flutter Presentation / UI Layer**.

---

## 1. Architectural Guarantee

1. **Zero Raw HTTP Calls in UI**: All remote operations pass through `SimpleNutriApiService` and domain repositories.
2. **Zero Raw SQL in UI**: All data persistence operations pass through typed domain models, DAOs, and repository interfaces.
3. **100% Offline Autonomy**: The application functions without degraded capability when disconnected from the network, querying `nutrition_reference.db` and writing to `riturasa_user.db`.
4. **Data Isolation**: User history (`riturasa_user.db`) is isolated from reference knowledge (`nutrition_reference.db`), ensuring data updates never corrupt user state.

---

## 2. Riverpod Dependency Injection & Controller Surface

UI screens consume the backend exclusively via these Riverpod providers:

### 2.1 Profile (`lib/features/profile/profile_controller.dart`)
```dart
final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>;

// State:
ProfileState {
  UserProfile? profile;
  UserPreferences? preferences;
  bool isLoading;
  String? errorMessage;
}

// Controller Methods:
Future<void> loadProfile();
Future<Result<void>> updateProfile(UserProfile profile);
```

### 2.2 Cycle (`lib/features/cycle/cycle_controller.dart`)
```dart
final cycleControllerProvider = StateNotifierProvider<CycleController, CycleStateModel>;

// State:
CycleStateModel {
  CycleRecord? latestRecord;
  CycleDayState? currentState; // Contains currentCycleDay, phaseInfo, nextPeriodDate, daysRemaining
  bool isLoading;
  String? errorMessage;
}

// Controller Methods:
Future<void> loadCycle();
Future<Result<void>> logPeriodStart(DateTime periodStart, {int cycleLength = 28});
```

### 2.3 Kitchen Pantry (`lib/features/kitchen/kitchen_controller.dart`)
```dart
final kitchenControllerProvider = StateNotifierProvider<KitchenController, KitchenState>;

// State:
KitchenState {
  List<KitchenItem> items;
  List<FoodItem> searchResults;
  bool isLoading;
  String? errorMessage;
}

// Controller Methods:
Future<void> loadInventory();
Future<void> searchFoods(String query); // Sub-20ms FTS5 search
Future<Result<void>> addItem({required String foodId, String? foodName, required double quantity, required String unit});
Future<Result<void>> removeItem(String foodId);
```

### 2.4 Daily Intake & RDA Progress (`lib/features/intake/intake_controller.dart`)
```dart
final intakeControllerProvider = StateNotifierProvider<IntakeController, IntakeState>;

// State:
IntakeState {
  String date; // YYYY-MM-DD
  List<IntakeEntry> entries;
  DailyProgressSummary? progressSummary; // Contains iron, calcium, protein progress percentages and statuses
  bool isLoading;
  String? errorMessage;
}

// Controller Methods:
Future<void> loadIntakesForDate(String date);
Future<Result<void>> logMeal({
  String? foodId,
  String? recipeId,
  required String name,
  required double quantity,
  required String unit,
  required MealType mealType,
  required Map<String, double> nutrients,
});
Future<Result<void>> removeIntake(String id);
```

### 2.5 Shopping Checklist (`lib/features/shopping/shopping_controller.dart`)
```dart
final shoppingControllerProvider = StateNotifierProvider<ShoppingController, ShoppingState>;

// State:
ShoppingState {
  List<ShoppingListItem> items;
  bool isLoading;
  String? errorMessage;
}

// Controller Methods:
Future<void> loadShoppingList();
Future<Result<void>> toggleChecked(String id, bool isChecked);
Future<Result<void>> deleteItem(String id);
Future<Result<void>> clearChecked();
```

### 2.6 Recommendation Engine ("What Should I Eat?") (`lib/features/nutrition/recommendation_controller.dart`)
```dart
final recommendationControllerProvider = StateNotifierProvider<RecommendationController, RecommendationState>;

// State:
RecommendationState {
  RecommendationResult? result; // cyclePhase, rankedRecipes, rankedFoods, isOfflineResult
  bool isLoading;
  String? errorMessage;
}

// Controller Methods:
Future<void> refreshRecommendations({bool forceRemote = false});
```

---

## 3. Domain Failure Types (`lib/core/errors/failure.dart`)

All domain and repository methods return `Result<T>` containing either the value or a sealed `Failure`:
- `NetworkFailure`: Connectivity unavailable.
- `ApiTimeoutFailure`: Remote API request timed out.
- `ApiResponseFailure`: Non-200 HTTP code or malformed remote response.
- `DatabaseFailure`: SQLite disk or query error.
- `NotFoundFailure`: Entity not found in database.
- `CycleCalculationFailure`: Date math or cycle calculation error.
- `OfflineDataUnavailableFailure`: Operation requires remote sync while offline.
- `ValidationFailure`: Invalid user input constraints.
