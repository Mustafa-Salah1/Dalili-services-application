import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_finder/features/review/presentation/providers/review_provider.dart';

import '../providers/request_provider.dart';
import '../providers/request_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────

class _C {
  // Brand
  static const primary = Color(0xFF0F766E);
  static const primaryDark = Color(0xFF0D6B63);
  static const secondary = Color(0xFF14B8A6);

  // Surface
  static const background = Color(0xFFF1F5F9);
  static const surface = Colors.white;
  static const surfaceAlt = Color(0xFFF8FAFC);

  // Text
  static const textDark = Color(0xFF0F172A);
  static const textMid = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);

  // Border
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);

  // Statuses
  static const pending = Color(0xFFF59E0B);
  static const pendingBg = Color(0xFFFFFBEB);
  static const pendingBorder = Color(0xFFFDE68A);
  static const accepted = Color(0xFF10B981);
  static const acceptedBg = Color(0xFFECFDF5);
  static const acceptedBorder = Color(0xFFA7F3D0);
  static const rejected = Color(0xFFEF4444);
  static const rejectedBg = Color(0xFFFEF2F2);
  static const rejectedBorder = Color(0xFFFECACA);
  static const inProgress = Color(0xFF3B82F6);
  static const inProgressBg = Color(0xFFEFF6FF);
  static const inProgressBorder = Color(0xFFBFDBFE);
  static const completed = Color(0xFF059669);
  static const completedBg = Color(0xFFD1FAE5);
  static const completedBorder = Color(0xFF6EE7B7);

  // Shimmer
  static const shimmerBase = Color(0xFFE2E8F0);
  static const shimmerHighlight = Color(0xFFF8FAFC);

  // Star
  static const star = Color(0xFFF59E0B);
}

// ─────────────────────────────────────────────────────────────────────────────
// Status helpers
// ─────────────────────────────────────────────────────────────────────────────

Color _statusColor(String s) {
  switch (s.toUpperCase()) {
    case 'ACCEPTED':
      return _C.accepted;
    case 'REJECTED':
      return _C.rejected;
    case 'PENDING':
      return _C.pending;
    case 'IN_PROGRESS':
      return _C.inProgress;
    case 'COMPLETED':
      return _C.completed;
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
    case 'IN_PROGRESS':
      return _C.inProgressBg;
    case 'COMPLETED':
      return _C.completedBg;
    default:
      return _C.surfaceAlt;
  }
}

Color _statusBorder(String s) {
  switch (s.toUpperCase()) {
    case 'ACCEPTED':
      return _C.acceptedBorder;
    case 'REJECTED':
      return _C.rejectedBorder;
    case 'PENDING':
      return _C.pendingBorder;
    case 'IN_PROGRESS':
      return _C.inProgressBorder;
    case 'COMPLETED':
      return _C.completedBorder;
    default:
      return _C.border;
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
    case 'IN_PROGRESS':
      return Icons.engineering_rounded;
    case 'COMPLETED':
      return Icons.task_alt_rounded;
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
    case 'IN_PROGRESS':
      return 'In Progress';
    case 'COMPLETED':
      return 'Completed';
    default:
      return s;
  }
}

