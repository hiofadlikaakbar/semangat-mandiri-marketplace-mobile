import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<String?> getFirebaseToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  static Future<String> sendTokenToBackend(String firebaseToken) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = FirebaseAuth.instance.currentUser;

    final header = {"alg": "HS256", "typ": "JWT"};

    final payload = {
      "uid": user?.uid,
      "email": user?.email,
      "iat": DateTime.now().millisecondsSinceEpoch,
      "exp": DateTime.now()
          .add(const Duration(hours: 1))
          .millisecondsSinceEpoch,
      "iss": "marketplace-app",
    };

    String encode(Map<String, dynamic> data) {
      return base64Url.encode(utf8.encode(jsonEncode(data)));
    }

    final encodedHeader = encode(header);
    final encodedPayload = encode(payload);

    final signature = base64Url.encode(
      utf8.encode("$encodedHeader.$encodedPayload.secret_key"),
    );

    return "$encodedHeader.$encodedPayload.$signature";
  }

  static Future<void> saveJWT(String jwt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("jwt", jwt);
  }

  static Future<String?> getJWT() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt");
  }
}
