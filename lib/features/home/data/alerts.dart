import 'package:flutter/material.dart';

class Alert {
  const Alert(
    this.title,
    this.body,
    this.when,
    this.icon, {
    this.urgent = false,
  });

  final String title;
  final String body;
  final String when;
  final IconData icon;
  final bool urgent;
}

const alerts = [
  Alert(
    'Renewal window is open',
    'Your licence expires in 42 days. Renew now to avoid a gap in practice.',
    'Today',
    Icons.verified_rounded,
    urgent: true,
  ),
  Alert(
    'New course matches your specialty',
    'Cardiac MRI: Reading the Essentials · 6 CME credits',
    'Yesterday',
    Icons.school_rounded,
  ),
  Alert(
    'Your paper was cited',
    'Remote monitoring after heart-failure discharge was cited in two new studies.',
    '2 days ago',
    Icons.auto_stories_rounded,
  ),
];
