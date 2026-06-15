import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/request_provider.dart';
import '../providers/request_state.dart';

class _C {
  static const primary = Color(0xFF0F766E);
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const textDark = Color(0xFF0F172A);
  static const textMid = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);

  // Status palette
  static const pending = Color(0xFFF59E0B);
  static const pendingBg = Color(0xFFFFFBEB);
  static const accepted = Color(0xFF10B981);
  static const acceptedBg = Color(0xFFECFDF5);
  static const rejected = Color(0xFFEF4444);
  static const rejectedBg = Color(0xFFFEF2F2);

  static const shimmerBase = Color(0xFFEEF2F6);
  static const shimmerHighlight = Color(0xFFF8FAFC);
}

Color _statusColor(String s) {
  switch (s.toUpperCase()) {
    case 'ACCEPTED':
      return _C.accepted;
    case 'REJECTED':
      return _C.rejected;
    case 'PENDING':
      return _C.pending;
    default:
      return _C.textMuted;
  }
}

Color _statusBg(String s) {
  switch (s.toUpperCase()) {
    case 'ACCEPTED':
      return _C.acceptedBg;
    case 'REJECTED':
      return _C.rejectedBg;
    case 'PENDING':
      return _C.pendingBg;
    default:
      return _C.background;
  }
}

IconData _statusIcon(String s) {
  switch (s.toUpperCase()) {
    case 'ACCEPTED':
      return Icons.check_circle_rounded;
    case 'REJECTED':
      return Icons.cancel_rounded;
    case 'PENDING':
      return Icons.schedule_rounded;
    default:
      return Icons.help_outline_rounded;
  }
}

String _statusLabel(String s) {
  switch (s.toUpperCase()) {
    case 'ACCEPTED':
      return 'Accepted';
    case 'REJECTED':
      return 'Rejected';
    case 'PENDING':
      return 'Pending';
    default:
      return s;
  }
}

int _timelineStep(String s) {
  switch (s.toUpperCase()) {
    case 'ACCEPTED':
      return 2;
    case 'REJECTED':
      return 2;
    case 'PENDING':
      return 1;
    default:
      return 0;
  }
}

Color _avatarColor(String name) {
  const pool = [
    Color(0xFF0F766E),
    Color(0xFF0369A1),
    Color(0xFF7C3AED),
    Color(0xFFB45309),
    Color(0xFFBE123C),
    Color(0xFF047857),
  ];
  return pool[name.hashCode.abs() % pool.length];
}

String _initials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

class MyRequestsScreen extends ConsumerStatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  ConsumerState<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends ConsumerState<MyRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(requestProvider.notifier).getMyRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestProvider);

    return Scaffold(
      backgroundColor: _C.background,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: _C.surface,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 60,
              decoration: const BoxDecoration(
                color: _C.surface,
                border: Border(bottom: BorderSide(color: _C.border, width: 1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Teal accent bar
                  Container(
                    width: 4,
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D6B63), Color(0xFF14B8A6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'My Requests',
                      style: TextStyle(
                        color: _C.textDark,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  // Badge showing count
                  if (state is MyRequestsLoaded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _C.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${state.requests.length} total',
                        style: const TextStyle(
                          color: _C.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Builder(
        builder: (context) {
          if (state is RequestLoading) return const _SkeletonList();

          if (state is RequestError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 52,
                      color: _C.textMuted.withOpacity(0.5),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.message,
                      style: const TextStyle(color: _C.textMid, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MyRequestsLoaded) {
            if (state.requests.isEmpty) return const _EmptyState();

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              itemCount: state.requests.length,
              itemBuilder: (context, index) =>
                  _RequestCard(request: state.requests[index], index: index),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  final dynamic request;
  final int index;
  const _RequestCard({required this.request, required this.index});

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final status = req.status as String? ?? 'PENDING';
    final providerName = req.providerName as String? ?? 'Unknown Provider';
    final requestDate = req.requestDate?.toString() ?? '';
    final step = _timelineStep(status);
    final sColor = _statusColor(status);

    // Try optional fields gracefully
    String? serviceName;
    try {
      serviceName = req.serviceName as String?;
    } catch (_) {}

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _C.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _avatarColor(providerName),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          _initials(providerName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Name + service
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            providerName,
                            style: const TextStyle(
                              color: _C.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (serviceName != null &&
                              serviceName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.home_repair_service_rounded,
                                  size: 12,
                                  color: _C.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  serviceName,
                                  style: const TextStyle(
                                    color: _C.textMuted,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBg(status),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(status), size: 13, color: sColor),
                          const SizedBox(width: 4),
                          Text(
                            _statusLabel(status),
                            style: TextStyle(
                              color: sColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(
                color: _C.border,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: _C.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      requestDate.isNotEmpty
                          ? requestDate
                          : 'Date not available',
                      style: const TextStyle(
                        color: _C.textMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),

              _TimelineStrip(step: step, status: status),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineStrip extends StatelessWidget {
  final int step; // 0 = created, 1 = pending, 2 = done
  final String status;
  const _TimelineStrip({required this.step, required this.status});

  @override
  Widget build(BuildContext context) {
    final isRejected = status.toUpperCase() == 'REJECTED';
    final doneColor = isRejected ? _C.rejected : _C.accepted;

    final steps = ['Created', 'Pending', isRejected ? 'Rejected' : 'Accepted'];
    final icons = [
      Icons.add_circle_outline_rounded,
      Icons.schedule_rounded,
      isRejected ? Icons.cancel_rounded : Icons.check_circle_rounded,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _C.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final active = i <= step;
          final isLast = i == 2;
          final color = active ? (i == 2 ? doneColor : _C.primary) : _C.border;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(icons[i], size: 18, color: color),
                      const SizedBox(height: 3),
                      Text(
                        steps[i],
                        style: TextStyle(
                          color: active ? color : _C.textMuted,
                          fontSize: 10,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 1.5,
                      margin: const EdgeInsets.only(bottom: 14),
                      color: i < step ? _C.primary : _C.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SkeletonList extends StatefulWidget {
  const _SkeletonList();

  @override
  State<_SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<_SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final shimmer = Color.lerp(
          _C.shimmerBase,
          _C.shimmerHighlight,
          _ctrl.value,
        )!;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: List.generate(
            4,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              height: 148,
              decoration: BoxDecoration(
                color: shimmer,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: _C.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_rounded,
                size: 40,
                color: _C.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Requests Yet',
              style: TextStyle(
                color: _C.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Browse available services and submit your first request to get started.',
              style: TextStyle(color: _C.textMuted, fontSize: 14, height: 1.55),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D6B63), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _C.primary.withOpacity(0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Browse Services',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
