import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/provider_provider.dart';
import '../providers/provider_state.dart';
import 'edit_provider_screen.dart';

const _primary = Color(0xFF0F766E);
const _secondary = Color(0xFF14B8A6);
const _bg = Color(0xFFF8FAFC);
const _surface = Color(0xFFFFFFFF);
const _onSurface = Color(0xFF0F172A);
const _textMuted = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);
const _shimmer1 = Color(0xFFE2E8F0);
const _shimmer2 = Color(0xFFF1F5F9);

class MyProviderScreen extends ConsumerStatefulWidget {
  const MyProviderScreen({super.key});

  @override
  ConsumerState<MyProviderScreen> createState() => _MyProviderScreenState();
}

class _MyProviderScreenState extends ConsumerState<MyProviderScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    Future.microtask(() async {
      await ref.read(providerProvider.notifier).getMyProvider();
      final providerState = ref.read(providerProvider);
      if (providerState is MyProviderLoaded) {
        await ref
            .read(providerProvider.notifier)
            .loadProviderImages(ref, providerState.provider.id);
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> pickAndUploadImage(int providerId) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    await ref
        .read(providerProvider.notifier)
        .uploadCoverImage(providerId: providerId, imagePath: image.path);
    if (mounted) {
      _showSnackBar('Cover image updated successfully', Icons.check_circle);
    }
  }

  Future<void> pickAndUploadGalleryImage(int providerId) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    await ref
        .read(providerProvider.notifier)
        .uploadGalleryImage(providerId: providerId, imagePath: image.path);
    await ref
        .read(providerProvider.notifier)
        .loadProviderImages(ref, providerId);
    if (mounted) {
      _showSnackBar('Work image added to gallery', Icons.photo_library);
    }
  }

  void _showSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: Builder(
        builder: (context) {
          if (state is ProviderLoading) {
            return const _SkeletonLoader();
          }

          if (state is ProviderError) {
            return _ErrorState(message: state.message);
          }

          if (state is MyProviderLoaded) {
            final provider = state.provider;
            final galleryImages = ref.watch(providerImagesProvider);

            return FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  _ProviderSliverHeader(
                    provider: provider,
                    onEditProfile: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditProviderScreen(provider: provider),
                        ),
                      ).then((_) {
                        ref.read(providerProvider.notifier).getMyProvider();
                      });
                    },
                    onUploadCover: () => pickAndUploadImage(provider.id),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Stats row
                        _StatsRow(galleryCount: galleryImages.length),

                        const SizedBox(height: 24),

                        // Quick actions
                        _QuickActions(
                          onUploadGallery: () =>
                              pickAndUploadGalleryImage(provider.id),
                          onUploadCover: () => pickAndUploadImage(provider.id),
                          onEditProfile: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditProviderScreen(provider: provider),
                              ),
                            ).then((_) {
                              ref
                                  .read(providerProvider.notifier)
                                  .getMyProvider();
                            });
                          },
                        ),

                        const SizedBox(height: 28),

                        // Info section
                        _InfoSection(provider: provider),

                        const SizedBox(height: 28),

                        // Gallery section
                        _GallerySection(
                          images: galleryImages,
                          providerId: provider.id,
                          onUpload: () =>
                              pickAndUploadGalleryImage(provider.id),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _ProviderSliverHeader extends StatelessWidget {
  final dynamic provider;
  final VoidCallback onEditProfile;
  final VoidCallback onUploadCover;

  const _ProviderSliverHeader({
    required this.provider,
    required this.onEditProfile,
    required this.onUploadCover,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: _primary,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
          ),
          onPressed: onUploadCover,
          tooltip: 'Change cover',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover image
            if (provider.coverImage != null)
              Image.network(
                'http://10.0.2.2:8080${provider.coverImage}',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _DefaultCoverGradient(),
              )
            else
              _DefaultCoverGradient(),

            // Gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            // Provider identity at bottom of header
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Avatar
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: _secondary,
                    ),
                    child: Center(
                      child: Text(
                        (provider.name as String)
                            .split(' ')
                            .take(2)
                            .map((w) => w.isNotEmpty ? w[0] : '')
                            .join()
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          provider.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Service badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _secondary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                provider.serviceName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 13,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                provider.city,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultCoverGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF14B8A6)],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int galleryCount;
  const _StatsRow({required this.galleryCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
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
      child: Row(
        children: [
          _StatCell(value: '0', label: 'Reviews', icon: Icons.star_rounded),
          _VertDivider(),
          _StatCell(value: '—', label: 'Rating', icon: Icons.thumb_up_rounded),
          _VertDivider(),
          _StatCell(
            value: '$galleryCount',
            label: 'Photos',
            icon: Icons.photo_library_rounded,
          ),
          _VertDivider(),
          _StatCell(value: '0', label: 'Saves', icon: Icons.bookmark_rounded),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: _border);
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatCell({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _primary, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: _onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: _textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onUploadGallery;
  final VoidCallback onUploadCover;
  final VoidCallback onEditProfile;

  const _QuickActions({
    required this.onUploadGallery,
    required this.onUploadCover,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: _onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.edit_rounded,
                label: 'Edit Profile',
                color: _primary,
                onTap: onEditProfile,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionTile(
                icon: Icons.image_rounded,
                label: 'Cover Photo',
                color: const Color(0xFF7C3AED),
                onTap: onUploadCover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionTile(
                icon: Icons.add_photo_alternate_rounded,
                label: 'Add Work',
                color: const Color(0xFF0369A1),
                onTap: onUploadGallery,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
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
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final dynamic provider;
  const _InfoSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Details',
          style: TextStyle(
            color: _onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        // Description card (full-width emphasis)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _primary.withOpacity(0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.format_quote_rounded, color: _primary, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'About',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                provider.description,
                style: const TextStyle(
                  color: _onSurface,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Info tiles grid
        Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.phone_rounded,
                label: 'Phone',
                value: provider.phone,
                isFirst: true,
              ),
              _DividerLine(),
              _InfoRow(
                icon: Icons.design_services_rounded,
                label: 'Service',
                value: provider.serviceName,
              ),
              _DividerLine(),
              _InfoRow(
                icon: Icons.location_city_rounded,
                label: 'City',
                value: provider.city,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(height: 1, color: _border),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, isFirst ? 18 : 14, 18, isLast ? 18 : 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: _onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

class _GallerySection extends StatelessWidget {
  final List<dynamic> images;
  final int providerId;
  final VoidCallback onUpload;

  const _GallerySection({
    required this.images,
    required this.providerId,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Work Gallery',
              style: TextStyle(
                color: _onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (images.isNotEmpty)
              GestureDetector(
                onTap: onUpload,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        if (images.isEmpty)
          _EmptyGallery(onUpload: onUpload)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final image = images[index];
              return _GalleryTile(
                imageUrl: 'http://10.0.2.2:8080${image.imageUrl}',
              );
            },
          ),
      ],
    );
  }
}

class _GalleryTile extends StatefulWidget {
  final String imageUrl;
  const _GalleryTile({required this.imageUrl});

  @override
  State<_GalleryTile> createState() => _GalleryTileState();
}

class _GalleryTileState extends State<_GalleryTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: _shimmer1,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: _shimmer1,
                  child: const Icon(
                    Icons.broken_image,
                    color: _textMuted,
                    size: 32,
                  ),
                ),
              ),
              // Subtle vignette
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.2)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  final VoidCallback onUpload;
  const _EmptyGallery({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, style: BorderStyle.solid),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_library_outlined,
              color: _primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No work photos yet',
            style: TextStyle(
              color: _onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Showcase your best work to attract\nmore clients',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textMuted, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_photo_alternate, size: 18),
              label: const Text(
                'Upload First Photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
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
      duration: const Duration(milliseconds: 1000),
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
      builder: (context, _) {
        final shade = Color.lerp(_shimmer1, _shimmer2, _anim.value)!;
        return SingleChildScrollView(
          child: Column(
            children: [
              // Cover skeleton
              Container(height: 280, color: shade),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _SkeletonBox(height: 100, color: shade, radius: 20),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SkeletonBox(
                            height: 80,
                            color: shade,
                            radius: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SkeletonBox(
                            height: 80,
                            color: shade,
                            radius: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SkeletonBox(
                            height: 80,
                            color: shade,
                            radius: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SkeletonBox(height: 120, color: shade, radius: 18),
                    const SizedBox(height: 16),
                    _SkeletonBox(height: 160, color: shade, radius: 18),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final Color color;
  final double radius;

  const _SkeletonBox({
    required this.height,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade400,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: _onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
