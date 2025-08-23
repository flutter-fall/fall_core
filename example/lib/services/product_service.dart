import 'package:fall_core/fall_core.dart';
import 'package:logger/logger.dart';

/// 商品服务示例，只使用@Service注解（不使用AOP）
@Service(lazy: false)
class ProductService {
  static final Logger _logger = LoggerFactory.getBusinessLogger();

  final List<Map<String, dynamic>> _products = [
    {'id': '1', 'name': '笔记本电脑', 'price': 5999.0, 'stock': 10},
    {'id': '2', 'name': '智能手机', 'price': 2999.0, 'stock': 50},
    {'id': '3', 'name': '平板电脑', 'price': 1999.0, 'stock': 30},
  ];

  /// 获取所有商品
  List<Map<String, dynamic>> getAllProducts() {
    _logger.i('获取所有商品列表');
    return List.from(_products);
  }

  /// 根据ID获取商品
  Map<String, dynamic> getProductById(String productId) {
    _logger.i('根据ID获取商品', error: {'productId': productId});

    final product = _products.firstWhere(
      (p) => p['id'] == productId,
      orElse: () => throw Exception('商品不存在: $productId'),
    );

    return Map.from(product);
  }

  /// 搜索商品
  List<Map<String, dynamic>> searchProducts(String keyword) {
    _logger.i('搜索商品', error: {'keyword': keyword});

    if (keyword.isEmpty) {
      return getAllProducts();
    }

    return _products.where((product) {
      final name = product['name'] as String;
      return name.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
  }

  /// 更新商品库存
  void updateStock(String productId, int newStock) {
    _logger.i('更新商品库存', error: {'productId': productId, 'newStock': newStock});

    final productIndex = _products.indexWhere((p) => p['id'] == productId);
    if (productIndex == -1) {
      throw Exception('商品不存在: $productId');
    }

    _products[productIndex]['stock'] = newStock;
    _logger.i(
      '商品库存更新成功',
      error: {'productId': productId, 'newStock': newStock},
    );
  }

  /// 检查库存是否充足
  bool isStockAvailable(String productId, int quantity) {
    final product = getProductById(productId);
    final currentStock = product['stock'] as int;
    return currentStock >= quantity;
  }
}
