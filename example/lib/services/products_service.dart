class Product {
  final String id;
  final String name;
  final double price;
  Product({
    required this.id,
    required this.name,
    required this.price,
  });
}

class ProductsService {
  static List<Product> products = [
    Product(id: '1', name: 'coca cola', price: 1.00),
    Product(id: '2', name: 'sprite', price: 1.20),
    Product(id: '3', name: 'Mountain Dew', price: 2.00),
    Product(id: '4', name: 'Doctor Pepper', price: 1.5)
  ];

  static Product? getById(String id) {
    try {
      return products.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }
}
