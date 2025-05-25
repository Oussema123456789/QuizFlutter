import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/pages/login.page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

// --- ThemeProvider existant ---
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode ? darkTheme : lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.transparent,
    primaryColor: Color(0xFF02B8FF),
    textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.black),
    cardColor: Colors.white.withOpacity(0.9),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Color(0xFF02B8FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.transparent,
    primaryColor: Color(0xFF02B8FF),
    textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.white),
    cardColor: Colors.grey[900]?.withOpacity(0.9),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF02B8FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

// --- Nouveau LanguageProvider ---
class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!L10n.supportedLocales.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }
}

// --- Liste des locales supportées ---
class L10n {
  static final supportedLocales = [
    const Locale('en'), // anglais
    const Locale('fr'), // français
    const Locale('ar'), // arabe
  ];
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      locale: languageProvider.locale,
      supportedLocales: L10n.supportedLocales,
      // Pour la localisation complète, tu peux ajouter delegates ici (ex: flutter_localizations)
      home: LoginPage(),
    );
  }
}
