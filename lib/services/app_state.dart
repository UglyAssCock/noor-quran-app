import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AyahItem {
  final int surahNumber;
  final String surahNameAr;
  final String surahNameEn;
  final int numberInSurah;
  final int globalNumber;
  final int juz;
  final int page;
  final String textUthmani;
  String translationEn;
  String translationFr;
  String tafsirAr;

  AyahItem({
    required this.surahNumber,
    required this.surahNameAr,
    required this.surahNameEn,
    required this.numberInSurah,
    required this.globalNumber,
    required this.juz,
    required this.page,
    required this.textUthmani,
    this.translationEn = '',
    this.translationFr = '',
    this.tafsirAr = '',
  });

  String get key => '$surahNumber:$numberInSurah';
}

class SurahMeta {
  final int number;
  final String nameAr;
  final String nameEn;
  final String meaningEn;
  final String revelationType;
  final int ayahCount;

  SurahMeta({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.meaningEn,
    required this.revelationType,
    required this.ayahCount,
  });
}

class ReciterOption {
  final String id;
  final String nameEn;
  final String nameAr;
  final String subfolder;

  const ReciterOption({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.subfolder,
  });
}

class AppState extends ChangeNotifier {
  late SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool isInitialized = false;
  bool isDarkMode = false;
  bool isArabicUi = false;
  bool keepScreenOn = true;
  double quranFontSize = 26.0;
  String selectedTranslation = 'en'; // 'en', 'fr', 'ar_tafsir', 'ibn_kathir'

  List<SurahMeta> surahs = [];
  List<AyahItem> allAyahs = [];
  Map<int, List<AyahItem>> surahMap = {};
  Map<int, List<AyahItem>> pageMap = {};
  Map<int, List<AyahItem>> juzMap = {};

  Set<String> bookmarks = {};
  Set<String> favorites = {};
  Set<String> memorizedAyahs = {};
  Map<String, String> ayahNotes = {};

  int lastSurah = 1;
  int lastAyah = 1;
  int lastPage = 1;

  int khatmaDailyGoalPages = 4;
  int khatmaCompletedPages = 0;
  int tasbihCount = 0;

  final List<ReciterOption> reciters = const [
    ReciterOption(
      id: 'alafasy',
      nameEn: 'Mishary Rashid Alafasy',
      nameAr: 'مشاري راشد العفاسي',
      subfolder: 'Alafasy_128kbps',
    ),
    ReciterOption(
      id: 'abdulbasit',
      nameEn: 'AbdulBaset AbdulSamad',
      nameAr: 'عبد الباسط عبد الصمد',
      subfolder: 'Abdul_Basit_Murattal_192kbps',
    ),
    ReciterOption(
      id: 'husary',
      nameEn: 'Mahmoud Khalil Al-Husary',
      nameAr: 'محمود خليل الحصري',
      subfolder: 'Husary_128kbps',
    ),
    ReciterOption(
      id: 'sudais',
      nameEn: 'Abdurrahmaan As-Sudais',
      nameAr: 'عبد الرحمن السديس',
      subfolder: 'Abdurrahmaan_As-Sudais_192kbps',
    ),
  ];

  ReciterOption selectedReciter = const ReciterOption(
    id: 'alafasy',
    nameEn: 'Mishary Rashid Alafasy',
    nameAr: 'مشاري راشد العفاسي',
    subfolder: 'Alafasy_128kbps',
  );

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    isArabicUi = _prefs.getBool('isArabicUi') ?? false;
    keepScreenOn = _prefs.getBool('keepScreenOn') ?? true;
    quranFontSize = _prefs.getDouble('quranFontSize') ?? 26.0;
    selectedTranslation = _prefs.getString('selectedTranslation') ?? 'en';

    bookmarks = (_prefs.getStringList('bookmarks') ?? []).toSet();
    favorites = (_prefs.getStringList('favorites') ?? []).toSet();
    memorizedAyahs = (_prefs.getStringList('memorizedAyahs') ?? []).toSet();

    final notesRaw = _prefs.getString('ayahNotes');
    if (notesRaw != null && notesRaw.isNotEmpty) {
      final decoded = jsonDecode(notesRaw) as Map<String, dynamic>;
      ayahNotes = decoded.map((k, v) => MapEntry(k, v.toString()));
    }

