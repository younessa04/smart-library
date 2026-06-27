import 'package:flutter/material.dart';

class CategoryEntity {
  final String id;
  final String name;
  final String icon;
  final int bookCount;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    this.bookCount = 0,
  });

  IconData get iconData {
    switch (icon) {
      case 'computer': return Icons.computer;
      case 'psychology': return Icons.psychology;
      case 'analytics': return Icons.analytics;
      case 'calculate': return Icons.calculate;
      case 'science': return Icons.science;
      case 'experiment': return Icons.biotech;
      case 'trending_up': return Icons.trending_up;
      case 'business_center': return Icons.business_center;
      case 'lan': return Icons.lan;
      case 'security': return Icons.security;
      default: return Icons.book;
    }
  }
}
