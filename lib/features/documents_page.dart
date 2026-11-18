import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../core/widgets.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key, required this.state});
  final AppState state;
  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  String query = '';
  String filter = 'Все';
  @override
  Widget build(BuildContext context) {
    final docs = widget.state.documents.where((d) =>
      (d.fileName.toLowerCase().contains(query.toLowerCase()) || d.ownerName.toLowerCase().contains(query.toLowerCase()) || d.id.toLowerCase().contains(query.toLowerCase())) &&
      (filter == 'Все' || (filter == 'Нетрика' ? d.signatureType.contains('Нетрики') : !d.signatureType.contains('Нетрики')))).toList();
    return PageBody(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const PageHeader(title: 'Документы', subtitle: 'История демонстрационных операций с файлами'),
      Row(children: [
        Expanded(child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Поиск по имени файла, сотруднику или ID'), onChanged: (v) => setState(() => query = v))),
        const SizedBox(width: 12),
        SizedBox(width: 160, child: DropdownButtonFormField<String>(
          value: filter, decoration: const InputDecoration(labelText: 'Категория'),
          items: const ['Все', 'Подписание', 'Нетрика'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => filter = v!),
        )),
      ]),
      const SizedBox(height: 18),
      SectionCard(title: 'Документы (${docs.length})', child: docs.isEmpty ? const EmptyState(title: 'Документы не найдены', subtitle: 'Измените параметры поиска') :
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Документ')),
          DataColumn(label: Text('Сотрудник')),
          DataColumn(label: Text('Тип операции')),
          DataColumn(label: Text('Дата')),
          DataColumn(label: Text('Статус')),
        ], rows: docs.map((d) => DataRow(cells: [
          DataCell(Text(d.id)),
          DataCell(Text(d.fileName)),
          DataCell(Text(d.ownerName)),
          DataCell(Text(d.signatureType)),
          DataCell(Text('${d.createdAt.day.toString().padLeft(2, '0')}.${d.createdAt.month.toString().padLeft(2, '0')}.${d.createdAt.year} ${d.createdAt.hour.toString().padLeft(2, '0')}:${d.createdAt.minute.toString().padLeft(2, '0')}')),
          DataCell(StatusChip(d.status, kind: d.status.contains('не является') || d.status.contains('Черновик') ? StatusKind.warning : StatusKind.info)),
        ])).toList()))),
    ]));
  }
}
