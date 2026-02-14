import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/elyx_welcome_screen.dart';
import 'screens/brain_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/user_progress_controller.dart';
import 'theme/level_theme.dart';

const bool isTestingOnboarding = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProgressController(),
        ),
      ],
      child: const ElyxApp(),
    ),
  );
}

class ElyxApp extends StatelessWidget {
  const ElyxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProgressController>(
      builder: (context, progress, child) {
        final themeColor = ElyxTheme.color(context);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: themeColor,
              secondary: themeColor,
            ),
          ),
          home: const AppEntry(),
        );
      },
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool? isFirstTime;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();

    if (isTestingOnboarding) {
      await prefs.remove('seen_onboarding');
    }

    final seen = prefs.getBool('seen_onboarding') ?? false;

    if (!seen) {
      await prefs.setBool('seen_onboarding', true);
    }

    if (!mounted) return;

    setState(() {
      isFirstTime = !seen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstTime == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.cyanAccent,
          ),
        ),
      );
    }

    if (isFirstTime!) {
      return const ElyxWelcomeScreen(
        firstTime: true,
        nextScreen: BrainScreen(),
      );
    }

    return const MainNavigationScreen();
  }
}
