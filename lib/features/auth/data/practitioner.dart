import 'package:flutter_riverpod/flutter_riverpod.dart';

class Practitioner {
  const Practitioner({
    required this.name,
    required this.shortName,
    required this.initials,
    required this.role,
    required this.facility,
    required this.emirate,
    required this.yearsLicensed,
    required this.boardCertification,
    required this.emiratesIdExpiry,
  });

  final String name;
  final String shortName;
  final String initials;
  final String role;
  final String facility;
  final String emirate;
  final int yearsLicensed;
  final String boardCertification;
  final String emiratesIdExpiry;
}

const demoPractitioner = Practitioner(
  name: 'Dr. Mariam Al Suwaidi',
  shortName: 'Dr. Mariam',
  initials: 'MS',
  role: 'Consultant Cardiologist',
  facility: 'Al Waha Heart Institute',
  emirate: 'Dubai',
  yearsLicensed: 11,
  boardCertification: 'Arab Board · Cardiology',
  emiratesIdExpiry: 'Sep 2029',
);

final practitionerProvider = Provider<Practitioner>((ref) => demoPractitioner);
