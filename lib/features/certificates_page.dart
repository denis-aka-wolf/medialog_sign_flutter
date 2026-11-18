import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../core/models.dart';
import '../core/widgets.dart';

class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final users = state.users.where((u) => u.certificateStatus != CertificateStatus.missing).toList();
    return PageBody(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const PageHeader(title: 'Управление ЭЦП', subtitle: 'Тестовые сертификаты и состояние регистрации'),
      SectionCard(title: 'Действия с сертификатами', child: Wrap(spacing: 10, runSpacing: 10, children: [
        OutlinedButton.icon(onPressed: () => _showInfo(context, 'Выбор контейнера', 'В рабочей версии здесь откроется выбор каталога контейнера КриптоПро. Сейчас файловая система не изменяется.'), icon: const Icon(Icons.folder_open), label: const Text('Добавить из каталога')),
        OutlinedButton.icon(onPressed: () => _showInfo(context, 'Файл сертификата', 'В рабочей версии можно будет выбрать файл .cer и проверить его содержимое. Сертификат сам по себе не содержит закрытого ключа.'), icon: const Icon(Icons.file_open), label: const Text('Выбрать .cer')),
        OutlinedButton.icon(onPressed: () => _showInfo(context, 'Проверка сертификатов', 'Проверка статусов в текущем прототипе использует только тестовые данные.'), icon: const Icon(Icons.fact_check_outlined), label: const Text('Проверить статусы')),
      ])),
      const SizedBox(height: 18),
      SectionCard(title: 'Сертификаты (${users.length})', child: users.isEmpty ? const EmptyState(title: 'Нет сертификатов', subtitle: 'Назначьте тестовую ЭЦП в карточке пользователя') :
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: const [
          DataColumn(label: Text('Владелец')),
          DataColumn(label: Text('Контейнер')),
          DataColumn(label: Text('Отпечаток')),
          DataColumn(label: Text('Срок действия')),
          DataColumn(label: Text('Статус')),
          DataColumn(label: Text('Регистрация')),
          DataColumn(label: Text('Действие')),
        ], rows: users.map((u) => DataRow(cells: [
          DataCell(Text(u.fullName)),
          DataCell(Text(u.containerName ?? 'Не назначен')),
          DataCell(Text(u.thumbprint ?? 'Нет данных')),
          DataCell(Text(u.certificateExpiry == null ? 'Неизвестно' : '${u.certificateExpiry!.day.toString().padLeft(2, '0')}.${u.certificateExpiry!.month.toString().padLeft(2, '0')}.${u.certificateExpiry!.year}')),
          DataCell(StatusChip(u.certificateStatus.label, kind: certificateKind(u.certificateStatus))),
          DataCell(StatusChip(u.isRegistered ? 'Зарегистрирован' : 'Ожидает', kind: u.isRegistered ? StatusKind.success : StatusKind.warning)),
          DataCell(TextButton(onPressed: () {
            state.registerDemoCertificate(u);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Обновлён тестовый статус. Реальный сертификат не устанавливался.')));
          }, child: const Text('Зарегистрировать')),)
    ])).toList()))),
      const SizedBox(height: 16),
      const Text('Отображаемые отпечатки и даты фиктивны. Не используйте этот экран для проверки реальных сертификатов.', style: TextStyle(color: Color(0xFF9A6700), fontSize: 12)),
    ]));
  }

  void _showInfo(BuildContext context, String title, String message) {
    showDialog<void>(context: context, builder: (context) => AlertDialog(
      title: Text(title), content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть'))],
    ));
  }
}
