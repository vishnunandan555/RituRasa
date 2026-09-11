# Flutter UI — 5-Screen Product SRS

## Final Primary Navigation

1. **Home**
2. **Eat**
3. **Kitchen**
4. **Cart**
5. **Profile**

Core loop:

**Understand your context → decide what to eat → use what you have → buy what is missing → eat/log → see nutrition progress.**

The UI consumes the local Flutter application backend. `SimpleNutriAPI` is the nutritional/reference data provider and is not called directly by UI widgets.

---

# 1. Home

**Purpose:** Daily command center. Answer quickly: where am I in my cycle, how am I doing nutritionally, and what should I do next?

### Header
- Greeting/name
- Current date
- Profile/avatar
- Optional notification/status icon

### Cycle card
Show:
- Current phase
- Cycle day
- Estimated cycle length
- Estimated next period date
- Days until next period
- Simple cycle progress visual

Example:

> **Luteal Phase**  
> Cycle Day 18 of ~28  
> Next period in 10 days

### Today's nutrition
Show a small number of relevant progress indicators, not every nutrient.

Potentially:
- Protein
- Iron
- Calcium
- Fiber
- Vitamin C
- Folate
- Magnesium

Example:

```text
Protein       ████████░░  78%
Iron          ██████░░░░  61%
Vitamin C     █████████░  89%
Fiber         ███████░░░  72%
```

The displayed nutrients should be selected from the current nutrition focus and daily intake.

### Today's nutrition focus
Example:

> **Today's focus**  
> Iron · Vitamin C · Protein

Include a short evidence-informed explanation. Avoid medical/treatment claims.

### Suggested next meal
Show one prominent recommendation:

> **What should you eat next?**

**Spinach Moong Dal**

CTA: **View meal**

### Quick actions
- Eat
- Log food
- Kitchen
- Optional Cart

### Nutrition tip
Short practical educational card.

### Recent intake
Optional compact list:
- Breakfast
- Lunch
- Snack

This explains changes to nutrition progress.

---

# 2. Eat

**Purpose:** Core product screen. Answer:

> **“Given my nutritional context and what I already have, what should I eat?”**

### Header
Title:

> **What should I eat?**

Context:

> Luteal phase · Today's focus: Protein + Magnesium

### Kitchen-aware recommendations
Primary section:

> **Based on what's in your kitchen**

Consider:
- Nutrition focus
- Cycle context
- Kitchen inventory
- Diet
- Allergies/exclusions
- Preferred foods
- Region
- Cuisine
- Meal type
- Ingredient availability

### Best meal cards
Each card can show:
- Recipe image
- Name
- Region/cuisine
- Meal type
- Availability
- Key nutrition values
- Why it matches

Example:

```text
┌─────────────────────────────────┐
│             IMAGE               │
│                                 │
│ Spinach Moong Dal               │
│ South Indian · Lunch            │
│                                 │
│ ✓ 5/5 ingredients available     │
│                                 │
│ 12g protein · 4.8mg iron        │
│                                 │
│ Good match for today's focus    │
└─────────────────────────────────┘
```

Availability:
- You have everything
- Almost there — missing 1
- Missing 3 ingredients

### Why this meal?
Explain recommendations:
- Nutrient relevance
- Nutrition focus match
- Ingredient availability
- Dietary fit

### Foods worth adding today
Examples:
- Spinach
- Green gram
- Egg
- Guava
- Sesame

Can show:
- Nutrient highlights
- Kitchen availability
- Add to Kitchen
- View food

### Filters
- Available in my kitchen
- Diet
- Cuisine
- Region
- Meal type
- Quick meals
- Favorites

---

## Recipe Detail

Show:

### Header
- Image
- Recipe name
- Region
- Cuisine
- Meal type
- Preparation/cooking time if available
- Servings

### Nutrition per serving
- Calories
- Protein
- Carbohydrates
- Fat
- Fiber
- Iron
- Calcium
- Magnesium
- Zinc
- Other available core nutrients

### Ingredients
Show quantity and kitchen status:

```text
✓ Spinach       100 g
✓ Moong dal     150 g
○ Coconut       50 g
```

### Instructions
Step-by-step instructions.

### Why recommended?
Short nutrition-focused explanation.

### Actions
**I Ate This**

**Add Missing Ingredients to Cart**

---

# 3. Kitchen

**Purpose:** Key differentiator. Represents the food the user actually has available at home.

### Header
> **My Kitchen**

> What do you have at home?

### Add food
Prominent:

> **+ Add food**

