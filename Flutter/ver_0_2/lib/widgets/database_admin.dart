import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
// import 'package:ver_0_2/widgets/models/bank_account.dart';
// import 'package:ver_0_2/widgets/models/card_account.dart';
import 'package:ver_0_2/widgets/models/money_transaction.dart';
import 'package:ver_0_2/widgets/models/transaction_category.dart';
// import 'package:ver_0_2/widgets/models/expiration_investment.dart';
// import 'package:ver_0_2/widgets/models/nonexpiration_investment.dart';
// import 'package:ver_0_2/widgets/models/current_holdings.dart';
import 'package:ver_0_2/widgets/models/budget_setting.dart';
import 'package:ver_0_2/widgets/models/extra_budget_group.dart';

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
      version: 10,
      onCreate: (db, version) {
        _createMoneyTransactionTable(db);
        _createTransactionCategoryTable(db);
        _insertDefaultCategories(db);
        _createBugetSettingTable(db);
        _createExtraBugetSettingTable(db);
        _deleteNameinExtraGroupTable(db);
        _addColumnHiddenPrameterToMoneyTransactionTable(db);
        // _addTriggerForParameterUpdate(db);
        _addTriggerForParameterUpdateRenewal(db);
        processExistingData(db);
        _createIncomeTable(db);
        _insertYearlyExpenseCategories(db);
        _createMoneyTransactionDisplayTable(db);
        _addColumnInstallationToMoneyTransactionTable(db);
        // _createBankAccountTable(db);
        // _createCardAccountTable(db);
        // _createExpirationInvestmentTable(db);
        // _createNonExpirationInvestmentTable(db);
        // _createCurrentHoldingTable(db);
        // _insertInitialHoldings(db);
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          _addColumnHiddenPrameterToMoneyTransactionTable(db);
        }
        if (oldVersion < 3) {
          // _addTriggerForParameterUpdate(db);
        }
        if (oldVersion < 4) {
          processExistingData(db);
        }
        if (oldVersion < 7) {
          _addTriggerForParameterUpdateRenewal(db);
        }
        if (oldVersion < 8) {
          _createIncomeTable(db);
        }
        if (oldVersion < 9) {
          _insertYearlyExpenseCategories(db);
        }
        if (oldVersion < 10) {
          _createMoneyTransactionDisplayTable(db);
          _addColumnInstallationToMoneyTransactionTable(db);
        }
        // if (oldVersion < 4) {
        //   _createCurrentHoldingTable(db);
        //   _insertInitialHoldings(db);
        // }
      },
    );
  }

  // Future<void> clearTable(String tableName) async {
  //   final db = await database;
  //   await db.delete(tableName);
  // }

  // Future<void> updateAllTable(String tableName,String parameterName, dynamic newValue) async {
  //   final db = await database;
  //   try { 
  //     await db.transaction((txn) async {
  //       await txn.update(
  //         tableName,
  //         {parameterName: newValue},
  //       );
  //     });
  //   } catch (e){
  //     logger.e(e);
  //   }
  // }

///
///
///
///
///
///
///
///
///
///
/// 은행계좌 
  ///테이블 생성
  // void _createBankAccountTable(Database db) {
  //   db.execute(
  //     """
  //     CREATE TABLE bank_accounts(
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       bankName TEXT,
  //       accountNickname TEXT,
  //       accountNumber TEXT,
  //       balance REAL,
  //       memo TEXT)
  //     """,        
  //   );
  // }

  // Future<int> insertBankAccount(BankAccount bankAccount) async {
  //   final db = await database;
  //   return await db.insert('bank_accounts', bankAccount.toMap());
  // }

  // Future<int> updateBankAccount(BankAccount updatedAccount) async {
  //   final db = await database;
  //   return await db.update(
  //     'bank_accounts',
  //     updatedAccount.toMap(),
  //     where: 'id = ?',
  //     whereArgs: [updatedAccount.id],
  //   );
  // }

  // Future<int> updateAccountBalance(MoneyTransaction updatedTransaction) async {
  //   final db = await database;

  //   var currentData = await db.query(
  //     'bank_accounts',
  //     where: 'bankName = ?',
  //     whereArgs: [updatedTransaction.account],
  //   );
  //   // logger.d('currentData: $currentData');
  //   int updateResult = 0;

  //   if (currentData.isEmpty) {
  //     var currentCardData = await db.query(
  //       'card_accounts',
  //       where: 'cardName = ?',
  //       whereArgs: [updatedTransaction.account],
  //     );

  //     // logger.d('currentCardData: $currentCardData'); 
  //     currentData = await db.query(
  //       'bank_accounts',
  //       where: 'id = ?',
  //       whereArgs: [currentCardData.first['cardIssuer']],
  //     );
  //     // logger.d('currentData: $currentData'); 
  //     if (currentData.isNotEmpty) {
  //       final double oldTotalAmount = currentData.first['balance'] as double;
  //       final double newTotalAmount = oldTotalAmount + updatedTransaction.amount;

  //       updateResult = await db.update(
  //         'bank_accounts',
  //         {'balance': newTotalAmount},
  //         where: 'id = ?',
  //         whereArgs: [currentCardData.first['cardIssuer']],
  //       );
  //     }
  //   } else {
  //     final double oldTotalAmount = currentData.first['balance'] as double;
  //     final double newTotalAmount = oldTotalAmount + updatedTransaction.amount;
  //     updateResult = await db.update(
  //       'bank_accounts',
  //       {'balance': newTotalAmount},
  //       where: 'bankName = ?',
  //       whereArgs: [updatedTransaction.account],
  //     );
  //   }

  //   return updateResult;
  // }

  // Future<int> deleteBankAccount(int id) async {
  //   final db = await database;
  //   return await db.delete(
  //     'bank_accounts',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  // Future<int> deletionUpdateAccountBalance(dynamic updatedTransaction) async {
  //   final db = await database;
  //   var currentData = await db.query(
  //     'bank_accounts',
  //     where: 'bankName = ?',
  //     whereArgs: [updatedTransaction['account']],
  //   );
    
  //   int updateResult = 0;

  //   if (currentData.isEmpty) {
  //     var currentCardData = await db.query(
  //       'card_accounts',
  //       where: 'cardName = ?',
  //       whereArgs: [updatedTransaction['account']],
  //     );

  //     currentData = await db.query(
  //       'bank_accounts',
  //       where: 'id = ?',
  //       whereArgs: [currentCardData.first['cardIssuer']],
  //     );
  //     if (currentData.isNotEmpty) {
  //       final double oldTotalAmount = currentData.first['balance'] as double;
  //       final double newTotalAmount = oldTotalAmount - updatedTransaction['amount'];

  //       updateResult = await db.update(
  //         'bank_accounts',
  //         {'balance': newTotalAmount},
  //         where: 'id = ?',
  //         whereArgs: [currentCardData.first['cardIssuer']],
  //       );
  //     }
  //   } else {
  //     final double oldTotalAmount = currentData.first['balance'] as double;
  //     final double newTotalAmount = oldTotalAmount - updatedTransaction['amount'];
  //     updateResult = await db.update(
  //       'bank_accounts',
  //       {'balance': newTotalAmount},
  //       where: 'bankName = ?',
  //       whereArgs: [updatedTransaction['account']],
  //     );
  //   }

  //   return updateResult;
  // }
  
  // ///모든 은행 계좌 가져오기 
  // Future<List<BankAccount>> getAllBankAccounts() async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> bankAccountMaps = await db.query('bank_accounts');
  //   return List.generate(bankAccountMaps.length, (i) {
  //     return BankAccount(
  //       id: bankAccountMaps[i]['id'],
  //       bankName: bankAccountMaps[i]['bankName'],
  //       accountNumber: bankAccountMaps[i]['accountNumber'],
  //       balance: bankAccountMaps[i]['balance'],
  //       memo: bankAccountMaps[i]['memo'],
  //     );
  //   });
  // }

  // ///은행 계좌 아이디로 가져오기
  // Future<BankAccount?> getBankAccountById(int id) async {
  //   final db = await database;
  //   List<Map<String, dynamic>> bankAccountMaps = await db.query(
  //     'bank_accounts',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  //   if (bankAccountMaps.isEmpty) {
  //     return null;
  //   }
  //   return BankAccount(
  //     id: bankAccountMaps[0]['id'],
  //     bankName: bankAccountMaps[0]['bankName'],
  //     accountNumber: bankAccountMaps[0]['accountNumber'],
  //     balance: bankAccountMaps[0]['balance'],
  //     memo: bankAccountMaps[0]['memo'],
  //   );
  // }

