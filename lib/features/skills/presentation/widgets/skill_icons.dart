import 'package:flutter/material.dart';

class SkillIcons {
  static IconData forCategory(String id) {
    switch (id) {
      case 'tech':
        return Icons.code_rounded;
      case 'design':
        return Icons.brush_rounded;
      case 'languages':
        return Icons.translate_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'business':
        return Icons.work_outline_rounded;
      case 'science':
        return Icons.science_outlined;
      case 'lifestyle':
        return Icons.spa_outlined;
      default:
        return Icons.auto_awesome_rounded;
    }
  }
}