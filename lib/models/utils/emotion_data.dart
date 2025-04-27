// 감정 데이터 클래스
import 'package:flutter/material.dart';

class EmotionData {
  final String label;
  final IconData icon;
  final Color color;
  final String description;

  EmotionData({
    required this.label,
    required this.icon,
    required this.color,
    required this.description,
  });
}