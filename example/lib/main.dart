import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fall_core/fall_core.dart';
import 'services/user_service.dart';
import 'services/product_service.dart';
import 'services/test_service.dart';
import 'init/auto_scan.g.dart';

void main() {
  runApp(FallCoreExampleApp());
}

class FallCoreExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fall Core Framework Example',
      home: ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  @override
  _ExampleHomePageState createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  String _output = '点击按钮测试功能...';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  /// 使用AutoScan自动初始化服务
  void _initializeServices() {
    // 手动注册AOP服务（这个不能被@Service注解，因为它不在扫描范围内）
    Get.lazyPut<AopService>(() => AopService());

    // 使用自动扫描生成的服务注册
    AutoScan.registerServices();
    // 执行自动依赖注入
    AutoScan.injectServices();
    // 注册AOP Hooks
    final aopService = Get.find<AopService>();
    aopService.addBeforeHook(LogBeforeHook());
    aopService.addAfterHook(LogAfterHook());
    aopService.addThrowHook(LogThrowHook());
  }

  void _testUserService() async {
    try {
      final userService = Get.find<UserService>();

      // 测试登录（成功）
      final loginResult = await userService.login('admin', 'password');

      // 测试获取用户信息
      final userInfo = userService.getUserInfo('1');

      // 测试获取访问令牌
      final token = userService.getAccessToken('1');

      setState(() {
        _output =
            '用户服务测试结果:\n'
            '登录结果: $loginResult\n'
            '用户信息: $userInfo\n'
            '访问令牌: $token';
      });
    } catch (e) {
      setState(() {
        _output = '用户服务测试失败: $e';
      });
    }
  }

  void _testProductService() {
    try {
      final productService = Get.find<ProductService>();

      // 测试获取所有商品
      final products = productService.getAllProducts();

      // 测试搜索商品
      final searchResults = productService.searchProducts('电脑');

      // 测试检查库存
      final stockAvailable = productService.isStockAvailable('1', 5);

      setState(() {
        _output =
            '商品服务测试结果:\n'
            '商品总数: ${products.length}\n'
            '搜索结果: ${searchResults.length}个商品\n'
            '库存充足: $stockAvailable';
      });
    } catch (e) {
      setState(() {
        _output = '商品服务测试失败: $e';
      });
    }
  }

  void _testErrorHandling() async {
    try {
      final userService = Get.find<UserService>();

      // 测试登录失败
      await userService.login('wrong', 'credentials');
    } catch (e) {
      // 预期的错误
    }

    try {
      final userService = Get.find<UserService>();

      // 测试获取不存在的用户
      userService.getUserInfo('999');
    } catch (e) {
      setState(() {
        _output = '错误处理测试完成\n查看控制台日志了解详细信息';
      });
    }
  }

  void _testValidation() async {
    try {
      final userService = Get.find<UserService>();

      // 测试参数验证
      await userService.login('', ''); // 应该抛出验证错误
    } catch (e) {
      setState(() {
        _output = '参数验证测试结果: $e';
      });
    }
  }

  void _testNamedInjection() {
    try {
      // 测试命名注入功能
      final testService = Get.find<TestService>(tag: 'testService');
      testService.testMethod();

      // 测试通过名称获取服务
      final userService = Get.find<UserService>();
      final namedService = Get.find<NamedService>(tag: 'namedService');

      setState(() {
        _output =
            '命名注入测试结果:\n'
            'TestService 创建成功\n'
            'UserService (通过名称): ${userService != null ? '成功' : '失败'}\n'
            'NamedService (通过名称): ${namedService != null ? '成功' : '失败'}\n'
            '查看控制台日志了解详细信息';
      });

      namedService.performAction();
    } catch (e) {
      setState(() {
        _output = '命名注入测试失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fall Core Framework Example'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fall Core框架功能测试',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: _testUserService,
                  child: Text('测试用户服务'),
                ),
                ElevatedButton(
                  onPressed: _testProductService,
                  child: Text('测试商品服务'),
                ),
                ElevatedButton(
                  onPressed: _testErrorHandling,
                  child: Text('测试错误处理'),
                ),
                ElevatedButton(
                  onPressed: _testValidation,
                  child: Text('测试参数验证'),
                ),
                ElevatedButton(
                  onPressed: _testNamedInjection,
                  child: Text('测试命名注入'),
                ),
              ],
            ),

            SizedBox(height: 20),
            Text(
              '输出结果:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _output,
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
