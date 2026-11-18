import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../core/models.dart';
import '../core/widgets.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key, required this.state});
  final AppState state;
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String query = '';
  AppUser? selected;

  @override
  Widget build(BuildContext context) {
    final users = widget.state.users.where((u) =>
      u.fullName.toLowerCase().contains(query.toLowerCase()) ||
      u.login.toLowerCase().contains(query.toLowerCase()) ||
      u.department.toLowerCase().contains(query.toLowerCase())).toList();
    selected ??= users.isNotEmpty ? users.first : null;
    if (selected != null && !widget.state.users.any((u) => u.id == selected!.id)) selected = null;

    return PageBody(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(title: 'Пользователи', subtitle: 'Демонстрационный справочник сотрудников',
        trailing: OutlinedButton.icon(onPressed: () => _showResetDialog(context), icon: const Icon(Icons.restart_alt), label: const Text('Сбросить данные'))),
      TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Поиск по ФИО, логину или отделению'),
        onChanged: (v) => setState(() { query = v; selected = null; })),
      const SizedBox(height: 16),
      LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth > 1000;
        return Flex(direction: wide ? Axis.horizontal : Axis.vertical, crossAxisAlignment: CrossAxisAlignment.start, children: [
          ExpandedOrFlexible(expanded: wide, child: SectionCard(title: 'Сотрудники (${users.length})',
            child: users.isEmpty ? const EmptyState(title: 'Ничего не найдено', subtitle: 'Измените поисковый запрос') :
            Column(children: users.map((u) => InkWell(
              onTap: () => setState(() => selected = u),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                decoration: BoxDecoration(
                  color: selected?.id == u.id ? const Color(0xFFEAF4F7) : Colors.transparent,
                  border: const Border(bottom: BorderSide(color: Color(0xFFEEF1F4))),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  CircleAvatar(radius: 19, backgroundColor: const Color(0xFFE5ECF5), child: Text(u.fullName.split(' ').take(2).map((s) => s.isNotEmpty ? s[0] : '').join(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(u.fullName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('${u.login} • ${u.department}', style: const TextStyle(fontSize: 10, color: Color(0xFF667085)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ])),
                  const SizedBox(width: 5),
                  Icon(u.canSignArbitrary ? Icons.check_circle : Icons.remove_circle_outline, size: 16, color: u.canSignArbitrary ? Colors.green : Colors.grey),
                ]),
              ),
            )).toList()))),
          SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 16),
          ExpandedOrFlexible(expanded: wide, child: selected == null
            ? const SectionCard(title: 'Карточка сотрудника', child: EmptyState(title: 'Выберите сотрудника', subtitle: 'Подробности появятся здесь'))
            : _UserDetails(state: widget.state, user: selected!, onRefresh: () => setState(() {}))),
        ]);
      }),
    ]));
  }

  Future<void> _showResetDialog(BuildContext context) async {
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Сбросить тестовые данные?'),
      content: const Text('Все изменения в прототипе будут заменены исходными демонстрационными данными.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Сбросить')),
      ],
    ));
    if (ok == true) {
      widget.state.reset();
      setState(() => selected = null);
    }
  }
}

class ExpandedOrFlexible extends StatelessWidget {
  const ExpandedOrFlexible({super.key, required this.expanded, required this.child});
  final bool expanded;
  final Widget child;
  @override
  Widget build(BuildContext context) => expanded ? Expanded(child: child) : child;
}

class _UserDetails extends StatelessWidget {
  const _UserDetails({required this.state, required this.user, required this.onRefresh});
  final AppState state;
  final AppUser user;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: 'Карточка сотрудника',
    trailing: StatusChip(user.isActive ? 'Активен' : 'Отключён', kind: user.isActive ? StatusKind.success : StatusKind.neutral),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(user.fullName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      const SizedBox(height: 5),
      Text('${user.role} • ${user.department}', style: const TextStyle(color: Color(0xFF667085), fontSize: 12)),
      const SizedBox(height: 18),
      _Detail('ID пользователя', user.id),
      _Detail('Логин', user.login),
      _Detail('Контейнер', user.containerName ?? 'Не назначен'),
      _Detail('Отпечаток', user.thumbprint ?? 'Нет данных'),
      _Detail('Сертификат', user.certificateStatus.label),
      const Divider(height: 28),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Подпись произвольных документов', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: const Text('Демонстрационный флаг доступа', style: TextStyle(fontSize: 11)),
        value: user.canSignArbitrary,
        onChanged: (v) => state.togglePermission(user, v),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Учётная запись активна', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        value: user.isActive,
        onChanged: (v) {
          user.isActive = v;
          state.log('Изменение учётной записи', '${user.fullName}: ${v ? "активна" : "отключена"}', 'Демо');
          state.notifyListeners();
        },
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        FilledButton.icon(onPressed: () {
          state.assignDemoCertificate(user);
          onRefresh();
          _message(context, 'Назначен тестовый сертификат. Реальный сертификат не устанавливался.');
        }, icon: const Icon(Icons.add_moderator_outlined), label: const Text('Добавить ЭЦП')),
        OutlinedButton.icon(onPressed: user.certificateStatus == CertificateStatus.missing ? null : () {
          state.registerDemoCertificate(user);
          onRefresh();
          _message(context, 'Демонстрационная регистрация завершена.');
        }, icon: const Icon(Icons.verified_outlined), label: const Text('Проверить / зарегистрировать')),
        OutlinedButton.icon(onPressed: () => _copyDialog(context), icon: const Icon(Icons.content_copy), label: const Text('Дублировать ЭЦП')),
      ]),
      const SizedBox(height: 12),
      const Text('Все операции с ЭЦП на этом экране демонстрационные.', style: TextStyle(color: Color(0xFF9A6700), fontSize: 11)),
    ]),
  );

  Future<void> _copyDialog(BuildContext context) async {
    AppUser? target = state.users.where((u) => u.id != user.id).firstOrNull;
    final result = await showDialog<AppUser>(context: context, builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      title: const Text('Дублировать тестовую ЭЦП'),
      content: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Источник: ${user.fullName}'),
        const SizedBox(height: 12),
        DropdownButtonFormField<AppUser>(
          value: target,
          decoration: const InputDecoration(labelText: 'Целевой пользователь'),
          items: state.users.where((u) => u.id != user.id).map((u) => DropdownMenuItem(value: u, child: Text(u.fullName))).toList(),
          onChanged: (v) => setDialogState(() => target = v),
        ),
        const SizedBox(height: 12),
        const Text('В реальной системе копирование закрытого ключа требует проверки политики безопасности и возможностей CSP.', style: TextStyle(fontSize: 12, color: Color(0xFF667085))),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(onPressed: target == null ? null : () => Navigator.pop(context, target), child: const Text('Запустить демо')),
      ],
    )));
    if (result != null) {
      state.copyDemoCertificate(user, result);
      onRefresh();
      if (context.mounted) _message(context, 'Демонстрационная операция завершена. Ключи не копировались.');
    }
  }

  void _message(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 115, child: Text(label, style: const TextStyle(color: Color(0xFF667085), fontSize: 11))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
    ]),
  );
}
