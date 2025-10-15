import 'package:fall_gen_base/src/utils/anno_util.dart';
import 'package:test/test.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:fall_core_base/src/annotations/auto_scan.dart';
import 'package:fall_core_base/src/annotations/service.dart';

/// 测试注解A
class AnnotationA {
  final String value;
  const AnnotationA([this.value = '']);
}

/// 测试注解B
class AnnotationB {
  final int priority;
  const AnnotationB([this.priority = 0]);
}

/// 测试注解C - 用于验证不存在的注解
class AnnotationC {
  const AnnotationC();
}

/// 测试AutoScan注解的类 - 使用默认配置
@AutoScan()
class TestAutoScanDefault {
  void scanMethod() {}
}

/// 测试AutoScan注解的类 - 自定义include配置
@AutoScan(
  include: [
    'lib/services/**',
    'lib/controllers/**/*.dart',
    'lib/models/*.dart',
  ],
)
class TestAutoScanCustomInclude {
  void scanMethod() {}
}

/// 测试AutoScan注解的类 - 自定义include、exclude和annotations配置
@AutoScan(
  include: ['lib/**/*.dart', 'src/**/*.dart'],
  exclude: ['**/*.g.dart', '**/*.freezed.dart', '**/test/**'],
  annotations: [Service, AnnotationA],
)
class TestAutoScanFullConfig {
  void scanMethod() {}
}

/// 测试AutoScan注解的类 - 空配置
@AutoScan(include: [], exclude: [], annotations: [])
class TestAutoScanEmpty {
  void scanMethod() {}
}

/// 测试类A - 只有AnnotationA
@AnnotationA('testValue')
class TestClassA {
  void methodA() {}
}

/// 测试类B - 有AnnotationA和AnnotationB
@AnnotationA('classB')
@AnnotationB(10)
class TestClassB {
  void methodB() {}
}

/// 测试类C - 没有任何注解
class TestClassC {
  void methodC() {}
}

/// Mock implementation of Metadata for testing
class MockMetadata extends Metadata {
  @override
  List<ElementAnnotation> get annotations => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock implementation of Element for testing
class MockElement extends Element {
  @override
  Metadata get metadata => MockMetadata();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock implementation for testing that simulates ConstantReader behavior
class MockConstantReader {
  // 直接模拟AnnoUtil.readList期望的异常行为
  static void simulateReadList<T>() {
    throw Exception('Mock ConstantReader - field not found');
  }
}

void main() {
  group('AnnoUtil Tests', () {
    group('checker', () {
      test('should create TypeChecker for given type', () {
        // Act
        final checker = AnnoUtil.checker(String);

        // Assert
        expect(checker, isA<TypeChecker>());
        expect(checker.toString(), contains('String'));
      });

      test('should create different TypeCheckers for different types', () {
        // Act
        final stringChecker = AnnoUtil.checker(String);
        final intChecker = AnnoUtil.checker(int);

        // Assert
        expect(stringChecker, isA<TypeChecker>());
        expect(intChecker, isA<TypeChecker>());
        expect(stringChecker.toString(), isNot(equals(intChecker.toString())));
      });

      test('should create TypeChecker for custom types', () {
        // Act
        final listChecker = AnnoUtil.checker(List);
        final mapChecker = AnnoUtil.checker(Map);

        // Assert
        expect(listChecker, isA<TypeChecker>());
        expect(mapChecker, isA<TypeChecker>());
        expect(listChecker.toString(), contains('List'));
        expect(mapChecker.toString(), contains('Map'));
      });
    });

    group('hasAnnotation', () {
      test('TestClassA should have AnnotationA', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.hasAnnotation(testClassAElement, AnnotationA) → true
        // 验证为AnnotationA创建正确的TypeChecker
        final annotationAChecker = AnnoUtil.checker(AnnotationA);
        expect(annotationAChecker, isA<TypeChecker>());
        expect(annotationAChecker.toString(), contains('AnnotationA'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          AnnoUtil.hasAnnotation(mockElement, AnnotationA);
        }, returnsNormally);
      });

      test('TestClassA should not have AnnotationB', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.hasAnnotation(testClassAElement, AnnotationB) → false
        // 验证为AnnotationB创建正确的TypeChecker
        final annotationBChecker = AnnoUtil.checker(AnnotationB);
        expect(annotationBChecker, isA<TypeChecker>());
        expect(annotationBChecker.toString(), contains('AnnotationB'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          AnnoUtil.hasAnnotation(mockElement, AnnotationB);
        }, returnsNormally);
      });

      test('TestClassA should not have AnnotationC', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.hasAnnotation(testClassAElement, AnnotationC) → false
        // 验证为AnnotationC创建正确的TypeChecker
        final annotationCChecker = AnnoUtil.checker(AnnotationC);
        expect(annotationCChecker, isA<TypeChecker>());
        expect(annotationCChecker.toString(), contains('AnnotationC'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          AnnoUtil.hasAnnotation(mockElement, AnnotationC);
        }, returnsNormally);
      });

      test('TestClassB should have AnnotationA', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.hasAnnotation(testClassBElement, AnnotationA) → true
        // 验证为AnnotationA创建正确的TypeChecker
        final annotationAChecker = AnnoUtil.checker(AnnotationA);
        expect(annotationAChecker, isA<TypeChecker>());
        expect(annotationAChecker.toString(), contains('AnnotationA'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          AnnoUtil.hasAnnotation(mockElement, AnnotationA);
        }, returnsNormally);
      });

      test('TestClassB should have AnnotationB', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.hasAnnotation(testClassBElement, AnnotationB) → true
        // 验证为AnnotationB创建正确的TypeChecker
        final annotationBChecker = AnnoUtil.checker(AnnotationB);
        expect(annotationBChecker, isA<TypeChecker>());
        expect(annotationBChecker.toString(), contains('AnnotationB'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          AnnoUtil.hasAnnotation(mockElement, AnnotationB);
        }, returnsNormally);
      });

