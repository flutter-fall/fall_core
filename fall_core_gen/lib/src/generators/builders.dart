import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'aop_generator.dart';
import 'service_autoscan.dart';

/// 创建AOP生成器的Builder
Builder aopGenerator(BuilderOptions options) {
  return LibraryBuilder(
    AopGenerator(),
    generatedExtension: '.g.dart',
    options: options,
  );
}

Builder serviceAutoScan(BuilderOptions options) {
  bool debug = false;
  if (options.config['debug'] == true) {
    debug = true;
  }
  return LibraryBuilder(
    ServiceAutoScan(debug: debug),
    generatedExtension: '.g.dart',
    options: options,
  );
}
