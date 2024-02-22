import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ver_0/widgets/models/account.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'your_database.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE bank_accounts(id INTEGER PRIMARY KEY, accountNumber TEXT, balance REAL)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertBankAccount(BankAccount bankAccount) async {
    final db = await database;
    return await db.insert('bank_accounts', bankAccount.toMap());
  }

  Future<List<BankAccount>> getAllBankAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bank_accounts');
    return List.generate(maps.length, (i) {
      return BankAccount(
        id: maps[i]['id'],
        accountNumber: maps[i]['accountNumber'],
        balance: maps[i]['balance'],
      );
    });
  }

  // Add other CRUD operations as needed
}