///
///
///
///
///
///
///
///
///
///
/// 카드
  ///테이블 생성
  // void _createCardAccountTable(Database db) {
  //   db.execute(
  //     """
  //     CREATE TABLE card_accounts(
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       cardIssuer INTEGER,cardName TEXT,
  //       accountNickname TEXT,
  //       cardNumber TEXT,
  //       memo TEXT,
  //       FOREIGN KEY(cardIssuer) REFERENCES bank_accounts(id) ON DELETE SET NULL)
  //     """,
  //   );
  // }

  // Future<int> insertCardAccount(CardAccount cardAccount) async {
  //   final db = await database;
  //   return await db.insert('card_accounts', cardAccount.toMap());
  // }

  // Future<int> updateCardAccount(CardAccount updatedAccount) async {
  //   final db = await database;
  //   return await db.update(
  //     'card_accounts',
  //     updatedAccount.toMap(),
  //     where: 'id = ?',
  //     whereArgs: [updatedAccount.id],
  //   );
  // }

  // Future<int> deleteCardAccount(int id) async {
  //   final db = await database;
  //   return await db.delete(
  //     'card_accounts',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  // ///모든 카드 계좌 가져오기
  // Future<List<CardAccount>> getAllCardAccounts() async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> cardAccountMaps = await db.query('card_accounts');
  //   return List.generate(cardAccountMaps.length, (i) {
  //     return CardAccount(
  //       id: cardAccountMaps[i]['id'],
  //       cardIssuer: cardAccountMaps[i]['cardIssuer'],
  //       cardName: cardAccountMaps[i]['cardName'],
  //       cardNumber: cardAccountMaps[i]['cardNumber'],
  //       memo: cardAccountMaps[i]['memo'],
  //     );
  //   });
  // }

