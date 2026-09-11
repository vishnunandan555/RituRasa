# Flutter App — Backend-First SRS & Build Plan
## Scope: Local App Backend + Integration with SimpleNutriAPI

**Status:** Backend-first implementation plan  
**Primary objective:** Build the Flutter application's complete internal backend/data layer before the UI is finalized.

---

## 1. Scope Clarification

The architecture has **two backend/data systems**:

### A. SimpleNutriAPI — Remote Nutritional API

Repository:
`https://github.com/vishnunandan555/SimpleNutriAPI`

Its responsibility is to provide the app with canonical nutritional knowledge and structured recommendation data:

- Foods
- Nutrients
- Ingredients
- Recipes
- Recipe nutrition per serving
- Regional/cuisine/taxonomy data
- Cycle phases
- Nutrition-focus data
- Food/recipe recommendations
- Kitchen-aware recommendation inputs
- Shopping-list generation
- Canonical IDs
- Offline seed/bundle data where applicable

The Flutter app should treat this API as a **data provider / domain knowledge source**, not as the application's entire backend.

### B. Flutter Local Backend

The Flutter application must have its own local backend/data layer responsible for:

- User profile
- Cycle history and current cycle state
- User preferences
- Kitchen inventory
- Daily food intake
- Daily nutrient totals
- Nutrition progress
- User-selected/consumed meals
- Local shopping list state
- Local recommendation orchestration
- Offline-first behavior
- Local persistence
- Synchronization/fallback rules
- Application-level business logic
- Versioning/migrations
- Data integrity

The local backend must remain usable even when the remote API is unavailable.

---

# 2. Core Architectural Principle

The app should be built as:

```text
Flutter UI
    ↓
Application / Presentation Controllers
    ↓
LOCAL APP BACKEND
    ├── User/Profile Service
    ├── Cycle Service
    ├── Nutrition Service
    ├── Kitchen Service
    ├── Meal/Recipe Service
    ├── Intake Service
    ├── Shopping Service
    └── Sync / Remote Data Service
          ↓
     Repository Layer
       ├── Local Repository
       └── Remote Repository
              ↓
       SimpleNutriAPI
```

The UI must **never directly call HTTP endpoints or SQLite tables**.

All UI requests should pass through the local application backend.

---

# 3. Responsibilities of the Local Backend

## 3.1 Profile Service

Stores and provides:

- User age
- Diet type
- Food preferences
- Allergies / exclusions
- Region
- Cuisine preference
- Cycle settings
- Other non-sensitive nutrition preferences used by the app

The Profile Service must expose typed operations such as:

```text
getProfile()
updateProfile()
setDiet()
setPreferences()
setRestrictions()
```

The service should not contain UI-specific formatting.

---

# 4. Cycle Service

The local Cycle Service is the authoritative source for the user's current cycle state.

### Inputs

- Last known period start
- Optional period end
- Typical cycle length
- Historical cycle starts
- Optional future period estimates

### Outputs

```text
CycleState
├── currentCycleDay
├── currentPhase
├── phaseStart
├── phaseEnd
├── estimatedNextPeriod
├── daysUntilNextPeriod
└── confidence / estimation metadata
```

### Important rule

Cycle calculation should happen **locally**.

Do not make the application dependent on the remote API for calculating the current day/phase.

The SimpleNutriAPI may provide phase definitions and nutrition-focus metadata, while Flutter owns the user's actual cycle state.

---

# 5. Nutrition Service

This is the main application-level orchestration layer.

Responsibilities:

1. Determine current cycle context.
2. Retrieve appropriate nutrition focus.
3. Retrieve user-specific dietary constraints.
4. Retrieve kitchen inventory.
5. Retrieve relevant food/recipe data.
6. Rank or request recommendations.
7. Calculate daily nutrition status.
8. Produce actionable meal recommendations.

Conceptually:

