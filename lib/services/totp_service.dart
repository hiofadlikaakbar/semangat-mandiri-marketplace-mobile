import 'dart:math';

class TotpService {
  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  static String generateSecret({int length = 32}) {
    final random = Random.secure();

    return List.generate(
      length,
      (_) => _chars[random.nextInt(_chars.length)],
    ).join();
  }

  static String buildOtpUri({required String email, required String secret}) {
    return 'otpauth://totp/SemangatMandiri:$email'
        '?secret=$secret'
        '&issuer=SemangatMandiri';
  }
}
