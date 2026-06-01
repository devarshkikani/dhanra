
# Budget Feature Implementation Plan (Revised)

## Goal Description
Add a new **Budget** tab (renamed from Tab 3) with three primary screens:
1. **Budget Home** – displays either an empty state or a budget summary with a category list.
2. **Create Budget** – form to set a monthly budget, optionally add budgets for up to five categories, and allow editing of an existing budget when appropriate.
3. **Category Detail** – shows budget vs. spent for a category, remaining amount, progress bar, transaction list, and provides an edit bottom‑sheet.

All data will be persisted locally using the same local‑storage mechanism currently employed for SMS data, keeping the feature offline‑first.

---

## Decisions (Confirmed by User)
- **State Management:** Bloc (as confirmed).
- **Tab Icon:** Don't change keep it as it is.
- **Storage Mechanism:** SQLite via sqflite (local persistence).
- **Default Categories:** Support up to **5** default categories.
- **Currency Symbol:** Configurable (e.g., via a global settings object or theme variable).
- **Charting Library:** Not yet decided (to be selected, e.g., fl_chart).
- **Data Sync:** Keep budget data local only for now.
- **Create/Edit Flow:** Provide the best user experience – the Create Budget screen will handle both creation and editing of a budget, with the bottom‑sheet edit option for quick adjustments on the Category Detail screen.
- **Styling:** Match the existing app theme (colors, typography, dark mode) while adding budget‑specific palette variables.


---

## Proposed Changes
### Navigation
#### [MODIFY] lib/widgets/bottom_navigation.dart (move to `/feat`)
- Rename Tab 3 label to **Budget**.
- keep the icon as it is.
- Add routes for `BudgetHome`, `CreateBudget`, and `CategoryDetail` screens.

### Screens & Components (all under `/feat`)
#### [NEW] feat/budget_home.dart
- Check for existing budget via `budget.dart`.
- **Empty state**: Text “Set your monthly budget” and a **Set Budget** button.
- **Populated state**: Show total budget, spent amount, remaining amount, and a progress bar.
- Display top 5 categories (or fewer if less exist) with clickable rows to open `CategoryDetail`.

#### [NEW] feat/create_budget.dart
- Input for **Monthly Budget** (currency configurable).
- Toggle **Add category budgets** – when on, render inputs for up to five default categories.
- Detect if a budget already exists; pre‑populate fields for editing.
- **Save** button persists data via `budget.dart.saveBudget` and navigates back to `BudgetHome`.

#### [NEW] feat/category_detail.dart
- Show budget vs. spent, remaining, and progress bar for the selected category.
- List transactions filtered by the category.
- **Edit** button opens `EditBudgetBottomSheet`.

#### [NEW] feat/edit_budget_bottom_sheet.dart
- Bottom‑sheet UI allowing the user to modify the category’s allocated budget.
- Immediate UI update after saving using the budget utility functions.

### Data Layer (placed in `/feat/utils`)
#### [NEW] feat/utils/budget.dart
- **getBudget()** – retrieve stored budget object from local storage.
- **saveBudget(budget)** – serialize and store budget.
- **updateCategoryBudget(catId, amount)** – modify a specific category’s budget.
- **calculateSpent(catId)** – sum transaction amounts for the given category using existing transaction data.
- **checkBudgetAlerts(budget)** – return flags for ≥80 % (warning) and ≥100 % (exceeded) thresholds.
- Export a configurable **currencySymbol** (default “₹”) that can be overridden via a settings file.

### Styles
#### [MODIFY] lib/theme/app_theme.dart (or equivalent Flutter theme file)
- Introduce theme colors for budget progress (`budgetGood`, `budgetWarning`, `budgetExceeded`).
- Style empty‑state container, progress bar, and bottom‑sheet to align with the app’s existing design system.

### Integration
#### [MODIFY] Existing category/transaction widgets
- Import helpers from `budget.dart` where needed to compute spent amounts.
- Display warning badge when a category reaches 80 % of its budget and error badge at 100 %.

### Additional Scenarios & Edge Cases

**Month Handling (critical)**
- Changing the displayed month must load the budget for that month while preserving all other months' data.
- Adding a transaction dated in a past month must not affect the current month’s budget totals.
- Deleting a past‑month transaction must only adjust that month’s budget.