int _timelineStep(String s) {
  switch (s.toUpperCase()) {
    case 'PENDING':
      return 1;
    case 'ACCEPTED':
      return 2;
    case 'IN_PROGRESS':
      return 3;
    case 'COMPLETED':
      return 4;
    case 'REJECTED':
      return -1;
    default:
      return 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Misc helpers
// ─────────────────────────────────────────────────────────────────────────────

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

void _showReviewDialog(BuildContext context, int providerId) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => _ReviewDialog(providerId: providerId),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class MyRequestsScreen extends ConsumerStatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  ConsumerState<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends ConsumerState<MyRequestsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _headerCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _headerCtrl.forward();

    Future.microtask(() => ref.read(requestProvider.notifier).getMyRequests());
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestProvider);

    return Scaffold(
      backgroundColor: _C.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(state, innerBoxIsScrolled),
        ],
        body: Builder(builder: (context) => _buildBody(state)),
      ),
    );
  }

  Widget _buildSliverAppBar(dynamic state, bool innerScrolled) {
    final count = state is MyRequestsLoaded ? state.requests.length : null;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: _C.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: _C.border,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: _C.textDark,
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: FadeTransition(
          opacity: _headerFade,
          child: SlideTransition(
            position: _headerSlide,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D6B63), Color(0xFF0F766E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Requests',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Track your service bookings',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (count != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.receipt_long_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        title: innerScrolled
            ? const Text(
                'My Requests',
                style: TextStyle(
                  color: _C.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              )
            : null,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  Widget _buildBody(dynamic state) {
    if (state is RequestLoading) return const _SkeletonList();

    if (state is RequestError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _C.rejected.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 32,
                  color: _C.rejected.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Connection issue',
                style: TextStyle(
                  color: _C.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.message,
                style: const TextStyle(
                  color: _C.textMid,
                  fontSize: 13.5,
                  height: 1.5,
                ),
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
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        itemCount: state.requests.length,
        itemBuilder: (context, index) =>
            _RequestCard(request: state.requests[index], index: index),
      );
    }

    return const SizedBox();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Request Card
// ─────────────────────────────────────────────────────────────────────────────

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
      duration: const Duration(milliseconds: 480),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 70 * widget.index), () {
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
    final sBg = _statusBg(status);
    final sBorder = _statusBorder(status);
    final isCompleted = status.toUpperCase() == 'COMPLETED';

    int? providerId;
    String? serviceName;
    try {
      providerId = req.providerId as int?;
    } catch (_) {}
    try {
      serviceName = req.serviceName as String?;
    } catch (_) {}

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Card header ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with gradient ring
                    Stack(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _avatarColor(providerName),
                                _avatarColor(providerName).withOpacity(0.75),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: _avatarColor(
                                  providerName,
                                ).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _initials(providerName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        // Online dot indicator
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: sColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: _C.surface, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 13),

                    // Name + service
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            providerName,
                            style: const TextStyle(
                              color: _C.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          if (serviceName != null && serviceName.isNotEmpty)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: _C.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Icon(
                                    Icons.home_repair_service_rounded,
                                    size: 11,
                                    color: _C.primary,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    serviceName,
                                    style: const TextStyle(
                                      color: _C.textMid,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          else
                            const Text(
                              'General Service',
                              style: TextStyle(
                                color: _C.textMuted,
                                fontSize: 12.5,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Status badge — improved
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: sBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: sBorder, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(status), size: 12, color: sColor),
                          const SizedBox(width: 4),
                          Text(
                            _statusLabel(status),
                            style: TextStyle(
                              color: sColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Date pill ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _C.surfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _C.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: _C.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            requestDate.isNotEmpty
                                ? requestDate
                                : 'Date not set',
                            style: const TextStyle(
                              color: _C.textMid,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Divider ───────────────────────────────────────────────
              const Divider(height: 1, color: _C.borderLight),

              // ── Timeline ──────────────────────────────────────────────
              _TimelineStrip(step: step, status: status),

              // ── Rate Provider button ──────────────────────────────────
              if (isCompleted && providerId != null)
                _RateProviderButton(
                  onTap: () => _showReviewDialog(context, providerId!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rate Provider Button
// ─────────────────────────────────────────────────────────────────────────────

class _RateProviderButton extends StatefulWidget {
  final VoidCallback onTap;
  const _RateProviderButton({required this.onTap});

  @override
  State<_RateProviderButton> createState() => _RateProviderButtonState();
}

class _RateProviderButtonState extends State<_RateProviderButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _starCtrl;
  late final Animation<double> _starAnim;

  @override
  void initState() {
    super.initState();
    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _starAnim = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _starCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D6B63), Color(0xFF14B8A6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _C.primary.withOpacity(0.28),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _starAnim,
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Rate Provider',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5-Step Timeline
// ─────────────────────────────────────────────────────────────────────────────

class _TimelineStrip extends StatelessWidget {
  final int step;
  final String status;
  const _TimelineStrip({required this.step, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status.toUpperCase() == 'REJECTED') return const _RejectedTimeline();

    const labels = ['Created', 'Pending', 'Accepted', 'Working', 'Done'];
    final icons = [
      Icons.add_circle_outline_rounded,
      Icons.schedule_rounded,
      Icons.check_circle_rounded,
      Icons.engineering_rounded,
      Icons.task_alt_rounded,
    ];
    final nodeColors = [
      _C.primary,
      _C.pending,
      _C.accepted,
      _C.inProgress,
      _C.completed,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: _C.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.borderLight),
        ),
        child: Row(
          children: List.generate(5, (i) {
            final isActive = i <= step;
            final isLast = i == 4;
            final color = isActive ? nodeColors[i] : _C.shimmerBase;
            final lineColor = i < step ? nodeColors[i] : _C.shimmerBase;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isActive ? 30 : 26,
                          height: isActive ? 30 : 26,
                          decoration: BoxDecoration(
                            color: isActive
                                ? color.withOpacity(0.12)
                                : _C.shimmerBase,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive ? color : _C.shimmerBase,
                              width: isActive ? 1.5 : 1,
                            ),
                          ),
                          child: Icon(
                            icons[i],
                            size: isActive ? 15 : 13,
                            color: isActive ? color : _C.textMuted,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          labels[i],
                          style: TextStyle(
                            color: isActive ? color : _C.textMuted,
                            fontSize: 9,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: lineColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _RejectedTimeline extends StatelessWidget {
  const _RejectedTimeline();

  @override
  Widget build(BuildContext context) {
    const labels = ['Created', 'Pending', 'Rejected'];
    final icons = [
      Icons.add_circle_outline_rounded,
      Icons.schedule_rounded,
      Icons.cancel_rounded,
    ];
    final colors = [_C.primary, _C.pending, _C.rejected];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _C.rejectedBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.rejectedBorder),
        ),
        child: Row(
          children: List.generate(3, (i) {
            final isLast = i == 2;
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: colors[i].withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors[i].withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(icons[i], size: 15, color: colors[i]),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          labels[i],
                          style: TextStyle(
                            color: colors[i],
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: i == 0 ? _C.pending : _C.rejected,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewDialog extends ConsumerStatefulWidget {
  final int providerId;
  const _ReviewDialog({required this.providerId});

  @override
  ConsumerState<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends ConsumerState<_ReviewDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  int _rating = 0;
  bool _submitted = false;
  bool _isSubmitting = false;
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) return;
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(reviewProvider.notifier)
          .createReview(
            providerId: widget.providerId,
            rating: _rating,
            comment: _commentCtrl.text.trim(),
          );
      if (!mounted) return;
      setState(() => _submitted = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: _submitted
                ? _SuccessBody(onDone: () => Navigator.pop(context))
                : _FormBody(
                    rating: _rating,
                    commentController: _commentCtrl,
                    isSubmitting: _isSubmitting,
                    onRatingChanged: (r) => setState(() => _rating = r),
                    onSubmit: _isSubmitting ? () {} : _submit,
                    onCancel: _isSubmitting
                        ? () {}
                        : () => Navigator.pop(context),
                  ),
          ),
        ),
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  final int rating;
  final TextEditingController commentController;
  final bool isSubmitting;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _FormBody({
    required this.rating,
    required this.commentController,
    required this.isSubmitting,
    required this.onRatingChanged,
    required this.onSubmit,
    required this.onCancel,
  });

  static const _labels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent!',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D6B63), Color(0xFF14B8A6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _C.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.rate_review_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Rate Your Experience',
          style: TextStyle(
            color: _C.textDark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'How would you rate this service?',
          style: TextStyle(color: _C.textMid, fontSize: 13.5),
        ),

        const SizedBox(height: 22),

        // Stars
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final filled = i < rating;
            return GestureDetector(
              onTap: () => onRatingChanged(i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    key: ValueKey(filled),
                    color: filled ? _C.star : _C.border,
                    size: 40,
                  ),
                ),
              ),
            );
          }),
        ),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: rating > 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _C.star.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _labels[rating],
                      key: ValueKey(rating),
                      style: const TextStyle(
                        color: _C.star,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              : const SizedBox(key: ValueKey(0), height: 8),
        ),

        const SizedBox(height: 16),

        // Comment
        Container(
          decoration: BoxDecoration(
            color: _C.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border),
          ),
          child: TextField(
            controller: commentController,
            maxLines: 3,
            style: const TextStyle(
              color: _C.textDark,
              fontSize: 14,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'Share your experience (optional)…',
              hintStyle: TextStyle(
                color: _C.textMuted.withOpacity(0.8),
                fontSize: 13.5,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _C.textMid,
                  side: const BorderSide(color: _C.border),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: (rating > 0 && !isSubmitting) ? onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  disabledBackgroundColor: _C.shimmerBase,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SuccessBody extends StatelessWidget {
  final VoidCallback onDone;
  const _SuccessBody({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_C.completed, _C.completed.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _C.completed.withOpacity(0.3),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
        ),

        const SizedBox(height: 20),

        const Text(
          'Review Submitted!',
          style: TextStyle(
            color: _C.textDark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Thank you for your feedback.\nIt helps others find great providers.',
          style: TextStyle(color: _C.textMid, fontSize: 13.5, height: 1.55),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 26),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer Skeleton (mimics real card structure)
// ─────────────────────────────────────────────────────────────────────────────

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
      duration: const Duration(milliseconds: 1200),
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
        final shimmerDark = Color.lerp(
          _C.shimmerBase,
          const Color(0xFFDDE3ED),
          _ctrl.value,
        )!;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          children: List.generate(3, (_) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _C.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: shimmerDark,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              width: 130,
                              decoration: BoxDecoration(
                                color: shimmerDark,
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 11,
                              width: 90,
                              decoration: BoxDecoration(
                                color: shimmer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 72,
                        height: 26,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Date pill
                  Container(
                    height: 28,
                    width: 120,
                    decoration: BoxDecoration(
                      color: shimmer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: _C.borderLight),
                  const SizedBox(height: 14),
                  // Timeline skeleton
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: shimmer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatefulWidget {
  const _EmptyState();

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Illustration-style icon stack
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _C.primary.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _C.primary.withOpacity(0.12),
                              _C.secondary.withOpacity(0.12),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0D6B63), Color(0xFF14B8A6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inbox_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'No Requests Yet',
                  style: TextStyle(
                    color: _C.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'You haven\'t made any service requests.\nBrowse providers and book your first service.',
                  style: TextStyle(
                    color: _C.textMuted,
                    fontSize: 14,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D6B63), Color(0xFF14B8A6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _C.primary.withOpacity(0.3),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.explore_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Browse Services',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
