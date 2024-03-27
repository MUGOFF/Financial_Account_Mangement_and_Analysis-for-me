import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';
import 'package:ver_0/widgets/models/bank_account.dart';
import 'package:ver_0/widgets/models/card_account.dart';
import 'package:ver_0/widgets/models/money_transaction.dart';
import 'package:ver_0/widgets/models/transaction_category.dart';
import 'package:ver_0/widgets/models/expiration_investment.dart';
import 'package:ver_0/widgets/models/nonexpiration_investment.dart';
import 'package:ver_0/widgets/models/current_holdings.dart';
import 'package:ver_0/widgets/models/budget_setting.dart';

class DatabaseAdmin {
  final Logger logger = Logger();
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
      version: 6,
      onCreate: (db, version) {
        _createBankAccountTable(db);
        _createCardAccountTable(db);
        _createMoneyTransactionTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          _createTransactionCategoryTable(db);
          _insertDefaultCategories(db);
        }
        if (oldVersion < 3) {
          _createExpirationInvestmentTable(db);
          _createNonExpirationInvestmentTable(db);
        }
        if (oldVersion < 4) {
          _createCurrentHoldingTable(db);
          _insertInitialHoldings(db);
        }
        if (oldVersion < 5) {
          _addColumnToMoneyTransactionTable(db);
          _addExtraBoolTransactionTable(db);
        }
        if (oldVersion < 6) {
          _createBugetSettingTable(db);
        }
      },
    );
  }

  Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<void> updateAllTable(String tableName,String parameterName, dynamic newValue) async {
    final db = await database;
    try { 
      await db.transaction((txn) async {
        await txn.update(
          tableName,
          {parameterName: newValue},
        );
      });
    } catch (e){
      logger.e(e);
    }
  }

  void _createBankAccountTable(Database db) {
    db.execute(
      """
      CREATE TABLE bank_accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bankName TEXT,
        accountNickname TEXT,
        accountNumber TEXT,
        balance REAL,
        memo TEXT)
      """,        
    );
  }

  void _createCardAccountTable(Database db) {
    db.execute(
      """
      CREATE TABLE card_accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cardIssuer INTEGER,cardName TEXT,
        accountNickname TEXT,
        cardNumber TEXT,
        memo TEXT,
        FOREIGN KEY(cardIssuer) REFERENCES bank_accounts(id) ON DELETE SET NULL)
      """,
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

  void _addColumnToMoneyTransactionTable(Database db) async  {
    db.execute(
      """
      ALTER TABLE money_transactions
      ADD COLUMN categoryType TEXT
      """
    );
  }

  void _addExtraBoolTransactionTable(Database db) async  {
    db.execute(
      """
      ALTER TABLE money_transactions
      ADD COLUMN extraBudget INTEGER INTEGER DEFAULT 0
      """
    );
  }

  void _createTransactionCategoryTable(Database db) {
    db.execute(
      """
        CREATE TABLE transactions_categorys(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          itemList TEXT)
      """,
    );
  }

  void _createExpirationInvestmentTable(Database db) {
    db.execute(
      """
        CREATE TABLE investments_expiration(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          creationTime TEXT DEFAULT CURRENT_TIMESTAMP,
          updateTime TEXT DEFAULT CURRENT_TIMESTAMP,
          investTime TEXT,
          expirationTime TEXT,
          interestRate REAL,
          account TEXT,
          amount REAL,
          valuePrice REAL,
          cost REAL,
          investment TEXT,
          investcategory TEXT,
          currency TEXT,
          description TEXT)
      """,
    );
  }

  void _createNonExpirationInvestmentTable(Database db) {
    db.execute(
      """
        CREATE TABLE investments_nonexpiration(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          creationTime TEXT DEFAULT CURRENT_TIMESTAMP,
          updateTime TEXT DEFAULT CURRENT_TIMESTAMP,
          investTime TEXT,
          account TEXT,
          amount REAL,
          valuePrice REAL,
          cost REAL,
          investment TEXT,
          investcategory TEXT,
          currency TEXT,
          description TEXT)
      """,
    );
  }

  void _createCurrentHoldingTable(Database db) {
    db.execute(
      """
        CREATE TABLE current_holdings(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          investment TEXT,
          totalAmount REAL,
          investcategory TEXT,
          currency TEXT)
      """,
    );
  }

  void _createBugetSettingTable(Database db) {
    db.execute(
      """
        CREATE TABLE budget_settings(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          year INTEGER,
          month INTEGER,
          budgetList TEXT)
      """,
    );
  }



  // insert 계열


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
    updateAccountBalance(moneyTransaction);
    return await db.insert('money_transactions', moneyTransaction.toMap());
  }

  Future<int> insertExpirationInvestment(ExpirationInvestment moneyInvestment) async {
    final db = await database;
    updateCurrentHoldingNonex(moneyInvestment);
    return await db.insert('investments_expiration', moneyInvestment.toMap());
  }

  Future<int> insertNonExpirationInvestment(NonexpirationInvestment moneyInvestment) async {
    final db = await database;
    updateCurrentHoldingNonex(moneyInvestment);
    return await db.insert('investments_nonexpiration', moneyInvestment.toMap());
  }

  Future<void> _insertDefaultCategories(Database db) async {
    Map<String, List<String>> defaultCategories = {
      "수입": ["급여소득", "용돈", "금융소득"],
      "소비": ["식비", "주거비", "통신비", "생활비", "미용비", "의료비", "문화비", "교통비", "세금", "카드대금", "보험", "기타", '특별예산'],
      "이체": ["내계좌송금", "타계좌송금", "내계좌수신", "저축", "투자", "충전"]
    };

    await Future.forEach(defaultCategories.entries, (entry) async {
      String categoryName = entry.key;
      List<String> itemList = entry.value;

      await db.insert('transactions_categorys', {
        'name': categoryName,
        'itemList': itemList.join(','),
      });
    });
  }

  Future<void> _insertInitialHoldings(Database db) async {


    // 각 투자 이름별 합계 계산
    final List<Map<String, dynamic>> summaryEx = await db.rawQuery(
      """
      SELECT investment, SUM(amount) AS totalAmount, investcategory, currency FROM investments_expiration GROUP BY investment, investcategory, currency 
      """
    );

    final List<Map<String, dynamic>> summaryNonex = await db.rawQuery(
      """
      SELECT investment, SUM(amount) AS totalAmount, investcategory, currency FROM investments_nonexpiration GROUP BY investment, investcategory, currency 
      """
    );

    final batch = db.batch();
    for (final entry in summaryEx) {
      final investment = entry['investment'] as String;
      final totalAmount = entry['totalAmount'] as double;
      final investcategory = entry['investcategory'] as String;
      final currency = entry['currency'] as String;
      
      if (totalAmount != 0) {
        batch.insert(
          'current_holdings',
          {'investment': investment, 'totalAmount': totalAmount, 'investcategory': investcategory, 'currency': currency},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    for (final entry in summaryNonex) {
      final investment = entry['investment'] as String;
      final totalAmount = entry['totalAmount'] as double;
      final investcategory = entry['investcategory'] as String;
      final currency = entry['currency'] as String;
      
      if (totalAmount != 0) {
        batch.insert(
          'current_holdings',
          {'investment': investment, 'totalAmount': totalAmount, 'investcategory': investcategory, 'currency': currency},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit();
  }

  Future<int> insertBugetSettingTable(BudgetSetting budgetSetting) async {
    final db = await database;
    return await db.insert('budget_settings', budgetSetting.toMap());
  }



  //UPDATE 계열 편집


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
    updateAccountBalance(updatedTransaction);
    return await db.update(
      'money_transactions',
      updatedTransaction.toMap(),
      where: 'id = ?',
      whereArgs: [updatedTransaction.id],
    );
  }

  ///특정 대상 카테고리 일괄 변경
  Future<void> updateCategorySearchAllTable(String goodsname, String newValue, String newValueType) async {
    final db = await database;
    try { 
      await db.transaction((txn) async {
        await txn.update(
          'money_transactions',
          {'category': newValue, 'categoryType': newValueType},
          where: 'goods  = ?',
          whereArgs: [goodsname],
        );
      });
    } catch (e){
      logger.e(e);
    }
  }

  Future<int> updateTransactionCategoryItemList(String name, List<String> updatedItemList) async {
    final db = await database;
    return await db.update(
      'transactions_categorys',
      {'itemList': updatedItemList.join(',')},
      where: 'name  = ?',
      whereArgs: [name],
    );
  }

  Future<int> updateAccountBalance(MoneyTransaction updatedTransaction) async {
    final db = await database;

    var currentData = await db.query(
      'bank_accounts',
      where: 'bankName = ?',
      whereArgs: [updatedTransaction.account],
    );
    // logger.d('currentData: $currentData');
    int updateResult = 0;

    if (currentData.isEmpty) {
      var currentCardData = await db.query(
        'card_accounts',
        where: 'cardName = ?',
        whereArgs: [updatedTransaction.account],
      );

      // logger.d('currentCardData: $currentCardData'); 
      currentData = await db.query(
        'bank_accounts',
        where: 'id = ?',
        whereArgs: [currentCardData.first['cardIssuer']],
      );
      // logger.d('currentData: $currentData'); 
      if (currentData.isNotEmpty) {
        final double oldTotalAmount = currentData.first['balance'] as double;
        final double newTotalAmount = oldTotalAmount + updatedTransaction.amount;

        updateResult = await db.update(
          'bank_accounts',
          {'balance': newTotalAmount},
          where: 'id = ?',
          whereArgs: [currentCardData.first['cardIssuer']],
        );
      }
    } else {
      final double oldTotalAmount = currentData.first['balance'] as double;
      final double newTotalAmount = oldTotalAmount + updatedTransaction.amount;
      updateResult = await db.update(
        'bank_accounts',
        {'balance': newTotalAmount},
        where: 'bankName = ?',
        whereArgs: [updatedTransaction.account],
      );
    }

    return updateResult;
  }

  Future<int> updateExpirationInvestment(ExpirationInvestment updatedInvestment) async {
    final db = await database;
    updateCurrentHoldingNonex(updatedInvestment);
    return await db.update(
      'investments_expiration',
      updatedInvestment.toMap(),
      where: 'id = ?',
      whereArgs: [updatedInvestment.id],
    );
  }

  Future<int> updateNonExpirationInvestment(NonexpirationInvestment updatedInvestment) async {
    final db = await database;
    updateCurrentHoldingNonex(updatedInvestment);
    return await db.update(
      'investments_nonexpiration',
      updatedInvestment.toMap(),
      where: 'id = ?',
      whereArgs: [updatedInvestment.id],
    );
  }

  Future<int> updateCurrentHoldingNonex(dynamic updatedInvestment) async {
    final db = await database;

    final currentData = await db.query(
      'current_holdings',
      where: 'investment = ?',
      whereArgs: [updatedInvestment.investment],
    );

    final double oldTotalAmount = currentData.isNotEmpty ? currentData.first['totalAmount'] as double : 0;
    final double newTotalAmount = oldTotalAmount + updatedInvestment.amount;

    int updateResult;

  if (currentData.isEmpty) {
    updateResult = await db.insert(
      'current_holdings',
      {
        'investment': updatedInvestment.investment,
        'totalAmount': updatedInvestment.amount,
        'investcategory': updatedInvestment.investcategory,
        'currency': updatedInvestment.currency,
      },
    );
  } else {
    updateResult = await db.update(
      'current_holdings',
      {'totalAmount': newTotalAmount},
      where: 'investment = ?',
      whereArgs: [updatedInvestment.investment],
    );

    if (newTotalAmount == 0) {
      await db.delete(
        'current_holdings',
        where: 'investment = ?',
        whereArgs: [updatedInvestment.investment],
      );
    }
  }

  return updateResult;
  }

  Future<int> updateBugetSettingTable(int year, int month, Map<String, double> updatedBudgetList) async {
    final db = await database;
    return await db.update(
      'budget_settings',
      {'budgetList': json.encode(updatedBudgetList)},
      where: 'year  = ? AND month = ?',
      whereArgs: [year, month],
    );
  }



  //DELETE 계열 편집//


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
    List<Map<String, dynamic>> transactions = await db.query(
      'money_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    deletionUpdateAccountBalance(transactions.first);
    return await db.delete(
      'money_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletionUpdateAccountBalance(dynamic updatedTransaction) async {
    final db = await database;
    var currentData = await db.query(
      'bank_accounts',
      where: 'bankName = ?',
      whereArgs: [updatedTransaction['account']],
    );
    
    int updateResult = 0;

    if (currentData.isEmpty) {
      var currentCardData = await db.query(
        'card_accounts',
        where: 'cardName = ?',
        whereArgs: [updatedTransaction['account']],
      );

      currentData = await db.query(
        'bank_accounts',
        where: 'id = ?',
        whereArgs: [currentCardData.first['cardIssuer']],
      );
      if (currentData.isNotEmpty) {
        final double oldTotalAmount = currentData.first['balance'] as double;
        final double newTotalAmount = oldTotalAmount - updatedTransaction['amount'];

        updateResult = await db.update(
          'bank_accounts',
          {'balance': newTotalAmount},
          where: 'id = ?',
          whereArgs: [currentCardData.first['cardIssuer']],
        );
      }
    } else {
      final double oldTotalAmount = currentData.first['balance'] as double;
      final double newTotalAmount = oldTotalAmount - updatedTransaction['amount'];
      updateResult = await db.update(
        'bank_accounts',
        {'balance': newTotalAmount},
        where: 'bankName = ?',
        whereArgs: [updatedTransaction['account']],
      );
    }

    return updateResult;
  }

  Future<int> deleteExpirationInvestment(int id) async {
    final db = await database;
    List<Map<String, dynamic>> investments = await db.query(
      'investments_expiration',
      where: 'id = ?',
      whereArgs: [id],
    );
    deletionUpdateCurrentHoldingNonex(investments.first);
    return await db.delete(
      'investments_expiration',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNonExpirationInvestment(int id) async {
    final db = await database;
    List<Map<String, dynamic>> investments = await db.query(
      'investments_nonexpiration',
      where: 'id = ?',
      whereArgs: [id],
    );
    deletionUpdateCurrentHoldingNonex(investments.first);
    return await db.delete(
      'investments_nonexpiration',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletionUpdateCurrentHoldingNonex(dynamic updatedInvestment) async {
    final db = await database;
    final currentData = await db.query(
      'current_holdings',
      where: 'investment = ?',
      whereArgs: [updatedInvestment['investment']],
    );

    final double oldTotalAmount = currentData.isNotEmpty ? currentData.first['totalAmount'] as double : 0;
    final double newTotalAmount = oldTotalAmount - updatedInvestment['amount'];

    int updateResult;

    if (currentData.isEmpty) {
      updateResult = await db.insert(
        'current_holdings',
        {
          'investment': updatedInvestment['investment'],
          'totalAmount': updatedInvestment['amount'],
          'investcategory': updatedInvestment['investcategory'],
          'currency': updatedInvestment['currency'],
        },
      );
    } else {
      updateResult = await db.update(
        'current_holdings',
        {'totalAmount': newTotalAmount},
        where: 'investment = ?',
        whereArgs: [updatedInvestment['investment']],
      );

      if (newTotalAmount == 0) {
        await db.delete(
          'current_holdings',
          where: 'investment = ?',
          whereArgs: [updatedInvestment['investment']],
        );
      }
    }

    return updateResult;
  }


//Search 계열 편집//

  ///모든 은행 계좌 가져오기 
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


  ///은행 계좌 아이디로 가져오기
  Future<BankAccount?> getBankAccountById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> bankAccountMaps = await db.query(
      'bank_accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (bankAccountMaps.isEmpty) {
      return null;
    }
    return BankAccount(
      id: bankAccountMaps[0]['id'],
      bankName: bankAccountMaps[0]['bankName'],
      accountNumber: bankAccountMaps[0]['accountNumber'],
      balance: bankAccountMaps[0]['balance'],
      memo: bankAccountMaps[0]['memo'],
    );
  }

  ///모든 카드 계좌 가져오기
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

  ///월간 거래내역 가져오기
  Future<List<MoneyTransaction>> getTransactionsByMonth(int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = await db.query(
      'money_transactions',
      where: "substr(transactionTime,1,9) = ?",
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

  ///월간 거래내역(카테고리) 항목별 총합 가져오기
  Future<List<Map<String, dynamic>>> getransactionsSUMBByGoodsCategoriesMonth(int year, int month, String category) async {
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = await db.query(
      'money_transactions',
      columns: ['goods', 'SUM(amount) * -1 as totalAmount'],
      where: "substr(transactionTime,1,9) = ? AND category = ? AND amount < 0 AND categoryType = '소비'",
      whereArgs: ['$year년 ${month.toString().padLeft(2, '0')}월', category],
      groupBy: 'goods'
    );

    return transactionMaps;
  }

  ///카테고리별 월간 소비 총합 가져오기
  Future<List<Map<String, dynamic>>> getTransactionsSUMByCategoryandDate(int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = await db.query(
      'money_transactions',
      columns: ['category', 'SUM(amount) * -1 as totalAmount'],
      where: "substr(transactionTime,1,9) = ? AND amount < 0 AND categoryType = '소비'",
      whereArgs: ['$year년 ${month.toString().padLeft(2, '0')}월'],
      groupBy: 'category'
    );
    
    return transactionMaps;
  }

  Future<List<ExpirationInvestment>> getExInvestmentsByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> invesmentMaps = await db.query(
      'investments_expiration',
      where: 
        """
          substr(investTime, 1, 4) || '-' || 
          substr(investTime, 7, 2) || '-' || 
          substr(investTime, 11, 2) || 'T' ||
          substr(investTime, 15, 5) BETWEEN ? AND ?
        """,
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return List.generate(invesmentMaps.length, (i) {
      return ExpirationInvestment(
        id: invesmentMaps[i]['id'],
        investTime: invesmentMaps[i]['investTime'],
        expirationTime: invesmentMaps[i]['expirationTime'],
        interestRate: invesmentMaps[i]['interestRate'],
        account: invesmentMaps[i]['account'],
        amount: invesmentMaps[i]['amount'],
        valuePrice: invesmentMaps[i]['valuePrice'],
        cost: invesmentMaps[i]['cost'],
        investment: invesmentMaps[i]['investment'],
        investcategory: invesmentMaps[i]['investcategory'],
        currency: invesmentMaps[i]['currency'],
        description: invesmentMaps[i]['description'],
      );
    });
  }

  Future<List<NonexpirationInvestment>> getNonExInvestmentsByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> invesmentMaps = await db.query(
      'investments_nonexpiration',
      where:
        """
          substr(investTime, 1, 4) || '-' || 
          substr(investTime, 7, 2) || '-' || 
          substr(investTime, 11, 2) || 'T' ||
          substr(investTime, 15, 5) BETWEEN ? AND ?
        """,
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return List.generate(invesmentMaps.length, (i) {
      return NonexpirationInvestment(
        id: invesmentMaps[i]['id'],
        investTime: invesmentMaps[i]['investTime'],
        account: invesmentMaps[i]['account'],
        amount: invesmentMaps[i]['amount'],
        valuePrice: invesmentMaps[i]['valuePrice'],
        cost: invesmentMaps[i]['cost'],
        investment: invesmentMaps[i]['investment'],
        investcategory: invesmentMaps[i]['investcategory'],
        currency: invesmentMaps[i]['currency'],
        description: invesmentMaps[i]['description'],
      );
    });
  }

  Future<List<Holdings>> getCurrentHoldInvestments() async {
    final db = await database;
    final List<Map<String, dynamic>> holdings = await db.query('current_holdings',);
    return List.generate(holdings.length, (i) {
      return Holdings(
        id: holdings[i]['id'],
        investment: holdings[i]['investment'],
        totalAmount: holdings[i]['totalAmount'],
        investcategory: holdings[i]['investcategory'],
        currency: holdings[i]['currency'],
      );
    });
  }

  Future<List<TransactionCategory>> getAllTransactionCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> categoryMaps = await db.query('transactions_categorys');
    return List.generate(categoryMaps.length, (i) {
      return TransactionCategory(
        id: categoryMaps[i]['id'],
        name: categoryMaps[i]['name'],
        itemList: categoryMaps[i]['itemList'] != null ? List<String>.from(categoryMaps[i]['itemList'].split(',')) : [],
      );
    });
  }

  Future<List<BudgetSetting>> getMonthBugetList(int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> budgetMaps = await db.query(
      'budget_settings',
      where:"year = ? AND month = ?",
      whereArgs: [year, month],
    );
    
    return List.generate(budgetMaps.length, (i) {
      return BudgetSetting(
        id: budgetMaps[i]['id'],
        year: budgetMaps[i]['year'],
        month: budgetMaps[i]['month'],
        budgetList: budgetMaps[i]['budgetList'] != null ? Map<String, double>.from(json.decode(budgetMaps[i]['budgetList'])) : null,
      );
    });
  }

  // 추가적인 데이터베이스 작업들...
}
