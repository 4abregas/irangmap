import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:irangmap_app/core/theme/app_theme.dart';

void main() {
  test('app theme uses material 3 and the expected seed palette', () {
    final theme = buildAppTheme();

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, isNot(equals(const Color(0x00000000))));
    expect(theme.scaffoldBackgroundColor, equals(const Color(0xFFF7F2EA)));
  });
}
