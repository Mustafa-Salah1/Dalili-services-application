import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/review_provider.dart';
import '../providers/review_state.dart';

class _C {
  static const primary = Color(0xFF0F766E);
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const textDark = Color(0xFF0F172A);
  static const textMid = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  static const star = Color(0xFFF59E0B);
  static const shimmerBase = Color(0xFFEEF2F6);
  static const shimmerHighlight = Color(0xFFF8FAFC);
}

class ProviderReviewsScreen extends ConsumerStatefulWidget {
  final int providerId;
  final String providerName;

  const ProviderReviewsScreen({
    super.key,
    required this.providerId,
    required this.providerName,
  });

  @override
  ConsumerState<ProviderReviewsScreen> createState() =>
      _ProviderReviewsScreenState();
}

class _ProviderReviewsScreenState extends ConsumerState<ProviderReviewsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fabCtrl;
  late final Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();

    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabScale = CurvedAnimation(parent: _fabCtrl, curve: Curves.elasticOut);

    Future.microtask(() {
      ref.read(reviewProvider.notifier).getProviderReviews(widget.providerId);
      _fabCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    super.dispose();
  }

  void _showAddReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddReviewSheet(
        providerId: widget.providerId,
        providerName: widget.providerName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewProvider);

    return Scaffold(
      backgroundColor: _C.background,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: _C.surface,
            border: Border(bottom: BorderSide(color: _C.border, width: 1)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: _C.textDark,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.providerName,
                          style: const TextStyle(
                            color: _C.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Reviews & Ratings',
                          style: TextStyle(
                            color: _C.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: FloatingActionButton.extended(
          onPressed: _showAddReviewSheet,
          backgroundColor: _C.primary,
          elevation: 4,
          icon: const Icon(
            Icons.rate_review_outlined,
            color: Colors.white,
            size: 20,
          ),
          label: const Text(
            'Write a Review',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      body: Builder(
        builder: (context) {
          if (state is ReviewLoading) return const _SkeletonList();

          if (state is ReviewError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 56,
                      color: _C.textMuted.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: _C.textMid, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ReviewLoaded) {
            return CustomScrollView(
              slivers: [
                // Rating summary card
                SliverToBoxAdapter(
                  child: _RatingSummaryCard(
                    average: state.averageRating,
                    reviews: state.reviews,
                  ),
                ),

                // Section header
                if (state.reviews.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        children: [
                          const Text(
                            'All Reviews',
                            style: TextStyle(
                              color: _C.textDark,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _C.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${state.reviews.length}',
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

                // Reviews list or empty state
                state.reviews.isEmpty
                    ? SliverFillRemaining(
                        child: _EmptyState(
                          providerName: widget.providerName,
                          onTap: _showAddReviewSheet,
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return _ReviewCard(
                              review: state.reviews[index],
                              index: index,
                            );
                          }, childCount: state.reviews.length),
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
}

class _RatingSummaryCard extends StatelessWidget {
  final double average;
  final List<dynamic> reviews;

  const _RatingSummaryCard({required this.average, required this.reviews});

  Map<int, int> get _distribution {
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in reviews) {
      final rating = (r.rating as num).round().clamp(1, 5);
      dist[rating] = (dist[rating] ?? 0) + 1;
    }
    return dist;
  }

  @override
  Widget build(BuildContext context) {
    final dist = _distribution;
    final total = reviews.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D6B63), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _C.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: big score
          Column(
            children: [
              Text(
                total == 0 ? '—' : average.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              _StarRow(rating: average, size: 16, color: _C.star),
              const SizedBox(height: 6),
              Text(
                total == 0
                    ? 'No reviews yet'
                    : '$total ${total == 1 ? "review" : "reviews"}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(width: 24),

          // Right: distribution bars
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = dist[star] ?? 0;
                final ratio = total == 0 ? 0.0 : count / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.star_rounded,
                        size: 11,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 5,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 18,
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final dynamic review;
  final int index;
  const _ReviewCard({required this.review, required this.index});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
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

  String get _initials {
    final name = widget.review.username as String? ?? '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color get _avatarColor {
    final colors = [
      const Color(0xFF0F766E),
      const Color(0xFF0369A1),
      const Color(0xFF7C3AED),
      const Color(0xFFB45309),
      const Color(0xFFBE123C),
    ];
    final idx =
        (widget.review.username as String).hashCode.abs() % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final rating = (review.rating as num).toDouble();

    // Try to access createdAt if it exists on the model
    String? dateStr;
    try {
      final dt = review.createdAt as DateTime?;
      if (dt != null) dateStr = _formatDate(dt);
    } catch (_) {}

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _avatarColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name + stars
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.username as String? ?? 'Anonymous',
                          style: const TextStyle(
                            color: _C.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _StarRow(rating: rating, size: 13, color: _C.star),
                      ],
                    ),
                  ),

                  // Date + rating badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _C.star.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: _C.star,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              rating.toStringAsFixed(0),
                              style: const TextStyle(
                                color: Color(0xFFB45309),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (dateStr != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: _C.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              if ((review.comment as String?)?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _C.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    review.comment as String,
                    style: const TextStyle(
                      color: _C.textMid,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).round();
      return '${months}mo ago';
    }
    final years = (diff.inDays / 365).round();
    return '${years}y ago';
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  const _StarRow({
    required this.rating,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final partial = !filled && i < rating;
        return Icon(
          partial
              ? Icons.star_half_rounded
              : filled
              ? Icons.star_rounded
              : Icons.star_outline_rounded,
          size: size,
          color: (filled || partial) ? color : _C.border,
        );
      }),
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
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
        final shimmer = Color.lerp(
          _C.shimmerBase,
          _C.shimmerHighlight,
          _anim.value,
        )!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary skeleton
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: shimmer,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              3,
              (i) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 100,
                decoration: BoxDecoration(
                  color: shimmer,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String providerName;
  final VoidCallback onTap;
  const _EmptyState({required this.providerName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _C.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.reviews_outlined,
                size: 38,
                color: _C.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Reviews Yet',
              style: TextStyle(
                color: _C.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your experience with $providerName.',
              style: const TextStyle(
                color: _C.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D6B63), Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _C.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Write the first review',
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
          ],
        ),
      ),
    );
  }
}

class _AddReviewSheet extends ConsumerStatefulWidget {
  final int providerId;
  final String providerName;
  const _AddReviewSheet({required this.providerId, required this.providerName});

  @override
  ConsumerState<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends ConsumerState<_AddReviewSheet>
    with SingleTickerProviderStateMixin {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  String? _commentError;
  String? _ratingError;

  late final AnimationController _sheetCtrl;
  late final Animation<Offset> _sheetAnim;

  final List<String> _ratingLabels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Great',
    'Excellent',
  ];

  @override
  void initState() {
    super.initState();
    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _sheetAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOutCubic));
    _sheetCtrl.forward();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _sheetCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _ratingError = null;
      _commentError = null;
      if (_rating == 0) {
        _ratingError = 'Please select a star rating';
        valid = false;
      }
      if (_commentCtrl.text.trim().isEmpty) {
        _commentError = 'Please share your experience';
        valid = false;
      }
    });
    return valid;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    await ref
        .read(reviewProvider.notifier)
        .createReview(
          providerId: widget.providerId,
          rating: _rating,
          comment: _commentCtrl.text,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(reviewProvider) is ReviewLoading;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SlideTransition(
      position: _sheetAnim,
      child: Container(
        decoration: const BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 14),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _C.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Write a Review',
                        style: TextStyle(
                          color: _C.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Share your experience with ${widget.providerName}',
                        style: const TextStyle(
                          color: _C.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _C.background,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: _C.textMid,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Star selector
            const Text(
              'Your rating',
              style: TextStyle(
                color: _C.textMid,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final starVal = i + 1;
                final filled = starVal <= _rating;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starVal),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: filled ? _C.star.withOpacity(0.12) : _C.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: filled ? _C.star : _C.border,
                        width: filled ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        filled
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: filled ? _C.star : _C.textMuted,
                        size: 28,
                      ),
                    ),
                  ),
                );
              }),
            ),

            if (_rating > 0) ...[
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _ratingLabels[_rating],
                  key: ValueKey(_rating),
                  style: TextStyle(
                    color: _rating >= 4 ? _C.primary : _C.textMid,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            if (_ratingError != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFEF4444),
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _ratingError!,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Comment field
            const Text(
              'Your comment',
              style: TextStyle(
                color: _C.textMid,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: _C.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _commentError != null
                      ? const Color(0xFFEF4444)
                      : _C.border,
                  width: 1.2,
                ),
              ),
              child: TextField(
                controller: _commentCtrl,
                maxLines: 4,
                style: const TextStyle(
                  color: _C.textDark,
                  fontSize: 14.5,
                  height: 1.5,
                ),
                decoration: const InputDecoration(
                  hintText: 'What did you love or what could be improved?',
                  hintStyle: TextStyle(color: _C.textMuted, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),

            if (_commentError != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFEF4444),
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _commentError!,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Submit button
            GestureDetector(
              onTap: isLoading ? null : _submit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: isLoading
                      ? const LinearGradient(
                          colors: [Color(0xFF94A3B8), Color(0xFFCBD5E1)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF0D6B63), Color(0xFF14B8A6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: _C.primary.withOpacity(0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Submit Review',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
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