```text
Profile
   +
CycleState
   +
NutritionFocus
   +
Kitchen
   +
Food/Recipe Knowledge
          ↓
   Nutrition Service
          ↓
     Recommendations
```

The Nutrition Service should not depend exclusively on an API request being successful.

---

# 6. Remote Nutritional Data Service

Create a dedicated remote client for SimpleNutriAPI.

Suggested responsibilities:

```text
SimpleNutriApiClient
├── fetchFoods()
├── searchFoods()
├── fetchFood()
├── fetchFoodNutrients()
├── searchIngredients()
├── fetchIngredient()
├── fetchNutrients()
├── fetchRecipes()
├── searchRecipes()
├── fetchRecipe()
├── fetchCyclePhases()
├── estimateCycle()
├── recommendFoods()
├── recommendRecipes()
└── generateShoppingList()
```

This client should contain:

- Base URL configuration
- HTTP timeout
- Retry policy
- Request serialization
- Response deserialization
- Error mapping
- API version handling
- Connectivity-aware behavior

The rest of the application should never know the API's HTTP details.

---

# 7. Local Database

The Flutter app should have its own SQLite database.

This database is **not simply a copy of the remote API database**.

It should contain two categories of data:

## A. Cached/reference nutritional data

Examples:

- Foods
- Nutrients
- Ingredients
- Recipes
- Recipe ingredients
- Recipe nutrition
- Taxonomies
- Cycle phase metadata

These can be seeded from the SimpleNutriAPI/mobile bundle and refreshed when appropriate.

## B. User-owned application data

Examples:

- Profile
- Cycle history
- Kitchen inventory
- Daily intake
- Shopping list
- User preferences
- Local recommendation state
- Favorite foods/recipes
- Local timestamps
- Sync metadata

User-owned data must remain available independently of network connectivity.

---

# 8. Suggested Local Database Schema

## user_profile

```text
id
age
diet_type
region
cuisine
created_at
updated_at
```

## user_preferences

```text
user_id
preferred_food_ids
excluded_food_ids
allergies
updated_at
```

## cycle_history

```text
id
period_start
period_end
cycle_length
created_at
updated_at
```

## kitchen_inventory

```text
id
food_id
quantity
unit
added_at
updated_at
expires_at (optional)
```

## daily_intake

```text
id
date
food_id
recipe_id (nullable)
quantity
unit
meal_type
logged_at
```

## daily_nutrient_totals

Prefer calculating these from `daily_intake`, with optional materialized/cache values.

```text
date
energy_kcal
protein_g
carbohydrate_g
fat_g
fiber_g
iron_mg
calcium_mg
magnesium_mg
zinc_mg
...
calculated_at
```

## shopping_list

```text
id
ingredient_id / food_id
quantity
unit
source_recipe_ids
is_checked
created_at
updated_at
```

## favorites

```text
id
entity_type
entity_id
created_at
```

## sync_metadata

```text
key
value
updated_at
```

---

# 9. Single Source of Truth Rules

The app needs explicit ownership rules.

### User state

**Local database is authoritative.**

Examples:

- Profile
- Cycle history
- Kitchen
- Intake
- Shopping list
- Favorites

### Nutritional reference data

**SimpleNutriAPI is authoritative.**

Examples:

- Nutrient composition
- Canonical food definitions
- Recipes
- Recipe nutrition
- Taxonomies
- Nutrition-focus metadata

### Derived application state

**Local application backend calculates it.**

Examples:

- Current cycle day
- Days until next period
- Daily nutrient totals
- Progress percentages
- Current recommendation context
- Kitchen matches
- “What should I eat?” result state

This separation prevents API outages from breaking the app.

---

# 10. Offline-First Behavior

The app must work without internet after initial setup/data availability.

### Online

```text
Local request
   ↓
Check local data
   ↓
If sufficient → use local
   ↓
If missing/stale → fetch API
   ↓
Persist/update local cache
   ↓
Return result
```

### Offline

