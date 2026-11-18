import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../core/app_theme.dart';
import '../core/widgets.dart';
import '../features/audit_page.dart';
import '../features/certificates_page.dart';
import '../features/dashboard_page.dart';
import '../features/documents_page.dart';
import '../features/netrika_page.dart';
import '../features/settings_page.dart';
import '../features/signing_page.dart';
import '../features/users_page.dart';

class MedialogSignApp extends StatefulWidget {
  const MedialogSignApp({super.key});

  @override
  State<MedialogSignApp> createState() => _MedialogSignAppState();
}

class _MedialogSignAppState extends State<MedialogSignApp> {
  final AppState state = AppState();
  int selectedIndex = 0;

  final List<NavigationItem> items = const [
    NavigationItem('Главная', Icons.dashboard_outlined),
    NavigationItem('Пользователи', Icons.people_outline),
    NavigationItem('Управление ЭЦП', Icons.verified_user_outlined),
    NavigationItem('Подписание', Icons.draw_outlined),
    NavigationItem('Нетрика', Icons.outgoing_mail),
    NavigationItem('Документы', Icons.folder_outlined),
    NavigationItem('Журнал операций', Icons.receipt_long_outlined),
    NavigationItem('Настройки', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => MaterialApp(
        title: 'Medialog Sign',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Scaffold(
          body: Row(
            children: [
              Container(
                width: 250,
                color: const Color(0xFF13243A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 24, 16, 30),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_user,
                            color: Color(0xFFB8C5D6),
                            size: 30,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Medialog Sign',
                              style: TextStyle(
                                color: Color(0xFFB8C5D6),
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isSelected = selectedIndex == index;

                          final foregroundColor = isSelected
                              ? Colors.white
                              : const Color(0xFFB8C5D6);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Material(
                              color: isSelected
                                  ? const Color(0xFF176B87)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 21,
                                        color: foregroundColor,
                                      ),
                                      const SizedBox(width: 13),
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style: TextStyle(
                                            color: foregroundColor,
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(color: Color(0xFF34465C)),
                          SizedBox(height: 10),
                          Text(
                            'ДЕМО-РЕЖИМ',
                            style: TextStyle(
                              color: Color(0xFFB8C5D6),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Реальные системы не подключены',
                            style: TextStyle(
                              color: Color(0xFFB8C5D6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(state: state),
                    Expanded(
                      child: IndexedStack(
                        index: selectedIndex,
                        children: [
                          DashboardPage(state: state, onNavigate: (i) => setState(() => selectedIndex = i)),
                          UsersPage(state: state),
                          CertificatesPage(state: state),
                          SigningPage(state: state),
                          NetrikaPage(state: state),
                          DocumentsPage(state: state),
                          AuditPage(state: state),
                          SettingsPage(state: state),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5EAF0))),
      ),
      child: Row(
        children: [
          const Text('Рабочее место администратора',
            style: TextStyle(fontSize: 13, color: Color(0xFF637083))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFFFF3D9), borderRadius: BorderRadius.circular(8)),
            child: const Row(children: [
              Icon(Icons.science_outlined, size: 16, color: Color(0xFF986A10)),
              SizedBox(width: 6),
              Text('Тестовый режим', style: TextStyle(color: Color(0xFF986A10), fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(width: 18),
          PopupMenuButton<String>(
            tooltip: 'Активный пользователь',
            onSelected: state.setActiveUser,
            itemBuilder: (_) => state.users.map((u) => PopupMenuItem(
              value: u.id, child: Text(u.fullName),
            )).toList(),
            child: Row(children: [
              const CircleAvatar(radius: 17, child: Icon(Icons.person_outline, size: 19)),
              const SizedBox(width: 9),
              Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(state.activeUser.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                const Text('Активный пользователь', style: TextStyle(fontSize: 10, color: Color(0xFF7B8796))),
              ]),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down),
            ]),
          ),
        ],
      ),
    );
  }
}
