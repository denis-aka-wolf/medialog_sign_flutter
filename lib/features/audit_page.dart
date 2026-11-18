import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../core/widgets.dart';

class AuditPage extends StatelessWidget {
  const AuditPage({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) => PageBody(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const PageHeader(title: 'Журнал операций', subtitle: 'Демонстрационная история действий пользователей'),
    SectionCard(title: 'События (${state.audit.length})', child: state.audit.isEmpty
      ? const EmptyState(title: 'Журнал пуст', subtitle: 'Операции появятся здесь')
      : SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: const [
        DataColumn(label: Text('Время')),
        DataColumn(label: Text('Пользователь')),
        DataColumn(label: Text('Операция')),
        DataColumn(label: Text('Подробности')),
        DataColumn(label: Text('Результат')),
      ], rows: state.audit.map((e) => DataRow(cells: [
        DataCell(Text('${e.time.day.toString().padLeft(2, '0')}.${e.time.month.toString().padLeft(2, '0')} ${e.time.hour.toString().padLeft(2, '0')}:${e.time.minute.toString().padLeft(2, '0')}')),
        DataCell(Text(e.actor)),
        DataCell(Text(e.action)),
        DataCell(SizedBox(width: 260, child: Text(e.details, maxLines: 2, overflow: TextOverflow.ellipsis))),
        DataCell(StatusChip(e.status, kind: e.status.contains('Успешно') ? StatusKind.success : StatusKind.info)),
      ])).toList()))),
  ]));
}
