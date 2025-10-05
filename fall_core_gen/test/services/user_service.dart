import 'package:fall_core_base/fall_core_base.dart';
import 'package:logger/logger.dart';

/// 用户服务示例，同时使用@Aop和@Service注解
@Aop(allowedHooks: ['logging', 'timing'])
@Service()
class UserService {
  static final Logger _logger = LoggerFactory.getBusinessLogger();

  /// 用户登录
  Future<bool> login(String username, String password) async {
    _logger.i('用户尝试登录', error: {'username': username});

    // 模拟登录逻辑
    await Future.delayed(const Duration(milliseconds: 100));

    if (username == 'admin' && password == 'password') {
      _logger.i('用户登录成功', error: {'username': username});
      return true;
    } else {
      _logger.w('用户登录失败', error: {'username': username});
      return false;
    }
  }

  /// 获取用户信息
  Map<String, dynamic> getUserInfo(String userId) {
    _logger.i('获取用户信息', error: {'userId': userId});

    // 模拟数据库查询
    if (userId == '1') {
      return {
        'id': '1',
        'name': '管理员',
        'email': 'admin@example.com',
        'role': 'admin',
      };
    }

    throw Exception('用户不存在: $userId');
  }

  /// 更新用户信息
  void updateUser(String userId, Map<String, dynamic> userData) {
    _logger.i('更新用户信息', error: {'userId': userId, 'userData': userData});

    // 模拟数据库更新
    if (userId != '1') {
      throw Exception('用户不存在: $userId');
    }

    _logger.i('用户信息更新成功', error: {'userId': userId});
  }

  /// 这个方法不会被AOP增强
  @NoAop(reason: '内部辅助方法，不需要日志记录')
  String _generateToken(String userId) {
    return 'token_${userId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 获取访问令牌
  String getAccessToken(String userId) {
    final token = _generateToken(userId);
    _logger.d('生成访问令牌', error: {'userId': userId});
    return token;
  }
}
