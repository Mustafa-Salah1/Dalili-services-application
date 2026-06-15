import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorite_provider.dart';
import '../providers/favorite_state.dart';
import '../../../provider/presentation/providers/provider_provider.dart';
import '../../../provider/presentation/screens/provider_details_screen.dart';

const _primary = Color(0xFF0F766E);
const _secondary = Color(0xFF14B8A6);
const _bg = Color(0xFFF8FAFC);
const _surface = Color(0xFFFFFFFF);
const _onSurface = Color(0xFF0F172A);
const _textMuted = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);
const _danger = Color(0xFFEF4444);
const _shimmer1 = Color(0xFFE2E8F0);
const _shimmer2 = Color(0xFFF1F5F9);

class MyFavoritesScreen extends ConsumerStatefulWidget {
  const MyFavoritesScreen({super.key});

  @override
  ConsumerState<MyFavoritesScreen> createState() => _MyFavoritesScreenState();
}

class _MyFavoritesScreenState extends ConsumerState<MyFavoritesScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
        );

    Future.microtask(() async {
      await ref.read(favoriteProvider.notifier).getMyFavorites();
      _headerController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoriteProvider);
    final count = state is FavoriteLoaded ? state.favorites.length : 0;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            SlideTransition(
              position: _headerSlide,
              child: FadeTransition(
                opacity: _headerFade,
                child: _FavoritesHeader(count: count),
              ),
            ),

            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(FavoriteState state) {
    if (state is FavoriteLoading) {
      return const _SkeletonLoader();
    }

    if (state is FavoriteLoaded) {
      if (state.favorites.isEmpty) {
        return _EmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: state.favorites.length,
        itemBuilder: (context, index) {
          final favorite = state.favorites[index];

          return _AnimatedFavoriteCard(
            index: index,
            child: Dismissible(
              key: ValueKey(favorite.id),
              direction: DismissDirection.endToStart,
              background: _SwipeDeleteBackground(),
              onDismissed: (_) async {
                await ref
                    .read(favoriteProvider.notifier)
                    .removeFavorite(favorite.providerId);
                await ref.read(favoriteProvider.notifier).getMyFavorites();
                if (mounted) {
                  _showRemovedSnack(favorite.providerName);
                }
              },
              child: GestureDetector(
                onTap: () async {
                  final provider = await ref
                      .read(providerProvider.notifier)
                      .getProviderById(favorite.providerId);
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProviderDetailsScreen(provider: provider),
                      ),
                    );
                  }
                },
                child: _FavoriteCard(favorite: favorite),
              ),
            ),
          );
        },
      );
    }

    return const SizedBox();
  }

  void _showRemovedSnack(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite_border, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('$name removed from favorites'),
          ],
        ),
        backgroundColor: _danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  final int count;
  const _FavoritesHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
          // Back button
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

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Favorites',
                  style: TextStyle(
                    color: _onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if (count > 0)
                  Text(
                    '$count saved provider${count == 1 ? '' : 's'}',
                    style: const TextStyle(color: _textMuted, fontSize: 13),
                  ),
              ],
            ),
          ),

          // Counter badge
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 14,
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
    );
  }
}

class _AnimatedFavoriteCard extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedFavoriteCard({required this.index, required this.child});

  @override
  State<_AnimatedFavoriteCard> createState() => _AnimatedFavoriteCardState();
}

class _AnimatedFavoriteCardState extends State<_AnimatedFavoriteCard>
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
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Stagger by index
    Future.delayed(Duration(milliseconds: widget.index * 70), () {
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
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _FavoriteCard extends StatefulWidget {
  final dynamic favorite;
  const _FavoriteCard({required this.favorite});

  @override
  State<_FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<_FavoriteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
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

  String _initials(String name) {
    return name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();
  }

  // Deterministic color from name
  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF0F766E),
      Color(0xFF0369A1),
      Color(0xFF7C3AED),
      Color(0xFFB45309),
      Color(0xFF065F46),
      Color(0xFF9D174D),
    ];
    return colors[name.codeUnits.first % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final favorite = widget.favorite;
    final avatarColor = _avatarColor(favorite.providerName as String);

    return ScaleTransition(
      scale: _pressScale,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) => _pressCtrl.reverse(),
        onTapCancel: () => _pressCtrl.reverse(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Teal accent strip on the left
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_primary, _secondary],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: avatarColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: avatarColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _initials(favorite.providerName as String),
                            style: TextStyle(
                              color: avatarColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              favorite.providerName,
                              style: const TextStyle(
                                color: _onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Service badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                favorite.serviceName,
                                style: const TextStyle(
                                  color: _primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 13,
                                  color: _secondary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  favorite.city,
                                  style: const TextStyle(
                                    color: _textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Favorite heart + swipe hint
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _danger.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: _danger,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'swipe',
                            style: TextStyle(
                              color: _textMuted,
                              fontSize: 9,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_left_rounded,
                            color: _textMuted,
                            size: 14,
                          ),
                        ],
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

class _SwipeDeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 28),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFCA5A5), _danger]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.delete_rounded, color: Colors.white, size: 24),
          SizedBox(height: 4),
          Text(
            'Remove',
            style: TextStyle(
              color: Colors.white,
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon cluster
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(
                  Icons.favorite_border_rounded,
                  size: 44,
                  color: _primary,
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'No Favorites Yet',
              style: TextStyle(
                color: _onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Providers you save will appear here.\nTap the heart on any profile to save it.',
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
                  shadowColor: _primary.withOpacity(0.3),
                ),
                icon: const Icon(Icons.search_rounded, size: 18),
                label: const Text(
                  'Browse Services',
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
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          itemCount: 5,
          itemBuilder: (_, i) => _SkeletonCard(color: shade),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final Color color;
  const _SkeletonCard({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 11,
                  width: 100,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 10,
                  width: 70,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}
