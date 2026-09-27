import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../services/app_lock_service.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({
    super.key,
    required this.onUnlocked,
  });

  final VoidCallback onUnlocked;

  @override
  State<AppLockScreen> createState() =>
      _AppLockScreenState();
}

class _AppLockScreenState
    extends State<AppLockScreen> {
  final AppLockService _lockService =
      AppLockService.instance;

  final TextEditingController _pinController =
      TextEditingController();

  bool _isLoading = true;
  bool _isUnlocking = false;
  bool _biometricsEnabled = false;
  bool _biometricsAvailable = false;
  bool _showPinInput = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _prepareScreen();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _lockService.stopAuthentication();

    super.dispose();
  }

  Future<void> _prepareScreen() async {
    final bool biometricsEnabled =
        await _lockService.isBiometricsEnabled();

    final bool biometricsAvailable =
        await _lockService.canUseBiometrics();

    if (!mounted) {
      return;
    }

    setState(() {
      _biometricsEnabled = biometricsEnabled;
      _biometricsAvailable = biometricsAvailable;
      _isLoading = false;
      _showPinInput =
          !biometricsEnabled || !biometricsAvailable;
    });

    if (biometricsEnabled && biometricsAvailable) {
      await _unlockWithBiometrics();
    }
  }

  Future<void> _unlockWithBiometrics() async {
    setState(() {
      _isUnlocking = true;
      _errorMessage = null;
    });

    final bool unlocked =
        await _lockService.authenticateWithBiometrics();

    if (!mounted) {
      return;
    }

    setState(() {
      _isUnlocking = false;
    });

    if (unlocked) {
      widget.onUnlocked();
      return;
    }

    setState(() {
      _showPinInput = true;
      _errorMessage =
          'لم يتم التحقق بالبصمة. استخدم الرمز السري.';
    });
  }

  Future<void> _unlockWithPin() async {
    final String pin = _pinController.text.trim();

    if (pin.isEmpty) {
      setState(() {
        _errorMessage = 'أدخل الرمز السري.';
      });
      return;
    }

    setState(() {
      _isUnlocking = true;
      _errorMessage = null;
    });

    final bool unlocked =
        await _lockService.verifyPinCode(pin);

    if (!mounted) {
      return;
    }

    setState(() {
      _isUnlocking = false;
    });

    if (unlocked) {
      widget.onUnlocked();
      return;
    }

    setState(() {
      _pinController.clear();
      _errorMessage = 'الرمز السري غير صحيح.';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.emerald.withValues(
                        alpha: 0.14,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 48,
                      color: AppColors.emerald,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'محاسبي الشامل مقفل',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'تحقق بالبصمة أو أدخل الرمز السري للوصول إلى بياناتك.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 26),
                  if (_biometricsEnabled &&
                      _biometricsAvailable &&
                      !_showPinInput)
                    FilledButton.icon(
                      onPressed: _isUnlocking
                          ? null
                          : _unlockWithBiometrics,
                      icon: const Icon(
                        Icons.fingerprint_rounded,
                      ),
                      label: const Text(
                        'فتح بالبصمة',
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          54,
                        ),
                      ),
                    ),
                  if (_biometricsEnabled &&
                      _biometricsAvailable &&
                      !_showPinInput)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showPinInput = true;
                        });
                      },
                      child: const Text(
                        'استخدام الرمز السري',
                      ),
                    ),
                  if (_showPinInput) ...<Widget>[
                    TextField(
                      controller: _pinController,
                      obscureText: true,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        _unlockWithPin();
                      },
                      decoration: const InputDecoration(
                        labelText: 'الرمز السري',
                        hintText: 'أدخل رمز التطبيق',
                        prefixIcon: Icon(
                          Icons.password_rounded,
                        ),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _isUnlocking
                          ? null
                          : _unlockWithPin,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          54,
                        ),
                      ),
                      child: _isUnlocking
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'فتح التطبيق',
                            ),
                    ),
                    if (_biometricsEnabled &&
                        _biometricsAvailable)
                      TextButton.icon(
                        onPressed: _isUnlocking
                            ? null
                            : _unlockWithBiometrics,
                        icon: const Icon(
                          Icons.fingerprint_rounded,
                        ),
                        label: const Text(
                          'استخدام البصمة',
                        ),
                      ),
                  ],
                  if (_errorMessage != null) ...<Widget>[
                    const SizedBox(height: 14),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
