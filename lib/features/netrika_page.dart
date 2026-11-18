import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../core/widgets.dart';

class NetrikaPage extends StatefulWidget {
  const NetrikaPage({super.key, required this.state});
  final AppState state;
  @override
  State<NetrikaPage> createState() => _NetrikaPageState();
}

class _NetrikaPageState extends State<NetrikaPage> {
  final patientController = TextEditingController(text: 'Тестовый пациент');
  final List<PlatformFile> files = [];
  @override
  void dispose() {
    patientController.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) setState(() => files.addAll(result.files.where((f) => !files.any((x) => x.path == f.path))));
  }

  void _prepare() {
    if (patientController.text.trim().isEmpty || files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Укажите пациента и добавьте хотя бы один документ.')));
      return;
    }
    widget.state.addNetrikaTask(patientController.text.trim(), files.map((f) => f.name).toList());
    setState(() => files.clear());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Демонстрационное задание добавлено в историю документов. В Нетрику ничего не отправлено.')));
  }

  @override
  Widget build(BuildContext context) => PageBody(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const PageHeader(title: 'Нетрика', subtitle: 'Подготовка документов для подписания пациентом'),
    SectionCard(title: 'Новое задание', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Получатель', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      TextField(controller: patientController, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline), labelText: 'Имя или идентификатор пациента')),
      const SizedBox(height: 18),
      Row(children: [
        const Expanded(child: Text('Документы к отправке', style: TextStyle(fontWeight: FontWeight.w700))),
        OutlinedButton.icon(onPressed: _pick, icon: const Icon(Icons.add), label: const Text('Добавить файлы')),
      ]),
      const SizedBox(height: 8),
      if (files.isEmpty) const EmptyState(title: 'Документы не выбраны', subtitle: 'Добавьте документы, которые нужно подготовить для пациента')
      else ...files.map((f) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.description_outlined),
        title: Text(f.name),
        trailing: IconButton(onPressed: () => setState(() => files.remove(f)), icon: const Icon(Icons.close)),
      )),
      const SizedBox(height: 14),
      const Text('На этом этапе создаётся только локальная демонстрационная запись. Реального обмена с Нетрикой нет.', style: TextStyle(fontSize: 12, color: Color(0xFF9A6700))),
      const SizedBox(height: 16),
      Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: _prepare, icon: const Icon(Icons.outgoing_mail), label: const Text('Подготовить задание'))),
    ])),
    const SizedBox(height: 18),
    const SectionCard(title: 'Этапы интеграции', child: Column(children: [
      _NetrikaStep('1', 'Подготовка документа', 'Выбор файлов и метаданных'),
      _NetrikaStep('2', 'Передача в сервис', 'Будет реализована после подключения API'),
      _NetrikaStep('3', 'Подписание пациентом', 'Получение статуса от сервиса'),
      _NetrikaStep('4', 'Получение результата', 'Сохранение результата и аудит'),
    ])),
  ]));
}

class _NetrikaStep extends StatelessWidget {
  const _NetrikaStep(this.number, this.title, this.subtitle);
  final String number, title, subtitle;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(radius: 17, child: Text(number)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
    trailing: const StatusChip('Не подключено'),
  );
}
