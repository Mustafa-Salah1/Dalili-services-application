import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/data/models/provider_model.dart';
import '../providers/request_provider.dart';
import '../providers/request_state.dart';

class _C {
  static const primary = Color(0xFF0F766E);
  static const secondary = Color(0xFF14B8A6);
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const textDark = Color(0xFF0F172A);
  static const textMid = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
}

String _initials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

String _formatDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final wd = days[d.weekday - 1];
  return '$wd, ${months[d.month - 1]} ${d.day}, ${d.year}';
}

String _apiDate(DateTime d) => d.toString().split(' ')[0];

class CreateRequestScreen extends ConsumerStatefulWidget {
  final ProviderModel provider;
  const CreateRequestScreen({super.key, required this.provider});

  @override
  ConsumerState<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen>
    with TickerProviderStateMixin {
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  String? _dateError;
  bool _notesFocused = false;

  // Entrance animations
  late final AnimationController _entranceCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _formFade;
  late final Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _headerFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
          ),
        );
    _formFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _C.primary,
              onPrimary: Colors.white,
              surface: _C.surface,
              onSurface: _C.textDark,
            ),
            dialogBackgroundColor: _C.surface,
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dateError = null;
      });
    }
  }

  void _submit() {
    if (_selectedDate == null) {
      setState(() => _dateError = 'Please choose a service date to continue');
      return;
    }
    setState(() => _dateError = null);
    ref
        .read(requestProvider.notifier)
        .createRequest(
          providerId: widget.provider.id,
          requestDate: _apiDate(_selectedDate!),
          notes: _notesController.text,
        );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        providerName: widget.provider.name,
        date: _selectedDate != null ? _formatDate(_selectedDate!) : '',
        onDone: () {
          Navigator.pop(context); // close dialog
          Navigator.pop(context); // back to previous screen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RequestState>(requestProvider, (previous, next) {
      if (next is RequestSuccess) {
        _showSuccessDialog();
      }
      if (next is RequestError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 17),
                const SizedBox(width: 8),
                Expanded(child: Text(next.message)),
              ],
            ),
            backgroundColor: _C.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });

    final state = ref.watch(requestProvider);
    final isLoading = state is RequestLoading;
    final p = widget.provider;

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
                  const Expanded(
                    child: Text(
                      'Request Service',
                      style: TextStyle(
                        color: _C.textDark,
                        fontSize: 17,
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

      body: SingleChildScrollView(
        child: Column(
          children: [
            FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: _HeaderBanner(provider: p),
              ),
            ),

            FadeTransition(
              opacity: _formFade,
              child: SlideTransition(
                position: _formSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date selection
                      _SectionLabel(
                        icon: Icons.calendar_month_rounded,
                        label: 'Select Date',
                      ),
                      const SizedBox(height: 10),
                      _DateSelector(
                        selectedDate: _selectedDate,
                        error: _dateError,
                        onTap: _pickDate,
                      ),

                      const SizedBox(height: 22),

                      // Notes
                      _SectionLabel(
                        icon: Icons.notes_rounded,
                        label: 'Additional Notes',
                      ),
                      const SizedBox(height: 10),
                      _NotesField(
                        controller: _notesController,
                        focused: _notesFocused,
                        onFocusChange: (f) => setState(() => _notesFocused = f),
                      ),

                      const SizedBox(height: 22),

                      // Summary card — only when date is picked
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SizeTransition(sizeFactor: anim, child: child),
                        ),
                        child: _selectedDate != null
                            ? _SummaryCard(
                                key: const ValueKey('summary'),
                                provider: p,
                                date: _selectedDate!,
                                notes: _notesController.text,
                              )
                            : const SizedBox(key: ValueKey('empty')),
                      ),

                      if (_selectedDate != null) const SizedBox(height: 22),

                      // Submit button
                      _SubmitButton(
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _submit,
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

class _HeaderBanner extends StatelessWidget {
  final ProviderModel provider;
  const _HeaderBanner({required this.provider});

  @override
  Widget build(BuildContext context) {
    // Try optional fields gracefully
    String? city, category;
    try {
      city = provider.city as String?;
    } catch (_) {}
    try {
      category = provider.serviceName as String?;
    } catch (_) {}

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D6B63), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                _initials(provider.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
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
                  provider.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                if (category != null && category.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.home_repair_service_rounded,
                        size: 13,
                        color: Colors.white.withOpacity(0.75),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
                if (city != null && city.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Colors.white.withOpacity(0.75),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        city,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Booking pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
                SizedBox(width: 3),
                Text(
                  'Book Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _C.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: _C.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final String? error;
  final VoidCallback onTap;
  const _DateSelector({
    required this.selectedDate,
    required this.error,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = selectedDate != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: hasDate ? _C.primary.withOpacity(0.04) : _C.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: error != null
                    ? _C.error
                    : hasDate
                    ? _C.primary
                    : _C.border,
                width: hasDate ? 1.8 : 1.2,
              ),
              boxShadow: hasDate
                  ? [
                      BoxShadow(
                        color: _C.primary.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: hasDate
                        ? _C.primary.withOpacity(0.12)
                        : _C.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: hasDate ? _C.primary : _C.textMuted,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Column(
                      key: ValueKey(selectedDate),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasDate ? 'Service Date' : 'Choose a date',
                          style: TextStyle(
                            color: hasDate ? _C.textMuted : _C.textMuted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (hasDate) ...[
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(selectedDate!),
                            style: const TextStyle(
                              color: _C.textDark,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Icon(
                  hasDate
                      ? Icons.edit_calendar_rounded
                      : Icons.chevron_right_rounded,
                  size: 20,
                  color: hasDate ? _C.primary : _C.textMuted,
                ),
              ],
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 13, color: _C.error),
              const SizedBox(width: 5),
              Text(
                error!,
                style: const TextStyle(color: _C.error, fontSize: 12),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NotesField extends StatelessWidget {
  final TextEditingController controller;
  final bool focused;
  final ValueChanged<bool> onFocusChange;
  const _NotesField({
    required this.controller,
    required this.focused,
    required this.onFocusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: focused ? _C.secondary : _C.border,
            width: focused ? 1.8 : 1.2,
          ),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: _C.secondary.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(
            color: _C.textDark,
            fontSize: 14.5,
            height: 1.55,
          ),
          decoration: InputDecoration(
            hintText:
                'Describe what you need, preferred timing, or any special instructions…',
            hintStyle: TextStyle(
              color: _C.textMuted.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ProviderModel provider;
  final DateTime date;
  final String notes;
  const _SummaryCard({
    super.key,
    required this.provider,
    required this.date,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _C.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.primary.withOpacity(0.18), width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 15, color: _C.primary),
              SizedBox(width: 6),
              Text(
                'Booking Summary',
                style: TextStyle(
                  color: _C.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.person_outline_rounded,
            label: 'Provider',
            value: provider.name,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: _formatDate(date),
          ),
          if (notes.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              icon: Icons.notes_rounded,
              label: 'Notes',
              value: notes.trim().length > 60
                  ? '${notes.trim().substring(0, 60)}…'
                  : notes.trim(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: _C.textMuted),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              color: _C.textMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: _C.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  const _SubmitButton({required this.isLoading, required this.onPressed});

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => _pressCtrl.reverse(),
      onTapUp: widget.isLoading
          ? null
          : (_) {
              _pressCtrl.forward();
              widget.onPressed?.call();
            },
      onTapCancel: () => _pressCtrl.forward(),
      child: ScaleTransition(
        scale: _pressCtrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: widget.isLoading
                ? const LinearGradient(
                    colors: [Color(0xFF94A3B8), Color(0xFFCBD5E1)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFF0D6B63), Color(0xFF14B8A6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.isLoading
                ? []
                : [
                    BoxShadow(
                      color: _C.primary.withOpacity(0.32),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
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
                      Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Submit Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
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

class _SuccessDialog extends StatefulWidget {
  final String providerName;
  final String date;
  final VoidCallback onDone;
  const _SuccessDialog({
    required this.providerName,
    required this.date,
    required this.onDone,
  });

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
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
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Check circle
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _C.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: _C.success,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Request Sent!',
                  style: TextStyle(
                    color: _C.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Your request to ${widget.providerName} has been submitted.',
                  style: const TextStyle(
                    color: _C.textMid,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (widget.date.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _C.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _C.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 15,
                          color: _C.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.date,
                          style: const TextStyle(
                            color: _C.textDark,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Done button
                GestureDetector(
                  onTap: widget.onDone,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D6B63), Color(0xFF14B8A6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _C.primary.withOpacity(0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
