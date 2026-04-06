import 'package:flutter/material.dart';

// Definition of objects used to hold each app page destination in main.dart
class AppDestination {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const AppDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}