import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/firebase_options.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FastLane',
      debugShowCheckedModeBanner: false,

      // Theme Setup
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,

      // Routing
      initialRoute: '/login',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
