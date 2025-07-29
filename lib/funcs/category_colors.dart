import 'package:flutter/material.dart';

/// Centralized category color utility for consistent category color mapping
/// across all discussion components.
/// 
/// Categories: 정치/사회, 경제/기술, 연예/문화, 생활/정보, 사건/사고, 커뮤/이슈, 스포츠, 게임/e스포츠, 국제, 기타
class CategoryColors {
  // Private constructor to prevent instantiation
  CategoryColors._();

  /// Fixed category color mappings for consistent UI
  static const Map<String, Color> _categoryColorMap = {
    // 정치/사회 - 빨간색 계열
    '정치': Color(0xFFEF4444),
    '사회': Color(0xFFDC2626),
    '정치/사회': Color(0xFFEF4444),
    
    // 경제/기술 - 파란색 계열
    '경제': Color(0xFF3B82F6),
    '기술': Color(0xFF2563EB),
    '경제/기술': Color(0xFF3B82F6),
    'IT': Color(0xFF2563EB),
    
    // 연예/문화 - 핑크/보라 계열
    '연예': Color(0xFFEC4899),
    '문화': Color(0xFF8B5CF6),
    '연예/문화': Color(0xFFEC4899),
    '엔터테인먼트': Color(0xFFEC4899),
    
    // 생활/정보 - 초록색 계열
    '생활': Color(0xFF10B981),
    '정보': Color(0xFF059669),
    '생활/정보': Color(0xFF10B981),
    '일상': Color(0xFF10B981),
    
    // 사건/사고 - 주황색 계열
    '사건': Color(0xFFF59E0B),
    '사고': Color(0xFFEA580C),
    '사건/사고': Color(0xFFF59E0B),
    '뉴스': Color(0xFFF59E0B),
    
    // 커뮤니티/이슈 - 보라색 계열
    '커뮤니티': Color(0xFF6366F1),
    '이슈': Color(0xFF4F46E5),
    '커뮤/이슈': Color(0xFF6366F1),
    '커뮤': Color(0xFF6366F1),
    
    // 스포츠 - 청록색 계열
    '스포츠': Color(0xFF14B8A6),
    '운동': Color(0xFF0D9488),
    '축구': Color(0xFF14B8A6),
    '야구': Color(0xFF0D9488),
    
    // 게임/e스포츠 - 자주색 계열
    '게임': Color(0xFF9333EA),
    'e스포츠': Color(0xFF7C3AED),
    '게임/e스포츠': Color(0xFF9333EA),
    'e-스포츠': Color(0xFF7C3AED),
    '이스포츠': Color(0xFF7C3AED),
    
    // 국제 - 남색 계열
    '국제': Color(0xFF0EA5E9),
    '해외': Color(0xFF0284C7),
    '국제/해외': Color(0xFF0EA5E9),
    '외교': Color(0xFF0EA5E9),
    
    // 기타 - 회색 계열
    '기타': Color(0xFF6B7280),
    '전체': Color(0xFF6B7280),
    'default': Color(0xFF6B7280),
  };

  /// Get color for a specific category.
  /// Returns default gray color if category is not found.
  /// 
  /// [category] - The category name to get color for
  /// [fallbackColor] - Optional fallback color instead of default gray
  static Color getCategoryColor(
    String category, {
    Color? fallbackColor,
  }) {
    if (category.isEmpty) {
      return fallbackColor ?? _categoryColorMap['기타']!;
    }

    // Direct lookup first
    Color? color = _categoryColorMap[category];
    if (color != null) {
      return color;
    }

    // Fuzzy matching for partial category names
    final lowercaseCategory = category.toLowerCase();
    for (final entry in _categoryColorMap.entries) {
      if (entry.key.toLowerCase().contains(lowercaseCategory) ||
          lowercaseCategory.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    return fallbackColor ?? _categoryColorMap['기타']!;
  }

  /// Get all available category colors as a map
  static Map<String, Color> get allCategoryColors => Map.unmodifiable(_categoryColorMap);

  /// Get list of primary category names
  static List<String> get primaryCategories => [
        '정치/사회',
        '경제/기술', 
        '연예/문화',
        '생활/정보',
        '사건/사고',
        '커뮤/이슈',
        '스포츠',
        '게임/e스포츠',
        '국제',
        '기타',
      ];

  /// Get color with opacity
  static Color getCategoryColorWithOpacity(
    String category,
    double opacity, {
    Color? fallbackColor,
  }) {
    return getCategoryColor(category, fallbackColor: fallbackColor)
        .withOpacity(opacity);
  }

  /// Check if a category has a defined color
  static bool hasCategoryColor(String category) {
    return _categoryColorMap.containsKey(category) ||
        _categoryColorMap.keys.any((key) => 
          key.toLowerCase().contains(category.toLowerCase()) ||
          category.toLowerCase().contains(key.toLowerCase()));
  }

  /// Get contrasting text color for a category background
  static Color getContrastingTextColor(String category) {
    final bgColor = getCategoryColor(category);
    final luminance = bgColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}