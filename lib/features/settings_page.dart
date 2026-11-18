import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../core/widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) => PageBody(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const PageHeader(title: 'Настройки', subtitle: 'Состояние интеграций и параметры прототипа'),
    SectionCard(title: 'Интеграции', child: Column(children: const [
      _Integration('Медиалог', 'Точка запуска и контекст пользователя', 'Не подключено'),
      _Integration('Microsoft SQL Server', 'Пользователи, права, документы и журнал', 'Не подключено'),
      _Integration('КриптоПро CSP', 'Проверка контейнеров и криптографические операции', 'Не подключено'),
      _Integration('Нетрика', 'Передача документов на подпись пациенту', 'Не подключено'),
    ])),
    const SizedBox(height: 18),
    SectionCard(title: 'Данные прототипа', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Все изменения хранятся только в памяти и будут сброшены при перезапуске приложения.', style: TextStyle(color: Color(0xFF667085))),
      const SizedBox(height: 14),
      FilledButton.tonalIcon(onPressed: () {
        state.reset();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Демонстрационные данные сброшены.')));
      }, icon: const Icon(Icons.restart_alt), label: const Text('Сбросить демонстрационные данные')),
    ])),
    const SizedBox(height: 18),
    const SectionCard(title: 'Безопасность', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SecurityLine('Закрытые ключи', 'Не используются'),
      _SecurityLine('PIN-коды', 'Не запрашиваются и не сохраняются'),
      _SecurityLine('Настоящие подписи', 'Не создаются'),
      _SecurityLine('Реальные подключения', 'Отсутствуют'),
    ])),
  ]));
}

class _Integration extends StatelessWidget {
  const _Integration(this.title, this.description, this.status);
  final String title, description, status;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const CircleAvatar(child: Icon(Icons.link_off_outlined)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(description),
    trailing: StatusChip(status),
  );
}

class _SecurityLine extends StatelessWidget {
  const _SecurityLine(this.title, this.value);
  final String title, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [
      const Icon(Icons.check_circle_outline, color: Color(0xFF18794E), size: 19),
      const SizedBox(width: 10),
      Expanded(child: Text(title)),
      Text(value, style: const TextStyle(color: Color(0xFF667085), fontSize: 12)),
    ]),
  );
}
