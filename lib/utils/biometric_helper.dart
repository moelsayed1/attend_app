import 'package:local_auth/local_auth.dart';

class BiometricHelper {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    final canCheck = await _auth.canCheckBiometrics;
    if (!canCheck) return false;
    return await _auth.authenticate(
      localizedReason: 'Please authenticate to continue',
      options: const AuthenticationOptions(biometricOnly: true),
    );
  }
}