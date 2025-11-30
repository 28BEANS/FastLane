import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/firebase_options.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'auth/presentation/controllers/auth_controller.dart';
import 'core/controllers/nav_controller.dart';
import 'chatbot/presentation/controllers/chatbot_controller.dart';
import 'checklist/presentation/controllers/checklist_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => NavController()),
        ChangeNotifierProvider(create: (_) => ChecklistController()),
        ChangeNotifierProxyProvider<ChecklistController, ChatbotController>(
          create: (context) =>
              ChatbotController(checklistController: context.read<ChecklistController>()),
          update: (context, checklistController, previous) =>
              previous!..updateChecklistController(checklistController),
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
      title: 'FastLane',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      initialRoute: '/login', // for testing
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
