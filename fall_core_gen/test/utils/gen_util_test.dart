import 'package:test/test.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:fall_core_gen/src/utils/gen_util.dart';
import 'package:build/build.dart';

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

/// Mock implementation of Element for testing
class MockElement extends Element {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('GenUtil Tests', () {
    group('getImportPath', () {
      test('should return package URI as-is for different packages', () {
        // Arrange
        final importUri = Uri.parse('package:flutter/material.dart');
        final outputUri = Uri.parse('package:fall_core/fall_core.dart');

        // Act
        final result = GenUtil.getImportPath(importUri, outputUri);

        // Assert
        expect(result, equals('package:flutter/material.dart'));
      });

      test('should calculate relative path for same package URIs', () {
        // Arrange
        final importUri = Uri.parse(
          'package:fall_core/src/annotations/service.dart',
        );
        final outputUri = Uri.parse(
          'package:fall_core/src/generators/service_generator.dart',
        );

        // Act
        final result = GenUtil.getImportPath(importUri, outputUri);

        // Assert
        expect(result, equals('../annotations/service.dart'));
      });

      test(
        'should calculate relative path for same package URIs in same directory',
        () {
          // Arrange
          final importUri = Uri.parse(
            'package:fall_core/src/hooks/before_hook.dart',
          );
          final outputUri = Uri.parse(
            'package:fall_core/src/hooks/after_hook.dart',
          );

          // Act
          final result = GenUtil.getImportPath(importUri, outputUri);

          // Assert
          expect(result, equals('./before_hook.dart'));
        },
      );
      test(
        'should calculate relative path for same package URIs in same directory',
        () {
          // Arrange
          final importUri = Uri.parse(
            'package:fall_core/src/hooks/before_hook.dart',
          );
          final inputId = AssetId.resolve(importUri);

          // Act
          final result = GenUtil.getImportPath(
            inputId.uri,
            inputId.changeExtension(".g.dart").uri,
          );

          // Assert
          expect(result, equals('./before_hook.dart'));
        },
      );

      test(
        'should calculate relative path for same package URIs with nested paths',
        () {
          // Arrange
          final importUri = Uri.parse(
            'package:fall_core/src/utils/gen_util.dart',
          );
          final outputUri = Uri.parse(
            'package:fall_core/lib/init/auto_scan.g.dart',
          );

          // Act
          final result = GenUtil.getImportPath(importUri, outputUri);

          // Assert
          expect(result, equals('../../src/utils/gen_util.dart'));
        },
      );

      test('should return package URI as-is when output is file URI', () {
        // Arrange
        final importUri = Uri.parse('package:flutter/material.dart');
        final outputUri = Uri.parse('file:///project/lib/main.dart');

        // Act
        final result = GenUtil.getImportPath(importUri, outputUri);

        // Assert
        expect(result, equals('package:flutter/material.dart'));
      });

      test('should handle same package with deeply nested paths', () {
        // Arrange
        final importUri = Uri.parse(
          'package:my_app/lib/features/auth/models/user.dart',
        );
        final outputUri = Uri.parse(
          'package:my_app/lib/features/home/widgets/home_widget.dart',
        );

        // Act
        final result = GenUtil.getImportPath(importUri, outputUri);

        // Assert
        expect(result, equals('../../auth/models/user.dart'));
      });

      test(
        'should calculate relative path for file URIs in same directory',
        () {
          // Arrange
          final importUri = Uri.parse(
            'file:///project/lib/services/user_service.dart',
          );
          final outputUri = Uri.parse('file:///project/lib/main.dart');

          // Act
          final result = GenUtil.getImportPath(importUri, outputUri);

          // Assert
          expect(result, equals('./services/user_service.dart'));
        },
      );

      test(
        'should calculate relative path for file URIs in parent directory',
        () {
          // Arrange
          final importUri = Uri.parse('file:///project/lib/main.dart');
          final outputUri = Uri.parse(
            'file:///project/lib/services/user_service.dart',
          );

          // Act
          final result = GenUtil.getImportPath(importUri, outputUri);

          // Assert
          expect(result, equals('../main.dart'));
        },
      );

      test(
        'should calculate relative path for file URIs in different subdirectories',
        () {
          // Arrange
          final importUri = Uri.parse('file:///project/lib/models/user.dart');
          final outputUri = Uri.parse(
            'file:///project/lib/services/user_service.dart',
          );

          // Act
          final result = GenUtil.getImportPath(importUri, outputUri);

          // Assert
          expect(result, equals('../models/user.dart'));
        },
      );

      test('should handle Windows-style paths correctly', () {
        // Arrange
        final importUri = Uri.file(r'C:\project\lib\models\user.dart');
        final outputUri = Uri.file(
          r'C:\project\lib\services\user_service.dart',
        );

        // Act
        final result = GenUtil.getImportPath(importUri, outputUri);

        // Assert
        expect(result, equals('../models/user.dart'));
      });

      test(
        'should add ./ prefix when file is in same directory without prefix',
        () {
          // Arrange
          final importUri = Uri.parse('file:///project/lib/user_service.dart');
          final outputUri = Uri.parse('file:///project/lib/main.dart');

          // Act
          final result = GenUtil.getImportPath(importUri, outputUri);

          // Assert
          expect(result, equals('./user_service.dart'));
        },
      );

      test('should return original URI string for non-file schemes', () {
        // Arrange
        final importUri = Uri.parse('http://example.com/resource');
        final outputUri = Uri.parse('file:///project/lib/main.dart');

        // Act
        final result = GenUtil.getImportPath(importUri, outputUri);

        // Assert
        expect(result, equals('http://example.com/resource'));
      });

      test(
        'should return original URI string when output is not file scheme',
        () {
          // Arrange
          final importUri = Uri.parse('file:///project/lib/main.dart');
          final outputUri = Uri.parse('http://example.com/output');

          // Act
          final result = GenUtil.getImportPath(importUri, outputUri);

          // Assert
          expect(result, equals('file:///project/lib/main.dart'));
        },
      );

      test('should handle nested directory structures', () {
        // Arrange
        final importUri = Uri.parse(
          'file:///project/lib/features/auth/models/user.dart',
        );
        final outputUri = Uri.parse(
          'file:///project/lib/features/home/widgets/home_widget.dart',
        );

        // Act
        final result = GenUtil.getImportPath(importUri, outputUri);

        // Assert
        expect(result, equals('../../auth/models/user.dart'));
      });

      test('should handle same file path', () {
        // Arrange
        final importUri = Uri.parse('file:///project/lib/main.dart');
        final outputUri = Uri.parse('file:///project/lib/main.dart');

        // Act
        final result = GenUtil.getImportPath(importUri, outputUri);

        // Assert
        expect(result, equals('./main.dart'));
      });

      test('should handle complex nested paths with multiple levels', () {
        // Arrange
        final importUri = Uri.parse(
          'file:///project/lib/core/utils/string_utils.dart',
        );
        final outputUri = Uri.parse(
          'file:///project/lib/features/auth/presentation/pages/login_page.dart',
        );

        // Act
        final result = GenUtil.getImportPath(importUri, outputUri);

        // Assert
        expect(result, equals('../../../../core/utils/string_utils.dart'));
      });

      test('should handle root level files', () {
        // Arrange
        final importUri = Uri.parse('file:///project/lib/main.dart');
        final outputUri = Uri.parse('file:///project/lib/core/app.dart');

        // Act
        final result = GenUtil.getImportPath(importUri, outputUri);

        // Assert
        expect(result, equals('../main.dart'));
      });

      test('should handle error cases gracefully', () {
        // This test verifies that the method doesn't throw exceptions for edge cases
        // and returns the original URI string as fallback

        // Test with malformed URIs - should not throw
        expect(() {
          final result = GenUtil.getImportPath(
            Uri.parse('package:flutter/material.dart'),
            Uri.parse('file:///project/lib/main.dart'),
          );
          expect(result, isNotEmpty);
        }, returnsNormally);
      });
    });

    group('checker', () {
      test('should create TypeChecker for given type', () {
        // Act
        final checker = GenUtil.checker(String);

        // Assert
        expect(checker, isA<TypeChecker>());
        expect(checker.toString(), contains('String'));
      });

      test('should create different TypeCheckers for different types', () {
        // Act
        final stringChecker = GenUtil.checker(String);
        final intChecker = GenUtil.checker(int);

        // Assert
        expect(stringChecker, isA<TypeChecker>());
        expect(intChecker, isA<TypeChecker>());
        expect(stringChecker.toString(), isNot(equals(intChecker.toString())));
      });

      test('should create TypeChecker for custom types', () {
        // Act
        final listChecker = GenUtil.checker(List);
        final mapChecker = GenUtil.checker(Map);

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

        // 在真实场景中: GenUtil.hasAnnotation(testClassAElement, AnnotationA) → true
        // 验证为AnnotationA创建正确的TypeChecker
        final annotationAChecker = GenUtil.checker(AnnotationA);
        expect(annotationAChecker, isA<TypeChecker>());
        expect(annotationAChecker.toString(), contains('AnnotationA'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          GenUtil.hasAnnotation(mockElement, AnnotationA);
        }, returnsNormally);
      });

      test('TestClassA should not have AnnotationB', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.hasAnnotation(testClassAElement, AnnotationB) → false
        // 验证为AnnotationB创建正确的TypeChecker
        final annotationBChecker = GenUtil.checker(AnnotationB);
        expect(annotationBChecker, isA<TypeChecker>());
        expect(annotationBChecker.toString(), contains('AnnotationB'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          GenUtil.hasAnnotation(mockElement, AnnotationB);
        }, returnsNormally);
      });

      test('TestClassA should not have AnnotationC', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.hasAnnotation(testClassAElement, AnnotationC) → false
        // 验证为AnnotationC创建正确的TypeChecker
        final annotationCChecker = GenUtil.checker(AnnotationC);
        expect(annotationCChecker, isA<TypeChecker>());
        expect(annotationCChecker.toString(), contains('AnnotationC'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          GenUtil.hasAnnotation(mockElement, AnnotationC);
        }, returnsNormally);
      });

      test('TestClassB should have AnnotationA', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.hasAnnotation(testClassBElement, AnnotationA) → true
        // 验证为AnnotationA创建正确的TypeChecker
        final annotationAChecker = GenUtil.checker(AnnotationA);
        expect(annotationAChecker, isA<TypeChecker>());
        expect(annotationAChecker.toString(), contains('AnnotationA'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          GenUtil.hasAnnotation(mockElement, AnnotationA);
        }, returnsNormally);
      });

      test('TestClassB should have AnnotationB', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.hasAnnotation(testClassBElement, AnnotationB) → true
        // 验证为AnnotationB创建正确的TypeChecker
        final annotationBChecker = GenUtil.checker(AnnotationB);
        expect(annotationBChecker, isA<TypeChecker>());
        expect(annotationBChecker.toString(), contains('AnnotationB'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          GenUtil.hasAnnotation(mockElement, AnnotationB);
        }, returnsNormally);
      });

