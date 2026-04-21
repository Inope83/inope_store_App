import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'inope_store.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE,
        name TEXT,
        phone TEXT,
        created_at TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        price REAL,
        discount_price REAL,
        category TEXT,
        image_url TEXT,
        rating REAL,
        is_new INTEGER,
        is_featured INTEGER,
        sizes TEXT,
        colors TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE cart(
        id TEXT PRIMARY KEY,
        product_id TEXT,
        user_id TEXT,
        name TEXT,
        price REAL,
        quantity INTEGER,
        size TEXT,
        color TEXT,
        image_url TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE orders(
        id TEXT PRIMARY KEY,
        user_id TEXT,
        total_amount REAL,
        status TEXT,
        payment_method TEXT,
        address TEXT,
        created_at TEXT
      )
    ''');
    
    await _insertSampleProducts(db);
  }

  Future<void> _insertSampleProducts(Database db) async {
    List<Map<String, dynamic>> products = [
      {'id': '1', 'name': 'Air Runner Pro', 'description': 'Comfortable running shoes', 'price': 89.99, 'category': 'Shoes', 'image_url': '👟', 'rating': 4.5, 'is_new': 1, 'is_featured': 1, 'sizes': 'S,M,L,XL', 'colors': 'Black,White,Blue'},
      {'id': '2', 'name': 'Floral Dress', 'description': 'Beautiful summer dress', 'price': 54.99, 'discount_price': 44.99, 'category': 'Dresses', 'image_url': '👗', 'rating': 4.8, 'is_new': 1, 'is_featured': 1, 'sizes': 'S,M,L', 'colors': 'Red,Blue,Pink'},
      {'id': '3', 'name': 'Classic Tee', 'description': 'Cotton t-shirt', 'price': 29.99, 'category': 'Tops', 'image_url': '👕', 'rating': 4.2, 'is_new': 0, 'is_featured': 1, 'sizes': 'S,M,L,XL', 'colors': 'Black,White,Gray'},
      {'id': '4', 'name': 'Slim Fit Pants', 'description': 'Comfortable slim fit pants', 'price': 69.99, 'category': 'Pants', 'image_url': '👖', 'rating': 4.3, 'is_new': 1, 'is_featured': 0, 'sizes': '28,30,32,34', 'colors': 'Black,Navy,Khaki'},
      {'id': '5', 'name': 'Mini Tote Bag', 'description': 'Stylish tote bag', 'price': 44.99, 'category': 'Bags', 'image_url': '👜', 'rating': 4.6, 'is_new': 0, 'is_featured': 1, 'sizes': 'One Size', 'colors': 'Brown,Black,Tan'},
      {'id': '6', 'name': 'Running Shoes', 'description': 'Lightweight running shoes', 'price': 79.99, 'category': 'Shoes', 'image_url': '👟', 'rating': 4.4, 'is_new': 0, 'is_featured': 0, 'sizes': '40,41,42,43,44', 'colors': 'Red,Blue,Black'},
    ];
    
    for (var product in products) {
      await db.insert('products', product, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
