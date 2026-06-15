import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/provider_application_provider.dart';
import '../providers/provider_application_state.dart';

const _primary = Color(0xFF0F766E);
const _bg = Color(0xFFF8FAFC);
const _surface = Colors.white;
const _textPrimary = Color(0xFF0F172A);
const _textSecondary = Color(0xFF64748B);
const _divider = Color(0xFFE2E8F0);

const _approvedColor = Color(0xFF16A34A);
const _approvedBg = Color(0xFFDCFCE7);
const _pendingColor = Color(0xFFD97706);
const _pendingBg = Color(0xFFFEF3C7);
const _rejectedColor = Color(0xFFDC2626);
const _rejectedBg = Color(0xFFFEE2E2);

class MyProviderApplicationScreen extends ConsumerStatefulWidget {
  const MyProviderApplicationScreen({super.key});

  @override
  ConsumerState<MyProviderApplicationScreen> createState() =>
      _MyProviderApplicationScreenState();
}

class _MyProviderApplicationScreenState
    extends ConsumerState<MyProviderApplicationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.microtask(() {
      ref.read(providerApplicationProvider.notifier).getMyApplication();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return _approvedColor;
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
      case 'APPROVED':
        return _approvedBg;
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
      case 'APPROVED':
        return Icons.check_circle_rounded;
      case 'REJECTED':
        return Icons.cancel_rounded;
      case 'PENDING':
        return Icons.access_time_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _statusMessage(String status) {
    switch (status) {
      case 'APPROVED':
        return 'Congratulations! Your application has been approved.';
      case 'REJECTED':
        return 'Your application was not approved.';
      case 'PENDING':
        return 'Your application is under review.';
      default:
        return 'Status unknown.';
    }
  }

  int _activeStep(String status) {
    switch (status) {
      case 'APPROVED':
        return 3;
      case 'REJECTED':
        return 3;
      case 'PENDING':
        return 1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerApplicationProvider);

    // Trigger entrance animation when success arrives
    if (state is ProviderApplicationSuccess) {
      _controller.forward();
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Builder(
        builder: (context) {
          if (state is ProviderApplicationLoading) {
            return _SkeletonLoader();
          }
          if (state is ProviderApplicationError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => ref
                  .read(providerApplicationProvider.notifier)
                  .getMyApplication(),
            );
          }
          if (state is ProviderApplicationSuccess) {
            final app = state.application;
            return FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildContent(app),
              ),
            );
          }
          return _EmptyView();
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Application Status',
        style: TextStyle(
          color: _textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 17,
          letterSpacing: -0.3,
        ),
      ),
      leading: BackButton(color: _textPrimary),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _divider),
      ),
    );
  }

  Widget _buildContent(dynamic application) {
    final status = application.status as String;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          _StatusCard(
            status: status,
            color: _statusColor(status),
            bgColor: _statusBg(status),
            icon: _statusIcon(status),
            message: _statusMessage(status),
          ),

          const SizedBox(height: 20),

          // Timeline
          _TimelineCard(
            status: status,
            activeStep: _activeStep(status),
            statusColor: _statusColor(status),
          ),

          const SizedBox(height: 20),

          // Details section
          _SectionLabel(label: 'Application Details'),
          const SizedBox(height: 12),

          _DetailCard(
            icon: Icons.design_services_rounded,
            label: 'Service',
            value: application.serviceName,
          ),
          const SizedBox(height: 12),
          _DetailCard(
            icon: Icons.phone_rounded,
            label: 'Phone Number',
            value: application.phone,
          ),
          const SizedBox(height: 12),
          _DetailCard(
            icon: Icons.location_city_rounded,
            label: 'City',
            value: application.city,
          ),
          const SizedBox(height: 12),
          _DetailCard(
            icon: Icons.article_rounded,
            label: 'Description',
            value: application.description,
            multiline: true,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String status;
  final Color color;
  final Color bgColor;
  final IconData icon;
  final String message;

  const _StatusCard({
    required this.status,
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Colored top strip
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon bubble
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final String status;
  final int
  activeStep; // 0-based index of the last completed step (0=submitted, 1=review, 2=decision)
  final Color statusColor;

  const _TimelineCard({
    required this.status,
    required this.activeStep,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep(
        label: 'Submitted',
        icon: Icons.upload_file_rounded,
        completed: true,
        active: false,
      ),
      _TimelineStep(
        label: 'Under Review',
        icon: Icons.manage_search_rounded,
        completed: activeStep >= 2,
        active: activeStep == 1,
      ),
      _TimelineStep(
        label: status == 'REJECTED' ? 'Rejected' : 'Approved',
        icon: status == 'REJECTED'
            ? Icons.cancel_rounded
            : Icons.verified_rounded,
        completed: activeStep >= 3,
        active: activeStep == 3,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Progress',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                Expanded(
                  child: _StepDot(step: steps[i], color: statusColor),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.only(bottom: 28),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: steps[i].completed ? _primary : _divider,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String label;
  final IconData icon;
  final bool completed;
  final bool active;
  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.completed,
    required this.active,
  });
}

class _StepDot extends StatelessWidget {
  final _TimelineStep step;
  final Color color;
  const _StepDot({required this.step, required this.color});

  @override
  Widget build(BuildContext context) {
    final bg = step.completed
        ? _primary
        : step.active
        ? color.withOpacity(0.12)
        : _divider;
    final iconColor = step.completed
        ? Colors.white
        : step.active
        ? color
        : _textSecondary;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: step.active
                ? Border.all(color: color, width: 2)
                : Border.all(color: Colors.transparent),
          ),
          child: Icon(step.icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          step.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: step.completed || step.active
                ? _textPrimary
                : _textSecondary,
            fontSize: 11,
            fontWeight: step.active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: _textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiline;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEFFCFA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLoader extends StatefulWidget {
  @override
  State<_SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<_SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        final t = _shimmer.value;
        final shimmerColor = Color.lerp(
          const Color(0xFFE2E8F0),
          const Color(0xFFCBD5E1),
          t,
        )!;

        Widget block(double w, double h, {double r = 10}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(r),
          ),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status card skeleton
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              // Timeline skeleton
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              block(140, 20, r: 8),
              const SizedBox(height: 14),
              for (int i = 0; i < 4; i++) ...[
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 12),
              ],
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: _rejectedColor,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 28),
            SizedBox(
              width: 160,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
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
              'No application yet',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You haven\'t submitted a provider application. Apply to start offering your services.',
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