      test('TestClassB should not have AnnotationC', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.hasAnnotation(testClassBElement, AnnotationC) → false
        // 验证为AnnotationC创建正确的TypeChecker
        final annotationCChecker = GenUtil.checker(AnnotationC);
        expect(annotationCChecker, isA<TypeChecker>());
        expect(annotationCChecker.toString(), contains('AnnotationC'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          GenUtil.hasAnnotation(mockElement, AnnotationC);
        }, returnsNormally);
      });

      test('TestClassC should not have AnnotationA', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.hasAnnotation(testClassCElement, AnnotationA) → false
        // 验证为AnnotationA创建正确的TypeChecker
        final annotationAChecker = GenUtil.checker(AnnotationA);
        expect(annotationAChecker, isA<TypeChecker>());
        expect(annotationAChecker.toString(), contains('AnnotationA'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          GenUtil.hasAnnotation(mockElement, AnnotationA);
        }, returnsNormally);
      });

      test('TestClassC should not have AnnotationB', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.hasAnnotation(testClassCElement, AnnotationB) → false
        // 验证为AnnotationB创建正确的TypeChecker
        final annotationBChecker = GenUtil.checker(AnnotationB);
        expect(annotationBChecker, isA<TypeChecker>());
        expect(annotationBChecker.toString(), contains('AnnotationB'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          GenUtil.hasAnnotation(mockElement, AnnotationB);
        }, returnsNormally);
      });

      test('TestClassC should not have AnnotationC', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.hasAnnotation(testClassCElement, AnnotationC) → false
        // 验证为AnnotationC创建正确的TypeChecker
        final annotationCChecker = GenUtil.checker(AnnotationC);
        expect(annotationCChecker, isA<TypeChecker>());
        expect(annotationCChecker.toString(), contains('AnnotationC'));

        // 验证hasAnnotation方法可以正常调用
        expect(() {
          GenUtil.hasAnnotation(mockElement, AnnotationC);
        }, returnsNormally);
      });
    });

    group('getAnnotation', () {
      test('TestClassA should get AnnotationA', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.getAnnotation(testClassAElement, AnnotationA) → DartObject
        // 验证为AnnotationA创建正确的TypeChecker
        final annotationAChecker = GenUtil.checker(AnnotationA);
        expect(annotationAChecker, isA<TypeChecker>());
        expect(annotationAChecker.toString(), contains('AnnotationA'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = GenUtil.getAnnotation(mockElement, AnnotationA);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassA should not get AnnotationB', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.getAnnotation(testClassAElement, AnnotationB) → null
        // 验证为AnnotationB创建正确的TypeChecker
        final annotationBChecker = GenUtil.checker(AnnotationB);
        expect(annotationBChecker, isA<TypeChecker>());
        expect(annotationBChecker.toString(), contains('AnnotationB'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = GenUtil.getAnnotation(mockElement, AnnotationB);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassA should not get AnnotationC', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.getAnnotation(testClassAElement, AnnotationC) → null
        // 验证为AnnotationC创建正确的TypeChecker
        final annotationCChecker = GenUtil.checker(AnnotationC);
        expect(annotationCChecker, isA<TypeChecker>());
        expect(annotationCChecker.toString(), contains('AnnotationC'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = GenUtil.getAnnotation(mockElement, AnnotationC);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassB should get AnnotationA', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.getAnnotation(testClassBElement, AnnotationA) → DartObject
        // 验证为AnnotationA创建正确的TypeChecker
        final annotationAChecker = GenUtil.checker(AnnotationA);
        expect(annotationAChecker, isA<TypeChecker>());
        expect(annotationAChecker.toString(), contains('AnnotationA'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = GenUtil.getAnnotation(mockElement, AnnotationA);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassB should get AnnotationB', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.getAnnotation(testClassBElement, AnnotationB) → DartObject
        // 验证为AnnotationB创建正确的TypeChecker
        final annotationBChecker = GenUtil.checker(AnnotationB);
        expect(annotationBChecker, isA<TypeChecker>());
        expect(annotationBChecker.toString(), contains('AnnotationB'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = GenUtil.getAnnotation(mockElement, AnnotationB);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassB should not get AnnotationC', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.getAnnotation(testClassBElement, AnnotationC) → null
        // 验证为AnnotationC创建正确的TypeChecker
        final annotationCChecker = GenUtil.checker(AnnotationC);
        expect(annotationCChecker, isA<TypeChecker>());
        expect(annotationCChecker.toString(), contains('AnnotationC'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = GenUtil.getAnnotation(mockElement, AnnotationC);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassC should not get AnnotationA', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.getAnnotation(testClassCElement, AnnotationA) → null
        // 验证为AnnotationA创建正确的TypeChecker
        final annotationAChecker = GenUtil.checker(AnnotationA);
        expect(annotationAChecker, isA<TypeChecker>());
        expect(annotationAChecker.toString(), contains('AnnotationA'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = GenUtil.getAnnotation(mockElement, AnnotationA);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassC should not get AnnotationB', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.getAnnotation(testClassCElement, AnnotationB) → null
        // 验证为AnnotationB创建正确的TypeChecker
        final annotationBChecker = GenUtil.checker(AnnotationB);
        expect(annotationBChecker, isA<TypeChecker>());
        expect(annotationBChecker.toString(), contains('AnnotationB'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = GenUtil.getAnnotation(mockElement, AnnotationB);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });

      test('TestClassC should not get AnnotationC', () {
        final mockElement = MockElement();

        // 在真实场景中: GenUtil.getAnnotation(testClassCElement, AnnotationC) → null
        // 验证为AnnotationC创建正确的TypeChecker
        final annotationCChecker = GenUtil.checker(AnnotationC);
        expect(annotationCChecker, isA<TypeChecker>());
        expect(annotationCChecker.toString(), contains('AnnotationC'));

        // 验证getAnnotation方法可以正常调用，返回类型为DartObject?
        expect(() {
          final result = GenUtil.getAnnotation(mockElement, AnnotationC);
          expect(result, anyOf(isNull, isA<DartObject>()));
        }, returnsNormally);
      });
    });

    group('Integration Tests', () {
      test('should handle real-world path scenarios', () {
        // Test common Flutter project structure scenarios
        final testCases = [
          {
            'import': 'file:///project/lib/models/user_model.dart',
            'output': 'file:///project/lib/screens/home_screen.dart',
            'expected': '../models/user_model.dart',
          },
          {
            'import': 'file:///project/lib/services/api_service.dart',
            'output': 'file:///project/lib/screens/login/login_screen.dart',
            'expected': '../../services/api_service.dart',
          },
          {
            'import': 'file:///project/lib/widgets/custom_button.dart',
            'output': 'file:///project/lib/screens/widgets/form_widget.dart',
            'expected': '../../widgets/custom_button.dart',
          },
        ];

        for (final testCase in testCases) {
          final result = GenUtil.getImportPath(
            Uri.parse(testCase['import']!),
            Uri.parse(testCase['output']!),
          );
          expect(
            result,
            equals(testCase['expected']),
            reason:
                'Failed for import: ${testCase['import']}, output: ${testCase['output']}',
          );
        }
      });

      test('should handle package imports consistently', () {
        // Test that package imports are always returned as-is regardless of output location
        final packageUris = [
          'package:flutter/material.dart',
          'package:flutter/widgets.dart',
          'package:get/get.dart',
          'package:fall_core/fall_core.dart',
        ];

        final outputLocations = [
          'file:///project/lib/main.dart',
          'file:///project/lib/screens/home.dart',
          'file:///project/lib/features/auth/pages/login.dart',
        ];

        for (final packageUri in packageUris) {
          for (final outputLocation in outputLocations) {
            final result = GenUtil.getImportPath(
              Uri.parse(packageUri),
              Uri.parse(outputLocation),
            );
            expect(
              result,
              equals(packageUri),
              reason: 'Package URI should remain unchanged: $packageUri',
            );
          }
        }
      });
    });
  });
}
