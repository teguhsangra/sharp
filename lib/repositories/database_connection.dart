import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseConnection{

  setDatabase() async{
    var dir  = await getApplicationDocumentsDirectory();
    var path = join(dir.path, 'db_sharp');
    var database = await openDatabase(path, version: 1, onCreate: createDatabase);
    return database;
  }


  createDatabase(Database database, int version) async{
    await database.execute("CREATE TABLE sales_orders ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "is_sync BOOLEAN DEFAULT false,"
        "tenant_id UNSIGNED BIG INT,"
        "location_id UNSIGNED BIG INT,"
        "customer_id UNSIGNED BIG INT NULL,"
        "contact_id UNSIGNED BIG INT NULL,"
        "emergency_contact_id UNSIGNED BIG INT NULL,"
        "primary_product_id UNSIGNED BIG INT,"
        "code VARCHAR,"
        "name VARCHAR,"
        "is_inquiry BOOLEAN DEFAULT false,"
        "has_contract BOOLEAN DEFAULT false,"
        "is_renewal BOOLEAN DEFAULT false,"
        "status VARCHAR DEFAULT draft,"
        "renewal_status VARCHAR DEFAULT draft,"
        "started_at DATETIME,"
        "ended_at DATETIME,"
        "signed_at DATETIME NULL,"
        "term VARCHAR,"
        "term_of_payment VARCHAR,"
        "term_notice_period INT,"
        "tax_percentage INT,"
        "length_of_term INT,"
        "total_cost DOUBLE,"
        "total_price DOUBLE,"
        "total_discount DOUBLE,"
        "total_tax DOUBLE,"
        "drafted_by VARCHAR)");

    await database.execute("CREATE TABLE sales_order_details ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "sales_order_id UNSIGNED BIG INT,"
        "product_id UNSIGNED BIG INT,"
        "customer_complimentary_id UNSIGNED BIG INT NULL,"
        "complimentary_id UNSIGNED BIG INT NULL,"
        "asset_type_id UNSIGNED BIG INT NULL,"
        "asset_id UNSIGNED BIG INT NULL,"
        "room_id UNSIGNED BIG INT NULL,"
        "name VARCHAR,"
        "type VARCHAR DEFAULT charged,"
        "has_complimentary INT,"
        "has_term INT,"
        "is_repeated_in_term INT,"
        "has_quantity INT,"
        "term VARCHAR,"
        "repeated_term VARCHAR,"
        "started_at DATETIME,"
        "ended_at DATETIME,"
        "length_of_term INT,"
        "quantity INT,"
        "total_use_of_complimentary INT,"
        "cost DOUBLE,"
        "price DOUBLE,"
        "discount DOUBLE,"
        "service_charge DOUBLE,"
        "tax DOUBLE,"
        "FOREIGN KEY (sales_order_id) REFERENCES sales_orders (id) ON UPDATE CASCADE ON DELETE CASCADE)");

  }
}