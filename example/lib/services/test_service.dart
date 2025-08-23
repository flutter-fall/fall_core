import 'package:fall_core/fall_core.dart';
import 'package:logger/logger.dart';
import 'user_service.dart';

/// 测试服务，用于验证命名注册和命名注入功能
@Service(name: 'testService', lazy: false)
class TestService {
  static final Logger _logger = LoggerFactory.getBusinessLogger();

  @Auto() // 通过类型注入 UserService
  late UserService userService;

  @Auto(name: 'nonExistentService') // 注入一个不存在的服务，用于测试错误处理
  late dynamic nonExistentService;

  /// 测试方法
  void testMethod() {
    _logger.i('TestService.testMethod called');

    if (userService != null) {
      _logger.i('UserService 注入成功');
    } else {
      _logger.e('UserService 注入失败');
    }

    if (nonExistentService != null) {
      _logger.i('NonExistentService 注入成功');
    } else {
      _logger.e('NonExistentService 注入失败（这是预期的）');
    }
  }
}

/// 另一个命名服务，用于测试多个命名服务的情况
@Service(name: 'namedService')
class NamedService {
  void performAction() {
    print('NamedService.performAction called');
  }
}
