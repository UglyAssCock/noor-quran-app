import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/app_state.dart';
import 'screens/quran_reader_screen.dart';
import 'screens/prayer_qibla_screen.dart';
import 'screens/islamic_tools_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.initialize();
  runApp(NoorQuranApp(appState: appState));
}

class NoorQuranApp extends StatefulWidget {
  final AppState appState;
  const NoorQuranApp({super.key, required this.appState});

  @override
  State<NoorQuranApp> createState() => _NoorQuranAppState();
}

class _NoorQuranAppState extends State<NoorQuranApp> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Noor Quran',
      locale: s.isArabicUi ? const Locale('ar') : const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: s.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B3B2E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F5F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B3B2E),
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF071E18),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B3B2E),
          foregroundColor: Color(0xFFD4AF37),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Icons.wb_twilight, color: Color(0xFFD4AF37)),
              const SizedBox(width: 10),
              Text(s.tr('Noor Al-Quran', 'نور القرآن الكريم')),
            ],
          ),
          actions: [
            IconButton(
              tooltip: s.tr('Switch Language', 'تغيير اللغة'),
              icon: const Icon(Icons.language),
              onPressed: s.toggleLanguage,
            ),
            IconButton(
              tooltip: s.tr('Toggle Theme', 'تبديل المظهر'),
              icon: Icon(s.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: s.toggleDarkMode,
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            QuranReaderScreen(appState: s),
            PrayerQiblaScreen(appState: s),
            HifzAndKhatmaScreen(appState: s),
            AzkarAndSettingsScreen(appState: s),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.menu_book),
              label: s.tr('Quran', 'المصحف'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore),
              label: s.tr('Prayer & Qibla', 'الصلاة والقبلة'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.school),
              label: s.tr('Hifz & Khatma', 'الحفظ والختمة'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.spa),
              label: s.tr('Azkar & Settings', 'الأذكار والإعدادات'),
            ),
          ],
        ),
      ),
    );
  }
}