///
///
///
///
///
///
///
///
///
///
///
///
/// 거래 내역
  ///테이블 생성
  void _createMoneyTransactionTable(Database db) {
    db.execute(
      """
        CREATE TABLE money_transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          creationTime TEXT DEFAULT CURRENT_TIMESTAMP,
          updateTime TEXT DEFAULT CURRENT_TIMESTAMP,
          transactionTime TEXT,
          amount REAL,
          goods TEXT,
          categoryType TEXT,
          category TEXT,
          description TEXT,
          extraBudget INTEGER DEFAULT 0
          )
      """,
      // account TEXT,
    );
  }

  void _createMoneyTransactionDisplayTable(Database db) {
    db.execute(
      """
        CREATE TABLE money_transactions_display(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          transactionTime TEXT,
          amount REAL,
          goods TEXT,
          categoryType TEXT,
          category TEXT,
          description TEXT,
          )
      """,
      // account TEXT,
    );
  }

  /// 테이블 키 추가
  void _addColumnHiddenPrameterToMoneyTransactionTable(Database db) async  {
    db.execute(
      """
      ALTER TABLE money_transactions
      ADD COLUMN parameter TEXT
      """
    );
  }

  /// 테이블 키 추가(할부기간)
  void _addColumnInstallationToMoneyTransactionTable(Database db) async  {
    db.execute(
      """
      ALTER TABLE money_transactions
      ADD COLUMN installation INTEGER DEFAULT 1
      """
    );
  }

  // void _addTriggerForParameterUpdate(Database db) async {
  //   db.execute(
  //     """
  //     CREATE TRIGGER update_parameter_trigger
  //     AFTER INSERT OR UPDATE
  //     ON money_transactions
  //     BEGIN
  //       UPDATE money_transactions
  //       SET parameter = json_object(
  //         'trans_code', json_object(
  //           'date', NEW.transactionTime,
  //           'goods', NEW.goods,
  //           'amount', NEW.amount
  //         )
  //       )
  //       WHERE id = NEW.id;
  //     END;
  //     """
  //   );
  // }
  void _addTriggerForParameterUpdateRenewal(Database db) async {
    // 기존 트리거 제거
    await db.execute("DROP TRIGGER IF EXISTS update_parameter_trigger");
    await db.execute("DROP TRIGGER IF EXISTS update_parameter_trigger_insert");
    await db.execute("DROP TRIGGER IF EXISTS update_parameter_trigger_update");

    // INSERT 트리거
    await db.execute(
      """
      CREATE TRIGGER update_parameter_trigger_insert
      AFTER INSERT
      ON money_transactions
      BEGIN
        UPDATE money_transactions
        SET parameter = json_patch(
          parameter,
          json_object(
            'trans_code', json_object(
              'date', NEW.transactionTime,
              'goods', NEW.goods,
              'amount', NEW.amount
            )
          )
        )
        WHERE id = NEW.id;
      END;
      """
    );

    // UPDATE 트리거
    await db.execute(
      """
      CREATE TRIGGER update_parameter_trigger_update
      AFTER UPDATE
      ON money_transactions
      BEGIN
        UPDATE money_transactions
        SET parameter = json_patch(
          parameter,
          json_object(
            'trans_code', json_object(
              'date', NEW.transactionTime,
              'goods', NEW.goods,
              'amount', NEW.amount
            )
          )
        )
        WHERE id = NEW.id;
      END;
      """
    );
  }

  Future<void> processExistingData(Database db) async {
    // 1. 기존 데이터 가져오기
    List<Map<String, dynamic>> existingRecords = await db.query('money_transactions');

    // 2. 트리거와 동일한 로직 적용
    for (var record in existingRecords) {
      // JSON 생성
      String parameter = jsonEncode({
        'trans_code': {
          'date': record['transactionTime'],
          'goods': record['goods'],
          'amount': record['amount'],
        },
      });

      // 3. 데이터베이스 업데이트
      await db.update(
        'money_transactions',
        {'parameter': parameter},
        where: 'id = ?',
        whereArgs: [record['id']],
      );
    }
  }

  // void _addExtraBoolTransactionTable(Database db) async  {
  //   db.execute(
  //     """
  //     ALTER TABLE money_transactions
  //     ADD COLUMN extraBudget INTEGER DEFAULT 0
  //     """
  //   );
  // }

  
  Future<int> insertMoneyTransaction(MoneyTransaction moneyTransaction) async {
    final db = await database;
    // updateAccountBalance(moneyTransaction);
    return await db.insert('money_transactions', moneyTransaction.toMap());
  }

  Future<int> updateMoneyTransaction(MoneyTransaction updatedTransaction) async {
    final db = await database;
    // updateAccountBalance(updatedTransaction);
    return await db.update(
      'money_transactions',
      updatedTransaction.toMap(),
      where: 'id = ?',
      whereArgs: [updatedTransaction.id],
    );
  }

  ///특정 대상 카테고리 일괄 변경
  Future<void> updateCategorySearchAllTable(String goodsname, String newValue, String newValueType, bool isPositive) async {
    final db = await database;
    try { 
      await db.transaction((txn) async {
        await txn.update(
          'money_transactions',
          {'category': newValue, 'categoryType': newValueType},
          where: 'goods  = ? AND ${isPositive ? 'amount  > 0' : 'amount < 0'}',
          whereArgs: [goodsname],
        );
      });
    } catch (e){
      logger.e(e);
    }
  }

  Future<int> deleteMoneyTransaction(int id) async {
    final db = await database;
    // List<Map<String, dynamic>> transactions = await db.query(
    //   'money_transactions',
    //   where: 'id = ?',
    //   whereArgs: [id],
    // );
    // deletionUpdateAccountBalance(transactions.first);
    return await db.delete(
      'money_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> idMoneyTransaction(MoneyTransaction moneyTransaction) async {
    final db = await database;
    // updateAccountBalance(updatedTransaction);
    return await db.update(
      'money_transactions',
      moneyTransaction.toMap(),
      where: 'id = ?',
      whereArgs: [moneyTransaction.id],
    );
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
        // account: transactionMaps[i]['account'],
        amount: transactionMaps[i]['amount'],
        goods: transactionMaps[i]['goods'],
        category: transactionMaps[i]['category'],
        categoryType: transactionMaps[i]['categoryType'],
        description: transactionMaps[i]['description'],
        parameter: transactionMaps[i]['parameter'],
        extraBudget: transactionMaps[i]['extraBudget'] == 0 ? false : true,
      );
    });
  }

   ///월간 거래내역(카테고리) 항목별 총합 가져오기
  Future<List<Map<String, dynamic>>> getransactionsSUMBByGoodsCategoriesMonth(int year, int month, String category) async {
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = await db.query(
      'money_transactions',
      columns: ['goods', 'SUM(amount) * -1 as totalAmount'],
      where: "substr(transactionTime,1,9) = ? AND category = ? AND categoryType = '소비' AND extraBudget == 0",
      whereArgs: ['$year년 ${month.toString().padLeft(2, '0')}월', category],
      groupBy: 'goods'
    );

    return transactionMaps;
  }

  ///월간 수입 가져오기
  Future<List<Map<String, dynamic>>> getIncomeSumMonthlyByMonth(int? range) async {
    try {
      final db = await database;
      if (range != null) {
        final today = DateTime.now();
        final startMonths = List.generate(
          range,
          (i) {
            final date = DateTime(today.year, today.month - i, 1);
            return "${date.year}년 ${date.month.toString().padLeft(2, '0')}월";
          },
        );
        final List<Map<String, dynamic>> transactionMaps = await db.query(
          'money_transactions',
          columns: ['substr(transactionTime,1,9) as yearmonth', 'SUM(amount) as totalAmount'],
          where: "substr(transactionTime, 1, 9) IN (${List.filled(startMonths.length, '?').join(', ')}) AND categoryType = '수입'",
          whereArgs: startMonths,
          groupBy: 'yearmonth'
        );
        
        return transactionMaps;
      } else{
        final List<Map<String, dynamic>> transactionMaps = await db.query(
          'money_transactions',
          columns: ['substr(transactionTime,1,9) as yearmonth', 'SUM(amount) as totalAmount'],
          where: "categoryType = '수입'",
          groupBy: 'yearmonth'
        );
        
        return transactionMaps;   
      }
    } catch (e) {
      logger.e('error: $e, fetching income failed');
      return [];
    }
  }

  ///월간 수입 카테고리로 구별하여 가져오기
  Future<List<Map<String, dynamic>>> getIncomeSumMonthlyByCategory(int? range) async {
    try {
      final db = await database;
      if (range != null) {
        final today = DateTime.now();
        final startMonths = List.generate(
          range,
          (i) {
            final date = DateTime(today.year, today.month - i, 1);
            return "${date.year}년 ${date.month.toString().padLeft(2, '0')}월";
          },
        );
        // 동적 바인딩을 위한 쿼리 생성
        final placeholders = List.filled(startMonths.length, '?').join(', ');

        // 쿼리 실행
        final List<Map<String, dynamic>> transactionMaps = await db.rawQuery(
          '''
          SELECT 
            substr(transactionTime, 1, 9) AS yearmonth,
            category,
            SUM(amount) AS totalAmount
          FROM money_transactions
          WHERE substr(transactionTime, 1, 9) IN ($placeholders)
            AND categoryType = '수입'
          GROUP BY yearmonth, category;
          ''',
          startMonths,
        );
        return transactionMaps;
      } else {
        final List<Map<String, dynamic>> transactionMaps = await db.rawQuery(
          '''
          SELECT 
            substr(transactionTime, 1, 9) AS yearmonth,
            category,
            SUM(amount) AS totalAmount
          FROM money_transactions
          WHERE categoryType = '수입'
          GROUP BY yearmonth, category;
          ''',
        );
        return transactionMaps;
      }
    } catch (e) {
      logger.e('error: $e, fetching income failed');
      return [];
    }
  }


  ///월간 순수입 가져오기
  Future<List<Map<String, dynamic>>> getNetIncomeSumMonthlyByMonth(int? range) async {
    try {
      final db = await database;
      if (range != null) {
        final today = DateTime.now();
        final startMonths = List.generate(
          range,
          (i) {
            final date = DateTime(today.year, today.month - i, 1);
            return "${date.year}년 ${date.month.toString().padLeft(2, '0')}월";
          },
        );
        // 동적 바인딩을 위한 쿼리 생성
        final placeholders = List.filled(startMonths.length, '?').join(', ');

        // 쿼리 실행
        final List<Map<String, dynamic>> transactionMaps = await db.rawQuery(
          '''
          SELECT 
            substr(transactionTime, 1, 9) AS yearmonth,
            SUM(amount) AS totalAmount
          FROM money_transactions
          WHERE substr(transactionTime, 1, 9) IN ($placeholders)
          GROUP BY yearmonth;
          ''',
          startMonths,
        );
        return transactionMaps;
      } else {
        final List<Map<String, dynamic>> transactionMaps = await db.rawQuery(
          '''
          SELECT 
            substr(transactionTime, 1, 9) AS yearmonth,
            SUM(amount) AS totalAmount
          FROM money_transactions
          GROUP BY yearmonth;
          ''',
        );
        return transactionMaps;
      }
    } catch (e) {
      logger.e('error: $e, fetching income failed');
      return [];
    }
  }

  ///카테고리별 월간 수입 총합 가져오기
  Future<List<Map<String, dynamic>>> getTransactionsIncomeSumByMonth(int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = await db.query(
      'money_transactions',
      columns: ['substr(transactionTime, 1, 9) AS yearmonth','SUM(amount) as totalAmount'],
      where: "substr(transactionTime,1,9) = ? AND categoryType = '수입' AND extraBudget == 0",
      whereArgs: ['$year년 ${month.toString().padLeft(2, '0')}월'],
    );
    
    return transactionMaps;
  }

  ///카테고리별 월간 소비 총합 가져오기
  Future<List<Map<String, dynamic>>> getTransactionsSUMByCategoryandDate(int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = await db.query(
      'money_transactions',
      columns: ['category', 'SUM(amount) * -1 as totalAmount'],
      where: "substr(transactionTime,1,9) = ? AND categoryType = '소비' AND extraBudget == 0",
      whereArgs: ['$year년 ${month.toString().padLeft(2, '0')}월'],
      groupBy: 'category'
    );
    
    return transactionMaps;
  }

  ///카테고리별 월간 소비 총합(0 이상) 가져오기
  Future<List<Map<String, dynamic>>> getTransactionsSUMByCategoryMonthNegative(int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = await db.query(
      'money_transactions',
      columns: ['category', 'SUM(amount) * -1 as totalAmount'],
      where: "substr(transactionTime,1,9) = ? AND categoryType = '소비' AND extraBudget == 0 AND amount < 0",
      whereArgs: ['$year년 ${month.toString().padLeft(2, '0')}월'],
      groupBy: 'category'
    );
    
    return transactionMaps;
  }

  ///카테고리별 연간 소비 총합 가져오기
  Future<List<Map<String, dynamic>>> getYearlySumByCategory(int year) async {
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = await db.query(
      'money_transactions',
      columns: ['category', 'SUM(amount) * -1 as totalAmount'],
      where: "substr(transactionTime,1,5) = ? AND categoryType = '소비'",
      whereArgs: ['$year년'],
      groupBy: 'category'
    );
    
    return transactionMaps;
  }

  ///카테고리별 연간 소비 총합(0 이상) 가져오기
  Future<List<Map<String, dynamic>>> getYearlySumByCategoryNegative(int year) async {
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = await db.query(
      'money_transactions',
      columns: ['category', 'SUM(amount) * -1 as totalAmount'],
      where: "substr(transactionTime,1,5) = ? AND categoryType = '소비' AND amount < 0",
      whereArgs: ['$year년'],
      groupBy: 'category'
    );
    
    return transactionMaps;
  }

  ///연도별 카테고리  소비 총합(0 이상) 가져오기
  Future<List<Map<String, dynamic>>> getCategorySumByYear(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = await db.query(
      'money_transactions',
      columns: ['substr(transactionTime,1,4) as year' , 'SUM(amount) * -1 as totalAmount'],
      where: "amount < 0 AND categoryType = '소비' AND category = ?",
      whereArgs: [category],
      groupBy: 'substr(transactionTime,1,4)'
    );
    
    return transactionMaps;
  }

  ///연도별 태그 소비 총합 가져오기
  Future<List<Map<String, dynamic>>> getTagSumByYear(String tagName) async {
    try {
      final db = await database;
      String secureTagname = tagName.replaceAll(RegExp(r'([*?\[\]])'), '');
      final List<Map<String, dynamic>> transactionMaps = await db.query(
        'money_transactions',
        columns: ['substr(transactionTime,1,4) as year' , 'SUM(amount) * -1 as totalAmount'],
        where: "categoryType = '소비' AND description LIKE ? OR description LIKE ?",
        whereArgs: ['%$secureTagname %', '%$secureTagname'],
        groupBy: 'substr(transactionTime,1,4)'
      );
      
      return transactionMaps;
    } catch(e) {
      return [];
    }
  }

  ///월간별 태그 소비 총합 가져오기
  Future<List<Map<String, dynamic>>> getTagSumByYearMonth(String tagName) async {
    try {
      // logger.d('tagName $tagName');
      final db = await database;
      String secureTagname = tagName.replaceAll(RegExp(r'([*?\[\]])'), '');
      final List<Map<String, dynamic>> transactionMaps = await db.query(
        'money_transactions',
        columns: ['substr(transactionTime,1,9) as yearmonth' , 'SUM(amount) * -1 as totalAmount'],
        where: "categoryType = '소비' AND description LIKE ? OR description LIKE ?",
        whereArgs: ['%$secureTagname %', '%$secureTagname'],
        groupBy: 'substr(transactionTime,1,9)'
      );
      // logger.d('transactionMaps $transactionMaps');
      
      return transactionMaps;
    } catch(e) {
      logger.e(e);
      return [];
    }
  }

  /// 태그 소비 리스트 가져오기 및 동일한 'installment' 항목을 기준으로 통합
  Future<List<MoneyTransaction>> getTransactionsByTag(String tagName) async {
    try {
      final db = await database;
      String secureTagname = tagName.replaceAll(RegExp(r'([*?\[\]])'), '');
      // 태그가 포함된 거래들을 찾는 쿼리
      final List<Map<String, dynamic>> rawList = await db.query(
        'money_transactions',
        where: "description LIKE ? OR description LIKE ?",
        whereArgs: ['%$secureTagname %', '%$secureTagname'],
      );
      // final List<Map<String, dynamic>> rawList = await db.query(
      //   'money_transactions',
      //   where: "description GLOB ? OR description GLOB ?",
      //   whereArgs: ['*$tagName *', '*$tagName'],
      // );
      // logger.d(rawList);

      // final List<MoneyTransaction> rawList =List.generate(transactionMaps.length, (i) {
      //   return MoneyTransaction(
      //     id: transactionMaps[i]['id'],
      //     transactionTime: transactionMaps[i]['transactionTime'],
      //     // account: transactionMaps[i]['account'],
      //     amount: transactionMaps[i]['amount'],
      //     goods: transactionMaps[i]['goods'],
      //     category: transactionMaps[i]['category'],
      //     categoryType: transactionMaps[i]['categoryType'],
      //     description: transactionMaps[i]['description'],
      //     parameter: transactionMaps[i]['parameter'],
      //     extraBudget: transactionMaps[i]['extraBudget'] == 0 ? false : true,
      //   );
      // });

      // installBaseId에 맞는 거래들을 그룹화
      Map<String, MoneyTransaction> groupedTransactions = {};
      for (Map<String, dynamic> transactionMap in rawList) {
        // logger.d(transactionMap);

        String? parameter = transactionMap['parameter'];
        Map<String, dynamic> parameterMap = jsonDecode(parameter!);

        // 'installment' 항목을 체크하고 base_id와 비교
        if (parameterMap['installment'] != null) {
          String baseId = parameterMap['installment']['base_id'].toString();

          if (groupedTransactions.containsKey(baseId)) {
            // 기존에 있는 항목에 amount를 합산
            MoneyTransaction existingTransaction = groupedTransactions[baseId]!;
            double newAmount = existingTransaction.amount + transactionMap['amount'];
            groupedTransactions[baseId] = existingTransaction.copyWith(amount: newAmount);
          } else {
            // 새로운 항목을 추가
            groupedTransactions[baseId] = MoneyTransaction(
              id: transactionMap['id'],
              transactionTime: transactionMap['transactionTime'],
              amount: transactionMap['amount'],
              goods: transactionMap['goods'],
              category: transactionMap['category'],
              categoryType: transactionMap['categoryType'],
              description: transactionMap['description'],
              parameter: transactionMap['parameter'],
              extraBudget: transactionMap['extraBudget'] == 0 ? false : true,
            );
          }
        } else {
          // installment가 없는 경우 별도로 추가
          String transactionId = transactionMap['id'].toString();
          groupedTransactions[transactionId] = MoneyTransaction(
            id: transactionMap['id'],
            transactionTime: transactionMap['transactionTime'],
            amount: transactionMap['amount'],
            goods: transactionMap['goods'],
            category: transactionMap['category'],
            categoryType: transactionMap['categoryType'],
            description: transactionMap['description'],
            parameter: transactionMap['parameter'],
            extraBudget: transactionMap['extraBudget'] == 0 ? false : true,
          );
        }
      }

      // 결과를 리스트로 변환
      List<MoneyTransaction> combinedTransactions = groupedTransactions.values.toList();

      // List<MoneyTransaction> combinedTransactions = List.generate(groupedTransactions.length, (i) {
      //   logger.i(i);
      //   return MoneyTransaction(
      //     id: groupedTransactions[i]['id'],
      //     transactionTime: groupedTransactions[i]['transactionTime'],
      //     // account: groupedTransactions[i]['account'],
      //     amount: groupedTransactions[i]['amount'],
      //     goods: groupedTransactions[i]['goods'],
      //     category: groupedTransactions[i]['category'],
      //     categoryType: groupedTransactions[i]['categoryType'],
      //     description: groupedTransactions[i]['description'],
      //     parameter: groupedTransactions[i]['parameter'],
      //     extraBudget: groupedTransactions[i]['extraBudget'] == 0 ? false : true,
      //   );
      // });
      
      logger.i(combinedTransactions.length);
      return combinedTransactions;

    } catch (e) {
      logger.e('Error fetching transactions by tag and installment: $e');
      return [];
    }
  }

  
  /// 리스트 가져오기 및 동일한 'installment' 항목을 기준으로 통합
  Future<List<MoneyTransaction>> getExportTransactions() async {
    try {
      final db = await database;
      // 태그가 포함된 거래들을 찾는 쿼리
      final List<Map<String, dynamic>> rawList = await db.query(
        'money_transactions',
      );
      // final List<Map<String, dynamic>> rawList = await db.query(
      //   'money_transactions',
      //   where: "description GLOB ? OR description GLOB ?",
      //   whereArgs: ['*$tagName *', '*$tagName'],
      // );
      // logger.d(rawList);

      // final List<MoneyTransaction> rawList =List.generate(transactionMaps.length, (i) {
      //   return MoneyTransaction(
      //     id: transactionMaps[i]['id'],
      //     transactionTime: transactionMaps[i]['transactionTime'],
      //     // account: transactionMaps[i]['account'],
      //     amount: transactionMaps[i]['amount'],
      //     goods: transactionMaps[i]['goods'],
      //     category: transactionMaps[i]['category'],
      //     categoryType: transactionMaps[i]['categoryType'],
      //     description: transactionMaps[i]['description'],
      //     parameter: transactionMaps[i]['parameter'],
      //     extraBudget: transactionMaps[i]['extraBudget'] == 0 ? false : true,
      //   );
      // });

      // installBaseId에 맞는 거래들을 그룹화
      Map<String, MoneyTransaction> groupedTransactions = {};
      for (Map<String, dynamic> transactionMap in rawList) {
        // logger.d(transactionMap);

        String? parameter = transactionMap['parameter'];
        Map<String, dynamic> parameterMap = jsonDecode(parameter!);

        // 'installment' 항목을 체크하고 base_id와 비교
        if (parameterMap['installment'] != null) {
          String baseId = parameterMap['installment']['base_id'].toString();

          if (groupedTransactions.containsKey(baseId)) {
            // 기존에 있는 항목에 amount를 합산
            MoneyTransaction existingTransaction = groupedTransactions[baseId]!;
            double newAmount = existingTransaction.amount + transactionMap['amount'];
            groupedTransactions[baseId] = existingTransaction.copyWith(amount: newAmount);
          } else {
            // 새로운 항목을 추가
            groupedTransactions[baseId] = MoneyTransaction(
              id: transactionMap['id'],
              transactionTime: transactionMap['transactionTime'],
              amount: transactionMap['amount'],
              goods: transactionMap['goods'],
              category: transactionMap['category'],
              categoryType: transactionMap['categoryType'],
              description: transactionMap['description'],
              parameter: transactionMap['parameter'],
              extraBudget: transactionMap['extraBudget'] == 0 ? false : true,
            );
          }
        } else {
          // installment가 없는 경우 별도로 추가
          String transactionId = transactionMap['id'].toString();
          groupedTransactions[transactionId] = MoneyTransaction(
            id: transactionMap['id'],
            transactionTime: transactionMap['transactionTime'],
            amount: transactionMap['amount'],
            goods: transactionMap['goods'],
            category: transactionMap['category'],
            categoryType: transactionMap['categoryType'],
            description: transactionMap['description'],
            parameter: transactionMap['parameter'],
            extraBudget: transactionMap['extraBudget'] == 0 ? false : true,
          );
        }
      }

      // 결과를 리스트로 변환
      List<MoneyTransaction> combinedTransactions = groupedTransactions.values.toList();

      // List<MoneyTransaction> combinedTransactions = List.generate(groupedTransactions.length, (i) {
      //   logger.i(i);
      //   return MoneyTransaction(
      //     id: groupedTransactions[i]['id'],
      //     transactionTime: groupedTransactions[i]['transactionTime'],
      //     // account: groupedTransactions[i]['account'],
      //     amount: groupedTransactions[i]['amount'],
      //     goods: groupedTransactions[i]['goods'],
      //     category: groupedTransactions[i]['category'],
      //     categoryType: groupedTransactions[i]['categoryType'],
      //     description: groupedTransactions[i]['description'],
      //     parameter: groupedTransactions[i]['parameter'],
      //     extraBudget: groupedTransactions[i]['extraBudget'] == 0 ? false : true,
      //   );
      // });
      
      logger.i(combinedTransactions.length);
      return combinedTransactions;

    } catch (e) {
      logger.e('Error fetching transactions by tag and installment: $e');
      return [];
    }
  }
  // ///태그 소비 리스트 가져오기
  // Future<List<MoneyTransaction>> getTransactionsByTag(String tagName) async {
  //   try {
  //     final db = await database;
  //     final List<Map<String, dynamic>> transactionMaps = await db.query(
  //       'money_transactions',
  //       where: "description LIKE ?",
  //       whereArgs: ['%$tagName%'],
  //     );

  //     return List.generate(transactionMaps.length, (i) {
  //       return MoneyTransaction(
  //         id: transactionMaps[i]['id'],
  //         transactionTime: transactionMaps[i]['transactionTime'],
  //         // account: transactionMaps[i]['account'],
  //         amount: transactionMaps[i]['amount'],
  //         goods: transactionMaps[i]['goods'],
  //         category: transactionMaps[i]['category'],
  //         categoryType: transactionMaps[i]['categoryType'],
  //         description: transactionMaps[i]['description'],
  //         parameter: transactionMaps[i]['parameter'],
  //         extraBudget: transactionMaps[i]['extraBudget'] == 0 ? false : true,
  //       );
  //     });
  //   } catch(e) {
  //     return [];
  //   }
  // }

  Future<List<String>> getTransactionsTags() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> tagResults = await db.rawQuery('''
        SELECT DISTINCT TRIM(SUBSTR(description, INSTR(description, '#'))) AS tag
        FROM money_transactions
        WHERE description LIKE '%#%'
      ''');
      
      // 태그 목록 생성
      final List<String> tags = tagResults
          .map((row) => row['tag'] as String)
          .expand((tagString) {
            // 공백으로 구분된 태그 분리
            // final RegExp tagPattern = RegExp(r'#\w+');
            final RegExp tagPattern = RegExp(r'#[\p{L}\p{N}_]+', unicode: true);
            return tagPattern.allMatches(tagString).map((m) => m.group(0)!);
          })
          .toSet() // 중복 제거
          .toList();

      return tags;
    } catch(e) {
      return [];
    }
  }

  ///특별 예산 항목 가져오기
  Future<List<MoneyTransaction>> getExtrabugetcategory() async {
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = await db.query(
      'money_transactions',
      where: "extraBudget = 1",
    );
    
    return List.generate(transactionMaps.length, (i) {
      return MoneyTransaction(
        id: transactionMaps[i]['id'],
        transactionTime: transactionMaps[i]['transactionTime'],
        // account: transactionMaps[i]['account'],
        amount: transactionMaps[i]['amount'],
        goods: transactionMaps[i]['goods'],
        category: transactionMaps[i]['category'],
        categoryType: transactionMaps[i]['categoryType'],
        description: transactionMaps[i]['description'],
        parameter: transactionMaps[i]['parameter'],
        extraBudget: transactionMaps[i]['extraBudget'] == 0 ? false : true,
      );
    });
  }

  Future<bool> checkIfTransCodeExists(String date, String goods, double amount) async {
    final db = await database;
    try {
      // JSON에서 trans_code 값을 비교하는 쿼리 실행
      final List<Map<String, dynamic>> result = await db.rawQuery(
        """
        SELECT COUNT(*) as count
        FROM money_transactions
        WHERE json_extract(parameter, '\$.trans_code.date') = ?
          AND json_extract(parameter, '\$.trans_code.goods') = ?
          AND json_extract(parameter, '\$.trans_code.amount') = ?
        """,
        [date, goods, amount]
      );

      // 결과에서 count 값이 0보다 크면 동일한 trans_code가 존재
      return result.isNotEmpty && result.first['count'] > 0;
    } catch (e) {
      logger.e('Error checking trans_code: $e');
      return false;
    }
  }

  Future<void> addInstallmentToParameter(int transactionId, int installBaseId) async {
    final db = await database;
    try {
      // 기존 parameter 데이터 가져오기
      final List<Map<String, dynamic>> result = await db.query(
        'money_transactions',
        where: 'id = ?',
        whereArgs: [transactionId],
      );

      if (result.isNotEmpty) {
        // 기존 parameter 값을 JSON 형식으로 가져오기
        String? parameter = result.first['parameter'];

        // parameter가 null인 경우 빈 JSON 객체로 초기화
        parameter ??= '{}';

        // JSON 파싱 및 installment 추가
        Map<String, dynamic> parameterMap = jsonDecode(parameter);
        if (parameterMap['installment'] == null) {
          parameterMap['installment'] = {};
        }


        parameterMap['installment']['base_id'] = installBaseId;

        // 업데이트된 parameter를 다시 JSON 문자열로 변환
        String updatedParameter = jsonEncode(parameterMap);
        // logger.d(updatedParameter);
        // parameter 업데이트
        await db.update(
          'money_transactions',
          {'parameter': updatedParameter},
          where: 'id = ?',
          whereArgs: [transactionId],
        );

        logger.i('Installment added successfully to transaction $transactionId');
      } else {
        logger.e('Transaction not found with ID: $transactionId');
      }
    } catch (e) {
      logger.e('Error adding installment to parameter: $e');
    }
  }

