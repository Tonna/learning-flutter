import 'dart:async';

import 'package:path/path.dart';
import 'package:shopping_list_app/log.dart';
import 'package:shopping_list_app/model.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'shopping_list.db'),
      onOpen: (db) {
//        db.delete("product");
//        db.delete("product_state_change");
//        db.delete("product_product_state_change_link");
      },
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE `product` ( `id` INTEGER, `name` TEXT NOT NULL, PRIMARY KEY(`id`) )");
        db.execute(
            "CREATE TABLE `product_product_state_change_link` ( `product_id` INTEGER, `product_state_change_id` INTEGER, PRIMARY KEY(`product_id`,`product_state_change_id`))");
        db.execute(
            "CREATE TABLE `product_state_change` ( `id` INTEGER, `new_state` TEXT NOT NULL, `changed_at` TEXT NOT NULL, PRIMARY KEY(`id`) )");
      },
      version: 1,
    );
  }

  Future<List<Product>> loadListOfProducts() async {
    log("loadList start");

    final Database db = await database;

    List<Map<String, dynamic>> list = await db.rawQuery(
        "select p.id as product_id, p.name as product_name, c.id as change_state_id, c.new_state as new_state, c.changed_at as state_changed_at"
        " from product p"
        " join product_product_state_change_link l"
        " on p.id == l.product_id"
        " join product_state_change c"
        " on c.id == l.product_state_change_id");
    //TODO add order by and stuff to reduce work
    log(list);

    var listOfStateChanges = Map<int, List<ProductStateChange>>();
    var listOfProducts = Map<int, Product>();

    try {
      list.forEach((element) {
        log(element);
        if (!listOfStateChanges.containsKey(element['product_id'])) {
          listOfStateChanges[element['product_id']] =
              List<ProductStateChange>();
        }
        listOfStateChanges[element['product_id']].add(ProductStateChange(
            element['change_state_id'],
            getStateObject(element['new_state']),
            DateTime.parse(element['state_changed_at'])));
      });
      log(listOfStateChanges);

      list.forEach((element) {
        if (!listOfProducts.containsKey(element['product_id'])) {
          listOfProducts[element['product_id']] = Product(
              element['product_id'],
              element['product_name'],
              listOfStateChanges[element['product_id']]);
        }
      });

      log(listOfProducts);
    } catch (e) {
      log(e);
      throw e;
    }
    return listOfProducts.values.toList();
  }

  Future<ProductStateChange> addProductStateChange(
      ProductState state, int productId) async {
    final Database db = await database;
    log(db);
    //TODO extract time creation later
    try {
      var when = DateTime.now();
      int stateChangeId = await db.rawInsert(
          "insert into product_state_change (new_state, changed_at) values(?, ?)",
          [getStateString(state), when.toIso8601String()]);

      await db.rawInsert(
          "insert into product_product_state_change_link (product_id, product_state_change_id) values(?, ?)",
          [productId, stateChangeId]);
      log("added state");
      return ProductStateChange(stateChangeId, state, when);
    } catch (e) {
      log(e);
      throw e;
    }
  }

  Future<Product> addNewProduct(String name) async {
    final Database db = await database;

    log(db);
    log(name);
    //TODO extract specific values, abstract this code
    int productId =
        await db.rawInsert("insert into product (name) values(?)", [name]);
    var productStateChange =
        await addProductStateChange(ProductState.active, productId);

    return Product(productId, name, [productStateChange]);
  }
}