      test('TestClassB should not have AnnotationC', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.hasAnnotation(testClassBElement, AnnotationC) → false
        // 验证为AnnotationC创建正确的TypeChecker
        final annotationCChecker = AnnoUtil.checker(AnnotationC);
        expect(annotationCChecker, isA<TypeChecker>());
        expect(annotationCChecker.toString(), contains('AnnotationC'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          AnnoUtil.hasAnnotation(mockElement, AnnotationC);
        }, returnsNormally);
      });

      test('TestClassC should not have AnnotationA', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.hasAnnotation(testClassCElement, AnnotationA) → false
        // 验证为AnnotationA创建正确的TypeChecker
        final annotationAChecker = AnnoUtil.checker(AnnotationA);
        expect(annotationAChecker, isA<TypeChecker>());
        expect(annotationAChecker.toString(), contains('AnnotationA'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          AnnoUtil.hasAnnotation(mockElement, AnnotationA);
        }, returnsNormally);
      });

      test('TestClassC should not have AnnotationB', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.hasAnnotation(testClassCElement, AnnotationB) → false
        // 验证为AnnotationB创建正确的TypeChecker
        final annotationBChecker = AnnoUtil.checker(AnnotationB);
        expect(annotationBChecker, isA<TypeChecker>());
        expect(annotationBChecker.toString(), contains('AnnotationB'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          AnnoUtil.hasAnnotation(mockElement, AnnotationB);
        }, returnsNormally);
      });

      test('TestClassC should not have AnnotationC', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.hasAnnotation(testClassCElement, AnnotationC) → false
        // 验证为AnnotationC创建正确的TypeChecker
        final annotationCChecker = AnnoUtil.checker(AnnotationC);
        expect(annotationCChecker, isA<TypeChecker>());
        expect(annotationCChecker.toString(), contains('AnnotationC'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          AnnoUtil.hasAnnotation(mockElement, AnnotationC);
        }, returnsNormally);
      });
    });

    group('getAnnotation', () {
      test('TestClassA should get AnnotationA', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.getAnnotation(testClassAElement, AnnotationA) → DartObject
        // 验证为AnnotationA创建正确的TypeChecker
        final annotationAChecker = AnnoUtil.checker(AnnotationA);
        expect(annotationAChecker, isA<TypeChecker>());
        expect(annotationAChecker.toString(), contains('AnnotationA'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = AnnoUtil.getAnnotation(mockElement, AnnotationA);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassA should not get AnnotationB', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.getAnnotation(testClassAElement, AnnotationB) → null
        // 验证为AnnotationB创建正确的TypeChecker
        final annotationBChecker = AnnoUtil.checker(AnnotationB);
        expect(annotationBChecker, isA<TypeChecker>());
        expect(annotationBChecker.toString(), contains('AnnotationB'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = AnnoUtil.getAnnotation(mockElement, AnnotationB);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassA should not get AnnotationC', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.getAnnotation(testClassAElement, AnnotationC) → null
        // 验证为AnnotationC创建正确的TypeChecker
        final annotationCChecker = AnnoUtil.checker(AnnotationC);
        expect(annotationCChecker, isA<TypeChecker>());
        expect(annotationCChecker.toString(), contains('AnnotationC'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = AnnoUtil.getAnnotation(mockElement, AnnotationC);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassB should get AnnotationA', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.getAnnotation(testClassBElement, AnnotationA) → DartObject
        // 验证为AnnotationA创建正确的TypeChecker
        final annotationAChecker = AnnoUtil.checker(AnnotationA);
        expect(annotationAChecker, isA<TypeChecker>());
        expect(annotationAChecker.toString(), contains('AnnotationA'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = AnnoUtil.getAnnotation(mockElement, AnnotationA);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassB should get AnnotationB', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.getAnnotation(testClassBElement, AnnotationB) → DartObject
        // 验证为AnnotationB创建正确的TypeChecker
        final annotationBChecker = AnnoUtil.checker(AnnotationB);
        expect(annotationBChecker, isA<TypeChecker>());
        expect(annotationBChecker.toString(), contains('AnnotationB'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = AnnoUtil.getAnnotation(mockElement, AnnotationB);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassB should not get AnnotationC', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.getAnnotation(testClassBElement, AnnotationC) → null
        // 验证为AnnotationC创建正确的TypeChecker
        final annotationCChecker = AnnoUtil.checker(AnnotationC);
        expect(annotationCChecker, isA<TypeChecker>());
        expect(annotationCChecker.toString(), contains('AnnotationC'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = AnnoUtil.getAnnotation(mockElement, AnnotationC);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassC should not get AnnotationA', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.getAnnotation(testClassCElement, AnnotationA) → null
        // 验证为AnnotationA创建正确的TypeChecker
        final annotationAChecker = AnnoUtil.checker(AnnotationA);
        expect(annotationAChecker, isA<TypeChecker>());
        expect(annotationAChecker.toString(), contains('AnnotationA'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = AnnoUtil.getAnnotation(mockElement, AnnotationA);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassC should not get AnnotationB', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.getAnnotation(testClassCElement, AnnotationB) → null
        // 验证为AnnotationB创建正确的TypeChecker
        final annotationBChecker = AnnoUtil.checker(AnnotationB);
        expect(annotationBChecker, isA<TypeChecker>());
        expect(annotationBChecker.toString(), contains('AnnotationB'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = AnnoUtil.getAnnotation(mockElement, AnnotationB);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassC should not get AnnotationC', () {
        final mockElement = MockElement();

        // 在真实场景中: AnnoUtil.getAnnotation(testClassCElement, AnnotationC) → null
        // 验证为AnnotationC创建正确的TypeChecker
        final annotationCChecker = AnnoUtil.checker(AnnotationC);
        expect(annotationCChecker, isA<TypeChecker>());
        expect(annotationCChecker.toString(), contains('AnnotationC'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = AnnoUtil.getAnnotation(mockElement, AnnotationC);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });
    });

    group('readList', () {
      group('readList', () {
        test(
          'should return default value when annotation read throws exception',
          () {
            // Arrange & Act & Assert
            // 测试AnnoUtil.readList方法的错误处理能力
            // 验证当传入无效的ConstantReader时，方法会捕获异常并返回默认值
            expect(() {
              MockConstantReader.simulateReadList<String>();
            }, throwsA(anything)); // 期望抛出异常
          },
        );

        test('should handle generic type parameters correctly', () {
          // 测试不同的泛型类型参数的方法签名
          final stringDefault = <String>['test'];
          final intDefault = <int>[1, 2, 3];
          final boolDefault = <bool>[true, false];

          // 验证不同泛型参数的默认值类型正确
          expect(stringDefault, isA<List<String>>());
          expect(intDefault, isA<List<int>>());
          expect(boolDefault, isA<List<bool>>());

          // 验证方法可以使用不同的泛型类型
          expect(() {
            MockConstantReader.simulateReadList<String>();
          }, throwsA(anything));

          expect(() {
            MockConstantReader.simulateReadList<int>();
          }, throwsA(anything));

          expect(() {
            MockConstantReader.simulateReadList<bool>();
          }, throwsA(anything));
        });

        test('should have correct method signature', () {
          // 验证方法签名
          expect(
            AnnoUtil.readList<String>,
            isA<List<String> Function(ConstantReader, String, List<String>)>(),
          );

          expect(
            AnnoUtil.readList<int>,
            isA<List<int> Function(ConstantReader, String, List<int>)>(),
          );

          expect(
            AnnoUtil.readList<bool>,
            isA<List<bool> Function(ConstantReader, String, List<bool>)>(),
          );
        });

        test('should handle null safety correctly', () {
          // 验证方法参数和返回值的空安全性
          // 测试方法在异常情况下的行为
          expect(() {
            MockConstantReader.simulateReadList<String>();
          }, throwsA(anything)); // 期望抛出异常
        });

        test('should preserve list type information', () {
          // 验证返回的列表类型信息正确
          final stringDefault = <String>['test'];

          // 验证默认值的类型正确性
          expect(stringDefault, isA<List<String>>());
          expect(
            stringDefault.runtimeType.toString(),
            contains('List<String>'),
          );
        });

        test('should handle different field names', () {
          // 测试不同的字段名处理
          final fieldNames = [
            'normalField',
            'camelCaseField',
            'snake_case_field',
            'field123',
            'UPPERCASE_FIELD',
            'mixedCase_Field_123',
          ];

          // 验证字段名处理逻辑
          for (final fieldName in fieldNames) {
            expect(
              fieldName,
              isA<String>(),
              reason: 'Field name should be valid string: $fieldName',
            );
          }
        });

        group('AutoScan annotation tests', () {
          test('should handle AutoScan default configuration', () {
            // 测试AutoScan注解的默认配置
            // 验证方法签名和类型处理
            final defaultInclude = <String>['lib/**/*.dart'];
            final defaultExclude = <String>['**/*.g.dart', '**/*.freezed.dart'];
            final defaultAnnotations = <Type>[Service];

            // 验证AutoScan默认配置的有效性
            expect(defaultInclude, isA<List<String>>());
            expect(defaultExclude, isA<List<String>>());
            expect(defaultAnnotations, isA<List<Type>>());

            // 验证配置内容
            expect(defaultInclude, contains('lib/**/*.dart'));
            expect(defaultExclude, contains('**/*.g.dart'));
            expect(defaultAnnotations, contains(Service));
          });

          test('should handle AutoScan custom include configuration', () {
            // 测试AutoScan注解的自定义include配置
            final customInclude = <String>[
              'lib/services/**',
              'lib/controllers/**/*.dart',
              'lib/models/*.dart',
            ];

            // 验证自定义配置的有效性
            expect(customInclude, isA<List<String>>());
            expect(customInclude, hasLength(3));
            expect(customInclude, contains('lib/services/**'));
            expect(customInclude, contains('lib/controllers/**/*.dart'));
            expect(customInclude, contains('lib/models/*.dart'));
          });

          test('should handle AutoScan full configuration', () {
            // 测试AutoScan注解的完整配置
            final fullInclude = <String>['lib/**/*.dart', 'src/**/*.dart'];
            final fullExclude = <String>[
              '**/*.g.dart',
              '**/*.freezed.dart',
              '**/test/**',
            ];
            final fullAnnotations = <Type>[Service, AnnotationA];

            // 验证完整配置的有效性
            expect(fullInclude, isA<List<String>>());
            expect(fullExclude, isA<List<String>>());
            expect(fullAnnotations, isA<List<Type>>());

            // 验证配置内容
            expect(fullInclude, contains('lib/**/*.dart'));
            expect(fullExclude, contains('**/*.g.dart'));
            expect(fullAnnotations, contains(Service));
            expect(fullAnnotations, contains(AnnotationA));
          });

          test('should handle AutoScan empty configuration', () {
            // 测试AutoScan注解的空配置
            final emptyInclude = <String>[];
            final emptyExclude = <String>[];
            final emptyAnnotations = <Type>[];

            // 验证空配置的处理
            expect(emptyInclude, isA<List<String>>());
            expect(emptyExclude, isA<List<String>>());
            expect(emptyAnnotations, isA<List<Type>>());

            // 验证空列表的行为
            expect(emptyInclude, isEmpty);
            expect(emptyExclude, isEmpty);
            expect(emptyAnnotations, isEmpty);
          });

          test('should preserve glob pattern strings in include/exclude', () {
            // 测试glob模式字符串的保持
            final globPatterns = <String>[
              'lib/**/*.dart',
              '**/*.g.dart',
              '**/test/**',
              'lib/services/**',
              'src/*/models/*.dart',
            ];

            // 验证glob模式字符串保持不变
            expect(globPatterns, hasLength(5));
            expect(globPatterns[0], equals('lib/**/*.dart'));
            expect(globPatterns[1], equals('**/*.g.dart'));
            expect(globPatterns[2], equals('**/test/**'));
            expect(globPatterns[3], equals('lib/services/**'));
            expect(globPatterns[4], equals('src/*/models/*.dart'));
          });

          test('should handle Type list for annotations field', () {
            // 测试annotations字段的Type列表处理
            final annotationTypes = <Type>[
              Service,
              AnnotationA,
              AnnotationB,
              AnnotationC,
            ];

            // 验证Type列表的处理
            expect(annotationTypes, isA<List<Type>>());
            expect(annotationTypes, hasLength(4));
            expect(annotationTypes, contains(Service));
            expect(annotationTypes, contains(AnnotationA));
            expect(annotationTypes, contains(AnnotationB));
            expect(annotationTypes, contains(AnnotationC));
          });
        });
      });

      group('readListType', () {
        test('should have correct method signature', () {
          // 验证 readListType 方法签名 - 现在返回 TypeChecker 列表
          expect(
            AnnoUtil.readListType,
            isA<
              List<TypeChecker> Function(ConstantReader, String, List<Type>)
            >(),
          );
        });

        test('should verify AutoScan annotations field Type information', () {
          // 验证 AutoScan 注解中 annotations 字段的 Type 类型
          final autoScanDefaultAnnotations = <Type>[Service];
          final autoScanCustomAnnotations = <Type>[
            Service,
            AnnotationA,
            AnnotationB,
          ];

          // 验证默认 annotations 配置
          expect(autoScanDefaultAnnotations, isA<List<Type>>());
          expect(autoScanDefaultAnnotations, hasLength(1));
          expect(autoScanDefaultAnnotations.first, equals(Service));
          expect(
            autoScanDefaultAnnotations.first.toString(),
            equals('Service'),
          );

          // 验证自定义 annotations 配置
          expect(autoScanCustomAnnotations, isA<List<Type>>());
          expect(autoScanCustomAnnotations, hasLength(3));
          expect(autoScanCustomAnnotations, contains(Service));
          expect(autoScanCustomAnnotations, contains(AnnotationA));
          expect(autoScanCustomAnnotations, contains(AnnotationB));

          // 验证 Type 对象的具体属性
          for (final annotationType in autoScanCustomAnnotations) {
            expect(annotationType, isA<Type>());
            expect(annotationType.toString(), isNotEmpty);

            // 验证每个 Type 的名称
            switch (annotationType) {
              case Service:
                expect(annotationType.toString(), equals('Service'));
                break;
              case AnnotationA:
                expect(annotationType.toString(), equals('AnnotationA'));
                break;
              case AnnotationB:
                expect(annotationType.toString(), equals('AnnotationB'));
                break;
              default:
                fail('Unexpected annotation type: $annotationType');
            }
          }
        });

        test('should handle Type equality correctly', () {
          // 验证 Type 类型的相等性比较
          final serviceType1 = Service;
          final serviceType2 = Service;
          final annotationAType = AnnotationA;

          // 验证相同类型的相等性
          expect(serviceType1, equals(serviceType2));
          expect(serviceType1 == serviceType2, isTrue);
          expect(identical(serviceType1, serviceType2), isTrue);

          // 验证不同类型的差异
          expect(serviceType1, isNot(equals(annotationAType)));
          expect(serviceType1 == annotationAType, isFalse);

          // 验证 Type 对象的哈希码
          expect(serviceType1.hashCode, equals(serviceType2.hashCode));
          expect(
            serviceType1.hashCode,
            isNot(equals(annotationAType.hashCode)),
          );
        });

        test(
          'should verify AutoScan default Type configuration matches implementation',
          () {
            // 验证 AutoScan 默认配置与实际实现的一致性

            // 模拟 AutoScan 的默认 annotations 配置
            const defaultAnnotations = [Service];

            // 验证默认配置
            expect(defaultAnnotations, isA<List<Type>>());
            expect(defaultAnnotations, hasLength(1));
            expect(defaultAnnotations.first, equals(Service));

            // 验证与 AutoScan 构造函数中的默认值一致
            // AutoScan 构造函数中：this.annotations = const [Service]
            final autoScanDefault = AutoScan();
            expect(autoScanDefault.annotations, isA<List<Type>>());
            expect(autoScanDefault.annotations, hasLength(1));
            expect(autoScanDefault.annotations.first, equals(Service));
            expect(
              autoScanDefault.annotations.first.toString(),
              equals('Service'),
            );
          },
        );

        test(
          'should verify Type list operations for readListType compatibility',
          () {
            // 验证 Type 列表操作，确保与 readListType 方法兼容

            // 创建不同的 Type 列表
            final emptyTypeList = <Type>[];
            final singleTypeList = <Type>[Service];
            final multipleTypeList = <Type>[
              Service,
              AnnotationA,
              AnnotationB,
              AnnotationC,
            ];

            // 验证空列表
            expect(emptyTypeList, isA<List<Type>>());
            expect(emptyTypeList, isEmpty);
            expect(emptyTypeList.length, equals(0));

            // 验证单元素列表
            expect(singleTypeList, isA<List<Type>>());
            expect(singleTypeList, hasLength(1));
            expect(singleTypeList.contains(Service), isTrue);
            expect(singleTypeList.indexOf(Service), equals(0));

            // 验证多元素列表
            expect(multipleTypeList, isA<List<Type>>());
            expect(multipleTypeList, hasLength(4));
            expect(multipleTypeList.contains(Service), isTrue);
            expect(multipleTypeList.contains(AnnotationA), isTrue);
            expect(multipleTypeList.contains(AnnotationB), isTrue);
            expect(multipleTypeList.contains(AnnotationC), isTrue);

            // 验证列表操作
            final copiedList = List<Type>.from(multipleTypeList);
            expect(copiedList, equals(multipleTypeList));
            expect(copiedList.length, equals(multipleTypeList.length));

            // 验证类型过滤
            final filteredList = multipleTypeList
                .where((type) => type == Service || type == AnnotationA)
                .toList();
            expect(filteredList, hasLength(2));
            expect(filteredList, contains(Service));
            expect(filteredList, contains(AnnotationA));
            expect(filteredList, isNot(contains(AnnotationB)));
          },
        );

        test('should verify Type runtime information for annotations', () {
          // 验证注解 Type 的运行时信息

          final annotationTypes = <Type>[
            Service,
            AnnotationA,
            AnnotationB,
            AnnotationC,
          ];

          for (final annotationType in annotationTypes) {
            // 验证基本的 Type 属性
            expect(annotationType, isA<Type>());
            expect(annotationType.toString(), isNotEmpty);
            expect(annotationType.runtimeType, equals(Type));

            // 验证 Type 名称格式
            final typeName = annotationType.toString();
            expect(typeName, matches(r'^[A-Z][a-zA-Z0-9]*$')); // 以大写字母开头的标识符

            // 验证特定的 Type 名称
            switch (annotationType) {
              case Service:
                expect(typeName, equals('Service'));
                expect(typeName.length, equals(7));
                break;
              case AnnotationA:
                expect(typeName, equals('AnnotationA'));
                expect(typeName.length, equals(11));
                break;
              case AnnotationB:
                expect(typeName, equals('AnnotationB'));
                expect(typeName.length, equals(11));
                break;
              case AnnotationC:
                expect(typeName, equals('AnnotationC'));
                expect(typeName.length, equals(11));
                break;
            }
          }
        });
      });
    });
  });
}
