import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../providers/notification_state.dart';

const _primary = Color(0xFF0F766E);
const _secondary = Color(0xFF14B8A6);
const _bg = Color(0xFFF8FAFC);
const _surface = Color(0xFFFFFFFF);
const _onSurface = Color(0xFF0F172A);
const _textMuted = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);
const _unreadBg = Color(0xFFEFFEFD);
const _unreadDot = Color(0xFF0F766E);
const _shimmer1 = Color(0xFFE2E8F0);
const _shimmer2 = Color(0xFFF1F5F9);

enum NotifType { provider, review, favorite, system, appStatus }

class _NotifMeta {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String label;

  const _NotifMeta({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.label,
  });
}

const _notifMeta = {
  NotifType.provider: _NotifMeta(
    icon: Icons.person_pin_rounded,
    color: Color(0xFF0F766E),
    bgColor: Color(0xFFCCFBF1),
    label: 'Provider Update',
  ),
  NotifType.review: _NotifMeta(
    icon: Icons.star_rounded,
    color: Color(0xFFB45309),
    bgColor: Color(0xFFFEF3C7),
    label: 'Review',
  ),
  NotifType.favorite: _NotifMeta(
    icon: Icons.favorite_rounded,
    color: Color(0xFFBE185D),
    bgColor: Color(0xFFFCE7F3),
    label: 'Favorite',
  ),
  NotifType.system: _NotifMeta(
    icon: Icons.settings_rounded,
    color: Color(0xFF374151),
    bgColor: Color(0xFFF3F4F6),
    label: 'System',
  ),
  NotifType.appStatus: _NotifMeta(
    icon: Icons.verified_rounded,
    color: Color(0xFF1D4ED8),
    bgColor: Color(0xFFDBEAFE),
    label: 'Application Status',
  ),
};

NotifType _resolveType(String? type) {
  switch (type?.toLowerCase()) {
    case 'review':
      return NotifType.review;
    case 'favorite':
      return NotifType.favorite;
    case 'system':
      return NotifType.system;
    case 'app_status':
    case 'appstatus':
      return NotifType.appStatus;
    default:
      return NotifType.provider;
  }
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).getNotifications();
    });

    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    int unreadCount = 0;
    bool hasUnread = false;
    if (state is NotificationLoaded) {
      unreadCount = state.notifications.where((n) => !n.isRead).length;
      hasUnread = unreadCount > 0;
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            FadeTransition(
              opacity: _headerFade,
              child: _Header(
                unreadCount: unreadCount,
                onMarkAllRead: hasUnread
                    ? () {
                        if (state is NotificationLoaded) {
                          for (final n in state.notifications) {
                            if (!n.isRead) {
                              ref
                                  .read(notificationProvider.notifier)
                                  .markAsRead(n.id);
                            }
                          }
                        }
                      }
                    : null,
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state is NotificationLoading) {
                    return const _SkeletonLoader();
                  }

                  if (state is NotificationError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is NotificationLoaded) {
                    final notifications = state.notifications;

                    if (notifications.isEmpty) {
                      return const _EmptyState();
                    }

                    final now = DateTime.now();
                    final todayStart = DateTime(now.year, now.month, now.day);
                    final yesterdayStart = todayStart.subtract(
                      const Duration(days: 1),
                    );

                    final today = notifications
                        .where((n) => n.createdAt.isAfter(todayStart))
                        .toList();
                    final yesterday = notifications
                        .where(
                          (n) =>
                              n.createdAt.isAfter(yesterdayStart) &&
                              !n.createdAt.isAfter(todayStart),
                        )
                        .toList();
                    final earlier = notifications
                        .where((n) => !n.createdAt.isAfter(yesterdayStart))
                        .toList();

                    final groups = <MapEntry<String, List<dynamic>>>[];
                    if (today.isNotEmpty) {
                      groups.add(MapEntry('Today', today));
                    }
                    if (yesterday.isNotEmpty) {
                      groups.add(MapEntry('Yesterday', yesterday));
                    }
                    if (earlier.isNotEmpty) {
                      groups.add(MapEntry('Earlier', earlier));
                    }

                    final items = <Object>[];
                    for (final g in groups) {
                      items.add(g.key);
                      items.addAll(List<Object>.from(g.value));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        if (item is String) {
                          return _GroupLabel(label: item);
                        }

                        final notification = item;
                        final notifType = NotifType.system;
                        final meta = _notifMeta[notifType]!;

                        return _AnimatedNotifCard(
                          key: ValueKey((notification as dynamic).id),
                          id: (notification as dynamic).id,
                          title: (notification as dynamic).title,
                          body: (notification as dynamic).message,
                          isRead: (notification as dynamic).isRead,
                          createdAt: (notification as dynamic).createdAt,
                          meta: meta,
                          onMarkRead: () {
                            ref
                                .read(notificationProvider.notifier)
                                .markAsRead((notification as dynamic).id);
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onMarkAllRead;

  const _Header({required this.unreadCount, this.onMarkAllRead});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 18),
      decoration: BoxDecoration(
        color: _surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: _onSurface,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: _onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if (unreadCount > 0)
                  Text(
                    '$unreadCount unread',
                    style: const TextStyle(color: _textMuted, fontSize: 13),
                  ),
              ],
            ),
          ),
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_primary, _secondary]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          if (onMarkAllRead != null)
            TextButton(
              onPressed: onMarkAllRead,
              style: TextButton.styleFrom(
                foregroundColor: _primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Mark all read',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  const _GroupLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: _border, height: 1)),
        ],
      ),
    );
  }
}