```text
Local request
   ↓
Local database
   ↓
Return available result
```

If data is unavailable locally:

```text
OfflineDataUnavailable
```

must be returned cleanly rather than producing a networking error in the UI.

---

# 11. Nutritional Reference Data Synchronization

The local database should support versioned nutritional data.

Use a metadata record such as:

```text
data_version
schema_version
last_updated
source_version
```

The app should be able to determine:

```text
Do I already have the required food/recipe data?
Is my dataset older than the remote dataset?
Can I continue offline?
```

Do not silently replace the user's local database.

Reference-data updates should be migrations/replacements of reference tables while preserving user tables.

---

# 12. Recipe Handling

Recipe data from SimpleNutriAPI should include:

- Canonical recipe ID
- Recipe name
- Region
- Cuisine
- Meal type
- Ingredients
- Canonical food IDs
- Ingredient quantities
- Servings
- Instructions
- Nutrition per serving
- Metadata/provenance

The local recipe model should preserve the canonical recipe ID.

Never use the recipe's display name as the primary identifier.

---

# 13. Kitchen Backend

The kitchen is a first-class local domain.

Operations:

```text
addFoodToKitchen()
updateKitchenQuantity()
removeFoodFromKitchen()
clearKitchenItem()
getKitchen()
searchKitchen()
```

The kitchen stores canonical `food_id` references wherever possible.

Example:

```text
KitchenItem
├── foodId
├── quantity
├── unit
├── addedAt
└── optionalExpiry
```

The UI can display localized names, aliases, or regional names without changing the stored ID.

---

# 14. What Should I Eat — Backend Flow

This feature should be implemented as an application service.

```text
getWhatShouldIEat()
```

Process:

1. Load profile.
2. Load current cycle state.
3. Determine nutrition focus.
4. Load kitchen inventory.
5. Load exclusions/preferences.
6. Query local recipe/food data.
7. If required data is unavailable locally, call SimpleNutriAPI.
8. Apply recommendation/ranking logic.
9. Return structured recommendation results.
10. Cache the result if useful.

Result:

```text
RecommendationResult
├── nutritionFocus
├── meals
├── foods
├── availabilitySummary
└── generatedAt
```

---

# 15. Daily Intake Backend

Food logging must be local.

Operations:

```text
logFood()
logRecipe()
removeIntake()
getDailyIntake()
getDailyNutrientTotals()
calculateDailyNutrientProgress()
```

When a recipe is logged:

```text
Recipe
   ↓
nutrition_per_serving
   ↓
quantity/servings consumed
   ↓
DailyIntake
   ↓
DailyNutrientTotals
```

Do not make a network request simply because the user tapped “I ate this”.

---

# 16. Nutrition Progress Calculation

The local backend calculates:

```text
progress = consumed / reference_target
```

with appropriate handling for:

- missing nutrient targets
- zero targets
- over-target values
- nutrient units
- daily reset
- date boundaries

The reference targets should come from the app's versioned nutrition-reference configuration.

The UI should receive a simple typed result:

```text
NutrientProgress
├── nutrient
├── consumed
├── target
├── percentage
└── status
```

The UI should not calculate these values itself.

---

# 17. Shopping List Backend

The shopping list is local application state.

Primary flow:

```text
Recipe selected
      ↓
Compare recipe ingredients
      ↓
Kitchen inventory
      ↓
Missing quantities
      ↓
Deduplicate
      ↓
ShoppingList
```

Operations:

```text
generateShoppingList()
addShoppingItem()
removeShoppingItem()
checkShoppingItem()
uncheckShoppingItem()
clearCompletedItems()
```

If the remote API already provides shopping-list generation, it may be used as a reference/fallback, but the local application backend should be capable of performing the operation using locally available recipe + kitchen data.

---

# 18. API Adapter vs Domain Models

Do not use raw API JSON models throughout the application.

Use three conceptual layers:

