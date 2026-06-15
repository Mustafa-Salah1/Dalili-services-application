import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../service/presentation/providers/service_provider.dart';
import '../../../service/presentation/providers/service_state.dart';

import '../providers/provider_application_provider.dart';
import '../providers/provider_application_state.dart';
import 'package:geolocator/geolocator.dart';

class ApplyProviderScreen extends ConsumerStatefulWidget {
  const ApplyProviderScreen({super.key});

  @override
  ConsumerState<ApplyProviderScreen> createState() =>
      _ApplyProviderScreenState();
}

class _ApplyProviderScreenState extends ConsumerState<ApplyProviderScreen> {
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final descriptionController = TextEditingController();

  int? selectedServiceId;
  String? selectedServiceTitle;
  Position? _position;
  bool _locationLoading = false;
  String? _locationError;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(serviceProvider.notifier).getServices();
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    cityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError = null;
      _position = null;
    });
    try {
      final pos = await getCurrentLocation();
      setState(() {
        _position = pos;
        _locationLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _locationLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _validationError = null);

    if (selectedServiceId == null) {
      setState(() => _validationError = 'Please select a service category.');
      return;
    }
    if (_position == null) {
      setState(() => _validationError = 'Please fetch your location first.');
      return;
    }

    try {
      await ref
          .read(providerApplicationProvider.notifier)
          .createApplication(
            phone: phoneController.text.trim(),
            city: cityController.text.trim(),
            description: descriptionController.text.trim(),
            serviceId: selectedServiceId!,
            latitude: _position!.latitude,
            longitude: _position!.longitude,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceState = ref.watch(serviceProvider);
    final appState = ref.watch(providerApplicationProvider);

    ref.listen<ProviderApplicationState>(providerApplicationProvider, (
      _,
      next,
    ) {
      if (next is ProviderApplicationSuccess) {
        _showSuccessDialog();
      }
      if (next is ProviderApplicationError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    final isSubmitting = appState is ProviderApplicationLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 28),

                    _buildStepProgress(),
                    const SizedBox(height: 28),

                    _sectionLabel(
                      icon: Icons.contact_phone_outlined,
                      title: 'Contact Information',
                    ),
                    const SizedBox(height: 14),
                    _styledField(
                      controller: phoneController,
                      label: 'Phone Number',
                      hint: 'e.g. +970 59 000 0000',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    _styledField(
                      controller: cityController,
                      label: 'City',
                      hint: 'e.g. Nablus, Ramallah…',
                      icon: Icons.location_city_outlined,
                    ),

                    const SizedBox(height: 28),

                    _sectionLabel(
                      icon: Icons.person_pin_outlined,
                      title: 'Provider Information',
                    ),
                    const SizedBox(height: 14),
                    _styledField(
                      controller: descriptionController,
                      label: 'About You',
                      hint: 'Tell clients about your experience and skills…',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 28),

                    _sectionLabel(
                      icon: Icons.category_outlined,
                      title: 'Service Category',
                    ),
                    const SizedBox(height: 14),
                    _buildServiceSelector(serviceState),

                    const SizedBox(height: 28),

                    _sectionLabel(
                      icon: Icons.my_location_rounded,
                      title: 'Your Location',
                    ),
                    const SizedBox(height: 14),
                    _buildLocationCard(),

                    if (_validationError != null) ...[
                      const SizedBox(height: 16),
                      _buildValidationError(_validationError!),
                    ],

                    const SizedBox(height: 28),

                    _buildBenefitsCard(),

                    const SizedBox(height: 28),

                    _buildSubmitButton(isSubmitting),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Application Submitted!',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your provider application is under review.\nWe\'ll notify you once it\'s approved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // go back
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F766E).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Back to Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Become a Provider',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Join our trusted service network',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFCCFBF1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'New',
              style: TextStyle(
                color: Color(0xFF0F766E),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🚀 Start Earning Today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Grow Your\nBusiness with Us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect with hundreds of\nclients in your area.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.handshake_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    final steps = ['Contact', 'About', 'Service', 'Location'];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isLast = i == steps.length - 1;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        steps[i],
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFFCCFBF1)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildServiceSelector(dynamic serviceState) {
    if (serviceState is! ServiceLoaded) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF0F766E),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Service',
          style: TextStyle(
            color: Color(0xFF475569),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selectedServiceId != null
                  ? const Color(0xFF0F766E)
                  : const Color(0xFFE2E8F0),
              width: selectedServiceId != null ? 1.5 : 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<int>(
              value: selectedServiceId,
              isExpanded: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                prefixIcon: Icon(
                  Icons.category_outlined,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
              hint: const Text(
                'Choose a service category',
                style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              items: serviceState.services
                  .map<DropdownMenuItem<int>>(
                    (service) => DropdownMenuItem<int>(
                      value: service.id,
                      child: Text(
                        service.title,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedServiceId = value;
                  selectedServiceTitle = serviceState.services
                      .firstWhere((s) => s.id == value)
                      .title;
                });
              },
            ),
          ),
        ),

        // Selected badge
        if (selectedServiceTitle != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFBF1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF0F766E),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      selectedServiceTitle!,
                      style: const TextStyle(
                        color: Color(0xFF0F766E),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLocationCard() {
    final hasLocation = _position != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasLocation
              ? const Color(0xFF0F766E)
              : _locationError != null
              ? const Color(0xFFEF4444)
              : const Color(0xFFE2E8F0),
          width: hasLocation || _locationError != null ? 1.5 : 1,
        ),
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasLocation
                      ? const Color(0xFFCCFBF1)
                      : _locationError != null
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  hasLocation
                      ? Icons.location_on_rounded
                      : _locationError != null
                      ? Icons.location_off_rounded
                      : Icons.my_location_rounded,
                  color: hasLocation
                      ? const Color(0xFF0F766E)
                      : _locationError != null
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF94A3B8),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasLocation
                          ? 'Location Detected'
                          : _locationError != null
                          ? 'Location Error'
                          : 'Detect My Location',
                      style: TextStyle(
                        color: hasLocation
                            ? const Color(0xFF0F172A)
                            : _locationError != null
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasLocation
                          ? 'Lat: ${_position!.latitude.toStringAsFixed(4)}, '
                                'Lng: ${_position!.longitude.toStringAsFixed(4)}'
                          : _locationError != null
                          ? _locationError!
                          : 'Tap the button to get your GPS coordinates',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          GestureDetector(
            onTap: _locationLoading ? null : _fetchLocation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                gradient: _locationLoading
                    ? null
                    : hasLocation
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: _locationLoading
                    ? const Color(0xFFCCFBF1)
                    : hasLocation
                    ? const Color(0xFFF0FDF9)
                    : null,
                borderRadius: BorderRadius.circular(12),
                border: hasLocation
                    ? Border.all(color: const Color(0xFF0F766E))
                    : null,
              ),
              child: Center(
                child: _locationLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0F766E),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasLocation
                                ? Icons.refresh_rounded
                                : Icons.gps_fixed_rounded,
                            color: hasLocation
                                ? const Color(0xFF0F766E)
                                : Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasLocation ? 'Update Location' : 'Get My Location',
                            style: TextStyle(
                              color: hasLocation
                                  ? const Color(0xFF0F766E)
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    final perks = [
      (Icons.people_outline_rounded, 'Access hundreds of local clients'),
      (Icons.payments_outlined, 'Get paid securely and on time'),
      (Icons.star_outline_rounded, 'Build your reputation with reviews'),
      (Icons.support_agent_outlined, '24/7 platform support'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCCFBF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFF0F766E),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Why Join Dalili?',
                style: TextStyle(
                  color: Color(0xFF0F766E),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...perks.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(p.$1, color: const Color(0xFF0F766E), size: 16),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    p.$2,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFCCFBF1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0F766E), size: 17),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _styledField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF0F766E),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValidationError(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isSubmitting) {
    return GestureDetector(
      onTap: isSubmitting ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: isSubmitting
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: isSubmitting ? const Color(0xFFCCFBF1) : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSubmitting
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withOpacity(0.38),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF0F766E),
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Submit Application',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
