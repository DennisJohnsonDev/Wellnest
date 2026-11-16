import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';

enum LicenceStatus { active, renewalDue, renewed }

class Licence {
  const Licence({
    required this.number,
    required this.authority,
    required this.authorityShort,
    required this.category,
    required this.specialty,
    required this.firstIssued,
    required this.validFrom,
    required this.expiresOn,
    required this.status,
    this.reference,
  });

  final String number;
  final String authority;
  final String authorityShort;
  final String category;
  final String specialty;
  final DateTime firstIssued;
  final DateTime validFrom;
  final DateTime expiresOn;
  final LicenceStatus status;
  final String? reference;

  int get daysRemaining => expiresOn.difference(Formatters.today).inDays;

  int get cycleDays => expiresOn.difference(validFrom).inDays;

  double get remaining => (daysRemaining / cycleDays).clamp(0.0, 1.0);

  bool get isRenewed => status == LicenceStatus.renewed;

  String get statusLabel => switch (status) {
    LicenceStatus.active => 'Active',
    LicenceStatus.renewalDue => 'Renewal window open',
    LicenceStatus.renewed => 'Renewed · Active',
  };

  Licence copyWith({
    DateTime? validFrom,
    DateTime? expiresOn,
    LicenceStatus? status,
    String? reference,
  }) => Licence(
    number: number,
    authority: authority,
    authorityShort: authorityShort,
    category: category,
    specialty: specialty,
    firstIssued: firstIssued,
    validFrom: validFrom ?? this.validFrom,
    expiresOn: expiresOn ?? this.expiresOn,
    status: status ?? this.status,
    reference: reference ?? this.reference,
  );
}

class ComplianceItem {
  const ComplianceItem(this.label, this.detail, this.icon);

  final String label;
  final String detail;
  final IconData icon;
}

class RenewalFee {
  const RenewalFee(this.label, this.amount);

  final String label;
  final int amount;
}

class RenewalDocument {
  const RenewalDocument(this.label, this.detail, {this.onFile = true});

  final String label;
  final String detail;
  final bool onFile;
}

const complianceItems = [
  ComplianceItem(
    'Good standing',
    'Verified with the medical council',
    Icons.verified_user_rounded,
  ),
  ComplianceItem(
    'Malpractice cover',
    'Valid until 14 Mar 2027',
    Icons.shield_moon_rounded,
  ),
  ComplianceItem(
    'Basic Life Support',
    'Certified until Aug 2027',
    Icons.monitor_heart_rounded,
  ),
  ComplianceItem('Emirates ID', 'Valid until Sep 2029', Icons.badge_rounded),
];

const renewalDocuments = [
  RenewalDocument('Passport photo', 'Updated Oct 2026 · JPG'),
  RenewalDocument('Malpractice certificate', 'Policy MP-55120 · PDF'),
  RenewalDocument(
    'Good standing letter',
    'Issued by the medical council',
    onFile: false,
  ),
];

const renewalFees = [
  RenewalFee('Licence renewal', 1500),
  RenewalFee('Knowledge & innovation fee', 20),
  RenewalFee('Digital service fee', 30),
];

const requiredCmeCredits = 50.0;

class LicenceController extends Notifier<Licence> {
  @override
  Licence build() {
    final today = Formatters.today;
    final expires = today.add(const Duration(days: 42));
    return Licence(
      number: 'DHA-P-0417238',
      authority: 'Dubai Health Authority',
      authorityShort: 'DHA',
      category: 'Consultant',
      specialty: 'Cardiology',
      firstIssued: DateTime(2015, 3, 8),
      validFrom: DateTime(expires.year - 1, expires.month, expires.day),
      expiresOn: expires,
      status: LicenceStatus.renewalDue,
    );
  }

  void renew() {
    final current = state;
    final next = current.expiresOn;
    state = current.copyWith(
      validFrom: next,
      expiresOn: DateTime(next.year + 1, next.month, next.day),
      status: LicenceStatus.renewed,
      reference: 'RN-${next.year}-58213',
    );
  }
}

final licenceProvider = NotifierProvider<LicenceController, Licence>(
  LicenceController.new,
);