```text
API DTOs
   ↓
Mapper
   ↓
Domain Models
   ↓
Local Persistence Models
```

Example:

```text
ApiRecipeDto
      ↓
RecipeMapper
      ↓
Recipe
      ↓
RecipeEntity
```

This protects the app from small API response changes.

---

# 19. Error Handling

Create a local application error model.

Examples:

```text
NetworkUnavailable
ApiUnavailable
ApiTimeout
InvalidApiResponse
LocalDatabaseError
MigrationError
ReferenceDataMissing
InvalidUserData
FoodNotFound
RecipeNotFound
```

The UI must receive meaningful domain errors rather than raw exceptions such as:

```text
DioException
SocketException
SQLiteException
```

---

# 20. Caching Strategy

Cache nutritional/reference data locally.

Prioritize caching:

### Tier 1
- Current profile
- Current cycle
- Kitchen
- Intake
- Shopping list

### Tier 2
- Recently viewed foods
- Recently viewed recipes
- Current recommendation results

### Tier 3
- Full reference bundle

Because an offline SQLite bundle already exists, the app can ship with a useful reference dataset from the beginning.

---

# 21. Security and Privacy

The local backend must assume user data is private.

Do not send these to SimpleNutriAPI unless there is a specific requirement:

- Full personal history
- Daily intake history
- User profile details
- Private kitchen inventory
- Shopping history

The remote API should receive only the minimum contextual information needed for a recommendation request.

For example, sending canonical IDs/preferences is preferable to sending unnecessary personal data.

---

# 22. Package / Project Structure

Suggested backend-first structure:

```text
lib/
├── core/
│   ├── errors/
│   ├── network/
│   ├── database/
│   ├── config/
│   └── utils/
│
├── data/
│   ├── local/
│   │   ├── database/
│   │   ├── dao/
│   │   └── entities/
│   │
│   ├── remote/
│   │   ├── api/
│   │   ├── dto/
│   │   └── mappers/
│   │
│   └── repositories/
│
├── domain/
│   ├── models/
│   ├── services/
│   └── repositories/
│
└── features/
    ├── profile/
    ├── cycle/
    ├── nutrition/
    ├── kitchen/
    ├── recipes/
    ├── intake/
    └── shopping/
```

UI widgets/screens can later sit above this without requiring backend restructuring.

---

# 23. Recommended Technologies

For the backend/data layer:

### State / dependency injection
- Riverpod

### Networking
- Dio or `http`

### Local database
- Drift preferred for strongly typed SQLite
- `sqflite` acceptable if the implementation remains disciplined

### Local preferences
- SharedPreferences for very small settings only

### Serialization
- `json_serializable` / generated model serialization where useful

The choice should prioritize stability and type safety rather than package count.

---

# 24. Testing Strategy

The backend must be testable without rendering any UI.

## Unit tests

### Cycle
- cycle-day calculation
- phase calculation
- next-period estimate
- boundary days

### Nutrition
- nutrition-focus mapping
- nutrient calculations
- progress calculation
- unit conversions

### Kitchen
- add/update/remove
- duplicate food handling
- quantity handling

### Recipes
- recipe nutrition mapping
- nutrition-per-serving calculations
- canonical ID integrity

### Intake
- logging foods
- logging recipes
- removing entries
- daily aggregation

### Shopping
- missing-ingredient calculation
- quantity deduction
- deduplication
- checked/unchecked state

---

# 25. Integration Tests

At minimum, test these complete flows:

### Flow A — Offline

```text
Seed database
→ create profile
→ set cycle
→ add kitchen foods
→ retrieve recommendations
→ select recipe
→ log recipe
→ calculate nutrient totals
→ generate shopping list
```

### Flow B — Online fallback

```text
Local data missing
→ request remote API
→ receive response
→ map DTO
→ persist locally
→ return domain model
```

### Flow C — API unavailable

```text
Remote request
→ timeout
→ local cache available
→ return local data
```

