// models/unSynced_data.dart
import 'package:flutter/material.dart';

class UnSyncedData {
  final String title;
  final String lastRecorded;
  final int count;
  final IconData icon;

  UnSyncedData({
    required this.title,
    required this.lastRecorded,
    required this.count,
    required this.icon,
  });
}
