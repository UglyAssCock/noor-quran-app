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
  // Starts at 0 -> QuranReaderScreen directly (Home page removed)
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

  void _showStreakOverviewSheet(BuildContext outerContext, AppState s) {
    final p = s.palette;
    final now = DateTime.now();
    final last7Days = List.generate(
      7,
      (i) => now.subtract(Duration(days: 6 - i)),
    );
    const weekdayLabelsEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const weekdayLabelsAr = ['إ', 'ث', 'أ', 'خ', 'ج', 'س', 'ح'];

    showModalBottomSheet(
      context: outerContext,
      backgroundColor: p.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.orangeAccent,
                    size: 36,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${s.streakDays}${s.tr("Day Streak", "أيام متتالية")}',
                          style: TextStyle(
                            color: p.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          s.tr(
                            'Stay consistent with daily Quran reading!',
                            'واظب على قراءة وردك اليومي للحفاظ على سلسلتك!',
                          ),
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: last7Days.map((dt) {
                    final active = s.isDateActiveInStreak(dt);
                    final wIdx = (dt.weekday - 1).clamp(0, 6);
                    final label = s.isRtlLanguage
                        ? weekdayLabelsAr[wIdx]
                        : weekdayLabelsEn[wIdx];
                    return Column(
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              active ? Colors.orangeAccent : p.bg,
                          child: Icon(
                            active
                                ? Icons.local_fire_department_rounded
                                : Icons.circle_outlined,
                            size: 18,
                            color: active ? Colors.black87 : p.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dt.day}',
                          style: TextStyle(
                            color: p.textPrimary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: p.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.border),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${s.bestStreak}',
                            style: TextStyle(
                              color: p.accent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            s.tr('Best Streak', 'أطول سلسلة'),
                            style: TextStyle(
                              color: p.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: p.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.border),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${s.todayPagesRead}',
                            style: TextStyle(
                              color: p.accent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            s.tr('Pages Today', 'صفحات اليوم'),
                            style: TextStyle(
                              color: p.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.accent,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  icon: const Icon(Icons.menu_book_rounded),
                  label: Text(
                    '${s.tr("Resume", "متابعة القراءة")} (${s.tr("Page", "صفحة")} ${s.lastPage})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(outerContext).push(
                      MaterialPageRoute(
                        builder: (_) => ActiveMushafView(
                          appState: s,
                          initialPage: s.lastPage,
                          initialSurah: s.lastSurah,
                          highlightAyah: s.lastAyah,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    final p = s.palette;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Noor Quran',
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
      home: Builder(
        builder: (innerContext) => Scaffold(
          backgroundColor: p.bg,
          appBar: AppBar(
            toolbarHeight: 68,
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
              // Interactive Daily Streak Flame Pill
              GestureDetector(
                onTap: () => _showStreakOverviewSheet(innerContext, s),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orangeAccent.withOpacity(0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.orangeAccent,
                        size: 19,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${s.streakDays}',
                        style: TextStyle(
                          color: p.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
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
              IconButton(
                tooltip: s.tr('Daily Reminder', 'التذكير اليومي'),
                icon: Icon(Icons.notifications_none, color: p.textPrimary),
                onPressed: () {
                  s.triggerInstantReminder(
                    s.tr('Quran — Daily Streak', 'القرآن الكريم — وردك اليومي'),
                    s.tr(
                      'Keep your ${s.streakDays}-day Quran streak alive today!',
                      'حافظ على سلسلتك اليومية (${s.streakDays} أيام) بقراءة وردك اليوم!',
                    ),
                  );
                },
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              QuranReaderScreen(appState: s),
              HifzAndKhatmaScreen(appState: s),
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
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (idx) =>
                  setState(() => _selectedIndex = idx),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined, color: p.textSecondary),
                  selectedIcon: Icon(Icons.menu_book, color: p.accent),
                  label: s.tr('Quran', 'المصحف'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.school_outlined, color: p.textSecondary),
                  selectedIcon: Icon(Icons.school, color: p.accent),
                  label: s.tr('Hifz & Khatmah', 'الحفظ والختمة'),
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.volunteer_activism_outlined,
                    color: p.textSecondary,
                  ),
                  selectedIcon: Icon(
                    Icons.volunteer_activism,
                    color: p.accent,
                  ),
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
