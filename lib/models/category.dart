import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final int bookCount;

  Category({
    required this.id,
    required this.name,
    this.icon = 'book',
    this.bookCount = 0,
  });

  IconData get iconData {
    switch (icon) {
      case 'computer': return Icons.computer;
      case 'psychology': return Icons.psychology;
      case 'analytics': return Icons.analytics;
      case 'calculate': return Icons.calculate;
      case 'science': return Icons.science;
      case 'experiment': return Icons.science_outlined;
      case 'trending_up': return Icons.trending_up;
      case 'business_center': return Icons.business_center;
      case 'lan': return Icons.lan;
      case 'security': return Icons.security;
      default: return Icons.book;
    }
  }

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? 'book',
      bookCount: data['bookCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'bookCount': bookCount,
    };
  }
}
