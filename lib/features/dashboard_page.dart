import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../core/models.dart';
import '../core/widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.state, required this.onNavigate});
  final AppState state;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final activeCerts = state.users.where((u) => u.certificateStatus == CertificateStatus.active || u.certificateStatus == CertificateStatus.expiring).length;
    final pending = state.users.where((u) => u.certificateStatus == CertificateStatus.pending).length;
    return PageBody(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const PageHeader(title: 'Панель управления', subtitle: 'Состояние демонстрационного рабочего места'),
      Wrap(spacing: 16, runSpacing: 16, children: [
        _MetricCard(title: 'Пользователи', value: '${state.users.length}', note: 'В тестовом справочнике', icon: Icons.people_outline),
        _MetricCard(title: 'Сертификаты', value: '$activeCerts', note: 'Действуют или скоро истекут', icon: Icons.verified_user_outlined),
        _MetricCard(title: 'Ожидают регистрации', value: '$pending', note: 'Требуют проверки', icon: Icons.pending_actions_outlined),
        _MetricCard(title: 'Документы', value: '${state.documents.length}', note: 'В истории прототипа', icon: Icons.description_outlined),
      ]),
      const SizedBox(height: 22),
      LayoutBuilder(builder: (context, constraints) => Wrap(
        spacing: 18, runSpacing: 18,
        children: [
          SizedBox(width: constraints.maxWidth > 1000 ? (constraints.maxWidth - 18) / 2 : constraints.maxWidth,
            child: SectionCard(title: 'Состояние интеграций', child: Column(children: const [
              _IntegrationRow('Медиалог', 'Не подключён'),
              _IntegrationRow('MS SQL Server', 'Демонстрационные данные'),
              _IntegrationRow('КриптоПро CSP', 'Не подключён'),
              _IntegrationRow('Нетрика', 'Демонстрационный режим'),
            ]))),
          SizedBox(width: constraints.maxWidth > 1000 ? (constraints.maxWidth - 18) / 2 : constraints.maxWidth,
            child: SectionCard(title: 'Быстрые действия', child: Column(children: [
              _QuickAction('Управление пользователями', 'Права доступа и выбор сотрудника', Icons.people_outline, () => onNavigate(1)),
              _QuickAction('Добавить тестовую ЭЦП', 'Назначение сертификата сотруднику', Icons.add_moderator_outlined, () => onNavigate(2)),
              _QuickAction('Подписать документы', 'Демонстрационный сценарий', Icons.draw_outlined, () => onNavigate(3)),
              _QuickAction('Подготовить для пациента', 'Задание для Нетрики', Icons.outgoing_mail, () => onNavigate(5)),
            ]))),
        ],
      )),
      const SizedBox(height: 22),
      SectionCard(title: 'Последние операции', trailing: TextButton(onPressed: () => onNavigate(6), child: const Text('Весь журнал')),
        child: state.audit.isEmpty ? const EmptyState(title: 'Операций пока нет', subtitle: 'Действия появятся здесь') :
        Column(children: state.audit.take(5).map((entry) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(radius: 17, child: Icon(Icons.history, size: 18)),
          title: Text(entry.action, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          subtitle: Text('${entry.actor} • ${entry.details}', maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: StatusChip(entry.status, kind: StatusKind.info),
        )).toList())),
    ]));
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.note, required this.icon});
  final String title, value, note;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    child: Card(child: Padding(padding: const EdgeInsets.all(19), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: const Color(0xFF176B87)), const Spacer(), const Icon(Icons.more_horiz, color: Color(0xFF98A2B3))]),
      const SizedBox(height: 17),
      Text(value, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w800, color: Color(0xFF172B4D))),
      const SizedBox(height: 3),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text(note, style: const TextStyle(color: Color(0xFF667085), fontSize: 11)),
    ]))),
  );
}

class _IntegrationRow extends StatelessWidget {
  const _IntegrationRow(this.name, this.status);
  final String name, status;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(children: [
      const Icon(Icons.circle, size: 8, color: Color(0xFF98A2B3)),
      const SizedBox(width: 10),
      Expanded(child: Text(name)),
      Text(status, style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
    ]),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(this.title, this.subtitle, this.icon, this.onTap);
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFEAF4F7), borderRadius: BorderRadius.circular(9)), child: Icon(icon, color: const Color(0xFF176B87))),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