Search should support:
- Canonical food names
- Regional aliases
- Indian-language aliases where available
- Relevant ingredient names

### Inventory
Group using data taxonomy.

Example:

**Vegetables**
- Spinach — 2 bunches
- Tomato — 5
- Onion — 4

**Protein**
- Eggs — 6
- Green gram — 500 g

**Staples**
- Rice
- Ragi
- Coconut

### Kitchen item
Show:
- Food name
- Quantity
- Unit
- Nutrient highlights
- Increase/decrease
- Edit
- Remove
- Optional expiry

### Smart kitchen summary
Optional:

> **Your kitchen has**
- 4 iron-rich foods
- 3 protein sources
- 5 vegetables
- 2 vitamin-C-rich foods

### Empty state
> **Let's see what you can make.**  
> Add a few foods you have at home.

CTA: **Add food**

---

# 4. Cart

**Purpose:** Shopping list that converts meal recommendations into purchases.

Navigation label: **Cart**

Screen title can be:

> **My Shopping List**

### Header
Show:
- Remaining item count
- Optional completed/clear action

Example:

> **7 items left**

### Shopping items
Group by category.

Example:

**Vegetables**
- ☐ Spinach
- ☐ Tomato

**Protein**
- ☐ Eggs

**Staples**
- ☐ Green gram

Each item can contain:
- Checkbox
- Name
- Quantity
- Unit
- Source recipe(s)

Example:

> **Spinach — 2 bunches**  
> Needed for: Spinach Moong Dal, Egg Spinach Rice

### Add manually
**+ Add item**

### Recipe → Cart
If ingredients are missing:

> **Missing from your kitchen**

- Coconut
- Onion
- Tomato

CTA:

**Add all to Cart**

Deduplicate items already present in the list.

### Completion
Checked items move to:

> **Completed**

Optional:

**Add purchased items to Kitchen**

This closes:

**Cart → Kitchen**

### Shopping summary
Show:
- Items remaining
- Items completed
- Recipes contributing items

Do not add budgeting/prices/delivery unless implemented later.

---

# 5. Profile

**Purpose:** Personalization and settings. It should not look like a medical-record page.

### Profile header
- Name
- Avatar
- Basic information

### Personal information
- Age
- Region
- Cuisine preference
- Diet type

Examples:
- Vegetarian
- Non-vegetarian
- Vegan

### Cycle information
- Last period start
- Average cycle length
- Period history
- Period start/end records

Possible:
> **Cycle history**

with calendar/list view.

### Food preferences
- Favorite foods
- Disliked foods
- Allergies
- Dietary exclusions

These feed recommendation filtering.

### Nutrition preferences
Potentially:
- Foods to prioritize
- Foods to avoid
- Nutrition goals/preferences

Avoid disease-specific treatment settings.

### App settings
- Units
- Notifications
- Offline data
- Privacy
- About
- Data reset

### Data controls
Because the app stores personal cycle, food and intake information:

> **Your personal data is stored locally on this device.**

Provide:
- Export data
- Delete data
- Reset app data

---

# Final Navigation

```text
┌────────────────────────────────────────────┐
│                                            │
│                  SCREEN                    │
│                                            │
├────────────────────────────────────────────┤
│ Home │ Eat │ Kitchen │ Cart │ Profile      │
└────────────────────────────────────────────┘
```

Final labels:

**Home · Eat · Kitchen · Cart · Profile**

---

# Screen Relationship

```text
                         PROFILE
                            │
                            ▼
                    Cycle + Preferences
                            │
                            ▼
HOME ───────────────► EAT
 │                     │
 │                     ▼
 │                  RECIPE
 │                     │
 │                ┌────┴────┐
 │                │         │
 │             I ATE IT   MISSING
 │                │         │
 │                ▼         ▼
 │             INTAKE      CART
 │                │         │
 │                ▼         ▼
 └──────► NUTRITION     PURCHASED
            PROGRESS         │
                             ▼
                          KITCHEN
                             │
                             └──────► EAT
```

---

# UI Priority

## P0 — Core experience
1. Eat
2. Kitchen
3. Recipe detail
4. I Ate This
5. Home nutrition progress

## P1
6. Cart generation
7. Profile/cycle editing
8. Food recommendations
9. Nutrition explanations

## P2
10. Favorites
11. Advanced filters
12. Smart kitchen summaries
13. Historical nutrition views
14. Additional personalization

The UI should prioritize the **recommendation → kitchen → meal → intake → nutrition progress → shopping** loop over decorative dashboards or secondary features.
