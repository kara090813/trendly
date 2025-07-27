import 'package:flutter_test/flutter_test.dart';
import '../lib/funcs/category_colors.dart';

void main() {
  group('Category Ordering Tests', () {
    test('should return categories in the correct predefined order', () {
      final expectedOrder = [
        '정치/사회',
        '경제/기술', 
        '연예/문화',
        '생활/정보',
        '사건/사고',
        '커뮤/이슈',
        '스포츠',
        '국제',
        '기타',
      ];
      
      final actualOrder = CategoryColors.primaryCategories;
      
      expect(actualOrder, equals(expectedOrder));
    });
    
    test('should maintain correct ordering when filtering categories', () {
      // Simulate API returning categories in random order
      final apiCategories = ['스포츠', '정치/사회', '기타', '경제/기술', '연예/문화'];
      
      // Apply the same logic used in components
      final orderedCategories = CategoryColors.primaryCategories
          .where((category) => apiCategories.contains(category))
          .toList();
      
      final expectedFiltered = ['정치/사회', '경제/기술', '연예/문화', '스포츠', '기타'];
      
      expect(orderedCategories, equals(expectedFiltered));
    });
  });
}