    lastSurah = _prefs.getInt('lastSurah') ?? 1;
    lastAyah = _prefs.getInt('lastAyah') ?? 1;
    lastPage = _prefs.getInt('lastPage') ?? 1;
    khatmaDailyGoalPages = _prefs.getInt('khatmaDailyGoalPages') ?? 4;
    khatmaCompletedPages = _prefs.getInt('khatmaCompletedPages') ?? 0;
    tasbihCount = _prefs.getInt('tasbihCount') ?? 0;

    final savedReciterId = _prefs.getString('selectedReciter') ?? 'alafasy';
    selectedReciter = reciters.firstWhere(
      (r) => r.id == savedReciterId,
      orElse: () => reciters.first,
    );

    if (keepScreenOn) {
      await WakelockPlus.enable();
    }

    await _initNotifications();
    await _loadOfflineQuranBundle();

    isInitialized = true;
    notifyListeners();
  }

  Future<void> _initNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await notificationsPlugin.initialize(initSettings);
  }

  Future<void> triggerInstantReminder(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'noor_quran_channel',
      'Quran & Prayer Notifications',
      channelDescription: 'Daily Quran reminders and Adhan alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await notificationsPlugin.show(100, title, body, details);
  }

  Future<void> _loadOfflineQuranBundle() async {
    try {
      final uthmaniStr =
          await rootBundle.loadString('assets/data/quran_uthmani.json');
      final enStr = await rootBundle.loadString('assets/data/quran_en.json');
      final frStr = await rootBundle.loadString('assets/data/quran_fr.json');
      final tafsirStr =
          await rootBundle.loadString('assets/data/quran_tafsir.json');

      final uthmaniJson = jsonDecode(uthmaniStr);
      final enJson = jsonDecode(enStr);
      final frJson = jsonDecode(frStr);
      final tafsirJson = jsonDecode(tafsirStr);

      final List<dynamic> surahList = uthmaniJson['data']['surahs'];
      final List<dynamic> enSurahs = enJson['data']['surahs'];
      final List<dynamic> frSurahs = frJson['data']['surahs'];
      final List<dynamic> tafsirSurahs = tafsirJson['data']['surahs'];

      surahs.clear();
      allAyahs.clear();
      surahMap.clear();
      pageMap.clear();
      juzMap.clear();

      for (int s = 0; s < surahList.length; s++) {
        final sObj = surahList[s];
        final sNum = sObj['number'] as int;
        final sNameAr = sObj['name'] as String;
        final sNameEn = sObj['englishName'] as String;
        final sMeaning = sObj['englishNameTranslation'] as String;
        final sRev = sObj['revelationType'] as String;
        final List<dynamic> ayahsRaw = sObj['ayahs'];

        surahs.add(
          SurahMeta(
            number: sNum,
            nameAr: sNameAr,
            nameEn: sNameEn,
            meaningEn: sMeaning,
            revelationType: sRev,
            ayahCount: ayahsRaw.length,
          ),
        );

        final List<dynamic> enAyahs = enSurahs[s]['ayahs'];
        final List<dynamic> frAyahs = frSurahs[s]['ayahs'];
        final List<dynamic> tafAyahs = tafsirSurahs[s]['ayahs'];

        final List<AyahItem> currentSurahAyahs = [];

        for (int a = 0; a < ayahsRaw.length; a++) {
          final aObj = ayahsRaw[a];
          final item = AyahItem(
            surahNumber: sNum,
            surahNameAr: sNameAr,
            surahNameEn: sNameEn,
            numberInSurah: aObj['numberInSurah'] as int,
            globalNumber: aObj['number'] as int,
            juz: aObj['juz'] as int,
            page: aObj['page'] as int,
            textUthmani: aObj['text'] as String,
            translationEn: enAyahs[a]['text'] as String,
            translationFr: frAyahs[a]['text'] as String,
            tafsirAr: tafAyahs[a]['text'] as String,
          );

          allAyahs.add(item);
          currentSurahAyahs.add(item);

          pageMap.putIfAbsent(item.page, () => []).add(item);
          juzMap.putIfAbsent(item.juz, () => []).add(item);
        }
        surahMap[sNum] = currentSurahAyahs;
      }
    } catch (e) {
      await _fetchOnlineFallbackSurah(1);
    }
  }

  Future<void> _fetchOnlineFallbackSurah(int surahNum) async {
    try {
      final url = Uri.parse(
        'https://api.alquran.cloud/v1/surah/$surahNum/editions/quran-uthmani,en.sahih,fr.hamidullah,ar.muyassar',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'] as List<dynamic>;
        final uth = data[0];
        final en = data[1];
        final fr = data[2];
        final taf = data[3];
        final List<dynamic> ayahs = uth['ayahs'];
        final List<AyahItem> items = [];
        for (int i = 0; i < ayahs.length; i++) {
          items.add(
            AyahItem(
              surahNumber: surahNum,
              surahNameAr: uth['name'],
              surahNameEn: uth['englishName'],
              numberInSurah: ayahs[i]['numberInSurah'],
              globalNumber: ayahs[i]['number'],
              juz: ayahs[i]['juz'],
              page: ayahs[i]['page'],
              textUthmani: ayahs[i]['text'],
              translationEn: en['ayahs'][i]['text'],
              translationFr: fr['ayahs'][i]['text'],
              tafsirAr: taf['ayahs'][i]['text'],
            ),
          );
        }
        surahMap[surahNum] = items;
        allAyahs = List.from(items);
        notifyListeners();
      }
    } catch (_) {}
  }

  String audioUrlForAyah(int surahNumber, int ayahNumber) {
    final sPad = surahNumber.toString().padLeft(3, '0');
    final aPad = ayahNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/${selectedReciter.subfolder}/$sPad$aPad.mp3';
  }

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    _prefs.setBool('isDarkMode', isDarkMode);
    notifyListeners();
  }

  void toggleLanguage() {
    isArabicUi = !isArabicUi;
    _prefs.setBool('isArabicUi', isArabicUi);
    notifyListeners();
  }

  void toggleKeepScreenOn() {
    keepScreenOn = !keepScreenOn;
    _prefs.setBool('keepScreenOn', keepScreenOn);
    if (keepScreenOn) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
    notifyListeners();
  }

  void updateFontSize(double value) {
    quranFontSize = value;
    _prefs.setDouble('quranFontSize', value);
    notifyListeners();
  }

  void setTranslationEdition(String edition) {
    selectedTranslation = edition;
    _prefs.setString('selectedTranslation', edition);
    notifyListeners();
  }

  void setReciter(ReciterOption reciter) {
    selectedReciter = reciter;
    _prefs.setString('selectedReciter', reciter.id);
    notifyListeners();
  }

  void saveLastRead({
    required int surah,
    required int ayah,
    required int page,
  }) {
    lastSurah = surah;
    lastAyah = ayah;
    lastPage = page;
    _prefs.setInt('lastSurah', surah);
    _prefs.setInt('lastAyah', ayah);
    _prefs.setInt('lastPage', page);
    notifyListeners();
  }

  void toggleBookmark(String key) {
    if (bookmarks.contains(key)) {
      bookmarks.remove(key);
    } else {
      bookmarks.add(key);
    }
    _prefs.setStringList('bookmarks', bookmarks.toList());
    notifyListeners();
  }

  void toggleFavorite(String key) {
    if (favorites.contains(key)) {
      favorites.remove(key);
    } else {
      favorites.add(key);
    }
    _prefs.setStringList('favorites', favorites.toList());
    notifyListeners();
  }

  void toggleMemorized(String key) {
    if (memorizedAyahs.contains(key)) {
      memorizedAyahs.remove(key);
    } else {
      memorizedAyahs.add(key);
    }
    _prefs.setStringList('memorizedAyahs', memorizedAyahs.toList());
    notifyListeners();
  }

  void saveNote(String key, String noteText) {
    if (noteText.trim().isEmpty) {
      ayahNotes.remove(key);
    } else {
      ayahNotes[key] = noteText.trim();
    }
    _prefs.setString('ayahNotes', jsonEncode(ayahNotes));
    notifyListeners();
  }

  void updateKhatmaProgress(int pagesCompleted, int dailyGoal) {
    khatmaCompletedPages = pagesCompleted.clamp(0, 604);
    khatmaDailyGoalPages = dailyGoal.clamp(1, 30);
    _prefs.setInt('khatmaCompletedPages', khatmaCompletedPages);
    _prefs.setInt('khatmaDailyGoalPages', khatmaDailyGoalPages);
    notifyListeners();
  }

  void incrementTasbih() {
    tasbihCount++;
    _prefs.setInt('tasbihCount', tasbihCount);
    notifyListeners();
  }

  void resetTasbih() {
    tasbihCount = 0;
    _prefs.setInt('tasbihCount', 0);
    notifyListeners();
  }

  String tr(String en, String ar) => isArabicUi ? ar : en;
}
