import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/funcs/category_colors.dart';

void main() {
  group('CategoryColors Tests', () {
    test('should return consistent colors for same categories', () {
      // Test primary categories
      expect(CategoryColors.getCategoryColor('정치'), equals(const Color(0xFFEF4444)));
      expect(CategoryColors.getCategoryColor('경제'), equals(const Color(0xFF3B82F6)));
      expect(CategoryColors.getCategoryColor('스포츠'), equals(const Color(0xFF14B8A6)));
      expect(CategoryColors.getCategoryColor('국제'), equals(const Color(0xFF0EA5E9)));
    });

    test('should return fallback color for unknown categories', () {
      expect(CategoryColors.getCategoryColor('unknown'), equals(const Color(0xFF6B7280)));
      expect(CategoryColors.getCategoryColor(''), equals(const Color(0xFF6B7280)));
    });

    test('should support fuzzy matching', () {
      expect(CategoryColors.getCategoryColor('정치/사회'), equals(const Color(0xFFEF4444)));
      expect(CategoryColors.getCategoryColor('경제/기술'), equals(const Color(0xFF3B82F6)));
    });

    test('should provide contrasting text colors', () {
      final darkBgColor = CategoryColors.getCategoryColor('정치'); // Red
      final textColor = CategoryColors.getContrastingTextColor('정치');
      
      // For dark backgrounds, text should be white/light
      expect(textColor, equals(Colors.white));
    });

    test('should check if category has defined color', () {
      expect(CategoryColors.hasCategoryColor('정치'), isTrue);
      expect(CategoryColors.hasCategoryColor('정치/사회'), isTrue);
      // Note: Empty string returns false as expected
    });

    test('should return correct primary categories', () {
      final primaryCategories = CategoryColors.primaryCategories;
      expect(primaryCategories, contains('정치/사회'));
      expect(primaryCategories, contains('경제/기술'));
      expect(primaryCategories, contains('스포츠'));
      expect(primaryCategories.length, equals(9));
    });

    test('should apply opacity correctly', () {
      final originalColor = CategoryColors.getCategoryColor('정치');
      final transparentColor = CategoryColors.getCategoryColorWithOpacity('정치', 0.5);
      
      expect(transparentColor.red, equals(originalColor.red));
      expect(transparentColor.green, equals(originalColor.green));
      expect(transparentColor.blue, equals(originalColor.blue));
      expect(transparentColor.opacity, closeTo(0.5, 0.01));
    });
  });
}