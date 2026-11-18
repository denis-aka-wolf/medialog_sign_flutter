import 'models.dart';

List<AppUser> createMockUsers() => [
  AppUser(id: '1001', fullName: 'Иванов Иван Иванович', login: 'i.ivanov', department: 'Терапевтическое отделение', role: 'Врач', canSignArbitrary: true, certificateStatus: CertificateStatus.active, containerName: 'IvanovContainer', thumbprint: 'A8F3 71C2 90BD 4E11 7A62', certificateExpiry: DateTime.now().add(const Duration(days: 310)), isRegistered: true),
  AppUser(id: '1002', fullName: 'Петров Пётр Сергеевич', login: 'p.petrov', department: 'Хирургическое отделение', role: 'Врач', certificateStatus: CertificateStatus.missing),
  AppUser(id: '1003', fullName: 'Сидорова Анна Викторовна', login: 'a.sidorova', department: 'Регистратура', role: 'Медицинский регистратор', canSignArbitrary: true, certificateStatus: CertificateStatus.expiring, containerName: 'SidorovaContainer', thumbprint: '5D19 0A7E 3F42 C8B1 6E90', certificateExpiry: DateTime.now().add(const Duration(days: 20)), isRegistered: true),
  AppUser(id: '1004', fullName: 'Смирнов Алексей Олегович', login: 'a.smirnov', department: 'Диагностическое отделение', role: 'Врач', certificateStatus: CertificateStatus.pending, containerName: 'SmirnovContainer', thumbprint: 'C2B7 11F9 40D3 8A62 19EF', certificateExpiry: DateTime.now().add(const Duration(days: 250))),
  AppUser(id: '1005', fullName: 'Кузнецова Мария Андреевна', login: 'm.kuznetsova', department: 'Администрация', role: 'Администратор', canSignArbitrary: true, certificateStatus: CertificateStatus.active, containerName: 'AdminContainer', thumbprint: 'D490 6F13 B2A8 0C57 11DE', certificateExpiry: DateTime.now().add(const Duration(days: 700)), isRegistered: true),
  AppUser(id: '1006', fullName: 'Волков Дмитрий Ильич', login: 'd.volkov', department: 'Лаборатория', role: 'Лаборант', certificateStatus: CertificateStatus.missing),
];

List<SignedDocument> createMockDocuments() => [
  SignedDocument(id: 'DOC-0001', fileName: 'Выписной_эпикриз.pdf', ownerName: 'Иванов Иван Иванович', createdAt: DateTime.now().subtract(const Duration(hours: 2)), signatureType: 'Откреплённая (.sig)', status: 'Подписан (демо)'),
  SignedDocument(id: 'DOC-0002', fileName: 'Направление_на_исследование.pdf', ownerName: 'Сидорова Анна Викторовна', createdAt: DateTime.now().subtract(const Duration(days: 1)), signatureType: 'Присоединённая', status: 'Подписан (демо)'),
  SignedDocument(id: 'DOC-0003', fileName: 'Согласие_пациента.pdf', ownerName: 'Иванов Иван Иванович', createdAt: DateTime.now().subtract(const Duration(days: 2)), signatureType: 'Для Нетрики', status: 'Ожидает пациента'),
];
