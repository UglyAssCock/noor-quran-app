import 'package:flutter/material.dart';
import '../services/app_state.dart';

class HifzAndKhatmaScreen extends StatefulWidget {
  final AppState appState;
  const HifzAndKhatmaScreen({super.key, required this.appState});

  @override
  State<HifzAndKhatmaScreen> createState() => _HifzAndKhatmaScreenState();
}

class _HifzAndKhatmaScreenState extends State<HifzAndKhatmaScreen> {
  int _selectedSurah = 114;
  bool _hideTextForTesting = true;
  final Set<String> _temporarilyRevealed = {};

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    final ayahs = s.surahMap[_selectedSurah] ?? [];
    final progressRatio = (s.khatmaCompletedPages / 604.0).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Khatma Tracker Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.track_changes, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 8),
                    Text(
                      s.tr('Khatma & Daily Wird Tracker', 'متابعة الختمة والورد اليومي'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progressRatio,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 8),
                Text(
                  '${s.khatmaCompletedPages} / 604 ${s.tr("Pages Read", "صفحة مقروءة")} (${(progressRatio * 100).toStringAsFixed(1)}%) • ${s.tr("Daily Goal", "الهدف اليومي")}: ${s.khatmaDailyGoalPages} ${s.tr("pages", "صفحات")}',
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(
                        '+${s.khatmaDailyGoalPages} (${s.tr("Complete Daily Wird", "إتمام الورد اليومي")})',
                      ),
                      onPressed: () => setState(
                        () => s.updateKhatmaProgress(
                          s.khatmaCompletedPages + s.khatmaDailyGoalPages,
                          s.khatmaDailyGoalPages,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => setState(
                        () => s.updateKhatmaProgress(
                          0,
                          s.khatmaDailyGoalPages,
                        ),
                      ),
                      child: Text(s.tr('Reset', 'إعادة ضبط')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Memorization (Hifz) Mode Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.tr('Hifz (Memorization) Mode', 'وضع الحفظ والمراجعة'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                      value: _hideTextForTesting,
                      onChanged: (v) => setState(() {
                        _hideTextForTesting = v;
                        _temporarilyRevealed.clear();
                      }),
                    ),
                  ],
                ),
                Text(
                  s.tr(
                    'Toggle switch to hide verse words and tap any verse to reveal and check your memory.',
                    'فعّل المفتاح لإخفاء الآيات واضغط على أي آية لإظهارها واختبار حفظك.',
                  ),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                DropdownButton<int>(
                  value: _selectedSurah,
                  isExpanded: true,
                  items: s.surahs
                      .map(
                        (surah) => DropdownMenuItem(
                          value: surah.number,
                          child: Text(
                            '${surah.number}. ${surah.nameEn} (${surah.nameAr})',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedSurah = val;
                        _temporarilyRevealed.clear();
                      });
                    }
                  },
                ),
                const Divider(),
                ...ayahs.take(40).map((item) {
                  final isMemorized = s.memorizedAyahs.contains(item.key);
                  final isHidden =
                      _hideTextForTesting && !_temporarilyRevealed.contains(item.key);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: IconButton(
                      icon: Icon(
                        isMemorized
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isMemorized ? Colors.green : Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => s.toggleMemorized(item.key)),
                    ),
                    title: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        isHidden
                            ? '•••••• ﴿${item.numberInSurah}﴾ (اضغط للإظهار / Tap to reveal)'
                            : '${item.textUthmani} ﴿${item.numberInSurah}﴾',
                        style: TextStyle(
                          fontFamily: 'AmiriQuran',
                          fontSize: s.quranFontSize - 2,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        if (_temporarilyRevealed.contains(item.key)) {
                          _temporarilyRevealed.remove(item.key);
                        } else {
                          _temporarilyRevealed.add(item.key);
                        }
                      });
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AzkarAndSettingsScreen extends StatefulWidget {
  final AppState appState;
  const AzkarAndSettingsScreen({super.key, required this.appState});

  @override
  State<AzkarAndSettingsScreen> createState() => _AzkarAndSettingsScreenState();
}

class _AzkarAndSettingsScreenState extends State<AzkarAndSettingsScreen> {
  final List<Map<String, String>> _azkarItems = const [
    {
      'categoryEn': 'Morning & Evening',
      'categoryAr': 'أذكار الصباح والمساء',
      'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ (١٠٠ مرة)',
      'meaning': 'Glory and praise be to Allah (100 times).',
    },
    {
      'categoryEn': 'Morning Protection',
      'categoryAr': 'ذكر الصباح',
      'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
      'meaning': 'We have entered a new morning and with it all dominion belongs to Allah.',
    },
    {
      'categoryEn': 'Evening Protection',
      'categoryAr': 'ذكر المساء',
      'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
      'meaning': 'We have entered the evening and with it all dominion belongs to Allah.',
    },
    {
      'categoryEn': 'Seeking Forgiveness',
      'categoryAr': 'الاستغفار',
      'arabic': 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ (١٠٠ مرة)',
      'meaning': 'I seek the forgiveness of Allah and repent to Him (100 times).',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final dailyAyah = s.allAyahs.isNotEmpty
        ? s.allAyahs[dayOfYear % s.allAyahs.length]
        : null;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Daily Verse Card
        if (dailyAyah != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny, color: Color(0xFFD4AF37)),
                      const SizedBox(width: 8),
                      Text(
                        '${s.tr("Verse of the Day", "آية اليوم")} (${dailyAyah.key})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      dailyAyah.textUthmani,
                      style: const TextStyle(
                        fontFamily: 'AmiriQuran',
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(dailyAyah.translationEn),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.notifications),
                    label: Text(
                      s.tr('Send Daily Verse Notification', 'إرسال تذكير آية اليوم'),
                    ),
                    onPressed: () {
                      s.triggerInstantReminder(
                        s.tr('Daily Quran Reminder', 'تذكير القرآن اليومي'),
                        '${dailyAyah.textUthmani} (${dailyAyah.key})',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 12),

        // Digital Tasbih Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  s.tr('Digital Tasbih Counter', 'المسبحة الإلكترونية'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '${s.tasbihCount}',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.touch_app),
                      label: Text(s.tr('Count (SubhanAllah)', 'تسبيح')),
                      onPressed: () => setState(() => s.incrementTasbih()),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => setState(() => s.resetTasbih()),
                      child: Text(s.tr('Reset', 'تصفير')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Morning & Evening Azkar
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.tr('Morning & Evening Azkar', 'أذكار الصباح والمساء'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ..._azkarItems.map(
                  (z) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          s.isArabicUi ? z['categoryAr']! : z['categoryEn']!,
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            z['arabic']!,
                            style: const TextStyle(
                              fontFamily: 'AmiriQuran',
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Text(
                          z['meaning']!,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // App Preferences & Settings
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.tr('Appearance & Reading Settings', 'إعدادات المظهر والقراءة'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                SwitchListTile(
                  title: Text(s.tr('Dark Mode', 'الوضع الليلي')),
                  value: s.isDarkMode,
                  onChanged: (_) => setState(() => s.toggleDarkMode()),
                ),
                SwitchListTile(
                  title: Text(s.tr('Arabic Interface (RTL)', 'واجهة التطبيق بالعربية')),
                  value: s.isArabicUi,
                  onChanged: (_) => setState(() => s.toggleLanguage()),
                ),
                SwitchListTile(
                  title: Text(
                    s.tr('Keep Screen On While Reading', 'إبقاء الشاشة مضاءة أثناء القراءة'),
                  ),
                  value: s.keepScreenOn,
                  onChanged: (_) => setState(() => s.toggleKeepScreenOn()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Text(s.tr('Quran Font Size', 'حجم خط المصحف')),
                      Expanded(
                        child: Slider(
                          min: 18.0,
                          max: 40.0,
                          value: s.quranFontSize,
                          onChanged: (v) => setState(() => s.updateFontSize(v)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