class _AnimatedNotifCard extends StatefulWidget {
  final int id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final _NotifMeta meta;
  final VoidCallback onMarkRead;

  const _AnimatedNotifCard({
    super.key,
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    required this.meta,
    required this.onMarkRead,
  });

  @override
  State<_AnimatedNotifCard> createState() => _AnimatedNotifCardState();
}

class _AnimatedNotifCardState extends State<_AnimatedNotifCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
        child: _NotifCard(
          id: widget.id,
          title: widget.title,
          body: widget.body,
          isRead: widget.isRead,
          createdAt: widget.createdAt,
          meta: widget.meta,
          onMarkRead: widget.onMarkRead,
        ),
      ),
    );
  }
}

class _NotifCard extends StatefulWidget {
  final int id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final _NotifMeta meta;
  final VoidCallback onMarkRead;

  const _NotifCard({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    required this.meta,
    required this.onMarkRead,
  });

  @override
  State<_NotifCard> createState() => _NotifCardState();
}

class _NotifCardState extends State<_NotifCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _pressScale = Tween(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  String _timeLabel(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final meta = widget.meta;
    final isUnread = !widget.isRead;

    return Dismissible(
      key: ValueKey('dismissible_${widget.id}'),
      background: _SwipeBg(
        alignment: Alignment.centerLeft,
        color: _primary,
        icon: Icons.mark_email_read_rounded,
        label: 'Mark read',
        isLeft: true,
      ),
      secondaryBackground: _SwipeBg(
        alignment: Alignment.centerRight,
        color: const Color(0xFFEF4444),
        icon: Icons.delete_rounded,
        label: 'Delete',
        isLeft: false,
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          widget.onMarkRead();
          return false;
        }
        return false;
      },
      child: GestureDetector(
        onTap: () {
          if (isUnread) widget.onMarkRead();
        },
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) => _pressCtrl.reverse(),
        onTapCancel: () => _pressCtrl.reverse(),
        child: ScaleTransition(
          scale: _pressScale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnread ? _unreadBg : _surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isUnread ? _primary.withOpacity(0.18) : _border,
                width: isUnread ? 1.2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isUnread
                      ? _primary.withOpacity(0.08)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: isUnread ? 14 : 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: meta.bgColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(meta.icon, color: meta.color, size: 22),
                    ),
                    if (isUnread)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: _unreadDot,
                            shape: BoxShape.circle,
                            border: Border.all(color: _unreadBg, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: meta.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              meta.label,
                              style: TextStyle(
                                color: meta.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _timeLabel(widget.createdAt),
                            style: TextStyle(
                              color: isUnread ? _primary : _textMuted,
                              fontSize: 11,
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: _onSurface,
                          fontSize: 14,
                          fontWeight: isUnread
                              ? FontWeight.w700
                              : FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.body,
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 13,
                          height: 1.45,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

class _SwipeBg extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;
  final bool isLeft;

  const _SwipeBg({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      padding: EdgeInsets.only(left: isLeft ? 24 : 0, right: isLeft ? 0 : 24),
      alignment: alignment,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.09),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFBF1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 34,
                    color: _primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'All caught up',
              style: TextStyle(
                color: _onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'New updates about providers, reviews,\nand your account will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textMuted, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.maybePop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.explore_rounded, size: 18),
                label: const Text(
                  'Explore Services',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonLoader extends StatefulWidget {
  const _SkeletonLoader();

  @override
  State<_SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<_SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final shade = Color.lerp(_shimmer1, _shimmer2, _anim.value)!;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _SkeletonGroupLabel(color: shade),
            for (int i = 0; i < 3; i++) _SkeletonCard(color: shade),
            _SkeletonGroupLabel(color: shade),
            for (int i = 0; i < 2; i++) _SkeletonCard(color: shade),
          ],
        );
      },
    );
  }
}

class _SkeletonGroupLabel extends StatelessWidget {
  final Color color;
  const _SkeletonGroupLabel({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Container(
        height: 11,
        width: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final Color color;
  const _SkeletonCard({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 36,
                      height: 11,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 13,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 11,
                  width: 180,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
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
