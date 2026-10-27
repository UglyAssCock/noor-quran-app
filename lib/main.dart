import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/app_state.dart';
import 'screens/quran_reader_screen.dart';
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
    final p = s.palette;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quran',
      locale: s.isRtlLanguage ? const Locale('ar') : const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: p.isLight ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: p.bg,
        cardColor: p.card,
        colorScheme: ColorScheme.fromSeed(
          seedColor: p.accent,
          brightness: p.isLight ? Brightness.light : Brightness.dark,
          surface: p.card,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: p.bg,
          foregroundColor: p.textPrimary,
          elevation: 0,
        ),
      ),
      home: Directionality(
        textDirection: s.isRtlLanguage ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: p.bg,
          appBar: AppBar(
            toolbarHeight: 64,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.tr('Quran', 'القرآن الكريم'),
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                ),
                Text(
                  s.tr('Read · Listen · Reflect', 'اقرأ · استمع · تدبر'),
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: s.tr('Switch Language', 'تغيير اللغة'),
                icon: Icon(Icons.language, color: p.textPrimary),
                onPressed: s.toggleLanguage,
              ),
              IconButton(
                tooltip: s.tr('Theme Colors', 'تغيير لون المظهر'),
                icon: Icon(Icons.palette_outlined, color: p.accent),
                onPressed: () {
                  final idx =
                      s.themes.indexWhere((t) => t.id == s.selectedThemeId);
                  final next = s.themes[(idx + 1) % s.themes.length];
                  s.setTheme(next.id);
                },
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              QuranReaderScreen(appState: s),
              AdiyahAndAzkarScreen(appState: s),
              BookmarksAndNotesScreen(appState: s),
              AzkarAndSettingsScreen(appState: s),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: p.card,
              border: Border(top: BorderSide(color: p.border, width: 1)),
            ),
            child: NavigationBar(
              backgroundColor: p.card,
              indicatorColor: p.accent.withOpacity(0.2),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) =>
                  setState(() => _selectedIndex = idx),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined, color: p.textSecondary),
                  selectedIcon: Icon(Icons.menu_book, color: p.accent),
                  label: s.tr('Quran', 'المصحف'),
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.volunteer_activism_outlined,
                    color: p.textSecondary,
                  ),
                  selectedIcon:
                      Icon(Icons.volunteer_activism, color: p.accent),
                  label: s.tr('Ad\'iyah', 'أدعية'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_border, color: p.textSecondary),
                  selectedIcon: Icon(Icons.bookmark, color: p.accent),
                  label: s.tr('Bookmarks', 'المحفوظات'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined, color: p.textSecondary),
                  selectedIcon: Icon(Icons.settings, color: p.accent),
                  label: s.tr('Settings', 'الإعدادات'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
