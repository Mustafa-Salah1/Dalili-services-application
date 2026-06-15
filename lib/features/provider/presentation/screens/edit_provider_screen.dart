import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/provider_model.dart';
import '../providers/provider_provider.dart';

const _primary = Color(0xFF0F766E);
const _secondary = Color(0xFF14B8A6);
const _bg = Color(0xFFF8FAFC);
const _surface = Colors.white;
const _textPrimary = Color(0xFF0F172A);
const _textSecondary = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);
const _focusBorder = Color(0xFF0F766E);
const _inputBg = Color(0xFFF8FAFC);

class EditProviderScreen extends ConsumerStatefulWidget {
  final ProviderModel provider;
  const EditProviderScreen({super.key, required this.provider});

  @override
  ConsumerState<EditProviderScreen> createState() => _EditProviderScreenState();
}

class _EditProviderScreenState extends ConsumerState<EditProviderScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController descriptionController;
  late TextEditingController cityController;

  bool isLoading = false;

  late AnimationController _enterController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.provider.name);
    phoneController = TextEditingController(text: widget.provider.phone);
    descriptionController = TextEditingController(
      text: widget.provider.description,
    );
    cityController = TextEditingController(text: widget.provider.city);

    // Rebuild preview on every keystroke
    for (final c in [nameController, cityController]) {
      c.addListener(() => setState(() {}));
    }

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    cityController.dispose();
    _enterController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    setState(() => isLoading = true);

    await ref
        .read(providerProvider.notifier)
        .updateMyProvider(
          name: nameController.text,
          phone: phoneController.text,
          description: descriptionController.text,
          city: cityController.text,
          serviceId: widget.provider.serviceId,
          latitude: widget.provider.latitude,
          longitude: widget.provider.longitude,
        );

    if (!mounted) return;
    setState(() => isLoading = false);

    await _showSuccessDialog();

    if (mounted) Navigator.pop(context);
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SuccessDialog(
        name: nameController.text,
        onDone: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(),

                const SizedBox(height: 20),

                _ProfileCard(
                  name: nameController.text,
                  serviceName: widget.provider.serviceName,
                ),

                const SizedBox(height: 24),

                _SectionLabel(label: 'Business Information'),
                const SizedBox(height: 14),

                _FormField(
                  controller: nameController,
                  label: 'Business Name',
                  hint: 'Enter your business name',
                  icon: Icons.storefront_rounded,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 14),

                _FormField(
                  controller: descriptionController,
                  label: 'Description',
                  hint: 'Describe your services…',
                  icon: Icons.article_rounded,
                  maxLines: 5,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 24),

                _SectionLabel(label: 'Contact Information'),
                const SizedBox(height: 14),

                _FormField(
                  controller: phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 14),

                _FormField(
                  controller: cityController,
                  label: 'City',
                  hint: 'Enter your city',
                  icon: Icons.location_city_rounded,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 24),

                _PreviewCard(
                  name: nameController.text,
                  city: cityController.text,
                  serviceName: widget.provider.serviceName,
                ),

                const SizedBox(height: 32),

                _SaveButton(
                  isLoading: isLoading,
                  onTap: isLoading ? null : saveChanges,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
    backgroundColor: _surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    title: const Text(
      'Edit Provider',
      style: TextStyle(
        color: _textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 17,
        letterSpacing: -0.3,
      ),
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
      child: Container(height: 1, color: _border),
    ),
  );
}

class _PageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Edit Provider Profile',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Manage your business information',
            style: TextStyle(color: _textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String serviceName;

  const _ProfileCard({required this.name, required this.serviceName});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Your Business' : name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    serviceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Edit indicator
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool enabled;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.enabled = true,
  });

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = _focused ? _focusBorder : _border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: _focused ? _primary : _textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.enabled ? _surface : _inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: _focused ? 2 : 1.5),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: _primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Focus(
            onFocusChange: (v) => setState(() => _focused = v),
            child: TextField(
              controller: widget.controller,
              maxLines: widget.maxLines,
              keyboardType: widget.keyboardType,
              enabled: widget.enabled,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  color: Color(0xFFBDC5D1),
                  fontSize: 14,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(top: widget.maxLines > 1 ? 14 : 0),
                  child: Icon(
                    widget.icon,
                    color: _focused ? _primary : _textSecondary,
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: widget.maxLines > 1 ? 14 : 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String name;
  final String city;
  final String serviceName;

  const _PreviewCard({
    required this.name,
    required this.city,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFCFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _secondary.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility_rounded, color: _primary, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Profile Preview',
                style: TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PreviewRow(
            icon: Icons.storefront_rounded,
            value: name.isEmpty ? '—' : name,
          ),
          const SizedBox(height: 8),
          _PreviewRow(icon: Icons.design_services_rounded, value: serviceName),
          const SizedBox(height: 8),
          _PreviewRow(
            icon: Icons.location_city_rounded,
            value: city.isEmpty ? '—' : city,
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _PreviewRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _primary, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _SaveButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isLoading
              ? const LinearGradient(
                  colors: [Color(0xFF94A3B8), Color(0xFF94A3B8)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: _primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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

class _SuccessDialog extends StatefulWidget {
  final String name;
  final VoidCallback onDone;
  const _SuccessDialog({required this.name, required this.onDone});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: _surface,
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Profile Updated!',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.name.isEmpty ? 'Your profile' : widget.name} has been updated successfully.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: widget.onDone,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
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
