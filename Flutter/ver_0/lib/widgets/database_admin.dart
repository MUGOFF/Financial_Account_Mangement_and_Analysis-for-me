import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ver_0/widgets/models/bank_account.dart';
import 'package:ver_0/widgets/models/card_account.dart';
import 'package:ver_0/widgets/models/money_transaction.dart';

class DatabaseAdmin {
  static final DatabaseAdmin _instance = DatabaseAdmin._internal();
  factory DatabaseAdmin() => _instance;

  static Database? _database;

  DatabaseAdmin._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'debug_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        _createBankAccountTable(db);
        _createCardAccountTable(db);
        _createMoneyTransactionTable(db);
      },
      // onUpgrade: (db, oldVersion, newVersion) {
      //   if (oldVersion < 1) {
      //     _createMoneyTransactionTable(db); // 새로운 테이블 추가
      //   }
      // },
    );
  }

  void _createBankAccountTable(Database db) {
    db.execute(
      "CREATE TABLE bank_accounts(id INTEGER PRIMARY KEY AUTOINCREMENT,bankName TEXT,accountNickname TEXT,accountNumber TEXT,balance REAL,memo TEXT)",
    );
  }

  void _createCardAccountTable(Database db) {
    db.execute(
      "CREATE TABLE card_accounts(id INTEGER PRIMARY KEY AUTOINCREMENT,cardIssuer INTEGER,cardName TEXT,accountNickname TEXT,cardNumber TEXT,memo TEXT,FOREIGN KEY(cardIssuer) REFERENCES bank_accounts(id) ON DELETE SET NULL)",
    );
  }
  void _createMoneyTransactionTable(Database db) {
    db.execute(
      """
        CREATE TABLE money_transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          creationTime TEXT DEFAULT CURRENT_TIMESTAMP,
          updateTime TEXT DEFAULT CURRENT_TIMESTAMP,
          transactionTime TEXT,
          account TEXT,
          amount REAL,
          goods TEXT,
          category TEXT,
          description TEXT)
      """,
    );
  }

  Future<int> insertBankAccount(BankAccount bankAccount) async {
    final db = await database;
    return await db.insert('bank_accounts', bankAccount.toMap());
  }

  Future<int> insertCardAccount(CardAccount cardAccount) async {
    final db = await database;
    return await db.insert('card_accounts', cardAccount.toMap());
  }
  Future<int> insertMoneyTransaction(MoneyTransaction moneyTransaction) async {
    final db = await database;
    return await db.insert('money_transactions', moneyTransaction.toMap());
  }

  Future<int> updateBankAccount(BankAccount updatedAccount) async {
    final db = await database;
    return await db.update(
      'bank_accounts',
      updatedAccount.toMap(),
      where: 'id = ?',
      whereArgs: [updatedAccount.id],
    );
  }

  Future<int> updateCardAccount(CardAccount updatedAccount) async {
    final db = await database;
    return await db.update(
      'card_accounts',
      updatedAccount.toMap(),
      where: 'id = ?',
      whereArgs: [updatedAccount.id],
    );
  }

  Future<int> updateMoneyTransaction(MoneyTransaction updatedTransaction) async {
    final db = await database;
    return await db.update(
      'money_transactions',
      updatedTransaction.toMap(),
      where: 'id = ?',
      whereArgs: [updatedTransaction.id],
    );
  }

  Future<int> deleteBankAccount(int id) async {
    final db = await database;
    return await db.delete(
      'bank_accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCardAccount(int id) async {
    final db = await database;
    return await db.delete(
      'card_accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMoneyTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'money_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<BankAccount>> getAllBankAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> bankAccountMaps = await db.query('bank_accounts');
    return List.generate(bankAccountMaps.length, (i) {
      return BankAccount(
        id: bankAccountMaps[i]['id'],
        bankName: bankAccountMaps[i]['bankName'],
        accountNumber: bankAccountMaps[i]['accountNumber'],
        balance: bankAccountMaps[i]['balance'],
        memo: bankAccountMaps[i]['memo'],
      );
    });
  }

  Future<BankAccount?> getBankAccountById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> bankAccountMaps = await db.query(
      'bank_accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (bankAccountMaps.isEmpty) {
      return null; // 해당 ID에 해당하는 은행 정보가 없을 경우 null을 반환합니다.
    }
    return BankAccount(
      id: bankAccountMaps[0]['id'],
      bankName: bankAccountMaps[0]['bankName'],
      accountNumber: bankAccountMaps[0]['accountNumber'],
      balance: bankAccountMaps[0]['balance'],
      memo: bankAccountMaps[0]['memo'],
    );
  }

  Future<List<CardAccount>> getAllCardAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> cardAccountMaps = await db.query('card_accounts');
    return List.generate(cardAccountMaps.length, (i) {
      return CardAccount(
        id: cardAccountMaps[i]['id'],
        cardIssuer: cardAccountMaps[i]['cardIssuer'],
        cardName: cardAccountMaps[i]['cardName'],
        cardNumber: cardAccountMaps[i]['cardNumber'],
        memo: cardAccountMaps[i]['memo'],
      );
    });
  }

  Future<List<MoneyTransaction>> getTransactionsByMonth(int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = await db.query(
      'money_transactions',
      where: "substr(transactionTime,1,9) = ?",
      // where: "substr('transactionTime',1,10) = ?",
      whereArgs: ['$year년 ${month.toString().padLeft(2, '0')}월'],
    );
    return List.generate(transactionMaps.length, (i) {
      return MoneyTransaction(
        id: transactionMaps[i]['id'],
        transactionTime: transactionMaps[i]['transactionTime'],
        account: transactionMaps[i]['account'],
        amount: transactionMaps[i]['amount'],
        goods: transactionMaps[i]['goods'],
        category: transactionMaps[i]['category'],
        description: transactionMaps[i]['description'],
      );
    });
  }

  // 추가적인 데이터베이스 작업들...
}
