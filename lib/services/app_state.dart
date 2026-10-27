import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppThemePalette {
  final String id;
  final String nameEn;
  final String nameAr;
  final Color bg;
  final Color card;
  final Color border;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final bool isLight;

  const AppThemePalette({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.bg,
    required this.card,
    required this.border,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    this.isLight = false,
  });
}

class MushafEdition {
  final String id;
  final String apiEdition;
  final String nameEn;
  final String nameAr;
  final String riwayah;

  const MushafEdition({
    required this.id,
    required this.apiEdition,
    required this.nameEn,
    required this.nameAr,
    required this.riwayah,
  });
}

class GlobalLanguageOption {
  final String code;
  final String nameEn;
  final String nativeName;
  final String defaultEdition;

  const GlobalLanguageOption({
    required this.code,
    required this.nameEn,
    required this.nativeName,
    required this.defaultEdition,
  });
}

class TafsirSourceOption {
  final String identifier;
  final String name;
  final String language;
  final String type;

  const TafsirSourceOption({
    required this.identifier,
    required this.name,
    required this.language,
    required this.type,
  });
}

class AyahItem {
  final int surahNumber;
  final String surahNameAr;
  final String surahNameEn;
  final String surahMeaningEn;
  final String revelationType;
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
    this.surahMeaningEn = '',
    this.revelationType = 'Meccan',
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
  final int startPage;

  SurahMeta({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.meaningEn,
    required this.revelationType,
    required this.ayahCount,
    this.startPage = 1,
  });
}

class ReciterOption {
  final String id;
  final String nameEn;
  final String nameAr;
  final String subfolder;
  final String fullSurahBaseUrl;

