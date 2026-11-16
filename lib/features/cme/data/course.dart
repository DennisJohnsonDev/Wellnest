import 'package:flutter/material.dart';

enum CmeCategory {
  cardiology('Cardiology', Icons.monitor_heart_outlined),
  emergency('Emergency', Icons.emergency_outlined),
  endocrinology('Endocrinology', Icons.bloodtype_outlined),
  infectious('Infectious disease', Icons.coronavirus_outlined),
  ethics('Ethics & law', Icons.balance_outlined),
  genomics('Genomics', Icons.biotech_outlined);

  const CmeCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum ModuleKind {
  video('Video', Icons.play_circle_outline_rounded),
  reading('Reading', Icons.article_outlined),
  caseStudy('Case study', Icons.cases_outlined),
  assessment('Assessment', Icons.fact_check_outlined);

  const ModuleKind(this.label, this.icon);

  final String label;
  final IconData icon;
}

class CourseModule {
  const CourseModule(this.title, this.minutes, this.kind);

  final String title;
  final int minutes;
  final ModuleKind kind;
}

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.provider,
    required this.category,
    required this.credits,
    required this.level,
    required this.rating,
    required this.learners,
    required this.summary,
    required this.outcomes,
    required this.modules,
    this.mandatory = false,
    this.featured = false,
  });

  final String id;
  final String title;
  final String provider;
  final CmeCategory category;
  final double credits;
  final String level;
  final double rating;
  final String learners;
  final String summary;
  final List<String> outcomes;
  final List<CourseModule> modules;
  final bool mandatory;
  final bool featured;

  int get minutes => modules.fold(0, (sum, m) => sum + m.minutes);

  int get seed => id.codeUnits.fold(7, (h, c) => (h * 31 + c) & 0x7fffffff);
}