**No Category / Unknown Category**
- Transactions without a category or marked “Uncategorized” will be grouped under an **Others** bucket.
- The budget calculations must safely handle the “Others” bucket even when empty.

**Edge Cases**
- Budget value = 0 should be allowed and displayed without division‑by‑zero errors.
- Very high budgets (e.g., ₹10 Lakh) must be supported; UI components should handle large numbers gracefully.
- Negative or malformed inputs must be validated and rejected with user‑friendly error messages.

**Real‑Time Sync**
- New transactions from SMS parsing or manual entry must instantly update the affected month’s budget without requiring a manual refresh.

**Delete / Update Transactions**
- Deleting a transaction should decrement the spent amount for the corresponding month and category.
- Editing a transaction’s amount or date must recalculate the appropriate month’s budget.
- Editing a transaction’s category must move the amount from the old category’s spent total to the new one.

**Category Changes**
- Changing a transaction’s category should update both the old and new category’s spent values and trigger any relevant alerts.

**Budget Overwrite Case**
- Creating a budget for a month that already has one should either replace the existing entry after a warning or prevent duplication, based on the chosen UX.

**Alert Spam Control**
- Crossing the 80 % threshold multiple times within the same month must not generate duplicate alerts; implement a once‑per‑month flag.

**Offline Behavior**
- All budget calculations and UI must function fully offline; any sync to a remote backend (if added later) should be deferred until connectivity returns.

**First‑Time User Experience**
- When no budgets or transactions exist, display a clean empty‑state screen with guidance to create a budget and add transactions.

**Recurring Budgets**
- Optionally support setting a recurring monthly budget that auto‑creates a new budget entry each month unless manually overridden.

**Currency Changes**
- If the global currency symbol changes, all budget displays must update instantly.

---

---

## Verification Plan

### Automated Tests (Flutter test framework)

- Unit tests for all functions in `budget.dart` (calculations, alerts, storage).
- Widget tests for `BudgetHome` empty and filled states, including month switching.
- Navigation tests ensuring the Budget tab switches correctly and each screen renders.
- **Month Handling Tests**: Verify budgets are isolated per month, past‑month transactions do not affect current month, and deleting past‑month entries updates only that month.
- **No Category / Others Bucket Tests**: Ensure transactions without a category are grouped under “Others” and calculations remain correct.
- **Edge Case Tests**: Budgets of 0, very high values (₹10 Lakh), and invalid inputs (negative amounts) are handled gracefully without crashes.
- **Real‑Time Sync Tests**: Adding transactions via SMS parser or manual entry updates UI instantly.
- **Delete / Update Transaction Tests**: Deleting a transaction reduces spent amount; editing amount/date/category recalculates budgets appropriately.
- **Budget Overwrite Tests**: Creating a budget for an existing month triggers a warning or replaces as per UX choice.
- **Alert Spam Control Tests**: Ensure the 80 % threshold alert fires only once per month.
- **Offline Behavior Tests**: All calculations and UI work without network connectivity.

### Manual Testing

1. Launch app, open Budget tab – verify empty state UI.
2. Create a new budget (with and without category budgets) – ensure data persists after app restart.
3. Add sample transactions (or use existing ones) – confirm spent/remaining values update on Home and Category screens.
4. Change the displayed month – verify a fresh budget loads and previous month data remains unchanged.
5. Add a transaction dated in a past month – ensure current month budget is unaffected.
6. Add a transaction without a category – confirm it appears in the “Others” section and calculations remain correct.
7. Test edge cases: set budget to 0, enter a very high budget (₹10 Lakh), attempt negative inputs – verify proper validation/error handling.
8. Reach 80 % of a category budget – verify warning badge appears (only once per month).
9. Exceed 100 % – verify exceeded badge appears.
10. Edit a category budget via bottom sheet – ensure UI reflects the change instantly.
11. Test editing existing budget through Create screen – confirm fields pre‑populate and save correctly.
12. Delete a transaction – verify budget decreases correctly.
13. Edit a transaction’s amount, date, or category – ensure recalculation works.
14. Simulate offline mode – verify all budget features continue to work.
15. First‑time user: no budgets/transactions – ensure empty‑state guidance is shown.

---

---

*All decisions have been incorporated. The plan is ready for execution.*