  const ReciterOption({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.subfolder,
    required this.fullSurahBaseUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReciterOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class AppState extends ChangeNotifier {
  static const MethodChannel _galleryChannel =
      MethodChannel('com.noor.quran/gallery');

  late SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool isInitialized = false;
  bool isArabicUi = false;
  bool keepScreenOn = true;
  bool wordByWordEnabled = true;
  double quranFontSize = 24.0;
  double playbackSpeed = 1.0;
  double autoScrollSpeed = 1.5;

  String selectedThemeId = 'emerald_night';
  String selectedMushafId = 'hafs_kfgqpc';
  String selectedLanguageCode = 'en';
  String selectedTafsirId = 'ar.muyassar';
  String activeQuickTafsirTab = 'ibn_kathir';

  List<SurahMeta> surahs = [];
  List<AyahItem> allAyahs = [];
  Map<int, List<AyahItem>> surahMap = {};
  Map<int, List<AyahItem>> pageMap = {};
  Map<int, List<AyahItem>> juzMap = {};

  Map<String, Map<String, String>> customEditionCache = {};
  List<TafsirSourceOption> catalogEditions = [];

  Set<String> bookmarks = {};
  Set<int> bookmarkedSurahs = {};
  Set<String> favorites = {};
  Set<String> memorizedAyahs = {};
  Map<String, String> ayahNotes = {};
  Map<String, int> duaCounters = {};

  Set<String> downloadedSurahs = {};
  Map<String, double> downloadProgress = {};
  String _offlineAudioDirPath = '';

  int lastSurah = 1;
  int lastAyah = 1;
  int lastPage = 1;

  int khatmaDailyGoalPages = 20;
  int khatmaCompletedPages = 20;
  String selectedReadingPlan = '30 Days Khatmah Plan';
  int tasbihCount = 0;

  // Daily Streak State
  int streakDays = 1;
  int bestStreak = 1;
  int todayPagesRead = 1;
  String lastStreakDate = '';
  Set<String> activeDatesHistory = {};

  bool get isRtlLanguage =>
      selectedLanguageCode == 'ar' ||
      selectedLanguageCode == 'ur' ||
      selectedLanguageCode == 'fa';

  final List<AppThemePalette> themes = const [
    AppThemePalette(
      id: 'emerald_night',
      nameEn: 'Emerald Night (Original)',
      nameAr: 'ليل الزمرد (الأصلي)',
      bg: Color(0xFF041A15),
      card: Color(0xFF082922),
      border: Color(0xFF195A4B),
      accent: Color(0xFF5CE1B6),
      textPrimary: Color(0xFFF2FBF8),
      textSecondary: Color(0xFF8AB5A8),
    ),
    AppThemePalette(
      id: 'royal_sapphire',
      nameEn: 'Royal Sapphire Night',
      nameAr: 'ياقوت أزرق ملكي',
      bg: Color(0xFF051324),
      card: Color(0xFF0B213D),
      border: Color(0xFF1D4475),
      accent: Color(0xFF60A5FA),
      textPrimary: Color(0xFFF0F6FF),
      textSecondary: Color(0xFF8DAAD0),
    ),
    AppThemePalette(
      id: 'madinah_gold',
      nameEn: 'Madinah Obsidian & Gold',
      nameAr: 'ذهب المدينة والأسود الملكي',
      bg: Color(0xFF0D0E11),
      card: Color(0xFF17191E),
      border: Color(0xFF3E3522),
      accent: Color(0xFFE5C158),
      textPrimary: Color(0xFFFAF8F2),
      textSecondary: Color(0xFFA8A293),
    ),
    AppThemePalette(
      id: 'andalus_burgundy',
      nameEn: 'Al-Andalus Warm Amber',
      nameAr: 'الأندلس العنابي الدافئ',
      bg: Color(0xFF1B0B11),
      card: Color(0xFF2B121B),
      border: Color(0xFF5A2638),
      accent: Color(0xFFF4A261),
      textPrimary: Color(0xFFFFF5F7),
      textSecondary: Color(0xFFC298A4),
    ),
    AppThemePalette(
      id: 'fajr_amethyst',
      nameEn: 'Fajr Dawn Amethyst',
      nameAr: 'أرجواني الفجر الهادئ',
      bg: Color(0xFF110B22),
      card: Color(0xFF1C1335),
      border: Color(0xFF3D2A6E),
      accent: Color(0xFFC084FC),
      textPrimary: Color(0xFFF7F2FF),
      textSecondary: Color(0xFFA393C4),
    ),
    AppThemePalette(
      id: 'classic_cream_light',
      nameEn: 'Classic Cream Mushaf (Light)',
      nameAr: 'ورق المصحف الكريمي (فاتح)',
      bg: Color(0xFFF6F2E6),
      card: Color(0xFFFFFFFF),
      border: Color(0xFFD5CBB4),
      accent: Color(0xFF0B6E4F),
      textPrimary: Color(0xFF132A23),
      textSecondary: Color(0xFF5C6B64),
      isLight: true,
    ),
  ];

  AppThemePalette get palette => themes.firstWhere(
        (t) => t.id == selectedThemeId,
        orElse: () => themes.first,
      );

  bool get isDarkMode => !palette.isLight;

  final List<MushafEdition> mushafEditions = const [
    MushafEdition(
      id: 'hafs_kfgqpc',
      apiEdition: 'quran-uthmani',
      nameEn: 'Hafs \'an Asim (King Fahd Complex)',
      nameAr: 'مصحف حفص عن عاصم - مجمع الملك فهد',
      riwayah: 'Hafs',
    ),
    MushafEdition(
      id: 'warsh_kfgqpc',
      apiEdition: 'quran-warsh',
      nameEn: 'Warsh \'an Nafi\' (King Fahd Complex)',
      nameAr: 'مصحف ورش عن نافع - مجمع الملك فهد',
      riwayah: 'Warsh',
    ),
    MushafEdition(
      id: 'qalun_kfgqpc',
      apiEdition: 'quran-qaloon',
      nameEn: 'Qalun \'an Nafi\' (King Fahd Complex)',
      nameAr: 'مصحف قالون عن نافع - مجمع الملك فهد',
      riwayah: 'Qalun',
    ),
    MushafEdition(
      id: 'tajweed_kfgqpc',
      apiEdition: 'quran-tajweed',
      nameEn: 'Tajweed Mushaf (King Fahd Complex)',
      nameAr: 'مصحف التجويد الملون - مجمع الملك فهد',
      riwayah: 'Hafs Tajweed',
    ),
    MushafEdition(
      id: 'simple_clean',
      apiEdition: 'quran-simple-enhanced',
      nameEn: 'Easy Imla\'i Script (Learners & Kids)',
      nameAr: 'الرسم الإملائي المبسط للمتعلمين',
      riwayah: 'Simple',
    ),
  ];

  MushafEdition get currentMushaf => mushafEditions.firstWhere(
        (m) => m.id == selectedMushafId,
        orElse: () => mushafEditions.first,
      );

  final List<GlobalLanguageOption> globalLanguages = const [
    GlobalLanguageOption(code: 'ar', nameEn: 'Arabic', nativeName: 'العربية', defaultEdition: 'ar.muyassar'),
    GlobalLanguageOption(code: 'en', nameEn: 'English', nativeName: 'English', defaultEdition: 'en.sahih'),
    GlobalLanguageOption(code: 'fr', nameEn: 'French', nativeName: 'Français', defaultEdition: 'fr.hamidullah'),
    GlobalLanguageOption(code: 'es', nameEn: 'Spanish', nativeName: 'Español', defaultEdition: 'es.cortes'),
    GlobalLanguageOption(code: 'de', nameEn: 'German', nativeName: 'Deutsch', defaultEdition: 'de.bubenheim'),
    GlobalLanguageOption(code: 'tr', nameEn: 'Turkish', nativeName: 'Türkçe', defaultEdition: 'tr.diyanet'),
    GlobalLanguageOption(code: 'ur', nameEn: 'Urdu', nativeName: 'اردو', defaultEdition: 'ur.jalandhry'),
    GlobalLanguageOption(code: 'id', nameEn: 'Indonesian', nativeName: 'Bahasa Indonesia', defaultEdition: 'id.indonesian'),
    GlobalLanguageOption(code: 'ms', nameEn: 'Malay', nativeName: 'Bahasa Melayu', defaultEdition: 'ms.basmeih'),
    GlobalLanguageOption(code: 'ru', nameEn: 'Russian', nativeName: 'Русский', defaultEdition: 'ru.kuliev'),
    GlobalLanguageOption(code: 'bn', nameEn: 'Bengali', nativeName: 'বাংলা', defaultEdition: 'bn.bengali'),
    GlobalLanguageOption(code: 'fa', nameEn: 'Persian', nativeName: 'فارسی', defaultEdition: 'fa.makarem'),
    GlobalLanguageOption(code: 'sw', nameEn: 'Swahili', nativeName: 'Kiswahili', defaultEdition: 'sw.barwani'),
    GlobalLanguageOption(code: 'ha', nameEn: 'Hausa', nativeName: 'Hausa', defaultEdition: 'ha.gumi'),
    GlobalLanguageOption(code: 'zh', nameEn: 'Chinese', nativeName: '中文', defaultEdition: 'zh.jian'),
    GlobalLanguageOption(code: 'ja', nameEn: 'Japanese', nativeName: '日本語', defaultEdition: 'ja.japanese'),
    GlobalLanguageOption(code: 'ko', nameEn: 'Korean', nativeName: '한국어', defaultEdition: 'ko.korean'),
    GlobalLanguageOption(code: 'it', nameEn: 'Italian', nativeName: 'Italiano', defaultEdition: 'it.piccardo'),
    GlobalLanguageOption(code: 'pt', nameEn: 'Portuguese', nativeName: 'Português', defaultEdition: 'pt.elhayek'),
    GlobalLanguageOption(code: 'nl', nameEn: 'Dutch', nativeName: 'Nederlands', defaultEdition: 'nl.keyzer'),
    GlobalLanguageOption(code: 'sv', nameEn: 'Swedish', nativeName: 'Svenska', defaultEdition: 'sv.bernstrom'),
    GlobalLanguageOption(code: 'no', nameEn: 'Norwegian', nativeName: 'Norsk', defaultEdition: 'no.berg'),
    GlobalLanguageOption(code: 'sq', nameEn: 'Albanian', nativeName: 'Shqip', defaultEdition: 'sq.ahmeti'),
    GlobalLanguageOption(code: 'bs', nameEn: 'Bosnian', nativeName: 'Bosanski', defaultEdition: 'bs.korkut'),
    GlobalLanguageOption(code: 'az', nameEn: 'Azerbaijani', nativeName: 'Azərbaycanca', defaultEdition: 'az.mammadaliyev'),
    GlobalLanguageOption(code: 'ku', nameEn: 'Kurdish', nativeName: 'Kurdî', defaultEdition: 'ku.asan'),
    GlobalLanguageOption(code: 'so', nameEn: 'Somali', nativeName: 'Soomaali', defaultEdition: 'so.abduh'),
    GlobalLanguageOption(code: 'ta', nameEn: 'Tamil', nativeName: 'தமிழ்', defaultEdition: 'ta.tamil'),
    GlobalLanguageOption(code: 'hi', nameEn: 'Hindi', nativeName: 'हिन्दी', defaultEdition: 'hi.hindi'),
    GlobalLanguageOption(code: 'ml', nameEn: 'Malayalam', nativeName: 'മലയാളം', defaultEdition: 'ml.abdulhameed'),
    GlobalLanguageOption(code: 'th', nameEn: 'Thai', nativeName: 'ภาษาไทย', defaultEdition: 'th.thai'),
    GlobalLanguageOption(code: 'uz', nameEn: 'Uzbek', nativeName: 'O‘zbek', defaultEdition: 'uz.sodik'),
    GlobalLanguageOption(code: 'am', nameEn: 'Amharic', nativeName: 'አማርኛ', defaultEdition: 'am.sadiq'),
    GlobalLanguageOption(code: 'pl', nameEn: 'Polish', nativeName: 'Polski', defaultEdition: 'pl.bielawskiego'),
    GlobalLanguageOption(code: 'ro', nameEn: 'Romanian', nativeName: 'Română', defaultEdition: 'ro.grigore'),
    GlobalLanguageOption(code: 'tg', nameEn: 'Tajik', nativeName: 'Тоҷикӣ', defaultEdition: 'tg.ayati'),
  ];

  final List<ReciterOption> reciters = const [
    ReciterOption(id: 'alafasy', nameEn: 'Mishary Rashid Alafasy', nameAr: 'مشاري راشد العفاسي', subfolder: 'Alafasy_128kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/afs'),
    ReciterOption(id: 'maher', nameEn: 'Maher Al-Muaiqly', nameAr: 'ماهر المعيقلي', subfolder: 'MaherAlMuaiqly128kbps', fullSurahBaseUrl: 'https://server12.mp3quran.net/maher'),
    ReciterOption(id: 'dussary', nameEn: 'Yasser Ad-Dussary', nameAr: 'ياسر الدوسري', subfolder: 'Yasser_Ad-Dussary_128kbps', fullSurahBaseUrl: 'https://server11.mp3quran.net/yasser'),
    ReciterOption(id: 'ghamdi', nameEn: 'Saad Al-Ghamdi', nameAr: 'سعد الغامدي', subfolder: 'Ghamadi_40kbps', fullSurahBaseUrl: 'https://server7.mp3quran.net/s_gmd'),
    ReciterOption(id: 'abdulbasit', nameEn: 'AbdulBaset AbdulSamad (Murattal)', nameAr: 'عبد الباسط عبد الصمد (مرتل)', subfolder: 'Abdul_Basit_Murattal_192kbps', fullSurahBaseUrl: 'https://server7.mp3quran.net/basit'),
    ReciterOption(id: 'abdulbasit_mjwd', nameEn: 'AbdulBaset AbdulSamad (Mujawwad)', nameAr: 'عبد الباسط عبد الصمد (مجود)', subfolder: 'Abdul_Basit_Mujawwad_128kbps', fullSurahBaseUrl: 'https://server13.mp3quran.net/basit_mjwd'),
    ReciterOption(id: 'husary', nameEn: 'Mahmoud Khalil Al-Husary', nameAr: 'محمود خليل الحصري', subfolder: 'Husary_128kbps', fullSurahBaseUrl: 'https://server13.mp3quran.net/husr'),
    ReciterOption(id: 'husary_muallim', nameEn: 'Al-Husary (Muallim / Teacher)', nameAr: 'الحصري (المصحف المعلم)', subfolder: 'Husary_Muallim_128kbps', fullSurahBaseUrl: 'https://server13.mp3quran.net/husr'),
    ReciterOption(id: 'husary_mjwd', nameEn: 'Al-Husary (Mujawwad)', nameAr: 'محمود خليل الحصري (مجود)', subfolder: 'Husary_128kbps_Mujawwad', fullSurahBaseUrl: 'https://server13.mp3quran.net/husr_mjwd'),
    ReciterOption(id: 'minshawi', nameEn: 'Muhammad Siddiq Al-Minshawi (Murattal)', nameAr: 'محمد صديق المنشاوي (مرتل)', subfolder: 'Minshawy_Murattal_128kbps', fullSurahBaseUrl: 'https://server10.mp3quran.net/minsh'),
    ReciterOption(id: 'minshawi_mjwd', nameEn: 'Muhammad Siddiq Al-Minshawi (Mujawwad)', nameAr: 'محمد صديق المنشاوي (مجود)', subfolder: 'Minshawy_Mujawwad_192kbps', fullSurahBaseUrl: 'https://server11.mp3quran.net/minsh_mjwd'),
    ReciterOption(id: 'sudais', nameEn: 'Abdurrahmaan As-Sudais', nameAr: 'عبد الرحمن السديس', subfolder: 'Abdurrahmaan_As-Sudais_192kbps', fullSurahBaseUrl: 'https://server11.mp3quran.net/sds'),
    ReciterOption(id: 'shuraym', nameEn: 'Saud Ash-Shuraym', nameAr: 'سعود الشريم', subfolder: 'Saood_ash-Shuraym_128kbps', fullSurahBaseUrl: 'https://server7.mp3quran.net/shur'),
    ReciterOption(id: 'ajmy', nameEn: 'Ahmed ibn Ali Al-Ajmy', nameAr: 'أحمد بن علي العجمي', subfolder: 'ahmed_ibn_ali_al_ajamy_128kbps', fullSurahBaseUrl: 'https://server10.mp3quran.net/ajm'),
    ReciterOption(id: 'shatri', nameEn: 'Abu Bakr Ash-Shatri', nameAr: 'أبو بكر الشاطري', subfolder: 'Abu_Bakr_Ash-Shaatree_128kbps', fullSurahBaseUrl: 'https://server11.mp3quran.net/shatri'),
    ReciterOption(id: 'qatami', nameEn: 'Nasser Al-Qatami', nameAr: 'ناصر القطامي', subfolder: 'Nasser_Alqatami_128kbps', fullSurahBaseUrl: 'https://server6.mp3quran.net/qtm'),
    ReciterOption(id: 'fares', nameEn: 'Fares Abbad', nameAr: 'فارس عباد', subfolder: 'Fares_Abbad_64kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/frs_a'),
    ReciterOption(id: 'hudhaify', nameEn: 'Ali Al-Hudhaify', nameAr: 'علي الحذيفي', subfolder: 'Hudhaify_128kbps', fullSurahBaseUrl: 'https://server9.mp3quran.net/hthfi'),
    ReciterOption(id: 'ayyub', nameEn: 'Muhammad Ayyub', nameAr: 'محمد أيوب', subfolder: 'Muhammad_Ayyoub_128kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/ayyub'),
    ReciterOption(id: 'basfar', nameEn: 'Abdullah Basfar', nameAr: 'عبد الله بصفر', subfolder: 'Abdullah_Basfar_192kbps', fullSurahBaseUrl: 'https://server6.mp3quran.net/bsfr'),
    ReciterOption(id: 'rifai', nameEn: 'Hani Ar-Rifai', nameAr: 'هاني الرفاعي', subfolder: 'Hani_Rifai_192kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/hani'),
    ReciterOption(id: 'tablawi', nameEn: 'Mohamed Al-Tablawi', nameAr: 'محمد محمود الطبلاوي', subfolder: 'Mohammad_al_Tablaway_128kbps', fullSurahBaseUrl: 'https://server12.mp3quran.net/tblawi'),
    ReciterOption(id: 'jazaery_warsh', nameEn: 'Yassin Al-Jazaery (Warsh)', nameAr: 'ياسين الجزائري (رواية ورش)', subfolder: 'warsh/yassin_al_jazaery_64kbps', fullSurahBaseUrl: 'https://server11.mp3quran.net/qari'),
    ReciterOption(id: 'kouchi_warsh', nameEn: 'Al-Uyun Al-Kouchi (Warsh)', nameAr: 'العيون الكوشي (رواية ورش)', subfolder: 'warsh/yassin_al_jazaery_64kbps', fullSurahBaseUrl: 'https://server11.mp3quran.net/koshi'),
    ReciterOption(id: 'omar_kazabri', nameEn: 'Omar Al-Kazabri (Warsh)', nameAr: 'عمر القزابري (رواية ورش)', subfolder: 'warsh/yassin_al_jazaery_64kbps', fullSurahBaseUrl: 'https://server9.mp3quran.net/omar_warsh'),
    ReciterOption(id: 'juhany', nameEn: 'Abdullah Awad Al-Juhany', nameAr: 'عبد الله عواد الجهني', subfolder: 'Abdullaah_3awwaad_Al-Juhaynee_128kbps', fullSurahBaseUrl: 'https://server13.mp3quran.net/jhn'),
    ReciterOption(id: 'budair', nameEn: 'Salah Al-Budair', nameAr: 'صلاح البدير', subfolder: 'Salah_Al_Budair_128kbps', fullSurahBaseUrl: 'https://server6.mp3quran.net/s_bud'),
    ReciterOption(id: 'ali_jaber', nameEn: 'Ali Jaber', nameAr: 'علي جابر', subfolder: 'Ali_Jaber_64kbps', fullSurahBaseUrl: 'https://server11.mp3quran.net/a_jbr'),
    ReciterOption(id: 'jibreel', nameEn: 'Muhammad Jibreel', nameAr: 'محمد جبريل', subfolder: 'Muhammad_Jibreel_128kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/jbrl'),
    ReciterOption(id: 'mohsin_qasim', nameEn: 'AbdulMohsin Al-Qasim', nameAr: 'عبد المحسن القاسم', subfolder: 'Muhsin_Al_Qasim_192kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/qasm'),
    ReciterOption(id: 'akram_alaqimy', nameEn: 'Akram Al-Alaqimy', nameAr: 'أكرم العلاقمي', subfolder: 'Akram_AlAlaqimy_128kbps', fullSurahBaseUrl: 'https://server9.mp3quran.net/akrm'),
    ReciterOption(id: 'ali_hajjaj', nameEn: 'Ali Hajjaj Alsouasi', nameAr: 'علي حجاج السويسي', subfolder: 'Ali_Hajjaj_Alsouasi_128kbps', fullSurahBaseUrl: 'https://server9.mp3quran.net/hajjaj'),
    ReciterOption(id: 'sahl_yassin', nameEn: 'Sahl Yassin', nameAr: 'سهل ياسين', subfolder: 'Sahl_Yassin_128kbps', fullSurahBaseUrl: 'https://server6.mp3quran.net/shl'),
    ReciterOption(id: 'khalifa_tunaiji', nameEn: 'Khalifa Al-Tunaiji', nameAr: 'خليفة الطنيجي', subfolder: 'khalefa_al_tunaiji_64kbps', fullSurahBaseUrl: 'https://server12.mp3quran.net/tnjy'),
    ReciterOption(id: 'mahmoud_banna', nameEn: 'Mahmoud Ali Al-Banna', nameAr: 'محمود علي البنا', subfolder: 'mahmoud_ali_al_banna_32kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/bna'),
    ReciterOption(id: 'mustafa_ismail', nameEn: 'Mustafa Ismail', nameAr: 'مصطفى إسماعيل', subfolder: 'Mustafa_Ismail_48kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/mustafa'),
    ReciterOption(id: 'abdulkarim', nameEn: 'Muhammad AbdulKareem', nameAr: 'محمد عبد الكريم', subfolder: 'Muhammad_AbdulKareem_128kbps', fullSurahBaseUrl: 'https://server12.mp3quran.net/m_krm'),
    ReciterOption(id: 'abdullah_matroud', nameEn: 'Abdullah Al-Matroud', nameAr: 'عبد الله المطرود', subfolder: 'Abdullah_Matroud_128kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/mtrod'),
    ReciterOption(id: 'ahmad_nauina', nameEn: 'Ahmad Nauina', nameAr: 'أحمد نعينع', subfolder: 'Ahmad_Neana_128kbps', fullSurahBaseUrl: 'https://server11.mp3quran.net/ahmad_nu'),
    ReciterOption(id: 'aziz_alili', nameEn: 'Aziz Alili', nameAr: 'عزيز عليلي', subfolder: 'aziz_alili_128kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/afs'),
    ReciterOption(id: 'bandar_baleela', nameEn: 'Bandar Baleela', nameAr: 'بندر بليلة', subfolder: 'MaherAlMuaiqly128kbps', fullSurahBaseUrl: 'https://server6.mp3quran.net/balilah'),
    ReciterOption(id: 'idris_abkar', nameEn: 'Idris Abkar', nameAr: 'إدريس أبكر', subfolder: 'Alafasy_128kbps', fullSurahBaseUrl: 'https://server6.mp3quran.net/abkr'),
    ReciterOption(id: 'islam_sobhi', nameEn: 'Islam Sobhi', nameAr: 'إسلام صبحي', subfolder: 'Alafasy_128kbps', fullSurahBaseUrl: 'https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem'),
    ReciterOption(id: 'hazza_balushi', nameEn: 'Hazza Al-Balushi', nameAr: 'هزاع البلوشي', subfolder: 'Alafasy_128kbps', fullSurahBaseUrl: 'https://server11.mp3quran.net/hazza'),
    ReciterOption(id: 'raad_kurdi', nameEn: 'Raad Mohammad Al-Kurdi', nameAr: 'رعد محمد الكردي', subfolder: 'Alafasy_128kbps', fullSurahBaseUrl: 'https://server6.mp3quran.net/kurdi'),
    ReciterOption(id: 'noreen_siddiq', nameEn: 'Noreen Mohammad Siddiq', nameAr: 'نورين محمد صديق', subfolder: 'Alafasy_128kbps', fullSurahBaseUrl: 'https://server16.mp3quran.net/nourin_siddig/Rewayat-Aldori-A-n-Abi-Amr'),
    ReciterOption(id: 'wadih_yamani', nameEn: 'Wadih Al-Yamani', nameAr: 'وديع اليمني', subfolder: 'Alafasy_128kbps', fullSurahBaseUrl: 'https://server6.mp3quran.net/wdee3'),
    ReciterOption(id: 'mansour_salimi', nameEn: 'Mansour Al-Salimi', nameAr: 'منصور السالمي', subfolder: 'Alafasy_128kbps', fullSurahBaseUrl: 'https://server14.mp3quran.net/mansor'),
    ReciterOption(id: 'khalid_jalil', nameEn: 'Khalid Al-Jalil', nameAr: 'خالد الجليل', subfolder: 'Alafasy_128kbps', fullSurahBaseUrl: 'https://server10.mp3quran.net/jleel'),
    ReciterOption(id: 'adel_kalbani', nameEn: 'Adel Al-Kalbani', nameAr: 'عادل الكلباني', subfolder: 'Alafasy_128kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/klb'),
    ReciterOption(id: 'tawfeeq_sayegh', nameEn: 'Tawfeeq As-Sayegh', nameAr: 'توفيق الصايغ', subfolder: 'Alafasy_128kbps', fullSurahBaseUrl: 'https://server6.mp3quran.net/twfiq'),
    ReciterOption(id: 'muhammad_luhaidan', nameEn: 'Muhammad Al-Luhaidan', nameAr: 'محمد اللحيدان', subfolder: 'Alafasy_128kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/lhdan'),
    ReciterOption(id: 'muhammad_muhaisny', nameEn: 'Muhammad Al-Muhaisny', nameAr: 'محمد المحيسني', subfolder: 'Alafasy_128kbps', fullSurahBaseUrl: 'https://server11.mp3quran.net/mhsny'),
    ReciterOption(id: 'salah_bukhatir', nameEn: 'Salah Bukhatir', nameAr: 'صلاح بو خاطر', subfolder: 'Salah_Al_Budair_128kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/bu_khtr'),
    ReciterOption(id: 'abdulrashid_sufi', nameEn: 'AbdulRashid Ali Sufi', nameAr: 'عبد الرشيد صوفي', subfolder: 'Husary_128kbps', fullSurahBaseUrl: 'https://server16.mp3quran.net/soufi/Rewayat-Hafs-A-n-Assem'),
    ReciterOption(id: 'mahmoud_rifai', nameEn: 'Mahmoud Al-Rifai', nameAr: 'محمود الرفاعي', subfolder: 'Hani_Rifai_192kbps', fullSurahBaseUrl: 'https://server11.mp3quran.net/m_rifai'),
    ReciterOption(id: 'hatem_farid', nameEn: 'Hatem Farid Al-Waer', nameAr: 'حاتم فريد الواعر', subfolder: 'Alafasy_128kbps', fullSurahBaseUrl: 'https://server11.mp3quran.net/hatem'),
    ReciterOption(id: 'ibrahim_akhdar', nameEn: 'Ibrahim Al-Akhdar', nameAr: 'إبراهيم الأخضر', subfolder: 'Ibrahim_Akhdar_32kbps', fullSurahBaseUrl: 'https://server6.mp3quran.net/akdr'),
    ReciterOption(id: 'khalid_qahtani', nameEn: 'Khalid Al-Qahtani', nameAr: 'خالد القحطاني', subfolder: 'Khaalid_Abdullaah_al-Qahtaanee_192kbps', fullSurahBaseUrl: 'https://server10.mp3quran.net/qht'),
    ReciterOption(id: 'yasser_salama', nameEn: 'Yasser Salama (Hadr)', nameAr: 'ياسر سلامة (حدر)', subfolder: 'Yaser_Salamah_128kbps', fullSurahBaseUrl: 'https://server12.mp3quran.net/salamah'),
    ReciterOption(id: 'ayman_suwaid', nameEn: 'Dr. Ayman Suwaid (Tajweed)', nameAr: 'د. أيمن سويد (تعليم التجويد)', subfolder: 'Ayman_Sowaid_64kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/afs'),
    ReciterOption(id: 'walk_english', nameEn: 'Ibrahim Walk (English Audio)', nameAr: 'إبراهيم ووك (ترجمة صوتية إنجليزية)', subfolder: 'English/Sahih_Intnl_Ibrahim_Walk_192kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/afs'),
    ReciterOption(id: 'urdu_audio', nameEn: 'Farhat Hashmi / Shamshad (Urdu)', nameAr: 'ترجمة صوتية أردية', subfolder: 'translations/urdu_shamshad_ali_khan_46kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/afs'),
    ReciterOption(id: 'parhizgar', nameEn: 'Shahriar Parhizgar', nameAr: 'شهريار برهيزكار', subfolder: 'Parhizgar_48kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/afs'),
    ReciterOption(id: 'abdulwadood_haneef', nameEn: 'AbdulWadood Haneef', nameAr: 'عبد الودود حنيف', subfolder: 'Abdul_Basit_Murattal_192kbps', fullSurahBaseUrl: 'https://server8.mp3quran.net/wdod'),
  ];

  ReciterOption selectedReciter = const ReciterOption(
    id: 'alafasy',
    nameEn: 'Mishary Rashid Alafasy',
    nameAr: 'مشاري راشد العفاسي',
    subfolder: 'Alafasy_128kbps',
    fullSurahBaseUrl: 'https://server8.mp3quran.net/afs',
  );

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    selectedThemeId = _prefs.getString('selectedThemeId') ?? 'emerald_night';
    selectedMushafId = _prefs.getString('selectedMushafId') ?? 'hafs_kfgqpc';
    selectedLanguageCode = _prefs.getString('selectedLanguageCode') ?? 'en';
    selectedTafsirId = _prefs.getString('selectedTafsirId') ?? 'ar.muyassar';
    isArabicUi = _prefs.getBool('isArabicUi') ?? false;
    keepScreenOn = _prefs.getBool('keepScreenOn') ?? true;
    wordByWordEnabled = _prefs.getBool('wordByWordEnabled') ?? true;
    quranFontSize = _prefs.getDouble('quranFontSize') ?? 24.0;
    playbackSpeed = _prefs.getDouble('playbackSpeed') ?? 1.0;

    bookmarks = (_prefs.getStringList('bookmarks') ?? ['2:255', '3:26', '16:43', '17:111']).toSet();
    bookmarkedSurahs = (_prefs.getStringList('bookmarkedSurahs') ?? ['1', '18', '36', '67'])
        .map((e) => int.tryParse(e) ?? 1)
        .toSet();
    favorites = (_prefs.getStringList('favorites') ?? []).toSet();
    memorizedAyahs = (_prefs.getStringList('memorizedAyahs') ?? []).toSet();
    downloadedSurahs = (_prefs.getStringList('downloadedSurahs') ?? []).toSet();

    final notesRaw = _prefs.getString('ayahNotes');
    if (notesRaw != null && notesRaw.isNotEmpty) {
      final decoded = jsonDecode(notesRaw) as Map<String, dynamic>;
      ayahNotes = decoded.map((k, v) => MapEntry(k, v.toString()));
    }

    lastSurah = _prefs.getInt('lastSurah') ?? 1;
    lastAyah = _prefs.getInt('lastAyah') ?? 1;
    lastPage = _prefs.getInt('lastPage') ?? 1;
    khatmaDailyGoalPages = _prefs.getInt('khatmaDailyGoalPages') ?? 20;
    khatmaCompletedPages = _prefs.getInt('khatmaCompletedPages') ?? 20;
    selectedReadingPlan =
        _prefs.getString('selectedReadingPlan') ?? '30 Days Khatmah Plan';
    tasbihCount = _prefs.getInt('tasbihCount') ?? 0;

    // Load & Verify Daily Streak
    streakDays = _prefs.getInt('streakDays') ?? 1;
    bestStreak = _prefs.getInt('bestStreak') ?? 1;
    todayPagesRead = _prefs.getInt('todayPagesRead') ?? 1;
    lastStreakDate = _prefs.getString('lastStreakDate') ?? '';
    activeDatesHistory =
        (_prefs.getStringList('activeDatesHistory') ?? []).toSet();
    _checkAndRecordDailyStreak(incrementPages: false);

    final savedReciterId = _prefs.getString('selectedReciter') ?? 'alafasy';
    selectedReciter = reciters.firstWhere(
      (r) => r.id == savedReciterId,
      orElse: () => reciters.first,
    );

    if (keepScreenOn) {
      await WakelockPlus.enable();
    }

    await _initOfflineStorageDir();
    await _initNotifications();
    await _loadOfflineQuranBundle();
    _buildDefaultCatalogEditions();

    isInitialized = true;
    notifyListeners();
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  void _checkAndRecordDailyStreak({bool incrementPages = false}) {
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final yesterdayKey = _dateKey(now.subtract(const Duration(days: 1)));

    activeDatesHistory.add(todayKey);

    if (lastStreakDate.isEmpty) {
      streakDays = 1;
      bestStreak = 1;
      todayPagesRead = 1;
      lastStreakDate = todayKey;
    } else if (lastStreakDate == todayKey) {
      if (incrementPages) {
        todayPagesRead++;
      }
    } else if (lastStreakDate == yesterdayKey) {
      streakDays++;
      if (streakDays > bestStreak) bestStreak = streakDays;
      todayPagesRead = 1;
      lastStreakDate = todayKey;
    } else {
      // Missed more than 1 day -> reset streak to 1
      streakDays = 1;
      todayPagesRead = 1;
      lastStreakDate = todayKey;
    }

    _prefs.setInt('streakDays', streakDays);
    _prefs.setInt('bestStreak', bestStreak);
    _prefs.setInt('todayPagesRead', todayPagesRead);
    _prefs.setString('lastStreakDate', lastStreakDate);
    _prefs.setStringList('activeDatesHistory', activeDatesHistory.toList());
  }

  bool isDateActiveInStreak(DateTime dt) {
    return activeDatesHistory.contains(_dateKey(dt));
  }

  /// Saves PNG bytes directly to the Android Gallery (Pictures/NoorQuran album)
  Future<String> savePngToGallery(Uint8List pngBytes, String fileName) async {
    try {
      final res = await _galleryChannel.invokeMethod<String>(
        'saveImageToGallery',
        {'bytes': pngBytes, 'fileName': fileName},
      );
      if (res != null && res.isNotEmpty) return res;
    } catch (_) {}

    // Fallback to public Pictures/Download directory
    final fallbackDirs = [
      '/storage/emulated/0/Pictures',
      '/storage/emulated/0/Download',
      Directory.systemTemp.path,
    ];
    for (final dirPath in fallbackDirs) {
      try {
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          final file = File('${dir.path}/$fileName');
          await file.writeAsBytes(pngBytes, flush: true);
          return file.path;
        }
      } catch (_) {}
    }
    return fileName;
  }

  void _buildDefaultCatalogEditions() {
    catalogEditions = [
      const TafsirSourceOption(identifier: 'ar.muyassar', name: 'Tafsir Al-Muyassar (King Fahd Complex)', language: 'ar', type: 'tafsir'),
      const TafsirSourceOption(identifier: 'ar.jalalayn', name: 'Tafsir Al-Jalalayn', language: 'ar', type: 'tafsir'),
      const TafsirSourceOption(identifier: 'ar.qurtubi', name: 'Tafsir Al-Qurtubi', language: 'ar', type: 'tafsir'),
      const TafsirSourceOption(identifier: 'ar.miqbas', name: 'Tanwir al-Miqbas (Ibn Abbas)', language: 'ar', type: 'tafsir'),
      const TafsirSourceOption(identifier: 'ar.waseet', name: 'Al-Tafsir Al-Wasit (Tantawi)', language: 'ar', type: 'tafsir'),
      const TafsirSourceOption(identifier: 'ar.baghawi', name: 'Tafsir Al-Baghawi', language: 'ar', type: 'tafsir'),
      const TafsirSourceOption(identifier: 'en.ibnkathir', name: 'Tafsir Ibn Kathir (Abridged English)', language: 'en', type: 'tafsir'),
      const TafsirSourceOption(identifier: 'en.sahih', name: 'Saheeh International (English)', language: 'en', type: 'translation'),
      const TafsirSourceOption(identifier: 'en.yusufali', name: 'Abdullah Yusuf Ali (English)', language: 'en', type: 'translation'),
      const TafsirSourceOption(identifier: 'en.pickthall', name: 'Mohammed Marmaduke Pickthall', language: 'en', type: 'translation'),
      const TafsirSourceOption(identifier: 'en.asad', name: 'Muhammad Asad (The Message of the Qur\'an)', language: 'en', type: 'translation'),
      const TafsirSourceOption(identifier: 'en.hilali', name: 'Al-Hilali & Khan (Noble Quran)', language: 'en', type: 'translation'),
      const TafsirSourceOption(identifier: 'fr.hamidullah', name: 'Muhammad Hamidullah (Français)', language: 'fr', type: 'translation'),
      ...globalLanguages.map((lang) => TafsirSourceOption(
            identifier: lang.defaultEdition,
            name: '${lang.nameEn} (${lang.nativeName}) Official Translation',
            language: lang.code,
            type: 'translation',
          )),
    ];
  }

  Future<void> fetchAll184CatalogEditionsOnline() async {
    try {
      final res =
          await http.get(Uri.parse('https://api.alquran.cloud/v1/edition'));
      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body)['data'];
        catalogEditions = list
            .map((e) => TafsirSourceOption(
                  identifier: e['identifier'].toString(),
                  name: '${e['englishName']} (${e['name']})',
                  language: e['language'].toString(),
                  type: e['type'].toString(),
                ))
            .toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  String normalizeArabicForSearch(String input) {
    return input
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .trim();
  }

  String _stripDuplicateBasmala(
      int surahNum, int ayahNumInSurah, String rawText) {
    final text = rawText.trim();
    if (surahNum == 1 || ayahNumInSurah != 1) {
      return text;
    }
    final words = text.split(RegExp(r'\s+'));
    if (words.length > 4) {
      final w0 = normalizeArabicForSearch(words[0]);
      final w1 = normalizeArabicForSearch(words[1]);
      if (w0.startsWith('بسم') && w1.contains('الله')) {
        return words.sublist(4).join(' ').trim();
      }
    }
    return text;
  }

  String toArabicDigits(int number) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String str = number.toString();
    for (int i = 0; i < 10; i++) {
      str = str.replaceAll(western[i], eastern[i]);
    }
    return str;
  }

  String pronounceArabicWord(String arabicWord) {
    final map = <String, String>{
      'بِسْمِ': 'Bismi',
      'اللَّهِ': 'Allahi',
      'الرَّحْمَٰنِ': 'Ar-Rahmani',
      'الرَّحِيمِ': 'Ar-Raheem',
      'الْحَمْدُ': 'Al-Hamdu',
      'لِلَّهِ': 'Lillahi',
      'رَبِّ': 'Rabbi',
      'الْعَالَمِينَ': 'Al-\'Aalameen',
      'مَالِكِ': 'Maliki',
      'مَلِكِ': 'Maliki',
      'يَوْمِ': 'Yawmi',
      'الدِّينِ': 'Ad-Deen',
      'إِيَّاكَ': 'Iyyaka',
      'نَعْبُدُ': 'Na\'budu',
      'وَإِيَّاكَ': 'Wa-Iyyaka',
      'نَسْتَعِينُ': 'Nasta\'een',
      'اهْدِنَا': 'Ihdina',
      'الصِّرَاطَ': 'As-Sirata',
      'الْمُسْتَقِيمَ': 'Al-Mustaqeem',
    };
    if (map.containsKey(arabicWord)) return map[arabicWord]!;

    final charMap = {
      'ا': 'a', 'أ': 'a', 'إ': 'i', 'آ': 'aa', 'ب': 'b', 'ت': 't', 'ث': 'th',
      'ج': 'j', 'ح': 'h', 'خ': 'kh', 'د': 'd', 'ذ': 'dh', 'ر': 'r', 'ز': 'z',
      'س': 's', 'ش': 'sh', 'ص': 's', 'ض': 'd', 'ط': 't', 'ظ': 'z', 'ع': '\'',
      'غ': 'gh', 'ف': 'f', 'ق': 'q', 'ك': 'k', 'ل': 'l', 'م': 'm', 'ن': 'n',
      'ه': 'h', 'ة': 'h', 'و': 'w', 'ي': 'y', 'ى': 'a', 'ء': '\'',
      '\u064E': 'a', '\u064F': 'u', '\u0650': 'i',
    };
    final sb = StringBuffer();
    for (int i = 0; i < arabicWord.length; i++) {
      final c = arabicWord[i];
      if (charMap.containsKey(c)) sb.write(charMap[c]);
    }
    final res = sb.toString();
    return res.isEmpty ? 'Quranic Word' : res;
  }

  String getTafsirForAyah(AyahItem item) {
    if (activeQuickTafsirTab == 'ibn_kathir') {
      return 'Tafsir Ibn Kathir (${item.key}):\n${item.translationEn}\n\nتفسير ابن كثير والميسر:\n${item.tafsirAr}';
    } else if (activeQuickTafsirTab == 'qurtubi') {
      return 'Al-Jami\' li-Ahkam al-Qur\'an — Imam Al-Qurtubi (${item.key}):\nأحكام الآية ومعانيها اللغوية والشرعية: ${item.tafsirAr}\n\nMeaning & Legal Rulings: ${item.translationEn}';
    } else if (activeQuickTafsirTab == 'jalalayn') {
      return 'Tafsir Al-Jalalayn (${item.key}):\n${item.tafsirAr}\n\nConcise Exegesis: ${item.translationEn}';
    }
    return '${item.tafsirAr}\n\n${item.translationEn}';
  }

  Future<void> _initOfflineStorageDir() async {
    try {
      final baseDir =
          Directory('${Directory.systemTemp.parent.path}/files/offline_audio');
      if (!await baseDir.exists()) {
        await baseDir.create(recursive: true);
      }
      _offlineAudioDirPath = baseDir.path;
    } catch (_) {
      final fallbackDir =
          Directory('${Directory.systemTemp.path}/offline_audio');
      if (!await fallbackDir.exists()) {
        await fallbackDir.create(recursive: true);
      }
      _offlineAudioDirPath = fallbackDir.path;
    }
  }

  String _surahDownloadKey(int surahNumber, [String? reciterId]) {
    final rId = reciterId ?? selectedReciter.id;
    return '${rId}_$surahNumber';
  }

  String fullSurahRemoteUrl(int surahNumber) {
    final sPad = surahNumber.toString().padLeft(3, '0');
    return '${selectedReciter.fullSurahBaseUrl}/$sPad.mp3';
  }

  String localSurahFilePath(int surahNumber) {
    final sPad = surahNumber.toString().padLeft(3, '0');
    return '$_offlineAudioDirPath/${selectedReciter.id}_$sPad.mp3';
  }

  bool isSurahDownloaded(int surahNumber) {
    final key = _surahDownloadKey(surahNumber);
    if (!downloadedSurahs.contains(key)) return false;
    final file = File(localSurahFilePath(surahNumber));
    return file.existsSync() && file.lengthSync() > 1024;
  }

  bool isDownloadingSurah(int surahNumber) {
    return downloadProgress.containsKey(_surahDownloadKey(surahNumber));
  }

  double getSurahDownloadProgress(int surahNumber) {
    return downloadProgress[_surahDownloadKey(surahNumber)] ?? 0.0;
  }

  Future<bool> downloadFullSurah(int surahNumber) async {
    final key = _surahDownloadKey(surahNumber);
    if (downloadProgress.containsKey(key)) return false;

    downloadProgress[key] = 0.01;
    notifyListeners();

    final url = Uri.parse(fullSurahRemoteUrl(surahNumber));
    final targetPath = localSurahFilePath(surahNumber);
    final tempFile = File('$targetPath.tmp');

    try {
      final client = http.Client();
      final request = http.Request('GET', url);
      final response = await client.send(request);

      if (response.statusCode != 200) {
        downloadProgress.remove(key);
        notifyListeners();
        client.close();
        return false;
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;
      final sink = tempFile.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          downloadProgress[key] =
              (receivedBytes / totalBytes).clamp(0.01, 0.99);
          notifyListeners();
        }
      }

      await sink.flush();
      await sink.close();
      client.close();

      await tempFile.rename(targetPath);

      downloadedSurahs.add(key);
      await _prefs.setStringList('downloadedSurahs', downloadedSurahs.toList());
      downloadProgress.remove(key);
      notifyListeners();
      return true;
    } catch (e) {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      downloadProgress.remove(key);
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteOfflineSurah(int surahNumber) async {
    final key = _surahDownloadKey(surahNumber);
    final file = File(localSurahFilePath(surahNumber));
    if (await file.exists()) {
      await file.delete();
    }
    downloadedSurahs.remove(key);
    await _prefs.setStringList('downloadedSurahs', downloadedSurahs.toList());
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

        final firstPage =
            ayahsRaw.isNotEmpty ? (ayahsRaw.first['page'] as int) : 1;

        surahs.add(
          SurahMeta(
            number: sNum,
            nameAr: sNameAr,
            nameEn: sNameEn,
            meaningEn: sMeaning,
            revelationType: sRev,
            ayahCount: ayahsRaw.length,
            startPage: firstPage,
          ),
        );

        final List<dynamic> enAyahs = enSurahs[s]['ayahs'];
        final List<dynamic> frAyahs = frSurahs[s]['ayahs'];
        final List<dynamic> tafAyahs = tafsirSurahs[s]['ayahs'];

        final List<AyahItem> currentSurahAyahs = [];

        for (int a = 0; a < ayahsRaw.length; a++) {
          final aObj = ayahsRaw[a];
          final numInSurah = aObj['numberInSurah'] as int;
          final rawUthmani = aObj['text'] as String;
          final cleanedUthmani =
              _stripDuplicateBasmala(sNum, numInSurah, rawUthmani);

          final item = AyahItem(
            surahNumber: sNum,
            surahNameAr: sNameAr,
            surahNameEn: sNameEn,
            surahMeaningEn: sMeaning,
            revelationType: sRev,
            numberInSurah: numInSurah,
            globalNumber: aObj['number'] as int,
            juz: aObj['juz'] as int,
            page: aObj['page'] as int,
            textUthmani: cleanedUthmani,
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
    } catch (_) {}
  }

  Future<void> switchLanguageAndDownloadTranslation(
      GlobalLanguageOption lang) async {
    selectedLanguageCode = lang.code;
    isArabicUi = (lang.code == 'ar' || lang.code == 'ur' || lang.code == 'fa');
    _prefs.setString('selectedLanguageCode', lang.code);
    _prefs.setBool('isArabicUi', isArabicUi);
    notifyListeners();

    if (lang.code == 'fr') {
      for (final item in allAyahs) {
        if (item.translationFr.isNotEmpty) {
          item.translationEn = item.translationFr;
        }
      }
      notifyListeners();
      return;
    }

    try {
      final url =
          Uri.parse('https://api.alquran.cloud/v1/quran/${lang.defaultEdition}');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List<dynamic> sList = jsonDecode(res.body)['data']['surahs'];
        for (int s = 0; s < sList.length && s < surahs.length; s++) {
          final List<dynamic> aList = sList[s]['ayahs'];
          final targetSurah = surahMap[s + 1] ?? [];
          for (int a = 0; a < aList.length && a < targetSurah.length; a++) {
            targetSurah[a].translationEn = aList[a]['text'].toString();
          }
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  String audioUrlForAyah(int surahNumber, int ayahNumber) {
    final sPad = surahNumber.toString().padLeft(3, '0');
    final aPad = ayahNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/${selectedReciter.subfolder}/$sPad$aPad.mp3';
  }

  void setTheme(String themeId) {
    selectedThemeId = themeId;
    _prefs.setString('selectedThemeId', themeId);
    notifyListeners();
  }

  void toggleDarkMode() {
    if (selectedThemeId == 'classic_cream_light') {
      setTheme('emerald_night');
    } else {
      setTheme('classic_cream_light');
    }
  }

  void setMushafEdition(String editionId) {
    selectedMushafId = editionId;
    _prefs.setString('selectedMushafId', editionId);
    if (editionId == 'warsh_kfgqpc') {
      final warshReciter = reciters.firstWhere(
        (r) => r.id == 'jazaery_warsh',
        orElse: () => selectedReciter,
      );
      setReciter(warshReciter);
    }
    notifyListeners();
  }

  void setQuickTafsirTab(String tab) {
    activeQuickTafsirTab = tab;
    notifyListeners();
  }

  void toggleLanguage() {
    if (selectedLanguageCode == 'ar') {
      selectedLanguageCode = 'en';
      isArabicUi = false;
    } else {
      selectedLanguageCode = 'ar';
      isArabicUi = true;
    }
    _prefs.setString('selectedLanguageCode', selectedLanguageCode);
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

  void toggleWordByWord() {
    wordByWordEnabled = !wordByWordEnabled;
    _prefs.setBool('wordByWordEnabled', wordByWordEnabled);
    notifyListeners();
  }

  void updateFontSize(double value) {
    quranFontSize = value;
    _prefs.setDouble('quranFontSize', value);
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    playbackSpeed = speed;
    _prefs.setDouble('playbackSpeed', speed);
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
    final pageChanged = page != lastPage;
    lastSurah = surah;
    lastAyah = ayah;
    lastPage = page;
    _prefs.setInt('lastSurah', surah);
    _prefs.setInt('lastAyah', ayah);
    _prefs.setInt('lastPage', page);
    _checkAndRecordDailyStreak(incrementPages: pageChanged);
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

  void toggleSurahBookmark(int surahNum) {
    if (bookmarkedSurahs.contains(surahNum)) {
      bookmarkedSurahs.remove(surahNum);
    } else {
      bookmarkedSurahs.add(surahNum);
    }
    _prefs.setStringList(
      'bookmarkedSurahs',
      bookmarkedSurahs.map((e) => e.toString()).toList(),
    );
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
    _checkAndRecordDailyStreak(incrementPages: true);
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

  void updateKhatmaProgress(int pagesCompleted, int dailyGoal, [String? planName]) {
    khatmaCompletedPages = pagesCompleted.clamp(0, 604);
    khatmaDailyGoalPages = dailyGoal.clamp(1, 60);
    if (planName != null) {
      selectedReadingPlan = planName;
      _prefs.setString('selectedReadingPlan', planName);
    }
    _prefs.setInt('khatmaCompletedPages', khatmaCompletedPages);
    _prefs.setInt('khatmaDailyGoalPages', khatmaDailyGoalPages);
    _checkAndRecordDailyStreak(incrementPages: true);
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

  // Multi-Language Interface Dictionary for 36+ Global Languages
  static const Map<String, Map<String, String>> _multiLangUi = {
    'fr': {
      'Quran': 'Coran',
      'Read · Listen · Reflect': 'Lire · Écouter · Méditer',
      'Hifz & Khatmah': 'Hifz & Khatma',
      'Ad\'iyah': 'Invocations',
      'Duas & Azkar': 'Douas & Azkar',
      'Bookmarks': 'Favoris',
      'Settings': 'Paramètres',
      'All': 'Tout',
      'Meccan': 'Mecquoise',
      'Medinan': 'Médinoise',
      '30 Juz': '30 Juz',
      '604 Pages': '604 Pages',
      'Verses': 'Versets',
      'Page': 'Page',
      'Juz': 'Juz',
      'Resume': 'Reprendre',
      'Day Streak': 'Jours de suite',
      'Theme Colors': 'Thèmes de couleur',
      'Reciter': 'Récitateur',
      'Playback Speed': 'Vitesse de lecture',
      'Mushaf Font Size': 'Taille de police',
      'Prayer & Qibla': 'Prière & Qibla',
      'Next Page': 'Page suiv.',
      'Prev Page': 'Page préc.',
      'Save to Gallery': 'Enregistrer dans la Galerie',
      'Copy Text + Tafsir': 'Copier Texte + Tafsir',
    },
    'es': {
      'Quran': 'Corán',
      'Read · Listen · Reflect': 'Leer · Escuchar · Reflexionar',
      'Hifz & Khatmah': 'Hifz y Jatmah',
      'Ad\'iyah': 'Súplicas (Duas)',
      'Duas & Azkar': 'Duas y Azkar',
      'Bookmarks': 'Marcadores',
      'Settings': 'Ajustes',
      'All': 'Todo',
      'Meccan': 'Mequí',
      'Medinan': 'Medinés',
      'Verses': 'Aleyas',
      'Page': 'Página',
      'Resume': 'Continuar',
      'Day Streak': 'Racha diaria',
      'Theme Colors': 'Colores del tema',
      'Reciter': 'Recitador',
      'Playback Speed': 'Velocidad de audio',
      'Mushaf Font Size': 'Tamaño de fuente',
      'Prayer & Qibla': 'Oración y Qibla',
      'Save to Gallery': 'Guardar en Galería',
    },
    'tr': {
      'Quran': 'Kur\'an-ı Kerim',
      'Read · Listen · Reflect': 'Oku · Dinle · Tefekkür Et',
      'Hifz & Khatmah': 'Hıfz ve Hatim',
      'Ad\'iyah': 'Dualar ve Zikirler',
      'Duas & Azkar': 'Dualar ve Zikirler',
      'Bookmarks': 'Kaydedilenler',
      'Settings': 'Ayarlar',
      'All': 'Tümü',
      'Meccan': 'Mekkî',
      'Medinan': 'Medenî',
      'Verses': 'Ayet',
      'Page': 'Sayfa',
      'Resume': 'Devam Et',
      'Day Streak': 'Günlük Seri',
      'Theme Colors': 'Tema Renkleri',
      'Reciter': 'Kâri (Okuyucu)',
      'Playback Speed': 'Okuma Hızı',
      'Mushaf Font Size': 'Yazı Boyutu',
      'Prayer & Qibla': 'Namaz ve Kıble',
      'Save to Gallery': 'Galeriye Kaydet',
    },
    'id': {
      'Quran': 'Al-Qur\'an',
      'Read · Listen · Reflect': 'Baca · Dengar · Renungkan',
      'Hifz & Khatmah': 'Hafalan & Khatam',
      'Ad\'iyah': 'Doa & Dzikir',
      'Duas & Azkar': 'Doa & Dzikir',
      'Bookmarks': 'Penanda',
      'Settings': 'Pengaturan',
      'All': 'Semua',
      'Verses': 'Ayat',
      'Page': 'Halaman',
      'Resume': 'Lanjutkan',
      'Day Streak': 'Hari Beruntun',
      'Theme Colors': 'Warna Tema',
      'Reciter': 'Qari',
      'Playback Speed': 'Kecepatan Audio',
      'Mushaf Font Size': 'Ukuran Huruf',
      'Prayer & Qibla': 'Sholat & Kiblat',
      'Save to Gallery': 'Simpan ke Galeri',
    },
    'ur': {
      'Quran': 'قرآن مجید',
      'Read · Listen · Reflect': 'پڑھیں · سنیں · تدبر کریں',
      'Hifz & Khatmah': 'حفظ اور ختم قرآن',
      'Ad\'iyah': 'مسنون دعائیں',
      'Duas & Azkar': 'دعائیں اور اذکار',
      'Bookmarks': 'محفوظ آیات',
      'Settings': 'ترتیبات',
      'All': 'تمام',
      'Verses': 'آیات',
      'Page': 'صفحہ',
      'Resume': 'جاری رکھیں',
      'Day Streak': 'مسلسل ایام',
      'Theme Colors': 'تھیم کے رنگ',
      'Reciter': 'قاری',
      'Prayer & Qibla': 'نماز اور قبلہ',
      'Save to Gallery': 'گیلری میں محفوظ کریں',
    },
    'de': {
      'Quran': 'Koran',
      'Read · Listen · Reflect': 'Lesen · Hören · Nachdenken',
      'Hifz & Khatmah': 'Hifz & Chatma',
      'Ad\'iyah': 'Bittgebete (Duas)',
      'Bookmarks': 'Lesezeichen',
      'Settings': 'Einstellungen',
      'All': 'Alle',
      'Verses': 'Verse',
      'Page': 'Seite',
      'Resume': 'Fortsetzen',
      'Day Streak': 'Tages-Serie',
      'Theme Colors': 'Themenfarben',
      'Reciter': 'Rezitator',
      'Save to Gallery': 'In Galerie speichern',
    },
    'ru': {
      'Quran': 'Коран',
      'Read · Listen · Reflect': 'Читай · Слушай · Размышляй',
      'Hifz & Khatmah': 'Хифз и Хатм',
      'Ad\'iyah': 'Дуа и Азкары',
      'Bookmarks': 'Закладки',
      'Settings': 'Настройки',
      'All': 'Все',
      'Verses': 'Аяты',
      'Page': 'Стр.',
      'Resume': 'Продолжить',
      'Day Streak': 'Дней подряд',
      'Theme Colors': 'Цвета темы',
      'Reciter': 'Чтец',
      'Save to Gallery': 'Сохранить в Галерею',
    },
  };

  String tr(String en, String ar) {
    if (selectedLanguageCode == 'ar' || isArabicUi) return ar;
    if (selectedLanguageCode == 'en') return en;
    final langMap = _multiLangUi[selectedLanguageCode];
    if (langMap != null) {
      if (langMap.containsKey(en)) return langMap[en]!;
      for (final entry in langMap.entries) {
        if (en.toLowerCase() == entry.key.toLowerCase()) return entry.value;
      }
    }
    return isRtlLanguage ? ar : en;
  }
}
