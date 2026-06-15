import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../request/presentation/providers/request_provider.dart';
import '../../../request/presentation/providers/request_state.dart';

const _primary = Color(0xFF0F766E);
const _bg = Color(0xFFF8FAFC);
const _surface = Colors.white;
const _textPrimary = Color(0xFF0F172A);
const _textSecondary = Color(0xFF64748B);
const _divider = Color(0xFFE2E8F0);

const _acceptedColor = Color(0xFF16A34A);
const _acceptedBg = Color(0xFFDCFCE7);
const _pendingColor = Color(0xFFD97706);
const _pendingBg = Color(0xFFFEF3C7);
const _rejectedColor = Color(0xFFDC2626);
const _rejectedBg = Color(0xFFFEE2E2);

class ProviderRequestsScreen extends ConsumerStatefulWidget {
  final int providerId;
  const ProviderRequestsScreen({super.key, required this.providerId});

  @override
  ConsumerState<ProviderRequestsScreen> createState() =>
      _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState
    extends ConsumerState<ProviderRequestsScreen> {
  // Track per-card loading state
  final Set<int> _processingIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(requestProvider.notifier).getProviderRequests(widget.providerId);
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACCEPTED':
        return _acceptedColor;
      case 'REJECTED':
        return _rejectedColor;
      case 'PENDING':
        return _pendingColor;
      default:
        return _textSecondary;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'ACCEPTED':
        return _acceptedBg;
      case 'REJECTED':
        return _rejectedBg;
      case 'PENDING':
        return _pendingBg;
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'ACCEPTED':
        return Icons.check_circle_rounded;
      case 'REJECTED':
        return Icons.cancel_rounded;
      case 'PENDING':
        return Icons.access_time_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  Future<void> _handleAccept(int requestId) async {
    final confirmed = await _showConfirmDialog(
      title: 'Accept Request',
      message: 'Are you sure you want to accept this request?',
      confirmLabel: 'Accept',
      confirmColor: _acceptedColor,
      icon: Icons.check_circle_rounded,
    );
    if (!confirmed || !mounted) return;

    setState(() => _processingIds.add(requestId));
    await ref
        .read(requestProvider.notifier)
        .acceptRequest(requestId, widget.providerId);
    if (mounted) setState(() => _processingIds.remove(requestId));
  }

  Future<void> _handleReject(int requestId) async {
    final confirmed = await _showConfirmDialog(
      title: 'Reject Request',
      message: 'Are you sure you want to reject this request?',
      confirmLabel: 'Reject',
      confirmColor: _rejectedColor,
      icon: Icons.cancel_rounded,
    );
    if (!confirmed || !mounted) return;

    setState(() => _processingIds.add(requestId));
    await ref
        .read(requestProvider.notifier)
        .rejectRequest(requestId, widget.providerId);
    if (mounted) setState(() => _processingIds.remove(requestId));
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required IconData icon,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => _ConfirmDialog(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            confirmColor: confirmColor,
            icon: icon,
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(state),
      body: Builder(
        builder: (context) {
          if (state is RequestLoading) return _SkeletonView();

          if (state is RequestError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => ref
                  .read(requestProvider.notifier)
                  .getProviderRequests(widget.providerId),
            );
          }

          if (state is ProviderRequestsLoaded) {
            final requests = state.requests;
            if (requests.isEmpty) return _EmptyView();

            final pending = requests.where((r) => r.status == 'PENDING').length;
            final accepted = requests
                .where((r) => r.status == 'ACCEPTED')
                .length;
            final rejected = requests
                .where((r) => r.status == 'REJECTED')
                .length;

            return CustomScrollView(
              slivers: [
                // Statistics row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _StatsRow(
                      total: requests.length,
                      pending: pending,
                      accepted: accepted,
                      rejected: rejected,
                    ),
                  ),
                ),

                // Request cards
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _AnimatedCard(
                        index: i,
                        child: _RequestCard(
                          request: requests[i],
                          isProcessing: _processingIds.contains(requests[i].id),
                          statusColor: _statusColor(requests[i].status),
                          statusBg: _statusBg(requests[i].status),
                          statusIcon: _statusIcon(requests[i].status),
                          onAccept: () => _handleAccept(requests[i].id),
                          onReject: () => _handleReject(requests[i].id),
                        ),
                      ),
                      childCount: requests.length,
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  AppBar _buildAppBar(dynamic state) {
    int? count;
    if (state is ProviderRequestsLoaded) count = state.requests.length;

    return AppBar(
      backgroundColor: _surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Column(
        children: [
          const Text(
            'Provider Requests',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 17,
              letterSpacing: -0.3,
            ),
          ),
          if (count != null)
            Text(
              '$count total',
              style: const TextStyle(color: _textSecondary, fontSize: 12),
            ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: _textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _divider),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int total, pending, accepted, rejected;
  const _StatsRow({
    required this.total,
    required this.pending,
    required this.accepted,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(label: 'Total', value: total, color: _primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            label: 'Pending',
            value: pending,
            color: _pendingColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            label: 'Accepted',
            value: accepted,
            color: _acceptedColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            label: 'Rejected',
            value: rejected,
            color: _rejectedColor,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedCard({required this.index, required this.child});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
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
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

class _RequestCard extends StatelessWidget {
  final dynamic request;
  final bool isProcessing;
  final Color statusColor;
  final Color statusBg;
  final IconData statusIcon;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.isProcessing,
    required this.statusColor,
    required this.statusBg,
    required this.statusIcon,
    required this.onAccept,
    required this.onReject,
  });

  String get _initials {
    final parts = (request.username as String).trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == 'PENDING';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: isPending
            ? Border.all(color: _pendingColor.withOpacity(0.3), width: 1.5)
            : Border.all(color: _divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isPending ? 0.07 : 0.04),
            blurRadius: isPending ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top accent strip for pending
          if (isPending)
            Container(
              height: 4,
              decoration: const BoxDecoration(
                color: _pendingColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer row
                Row(
                  children: [
                    _Avatar(initials: _initials, color: statusColor),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.username,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Customer',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 13, color: statusColor),
                          const SizedBox(width: 5),
                          Text(
                            request.status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Container(height: 1, color: _divider),
                const SizedBox(height: 14),

                // Date row
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: request.requestDate,
                ),

                const SizedBox(height: 10),

                // Notes row
                _InfoRow(
                  icon: Icons.notes_rounded,
                  label: 'Notes',
                  value: request.notes,
                  multiline: true,
                ),

                // Action buttons (pending only)
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Container(height: 1, color: _divider),
                  const SizedBox(height: 14),
                  isProcessing
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: _primary,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                label: 'Accept',
                                icon: Icons.check_rounded,
                                color: _acceptedColor,
                                bg: _acceptedBg,
                                onTap: onAccept,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ActionButton(
                                label: 'Reject',
                                icon: Icons.close_rounded,
                                color: _rejectedColor,
                                bg: _rejectedBg,
                                onTap: onReject,
                              ),
                            ),
                          ],
                        ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final Color color;
  const _Avatar({required this.initials, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiline;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: multiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFEFFCFA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: _primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final IconData icon;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: _surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: confirmColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: confirmColor, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _divider, width: 1.5),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: _textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: confirmColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          confirmLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonView extends StatefulWidget {
  @override
  State<_SkeletonView> createState() => _SkeletonViewState();
}

class _SkeletonViewState extends State<_SkeletonView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

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
          const Color(0xFFE2E8F0),
          const Color(0xFFCBD5E1),
          _ctrl.value,
        )!;

        Widget block(double w, double h, {double r = 10}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: shimmer,
            borderRadius: BorderRadius.circular(r),
          ),
        );

        Widget skeletonCard() => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  block(48, 48, r: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        block(120, 16, r: 8),
                        const SizedBox(height: 6),
                        block(70, 12, r: 6),
                      ],
                    ),
                  ),
                  block(70, 26, r: 13),
                ],
              ),
              const SizedBox(height: 16),
              block(double.infinity, 1, r: 0),
              const SizedBox(height: 14),
              block(double.infinity, 14, r: 7),
              const SizedBox(height: 10),
              block(double.infinity, 40, r: 8),
            ],
          ),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              // Stats row skeleton
              Row(
                children: List.generate(
                  4,
                  (_) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      height: 64,
                      decoration: BoxDecoration(
                        color: shimmer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Card skeletons
              for (int i = 0; i < 3; i++) skeletonCard(),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _rejectedBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: _rejectedColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Try again',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEFFCFA),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_rounded, color: _primary, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Requests Yet',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'When customers send you service requests,\nthey will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
