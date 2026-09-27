import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AppLockService {
  AppLockService._();

  static final AppLockService instance = AppLockService._();

  static const String _lockEnabledKey = 'app_lock_enabled';
  static const String _pinCodeKey = 'app_lock_pin_code';
  static const String _biometricsEnabledKey =
      'app_lock_biometrics_enabled';

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  final LocalAuthentication _authentication =
      LocalAuthentication();

  Future<bool> isLockEnabled() async {
    final String? value = await _storage.read(
      key: _lockEnabledKey,
    );

    return value == 'true';
  }

  Future<bool> isBiometricsEnabled() async {
    final String? value = await _storage.read(
      key: _biometricsEnabledKey,
    );

    return value == 'true';
  }

  Future<void> enableLock({
    required String pinCode,
    required bool enableBiometrics,
  }) async {
    await _storage.write(
      key: _lockEnabledKey,
      value: 'true',
    );

    await _storage.write(
      key: _pinCodeKey,
      value: pinCode,
    );

    await _storage.write(
      key: _biometricsEnabledKey,
      value: enableBiometrics ? 'true' : 'false',
    );
  }

  Future<void> disableLock() async {
    await _storage.delete(key: _lockEnabledKey);
    await _storage.delete(key: _pinCodeKey);
    await _storage.delete(key: _biometricsEnabledKey);
  }

  Future<bool> verifyPinCode(
    String pinCode,
  ) async {
    final String? savedPin = await _storage.read(
      key: _pinCodeKey,
    );

    return savedPin != null && savedPin == pinCode;
  }

  Future<bool> canUseBiometrics() async {
    try {
      final bool isSupported =
          await _authentication.isDeviceSupported();

      final bool canCheck =
          await _authentication.canCheckBiometrics;

      final List<BiometricType> types =
          await _authentication.getAvailableBiometrics();

      return isSupported && canCheck && types.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool available = await canUseBiometrics();

      if (!available) {
        return false;
      }

      return await _authentication.authenticate(
        localizedReason:
            'استخدم البصمة أو الوجه لفتح محاسبي الشامل',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> stopAuthentication() async {
    await _authentication.stopAuthentication();
  }
}
