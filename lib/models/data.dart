// models/unsynced_data.dart
import 'package:flutter/material.dart';

class UnsyncedData {
  final String title;
  final String lastRecorded;
  final int count;
  final IconData icon;

  UnsyncedData({
    required this.title,
    required this.lastRecorded,
    required this.count,
    required this.icon,
  });
}