///
///
///
///
///
///
///
///
///
///
/// 카테고리
  ///테이블 생성 
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

  Future<void> _insertDefaultCategories(Database db) async {
    Map<String, List<String>> defaultCategories = {
      "수입": ["급여소득", "금융소득", "기타소득", "용돈", "페이백"],
      "소비": ["식비", "외식비", "주거비", "통신비", "생활비", "미용비", "의료비", "문화비", "유흥비", "교통비", "세금", '여행비', "금융비용", "보험", "기타",],
      "이체": ["내계좌송금", "타계좌송금", "내계좌수신", "저축", "투자", "충전", "카드대금"]
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

  Future<void> _insertYearlyExpenseCategories(Database db) async {
    Map<String, List<String>> defaultCategories = {
      "연간 예산": ["여행비"],
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
  
  Future<int> updateTransactionCategoryItemList(String name, List<String> updatedItemList) async {
    final db = await database;
    return await db.update(
      'transactions_categorys',
      {'itemList': updatedItemList.join(',')},
      where: 'name  = ?',
      whereArgs: [name],
    );
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

  Future<TransactionCategory> getYearlyExpenseCategories() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> categoryMaps = await db.query(
        'transactions_categorys',
        where: "name = 연간 예산",
      );
      return List.generate(categoryMaps.length, (i) {
        return TransactionCategory(
          id: categoryMaps[i]['id'],
          name: categoryMaps[i]['name'],
          itemList: categoryMaps[i]['itemList'] != null ? List<String>.from(categoryMaps[i]['itemList'].split(',')) : [],
        );
      }).first;
    } catch(e) {
      logger.e(e);
      return TransactionCategory(name: '오류', itemList: []);
    }
  }
  
///
///
///
///
///
///
///
///
///
///
/// 만기투자
  ///테이블 생성 
  // void _createExpirationInvestmentTable(Database db) {
  //   db.execute(
  //     """
  //       CREATE TABLE investments_expiration(
  //         id INTEGER PRIMARY KEY AUTOINCREMENT,
  //         creationTime TEXT DEFAULT CURRENT_TIMESTAMP,
  //         updateTime TEXT DEFAULT CURRENT_TIMESTAMP,
  //         investTime TEXT,
  //         expirationTime TEXT,
  //         interestRate REAL,
  //         account TEXT,
  //         amount REAL,
  //         valuePrice REAL,
  //         cost REAL,
  //         investment TEXT,
  //         investcategory TEXT,
  //         currency TEXT,
  //         description TEXT)
  //     """,
  //   );
  // }

  // Future<int> insertExpirationInvestment(ExpirationInvestment moneyInvestment) async {
  //   final db = await database;
  //   updateCurrentHoldingNonex(moneyInvestment);
  //   return await db.insert('investments_expiration', moneyInvestment.toMap());
  // }

  // Future<int> updateExpirationInvestment(ExpirationInvestment updatedInvestment) async {
  //   final db = await database;
  //   updateCurrentHoldingNonex(updatedInvestment);
  //   return await db.update(
  //     'investments_expiration',
  //     updatedInvestment.toMap(),
  //     where: 'id = ?',
  //     whereArgs: [updatedInvestment.id],
  //   );
  // }

  // Future<int> deleteExpirationInvestment(int id) async {
  //   final db = await database;
  //   List<Map<String, dynamic>> investments = await db.query(
  //     'investments_expiration',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  //   deletionUpdateCurrentHoldingNonex(investments.first);
  //   return await db.delete(
  //     'investments_expiration',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  // Future<List<ExpirationInvestment>> getExInvestmentsByDateRange(DateTime start, DateTime end) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> invesmentMaps = await db.query(
  //     'investments_expiration',
  //     where: 
  //       """
  //         substr(investTime, 1, 4) || '-' || 
  //         substr(investTime, 7, 2) || '-' || 
  //         substr(investTime, 11, 2) || 'T' ||
  //         substr(investTime, 15, 5) BETWEEN ? AND ?
  //       """,
  //     whereArgs: [start.toIso8601String(), end.toIso8601String()],
  //   );
  //   return List.generate(invesmentMaps.length, (i) {
  //     return ExpirationInvestment(
  //       id: invesmentMaps[i]['id'],
  //       investTime: invesmentMaps[i]['investTime'],
  //       expirationTime: invesmentMaps[i]['expirationTime'],
  //       interestRate: invesmentMaps[i]['interestRate'],
  //       account: invesmentMaps[i]['account'],
  //       amount: invesmentMaps[i]['amount'],
  //       valuePrice: invesmentMaps[i]['valuePrice'],
  //       cost: invesmentMaps[i]['cost'],
  //       investment: invesmentMaps[i]['investment'],
  //       investcategory: invesmentMaps[i]['investcategory'],
  //       currency: invesmentMaps[i]['currency'],
  //       description: invesmentMaps[i]['description'],
  //     );
  //   });
  // }

///
///
///
///
///
///
///
///
///
///
/// 비만기투자
  ///테이블 생성 
  // void _createNonExpirationInvestmentTable(Database db) {
  //   db.execute(
  //     """
  //       CREATE TABLE investments_nonexpiration(
  //         id INTEGER PRIMARY KEY AUTOINCREMENT,
  //         creationTime TEXT DEFAULT CURRENT_TIMESTAMP,
  //         updateTime TEXT DEFAULT CURRENT_TIMESTAMP,
  //         investTime TEXT,
  //         account TEXT,
  //         amount REAL,
  //         valuePrice REAL,
  //         cost REAL,
  //         investment TEXT,
  //         investcategory TEXT,
  //         currency TEXT,
  //         description TEXT)
  //     """,
  //   );
  // }

  // Future<int> insertNonExpirationInvestment(NonexpirationInvestment moneyInvestment) async {
  //   final db = await database;
  //   updateCurrentHoldingNonex(moneyInvestment);
  //   return await db.insert('investments_nonexpiration', moneyInvestment.toMap());
  // }

  // Future<int> updateNonExpirationInvestment(NonexpirationInvestment updatedInvestment) async {
  //   final db = await database;
  //   updateCurrentHoldingNonex(updatedInvestment);
  //   return await db.update(
  //     'investments_nonexpiration',
  //     updatedInvestment.toMap(),
  //     where: 'id = ?',
  //     whereArgs: [updatedInvestment.id],
  //   );
  // }

  // Future<int> deleteNonExpirationInvestment(int id) async {
  //   final db = await database;
  //   List<Map<String, dynamic>> investments = await db.query(
  //     'investments_nonexpiration',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  //   deletionUpdateCurrentHoldingNonex(investments.first);
  //   return await db.delete(
  //     'investments_nonexpiration',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  // Future<List<NonexpirationInvestment>> getNonExInvestmentsByDateRange(DateTime start, DateTime end) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> invesmentMaps = await db.query(
  //     'investments_nonexpiration',
  //     where:
  //       """
  //         substr(investTime, 1, 4) || '-' || 
  //         substr(investTime, 7, 2) || '-' || 
  //         substr(investTime, 11, 2) || 'T' ||
  //         substr(investTime, 15, 5) BETWEEN ? AND ?
  //       """,
  //     whereArgs: [start.toIso8601String(), end.toIso8601String()],
  //   );
  //   return List.generate(invesmentMaps.length, (i) {
  //     return NonexpirationInvestment(
  //       id: invesmentMaps[i]['id'],
  //       investTime: invesmentMaps[i]['investTime'],
  //       account: invesmentMaps[i]['account'],
  //       amount: invesmentMaps[i]['amount'],
  //       valuePrice: invesmentMaps[i]['valuePrice'],
  //       cost: invesmentMaps[i]['cost'],
  //       investment: invesmentMaps[i]['investment'],
  //       investcategory: invesmentMaps[i]['investcategory'],
  //       currency: invesmentMaps[i]['currency'],
  //       description: invesmentMaps[i]['description'],
  //     );
  //   });
  // }

///
///
///
///
///
///
///
///
///
///
/// 보유투자
  ///테이블 생성
  // void _createCurrentHoldingTable(Database db) {
  //   db.execute(
  //     """
  //       CREATE TABLE current_holdings(
  //         id INTEGER PRIMARY KEY AUTOINCREMENT,
  //         investment TEXT,
  //         totalAmount REAL,
  //         investcategory TEXT,
  //         currency TEXT)
  //     """,
  //   );
  // }

  // Future<void> _insertInitialHoldings(Database db) async {


  //   // 각 투자 이름별 합계 계산
  //   final List<Map<String, dynamic>> summaryEx = await db.rawQuery(
  //     """
  //     SELECT investment, SUM(amount) AS totalAmount, investcategory, currency FROM investments_expiration GROUP BY investment, investcategory, currency 
  //     """
  //   );

  //   final List<Map<String, dynamic>> summaryNonex = await db.rawQuery(
  //     """
  //     SELECT investment, SUM(amount) AS totalAmount, investcategory, currency FROM investments_nonexpiration GROUP BY investment, investcategory, currency 
  //     """
  //   );

  //   final batch = db.batch();
  //   for (final entry in summaryEx) {
  //     final investment = entry['investment'] as String;
  //     final totalAmount = entry['totalAmount'] as double;
  //     final investcategory = entry['investcategory'] as String;
  //     final currency = entry['currency'] as String;
      
  //     if (totalAmount != 0) {
  //       batch.insert(
  //         'current_holdings',
  //         {'investment': investment, 'totalAmount': totalAmount, 'investcategory': investcategory, 'currency': currency},
  //         conflictAlgorithm: ConflictAlgorithm.replace,
  //       );
  //     }
  //   }

  //   for (final entry in summaryNonex) {
  //     final investment = entry['investment'] as String;
  //     final totalAmount = entry['totalAmount'] as double;
  //     final investcategory = entry['investcategory'] as String;
  //     final currency = entry['currency'] as String;
      
  //     if (totalAmount != 0) {
  //       batch.insert(
  //         'current_holdings',
  //         {'investment': investment, 'totalAmount': totalAmount, 'investcategory': investcategory, 'currency': currency},
  //         conflictAlgorithm: ConflictAlgorithm.replace,
  //       );
  //     }
  //   }

  //   await batch.commit();
  // }

  // Future<int> updateCurrentHoldingNonex(dynamic updatedInvestment) async {
  //   final db = await database;

  //   final currentData = await db.query(
  //     'current_holdings',
  //     where: 'investment = ?',
  //     whereArgs: [updatedInvestment.investment],
  //   );

  //   final double oldTotalAmount = currentData.isNotEmpty ? currentData.first['totalAmount'] as double : 0;
  //   final double newTotalAmount = oldTotalAmount + updatedInvestment.amount;

  //   int updateResult;

  //   if (currentData.isEmpty) {
  //     updateResult = await db.insert(
  //       'current_holdings',
  //       {
  //         'investment': updatedInvestment.investment,
  //         'totalAmount': updatedInvestment.amount,
  //         'investcategory': updatedInvestment.investcategory,
  //         'currency': updatedInvestment.currency,
  //       },
  //     );
  //   } else {
  //     updateResult = await db.update(
  //       'current_holdings',
  //       {'totalAmount': newTotalAmount},
  //       where: 'investment = ?',
  //       whereArgs: [updatedInvestment.investment],
  //     );

  //     if (newTotalAmount == 0) {
  //       await db.delete(
  //         'current_holdings',
  //         where: 'investment = ?',
  //         whereArgs: [updatedInvestment.investment],
  //       );
  //     }
  //   }

  //   return updateResult;
  // }

  // Future<int> deletionUpdateCurrentHoldingNonex(dynamic updatedInvestment) async {
  //   final db = await database;
  //   final currentData = await db.query(
  //     'current_holdings',
  //     where: 'investment = ?',
  //     whereArgs: [updatedInvestment['investment']],
  //   );

  //   final double oldTotalAmount = currentData.isNotEmpty ? currentData.first['totalAmount'] as double : 0;
  //   final double newTotalAmount = oldTotalAmount - updatedInvestment['amount'];

  //   int updateResult;

  //   if (currentData.isEmpty) {
  //     updateResult = await db.insert(
  //       'current_holdings',
  //       {
  //         'investment': updatedInvestment['investment'],
  //         'totalAmount': updatedInvestment['amount'],
  //         'investcategory': updatedInvestment['investcategory'],
  //         'currency': updatedInvestment['currency'],
  //       },
  //     );
  //   } else {
  //     updateResult = await db.update(
  //       'current_holdings',
  //       {'totalAmount': newTotalAmount},
  //       where: 'investment = ?',
  //       whereArgs: [updatedInvestment['investment']],
  //     );

  //     if (newTotalAmount == 0) {
  //       await db.delete(
  //         'current_holdings',
  //         where: 'investment = ?',
  //         whereArgs: [updatedInvestment['investment']],
  //       );
  //     }
  //   }

  //   return updateResult;
  // }

  // Future<List<Holdings>> getCurrentHoldInvestments() async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> holdings = await db.query('current_holdings',);
  //   return List.generate(holdings.length, (i) {
  //     return Holdings(
  //       id: holdings[i]['id'],
  //       investment: holdings[i]['investment'],
  //       totalAmount: holdings[i]['totalAmount'],
  //       investcategory: holdings[i]['investcategory'],
  //       currency: holdings[i]['currency'],
  //     );
  //   });
  // }

///
///
///
///
///
///
///
///
  /// 수입 설정
  void _createIncomeTable(Database db) {
    db.execute(
      """
        CREATE TABLE income_settings(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          income INTEGER)
      """,
    );
  }

  Future<int> insertIncomeTable(int incomeNumber) async {
    final db = await database;
    await db.delete('income_settings');
    return await db.insert(
      'income_settings',
      {'income' : incomeNumber}
    );
  }

  Future<int> updateIncomeTable(int incomeNumber, int incomeID) async {
    final db = await database;
    return await db.update(
      'income_settings',
      {'income' : incomeNumber},
      where: 'id = ?',
      whereArgs: [incomeID],
    );
  }

   Future<Map<String, dynamic>> getIncome() async {
    final db = await database;
    final List<Map<String, dynamic>> incomeMap = await db.query(
      'income_settings',
    );
    try {
      if (incomeMap.isEmpty) {
        return {};
      } else {
        return incomeMap[0];
      }
    } catch(e) {
      logger.e(e);
      return {};
    }
  }
///
///
/// 예산설정
  ///테이블 생성
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
  
  Future<int> insertBugetSettingTable(BudgetSetting budgetSetting) async {
    final db = await database;
    return await db.insert('budget_settings', budgetSetting.toMap());
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

///
///
///
///
///
///
///
///
///
///
/// 연간별도예산설정
  ///테이블 생성
  void _createExtraBugetSettingTable(Database db) {
    db.execute(
      """
        CREATE TABLE extra_budgets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          dataList TEXT)
      """,
    );
  }

  void _deleteNameinExtraGroupTable(Database db) async  {
    db.execute(
      """
      ALTER TABLE extra_budgets
      DROP COLUMN name
      """
    );
  }

  Future<int> insertExtraBugetSettingTable(ExtraBudgetGroup extraBudgetSetting) async {
    final db = await database;
    return await db.insert('extra_budgets', extraBudgetSetting.toMap());
  }

  Future<int> updateExtraGroup(ExtraBudgetGroup updatedExtraBudgetSetting) async {
    final db = await database;
    return await db.update(
      'extra_budgets',
      updatedExtraBudgetSetting.toMap(),
      where: 'id = ?',
      whereArgs: [updatedExtraBudgetSetting.id],
    );
  }

  Future<void> updateExtraJsonData(String jsonData, int dataID) async {
    final db = await database;
    // await db.execute(
    //   """
    //     UPDATE extra_budgets
    //     SET dataList = json_patch(
    //       dataList,
    //       json_object(
    //         'tableData', json_object(
    //           $jsonData
    //         )
    //       )
    //     )
    //     WHERE id = $dataID;
    //   """
    // );
    await db.rawUpdate(
      """
      UPDATE extra_budgets
        SET dataList = json_patch(
          dataList,
          json(?)
        )
        WHERE id = ?;
      """,
      [jsonData, dataID],
    );
  }

  Future<int> clearExtraGroup() async {
    final db = await database;
    return await db.delete(
      'extra_budgets',
    );
  }

  Future<int> deleteExtraGroup(int id) async {
    final db = await database;
    return await db.delete(
      'extra_budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  ///모든 특별 예산 그룹 가져오기 
  Future<List<ExtraBudgetGroup>> getAllExtraGroupDatas() async {
    final db = await database;
    final List<Map<String, dynamic>> groupDataMaps = await db.query('extra_budgets');
    try {
      return List.generate(groupDataMaps.length, (i) {
        return ExtraBudgetGroup(
          id: groupDataMaps[i]['id'],
          dataList: groupDataMaps[i]['dataList'] != null ? Map<String, dynamic>.from(json.decode(groupDataMaps[i]['dataList'])) : null,
        );
      });
    } catch(e) {
      logger.d(groupDataMaps);
      return [];
    }
  }

  ///특별 예산 그룹 아이디로 가져오기
  Future<ExtraBudgetGroup?> getExtraGroupDatasById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> groupDataMaps = await db.query(
      'extra_budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (groupDataMaps.isEmpty) {
      return null;
    }
    return ExtraBudgetGroup(
      id: groupDataMaps[0]['id'],
      dataList: groupDataMaps[0]['dataList'] != null ? Map<String, dynamic>.from(json.decode(groupDataMaps[0]['dataList'])) : null,
    );
  }

  
  // 추가적인 데이터베이스 작업들...
}
