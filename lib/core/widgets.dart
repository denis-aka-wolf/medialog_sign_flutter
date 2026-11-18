import 'package:flutter/material.dart';
import 'models.dart';

class NavigationItem {
  const NavigationItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, required this.subtitle, this.trailing});
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: Color(0xFF172B4D))),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7788))),
        ])),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(28),
    child: child,
  );
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.kind = StatusKind.neutral});
  final String label;
  final StatusKind kind;

  @override
  Widget build(BuildContext context) {
    final color = switch (kind) {
      StatusKind.success => const Color(0xFF18794E),
      StatusKind.warning => const Color(0xFF9A6700),
      StatusKind.error => const Color(0xFFB42318),
      StatusKind.info => const Color(0xFF175CD3),
      StatusKind.neutral => const Color(0xFF475467),
    };
    final bg = switch (kind) {
      StatusKind.success => const Color(0xFFE8F7EF),
      StatusKind.warning => const Color(0xFFFFF4D6),
      StatusKind.error => const Color(0xFFFEECEB),
      StatusKind.info => const Color(0xFFEAF2FF),
      StatusKind.neutral => const Color(0xFFF0F2F5),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

enum StatusKind { success, warning, error, info, neutral }

StatusKind certificateKind(CertificateStatus status) => switch (status) {
  CertificateStatus.active => StatusKind.success,
  CertificateStatus.expiring || CertificateStatus.pending => StatusKind.warning,
  CertificateStatus.expired => StatusKind.error,
  CertificateStatus.missing => StatusKind.neutral,
};

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))), if (trailing != null) trailing!]),
        const SizedBox(height: 16),
        child,
      ]),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.subtitle, this.icon = Icons.inbox_outlined});
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 44, color: const Color(0xFF98A2B3)),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF667085))),
      ]),
    ),
  );
}