### Flow D — Reference data update

```text
Existing user database
→ receive newer dataset
→ update reference tables
→ preserve profile
→ preserve kitchen
→ preserve intake
→ preserve shopping list
```

---

# 26. Backend Build Order

Do not build according to screen order.

Build according to dependency order:

## Phase 1 — Project foundation

- Flutter project
- Environment configuration
- Dependency injection
- Error model
- Domain conventions

## Phase 2 — Local database

- SQLite/Drift schema
- migrations
- DAOs
- seed/import mechanism
- database versioning

## Phase 3 — Remote API

- HTTP client
- DTOs
- mappers
- API error handling
- endpoint adapters

## Phase 4 — Repository layer

Implement:

```text
FoodRepository
RecipeRepository
NutritionRepository
ProfileRepository
CycleRepository
KitchenRepository
IntakeRepository
ShoppingRepository
```

## Phase 5 — Domain services

Implement:

```text
CycleService
NutritionService
RecommendationService
KitchenMatchingService
IntakeService
ShoppingService
```

## Phase 6 — Offline/online orchestration

- cache-first reads
- remote fallback
- reference-data refresh
- failure handling

## Phase 7 — Backend test suite

- unit tests
- repository tests
- database tests
- integration tests

## Phase 8 — Freeze backend contract

Only after all critical flows pass should the UI be built against it.

---

# 27. Backend Definition of Done

The Flutter backend is considered complete when:

- [ ] App can start entirely from local data.
- [ ] Local database can be created/migrated safely.
- [ ] SimpleNutriAPI can be queried through a dedicated client.
- [ ] API DTOs never leak directly into UI/domain code.
- [ ] Profile persists locally.
- [ ] Cycle history persists locally.
- [ ] Current cycle is calculated locally.
- [ ] Nutrition focus can be resolved locally.
- [ ] Kitchen inventory works offline.
- [ ] Recipes work offline.
- [ ] Recipe nutrition-per-serving works offline.
- [ ] Food/recipe recommendations work with available local data.
- [ ] Daily intake works offline.
- [ ] Daily nutrient totals work offline.
- [ ] Nutrition progress works offline.
- [ ] Shopping list works offline.
- [ ] Missing ingredients can be generated locally.
- [ ] Remote API can refresh reference data.
- [ ] API failure does not destroy local functionality.
- [ ] User-owned data survives reference-data refreshes.
- [ ] Database migrations are tested.
- [ ] Critical business logic has unit tests.
- [ ] Main workflows have integration tests.
- [ ] UI can consume the backend entirely through typed services/repositories.

---

# 28. What Is Explicitly NOT in This Phase

Do not spend backend time on:

- Final UI design
- Animations
- Visual styling
- Screen layouts
- Marketing copy
- Social/community features
- Chatbot
- Wearables
- Health Connect
- Cloud user accounts
- Cross-device synchronization
- Grocery delivery integrations
- Medical diagnosis
- Supplement prescription

These can be evaluated later.

---

# 29. Final Architecture Goal

The finished Flutter backend should make the eventual UI almost trivial to connect.

A UI action should look conceptually like:

```text
User taps "What should I eat?"
        ↓
NutritionController
        ↓
RecommendationService
        ↓
ProfileRepository
CycleRepository
KitchenRepository
RecipeRepository
NutritionRepository
        ↓
RecommendationResult
        ↓
UI
```

And:

```text
User taps "I ate this"
        ↓
IntakeService
        ↓
Local Database
        ↓
DailyNutrientTotals
        ↓
NutritionProgress
        ↓
UI
```

And:

```text
User taps "Add missing ingredients"
        ↓
ShoppingService
        ↓
Local Database
        ↓
ShoppingList
        ↓
UI
```

The UI should therefore be a **consumer of the local application backend**, while SimpleNutriAPI remains the **remote nutritional knowledge/data provider**.

That separation is the key architectural requirement for this project.
