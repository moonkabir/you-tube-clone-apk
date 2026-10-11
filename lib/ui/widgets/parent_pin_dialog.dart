import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../state/storage_provider.dart';

class ParentPinDialog extends ConsumerStatefulWidget {
  const ParentPinDialog({super.key});

  @override
  ConsumerState<ParentPinDialog> createState() => _ParentPinDialogState();
}

class _ParentPinDialogState extends ConsumerState<ParentPinDialog> {
  String _enteredPin = '';
  bool _isError = false;

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _isError = false;
        _enteredPin += digit;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _isError = false;
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _verifyPin() {
    final storageService = ref.read(storageServiceProvider);
    final isValid = storageService.verifyPin(_enteredPin);

    if (isValid) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isError = true;
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                size: 36,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Parental Lock',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter your 4-digit PIN to open settings\n(Default: 1234)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),

            // PIN Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isError
                        ? AppColors.vibrantCoral
                        : isFilled
                            ? AppColors.primaryBlue
                            : Colors.grey.shade300,
                    border: Border.all(
                      color: _isError ? AppColors.vibrantCoral : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                );
              }),
            ),

            if (_isError) ...[
              const SizedBox(height: 10),
              const Text(
                'Incorrect PIN. Please try again.',
                style: TextStyle(
                  color: AppColors.vibrantCoral,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Number pad
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Column(
                children: [
                  _buildKeyRow(['1', '2', '3']),
                  const SizedBox(height: 12),
                  _buildKeyRow(['4', '5', '6']),
                  const SizedBox(height: 12),
                  _buildKeyRow(['7', '8', '9']),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.of(context).pop(false),
                      ),
                      _buildNumberKey('0'),
                      _buildActionButton(
                        icon: Icons.backspace_rounded,
                        onTap: _onBackspace,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildNumberKey(d)).toList(),
    );
  }

  Widget _buildNumberKey(String digit) {
    return InkWell(
      onTap: () => _onDigitPressed(digit),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.textDark, size: 22),
      ),
    );
  }
}
