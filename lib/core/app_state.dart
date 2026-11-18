import 'package:flutter/foundation.dart';
import 'mock_data.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  AppState() {
    reset();
  }

  late List<AppUser> users;
  late List<SignedDocument> documents;
  late List<AuditEntry> audit;
  String activeUserId = '1005';
  int _documentCounter = 4;

  AppUser get activeUser => users.firstWhere((u) => u.id == activeUserId, orElse: () => users.first);

  void reset() {
    users = createMockUsers();
    documents = createMockDocuments();
    audit = [
      AuditEntry(DateTime.now().subtract(const Duration(minutes: 12)), 'Кузнецова Мария Андреевна', 'Вход в приложение', 'Открыта административная панель', 'Успешно'),
      AuditEntry(DateTime.now().subtract(const Duration(minutes: 9)), 'Кузнецова Мария Андреевна', 'Проверка сертификата', 'IvanovContainer', 'Демо'),
      AuditEntry(DateTime.now().subtract(const Duration(minutes: 5)), 'Иванов Иван Иванович', 'Подписание документа', 'Выписной_эпикриз.pdf', 'Подписан (демо)'),
    ];
    activeUserId = '1005';
    _documentCounter = 4;
    notifyListeners();
  }

  void setActiveUser(String id) {
    activeUserId = id;
    log('Смена пользователя', 'Активный пользователь: ${activeUser.fullName}', 'Демо');
    notifyListeners();
  }

  void togglePermission(AppUser user, bool value) {
    user.canSignArbitrary = value;
    log('Изменение прав', '${user.fullName}: право подписи ${value ? "включено" : "выключено"}', 'Успешно');
    notifyListeners();
  }

  void assignDemoCertificate(AppUser user) {
    user.containerName ??= '${user.login.replaceAll('.', '_')}_Container';
    user.thumbprint = 'DEMO ${user.id} 7A91 C40F 12BD';
    user.certificateExpiry = DateTime.now().add(const Duration(days: 365));
    user.certificateStatus = CertificateStatus.pending;
    user.isRegistered = false;
    log('Назначение тестовой ЭЦП', 'Для ${user.fullName} назначен тестовый контейнер ${user.containerName}', 'Демо');
    notifyListeners();
  }

  void registerDemoCertificate(AppUser user) {
    if (user.certificateStatus == CertificateStatus.missing) return;
    user.certificateStatus = CertificateStatus.active;
    user.isRegistered = true;
    log('Регистрация сертификата', 'Демонстрационная регистрация для ${user.fullName}', 'Демо');
    notifyListeners();
  }

  void copyDemoCertificate(AppUser source, AppUser target) {
    target.containerName = '${source.login.replaceAll('.', '_')}_Copy_${target.id}';
    target.thumbprint = source.thumbprint ?? 'DEMO ${source.id} 7A91 C40F 12BD';
    target.certificateExpiry = source.certificateExpiry ?? DateTime.now().add(const Duration(days: 365));
    target.certificateStatus = CertificateStatus.pending;
    target.isRegistered = false;
    log('Копирование ЭЦП', 'Демо-копирование от ${source.fullName} к ${target.fullName}', 'Демо');
    notifyListeners();
  }

  void addDemoSigning(List<String> fileNames, String signatureType) {
    for (final fileName in fileNames) {
      documents.insert(0, SignedDocument(
        id: 'DOC-${(_documentCounter++).toString().padLeft(4, '0')}',
        fileName: fileName,
        ownerName: activeUser.fullName,
        createdAt: DateTime.now(),
        signatureType: signatureType,
        status: 'Демонстрация: не является криптографической подписью',
      ));
      log('Демонстрационное подписание', '$fileName; тип: $signatureType', 'Тестовый результат');
    }
    notifyListeners();
  }

  void addNetrikaTask(String patient, List<String> fileNames) {
    for (final fileName in fileNames) {
      documents.insert(0, SignedDocument(
        id: 'DOC-${(_documentCounter++).toString().padLeft(4, '0')}',
        fileName: fileName,
        ownerName: activeUser.fullName,
        createdAt: DateTime.now(),
        signatureType: 'Подготовка для Нетрики',
        status: 'Черновик отправления (демо)',
        patientName: patient,
      ));
    }
    log('Подготовка задания Нетрики', 'Пациент: $patient; документов: ${fileNames.length}', 'Демо');
    notifyListeners();
  }

  void log(String action, String details, String status) {
    audit.insert(0, AuditEntry(DateTime.now(), activeUser.fullName, action, details, status));
  }
}
