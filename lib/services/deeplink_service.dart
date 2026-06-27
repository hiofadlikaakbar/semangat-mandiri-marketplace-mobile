import 'package:url_launcher/url_launcher.dart';

class DeepLinkService {
  static Future<void> openWallet({
    required String orderId,
    required int amount,
    required String merchant,
  }) async {
    final uri = Uri(
      scheme: 'smwallet',
      host: 'pay',
      queryParameters: {
        'orderId': orderId,
        'amount': amount.toString(),
        'merchant': merchant,
      },
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
