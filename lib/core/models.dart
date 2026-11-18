enum CertificateStatus { missing, pending, active, expiring, expired }

extension CertificateStatusLabel on CertificateStatus {
  String get label => switch (this) {
    CertificateStatus.missing => 'Не назначена',
    CertificateStatus.pending => 'Ожидает регистрации',
    CertificateStatus.active => 'Действует',
    CertificateStatus.expiring => 'Истекает скоро',
    CertificateStatus.expired => 'Истекла',
  };
}

class AppUser {
  AppUser({
    required this.id,
    required this.fullName,
    required this.login,
    required this.department,
    required this.role,
    this.canSignArbitrary = false,
    this.isActive = true,
    this.certificateStatus = CertificateStatus.missing,
    this.containerName,
    this.thumbprint,
    this.certificateExpiry,
    this.isRegistered = false,
  });

  final String id;
  final String fullName;
  final String login;
  final String department;
  final String role;
  bool canSignArbitrary;
  bool isActive;
  CertificateStatus certificateStatus;
  String? containerName;
  String? thumbprint;
  DateTime? certificateExpiry;
  bool isRegistered;
}

class SignedDocument {
  SignedDocument({
    required this.id,
    required this.fileName,
    required this.ownerName,
    required this.createdAt,
    required this.signatureType,
    required this.status,
    this.patientName,
  });

  final String id;
  final String fileName;
  final String ownerName;
  final DateTime createdAt;
  final String signatureType;
  final String status;
  final String? patientName;
}

class AuditEntry {
  AuditEntry(this.time, this.actor, this.action, this.details, this.status);
  final DateTime time;
  final String actor;
  final String action;
  final String details;
  final String status;
}
