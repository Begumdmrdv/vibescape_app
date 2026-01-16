import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:vibescape_app/screens/login_screen.dart';
import 'services/stats_service.dart';
import 'services/favorites_service.dart';
import 'services/visited_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await StatsService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesService()),
        ChangeNotifierProvider(
          create: (_) {
            final svc = VisitedService();
            svc.load();
            return svc;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibescape',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D4F8B),
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}
