import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/budget_model.dart';

class BudgetDatabaseHelper {
  static final BudgetDatabaseHelper instance = BudgetDatabaseHelper._init();
  static Database? _database;

  BudgetDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('budget.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE budgets (
  id $idType,
  month $textType,
  totalBudget $doubleType
)
''');

    await db.execute('''
CREATE TABLE category_budgets (
  id $idType,
  budgetId $textType,
  category $textType,
  amount $doubleType,
  FOREIGN KEY (budgetId) REFERENCES budgets (id) ON DELETE CASCADE
)
''');
  }

  Future<void> saveBudget(Budget budget) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      // Check if budget for this month already exists
      final results = await txn.query(
        'budgets',
        where: 'month = ?',
        whereArgs: [budget.month],
      );

      String budgetId = budget.id;

      if (results.isNotEmpty) {
        // Update existing budget
        budgetId = results.first['id'] as String;
        await txn.update(
          'budgets',
          budget.copyWith(id: budgetId).toMap(),
          where: 'id = ?',
          whereArgs: [budgetId],
        );
        // Clear existing category budgets
        await txn.delete(
          'category_budgets',
          where: 'budgetId = ?',
          whereArgs: [budgetId],
        );
      } else {
        // Insert new budget
        await txn.insert('budgets', budget.toMap());
      }

      // Insert category budgets
      for (var catBudget in budget.categoryBudgets) {
        await txn.insert(
          'category_budgets',
          catBudget.copyWith(budgetId: budgetId).toMap(),
        );
      }
    });
  }

  Future<Budget?> getBudgetForMonth(String month) async {
    final db = await instance.database;

    final budgetResults = await db.query(
      'budgets',
      where: 'month = ?',
      whereArgs: [month],
    );

    if (budgetResults.isEmpty) return null;

    final budgetMap = budgetResults.first;
    final budgetId = budgetMap['id'] as String;

    final categoryResults = await db.query(
      'category_budgets',
      where: 'budgetId = ?',
      whereArgs: [budgetId],
    );

    final categories = categoryResults.map((map) => CategoryBudget.fromMap(map)).toList();

    return Budget.fromMap(budgetMap, categories);
  }

  Future<void> deleteBudget(String id) async {
    final db = await instance.database;
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
