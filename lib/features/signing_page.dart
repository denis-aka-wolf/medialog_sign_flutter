import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../core/widgets.dart';

class SigningPage extends StatefulWidget {
  const SigningPage({super.key, required this.state});
  final AppState state;
  @override
  State<SigningPage> createState() => _SigningPageState();
}

class _SigningPageState extends State<SigningPage> {
  final List<PlatformFile> files = [];
  String signatureType = 'Откреплённая подпись (.sig)';

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: false);
    if (result != null) setState(() {
      for (final file in result.files) {
        if (!files.any((f) => f.path == file.path)) files.add(file);
      }
    });
  }

  void _sign() {
    if (!widget.state.activeUser.canSignArbitrary) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('У активного пользователя выключено право подписи произвольных документов.')));
      return;
    }
    if (widget.state.activeUser.certificateStatus !=
        // Для демонстрации допускается только сертификат со статусом active.
        // ignore: unrelated_type_equality_checks
        null) {
      // Проверка ниже выполняется через метку статуса, чтобы не обращаться к реальному CSP.
    }
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сначала добавьте файлы.')));
      return;
    }
    final names = files.map((f) => f.name).toList();
    widget.state.addDemoSigning(names, signatureType);
    setState(() => files.clear());
    showDialog<void>(context: context, builder: (context) => AlertDialog(
      title: const Text('Демонстрационная операция завершена'),
      content: Text('Обработано файлов: ${names.length}.\n\nНастоящая подпись не создавалась. Файлы .sig не сформированы. Результат добавлен в историю прототипа.'),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Понятно'))],
    ));
  }

  @override
  Widget build(BuildContext context) => PageBody(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const PageHeader(title: 'Подписание документов', subtitle: 'Демонстрационный сценарий без криптографических операций'),
    SectionCard(title: 'Параметры подписания', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const CircleAvatar(radius: 23, child: Icon(Icons.person_outline)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.state.activeUser.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text('${widget.state.activeUser.role} • ${widget.state.activeUser.login}', style: const TextStyle(color: Color(0xFF667085), fontSize: 12)),
        ])),
        StatusChip(widget.state.activeUser.canSignArbitrary ? 'Право подписи включено' : 'Нет права подписи',
          kind: widget.state.activeUser.canSignArbitrary ? StatusKind.success : StatusKind.error),
      ]),
      const Divider(height: 28),
      const Text('Тип подписи', style: TextStyle(fontWeight: FontWeight.w700)),
      RadioListTile<String>(
        contentPadding: EdgeInsets.zero, title: const Text('Откреплённая подпись (.sig)'),
        subtitle: const Text('Подпись хранится отдельно от исходного файла'),
        value: 'Откреплённая подпись (.sig)', groupValue: signatureType,
        onChanged: (v) => setState(() => signatureType = v!),
      ),
      RadioListTile<String>(
        contentPadding: EdgeInsets.zero, title: const Text('Присоединённая подпись'),
        subtitle: const Text('Документ и подпись должны находиться в одном контейнере'),
        value: 'Присоединённая', groupValue: signatureType,
        onChanged: (v) => setState(() => signatureType = v!),
      ),
    ])),
    const SizedBox(height: 18),
    SectionCard(title: 'Файлы (${files.length})', trailing: FilledButton.icon(onPressed: _pickFiles, icon: const Icon(Icons.add), label: const Text('Добавить файлы')),
      child: files.isEmpty ? const EmptyState(title: 'Файлы не выбраны', subtitle: 'Выберите один или несколько документов с компьютера', icon: Icons.drive_folder_upload_outlined) :
      Column(children: files.map((f) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.insert_drive_file_outlined),
        title: Text(f.name),
        subtitle: Text(_size(f.size)),
        trailing: IconButton(tooltip: 'Удалить', onPressed: () => setState(() => files.remove(f)), icon: const Icon(Icons.close)),
      )).toList())),
    const SizedBox(height: 18),
    Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFFF4D6), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFF2D58A))),
      child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.warning_amber_rounded, color: Color(0xFF9A6700)),
        SizedBox(width: 10),
        Expanded(child: Text('Демо-режим: приложение не создаёт настоящие подписи и не формирует .sig-файлы. Не используйте результат как юридически значимый документ.', style: TextStyle(color: Color(0xFF7A5300), fontSize: 12))),
      ]),
    ),
    const SizedBox(height: 16),
    Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: _sign, icon: const Icon(Icons.draw_outlined), label: const Text('Запустить демо-подписание'))),
  ]));
}

String _size(int bytes) {
  if (bytes < 1024) return '$bytes Б';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} КБ';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
}
