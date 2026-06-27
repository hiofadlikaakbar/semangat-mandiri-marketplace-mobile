import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'features/auth/login_page.dart';
import 'features/auth/signup_page.dart';
import 'features/cart/cart_page.dart';
import 'features/home/home_page.dart';
import 'features/providers/cart_provider.dart';
import 'features/splash/splash_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint("Background notif: ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  await FirebaseMessaging.instance.requestPermission();

  runApp(const AppProvider());
}

class AppProvider extends StatelessWidget {
  const AppProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks appLinks;
  StreamSubscription<Uri>? sub;

  @override
  void initState() {
    super.initState();

    appLinks = AppLinks();

    _initDeepLink();
  }

  Future<void> _initDeepLink() async {
    final initial = await appLinks.getInitialLink();

    if (initial != null) {
      _handleUri(initial);
    }

    sub = appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    if (uri.scheme != "marketplace") return;
    if (uri.host != "payment") return;

    final status = uri.queryParameters["status"];

    if (status == "success") {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(const SnackBar(content: Text("Pembayaran berhasil")));
    }
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Hio Marketplace UAS',
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/home': (_) => const HomePage(),
        '/cart': (_) => const CartPage(),
      },
    );
  }
}
