import 'package:fall_core_base/fall_core_base.dart';

@AutoScan(include: ['test/services/**'], annotations: [Aop])
abstract class ServiceScan implements Ioc {}
