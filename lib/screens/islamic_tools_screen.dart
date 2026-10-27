import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_state.dart';
import 'quran_reader_screen.dart';
import 'prayer_qibla_screen.dart';

/// PART 3: Expanded Ad'iyah (أدعية), Azkar, Digital Tasbih & Settings Screen (Hifz & Khatmah Removed)
typedef AdiyahScreen = AdiyahAndAzkarScreen;
typedef DuasScreen = AdiyahAndAzkarScreen;
typedef DuasAndAzkarScreen = AdiyahAndAzkarScreen;
typedef SettingsScreen = AzkarAndSettingsScreen;

class AdiyahAndAzkarScreen extends StatefulWidget {
  final AppState appState;
  const AdiyahAndAzkarScreen({super.key, required this.appState});

  @override
  State<AdiyahAndAzkarScreen> createState() => _AdiyahAndAzkarScreenState();
}

class _AdiyahAndAzkarScreenState extends State<AdiyahAndAzkarScreen> {
  String _selectedCategory = 'all';

  // Expanded Ad'iyah & Azkar library with dozens of authentic Quranic and Prophetic supplications
  final List<Map<String, dynamic>> _duasList = const [
    {
      'id': 'q_rabbana_atina',
      'cat': 'quranic',
      'titleEn': 'Dua for Goodness in Both Worlds',
      'titleAr': 'دعاء جامع لخيري الدنيا والآخرة',
      'arabic':
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      'translation':
          'Our Lord, give us in this world [that which is] good and in the Hereafter [that which is] good and protect us from the punishment of the Fire. (Al-Baqarah 2:201)',
      'target': 3,
    },
    {
      'id': 'q_la_tuzigh',
      'cat': 'quranic',
      'titleEn': 'Dua for Steadfastness of Heart',
      'titleAr': 'دعاء الثبات على الهداية',
      'arabic':
          'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً ۚ إِنَّكَ أَنتَ الْوَهَّابُ',
      'translation':
          'Our Lord, let not our hearts deviate after You have guided us and grant us from Yourself mercy. Indeed, You are the Bestower. (Aal-e-Imran 3:8)',
      'target': 3,
    },
    {
      'id': 'q_ishrah_sadri',
      'cat': 'quranic',
      'titleEn': 'Dua for Ease & Eloquence',
      'titleAr': 'دعاء انشراح الصدر وتيسير الأمر',
      'arabic':
          'رَبِّ اشْرَحْ لِي صَدْرِي ۝ وَيَسِّرْ لِي أَمْرِي ۝ وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي ۝ يَفْقَهُوا قَوْلِي',
      'translation':
          'My Lord, expand for me my breast [with assurance], ease for me my task, and untie the knot from my tongue that they may understand my speech. (Ta-Ha 20:25-28)',
      'target': 3,
    },
    {
      'id': 'q_zidni_ilma',
      'cat': 'quranic',
      'titleEn': 'Dua for Beneficial Knowledge',
      'titleAr': 'دعاء طلب العلم النافع',
      'arabic': 'رَّبِّ زِدْنِي عِلْمًا',
      'translation': 'My Lord, increase me in knowledge. (Ta-Ha 20:114)',
      'target': 7,
    },
    {
      'id': 'q_yunus',
      'cat': 'quranic',
      'titleEn': 'Dua of Prophet Yunus (Relief from Distress)',
      'titleAr': 'دعاء الكرب (دعاء ذي النون)',
      'arabic':
          'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      'translation':
          'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers. (Al-Anbiya 21:87)',
      'target': 7,
    },
    {
      'id': 'q_walidayya',
      'cat': 'quranic',
      'titleEn': 'Dua for Parents & Believers',
      'titleAr': 'دعاء للوالدين والمؤمنين',
      'arabic':
          'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
      'translation':
          'Our Lord, forgive me and my parents and the believers the Day the account is established. (Ibrahim 14:41)',
      'target': 3,
    },
    {
      'id': 'q_sabrun_jameel',
      'cat': 'quranic',
      'titleEn': 'Dua for Patience & Perseverance',
      'titleAr': 'دعاء الصبر والثبات عند البلاء',
      'arabic': 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَتَوَفَّنَا مُسْلِمِينَ',
      'translation':
          'Our Lord, pour upon us patience and let us die as Muslims [in submission to You]. (Al-A\'raf 7:126)',
      'target': 3,
    },
    {
      'id': 'q_rabbi_hab_li',
      'cat': 'quranic',
      'titleEn': 'Dua for Righteous Offspring',
      'titleAr': 'دعاء صلاح الذرية والأسرة',
      'arabic': 'رَبِّ هَبْ لِي مِن لَّدُنْكَ ذُرِّيَّةً طَيِّبَةً ۖ إِنَّكَ سَمِيعُ الدُّعَاءِ',
      'translation':
          'My Lord, grant me from Yourself a good offspring. Indeed, You are the Hearer of supplication. (Aal-e-Imran 3:38)',
      'target': 3,
    },
    {
      'id': 'p_sayyid_istighfar',
      'cat': 'prophetic',
      'titleEn': 'Sayyid Al-Istighfar (Master Supplication for Forgiveness)',
      'titleAr': 'سيد الاستغفار',
      'arabic':
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
      'translation':
          'O Allah, You are my Lord, there is none worthy of worship but You. You created me and I am Your servant... Forgive me, for none forgives sins except You.',
      'target': 1,
    },
    {
      'id': 'p_muqallib_qulub',
      'cat': 'prophetic',
      'titleEn': 'Prophetic Dua for Firm Faith',
      'titleAr': 'دعاء تثبيت القلب على الدين',
      'arabic': 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَىٰ دِينِكَ',
      'translation':
          'O Turner of the hearts, make my heart firm upon Your religion.',
      'target': 3,
    },
    {
      'id': 'p_afiyah',
      'cat': 'prophetic',
      'titleEn': 'Dua for Forgiveness & Well-Being',
      'titleAr': 'دعاء العفو والعافية',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
      'translation':
          'O Allah, I ask You for pardon and well-being in this life and the next.',
      'target': 3,
    },
    {
      'id': 'p_rizq_halal',
      'cat': 'prophetic',
      'titleEn': 'Dua for Halal Sustenance & Knowledge',
      'titleAr': 'دعاء الرزق الواسع والعلم النافع',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا',
      'translation':
          'O Allah, I ask You for beneficial knowledge, good and lawful sustenance, and accepted deeds.',
      'target': 1,
    },
    {
      'id': 'p_shifa',
      'cat': 'prophetic',
      'titleEn': 'Dua for Healing from Illness',
      'titleAr': 'دعاء الشفاء العاجل',
      'arabic': 'اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَاسَ، اشْفِ أَنْتَ الشَّافِي لاَ شِفَاءَ إِلاَّ شِفَاؤُكَ، شِفَاءً لاَ يُغَادِرُ سَقَمًا',
      'translation':
          'O Allah, Lord of mankind, remove the adversity and heal, for You are the Healer. There is no healing except Your healing, a healing that leaves no illness behind.',
      'target': 3,
    },
    {
      'id': 'm_morning',
      'cat': 'azkar',
      'titleEn': 'Morning Remembrance',
      'titleAr': 'أذكار الصباح',
      'arabic':
          'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      'translation':
          'We have reached the morning and at this very time all sovereignty belongs to Allah, and all praise is for Allah.',
      'target': 1,
    },
    {
      'id': 'm_evening',
      'cat': 'azkar',
      'titleEn': 'Evening Remembrance',
      'titleAr': 'أذكار المساء',
      'arabic':
          'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      'translation':
          'We have reached the evening and at this very time all sovereignty belongs to Allah, and all praise is for Allah.',
      'target': 1,
    },
    {
      'id': 'm_subhanallah',
      'cat': 'azkar',
      'titleEn': 'Daily Glorification (SubhanAllahi wa bi-hamdih)',
      'titleAr': 'تسبيح اليوم والليلة',
      'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      'translation':
          'Glory and praise be to Allah; Glory be to Allah, the Supreme.',
      'target': 33,
    },
    {
      'id': 'k_khatm_quran',
      'cat': 'khatm',
      'titleEn': 'Dua Khatm Al-Quran (Upon Completing the Quran)',
      'titleAr': 'دعاء ختم القرآن الكريم',
      'arabic':
          'اللَّهُمَّ ارْحَمْنِي بِالْقُرْآنِ وَاجْعَلْهُ لِي إِمَامًا وَنُورًا وَهُدًى وَرَحْمَةً، اللَّهُمَّ ذَكِّرْنِي مِنْهُ مَا نُسِّيتُ وَعَلِّمْنِي مِنْهُ مَا جَهِلْتُ وَارْزُقْنِي تِلَاوَتَهُ آنَاءَ اللَّيْلِ وَأَطْرَافَ النَّهَارِ وَاجْعَلْهُ لِي حُجَّةً يَا رَبَّ الْعَالَمِينَ',
      'translation':
          'O Allah, have mercy on me through the Qur’an, and make it for me a leader, a light, a guidance, and a mercy...',
      'target': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    final p = s.palette;

    final filteredDuas = _duasList.where((d) {
      if (_selectedCategory == 'all') return true;
      return d['cat'] == _selectedCategory;
    }).toList();

    return Container(
      color: p.bg,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.border, width: 1.3),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.spa_outlined, color: p.accent),
                        const SizedBox(width: 8),
                        Text(
                          s.tr('Digital Tasbih Counter', 'المسبحة الإلكترونية'),
                          style: TextStyle(
                            color: p.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.refresh, color: p.textSecondary, size: 18),
                      label: Text(
                        s.tr('Reset', 'تصفير'),
                        style: TextStyle(color: p.textSecondary),
                      ),
                      onPressed: () => setState(() => s.resetTasbih()),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => s.incrementTasbih());
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: p.bg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: p.accent.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${s.tasbihCount}',
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.tr(
                            'Tap anywhere here to count Dhikr',
                            'اضغط هنا للتسبيح والذكر',
                          ),
                          style: TextStyle(color: p.textSecondary, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCatPill('all', s.tr('All Duas', 'جميع الأدعية'), p),
                const SizedBox(width: 8),
                _buildCatPill('quranic', s.tr('Quranic Duas', 'أدعية قرآنية'), p),
                const SizedBox(width: 8),
                _buildCatPill('prophetic', s.tr('Prophetic Duas', 'أدعية نبوية'), p),
                const SizedBox(width: 8),
                _buildCatPill('azkar', s.tr('Morning & Evening', 'الأذكار'), p),
                const SizedBox(width: 8),
                _buildCatPill('khatm', s.tr('Khatm Al-Quran', 'ختم القرآن'), p),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...filteredDuas.map((dua) {
            final id = dua['id'] as String;
            final target = dua['target'] as int;
            final currentCount = s.duaCounters[id] ?? 0;
            final isDone = currentCount >= target;
            final title = s.isRtlLanguage
                ? dua['titleAr'] as String
                : dua['titleEn'] as String;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDone ? p.accent : p.border,
                  width: isDone ? 1.6 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: p.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: s.tr('Copy Dua', 'نسخ الدعاء'),
                        icon: Icon(Icons.copy, color: p.textSecondary, size: 19),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text:
                                  '${dua['arabic']}\n\n${dua['translation']}',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                s.tr('Dua copied to clipboard!', 'تم نسخ الدعاء!'),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      dua['arabic'] as String,
                      style: TextStyle(
                        color: p.textPrimary,
                        fontFamily: 'AmiriQuran',
                        fontSize: s.quranFontSize - 1,
                        height: 1.95,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dua['translation'] as String,
                    style: TextStyle(
                      color: p.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentCount > 0)
                        TextButton(
                          onPressed: () {
                            setState(() => s.duaCounters[id] = 0);
                          },
                          child: Text(
                            s.tr('Reset', 'إعادة'),
                            style: TextStyle(color: p.textSecondary, fontSize: 12),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDone ? p.accent : p.bg,
                          foregroundColor: isDone ? Colors.black87 : p.accent,
                          side: BorderSide(color: p.accent),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                        icon: Icon(
                          isDone ? Icons.check_circle : Icons.touch_app,
                          size: 18,
                        ),
                        label: Text(
                          '${s.tr("Count", "تكرار")}: $currentCount / $target',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            s.duaCounters[id] = currentCount + 1;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCatPill(String catId, String label, AppThemePalette p) {
    final selected = _selectedCategory == catId;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = catId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? p.accent : p.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? p.accent : p.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black87 : p.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

class BookmarksAndNotesScreen extends StatefulWidget {
  final AppState appState;
  const BookmarksAndNotesScreen({super.key, required this.appState});

  @override
  State<BookmarksAndNotesScreen> createState() =>
      _BookmarksAndNotesScreenState();
}

class _BookmarksAndNotesScreenState extends State<BookmarksAndNotesScreen> {
  bool _showVersesTab = true;

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    final p = s.palette;

    return Container(
      color: p.bg,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showVersesTab = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _showVersesTab ? p.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        s.tr('Verses & Notes', 'الآيات والملاحظات'),
                        style: TextStyle(
                          color:
                              _showVersesTab ? Colors.black87 : p.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showVersesTab = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_showVersesTab ? p.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        s.tr('Surahs', 'السور المحفوظة'),
                        style: TextStyle(
                          color: !_showVersesTab
                              ? Colors.black87
                              : p.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _showVersesTab
                ? _buildBookmarkedVersesList(s, p)
                : _buildBookmarkedSurahsList(s, p),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkedVersesList(AppState s, AppThemePalette p) {
    final keys = <String>{...s.bookmarks, ...s.ayahNotes.keys}.toList();
    if (keys.isEmpty) {
      return Center(
        child: Text(
          s.tr('No bookmarked verses yet.', 'لا توجد آيات محفوظة بعد.'),
          style: TextStyle(color: p.textSecondary),
        ),
      );
    }

    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, idx) {
        final key = keys[idx];
        final parts = key.split(':');
        final sNum = int.tryParse(parts[0]) ?? 1;
        final aNum = int.tryParse(parts[1]) ?? 1;
        final surahAyahs = s.surahMap[sNum] ?? [];
        final ayah = surahAyahs.firstWhere(
          (a) => a.numberInSurah == aNum,
          orElse: () => AyahItem(
            surahNumber: sNum,
            surahNameAr: 'سورة',
            surahNameEn: 'Surah $sNum',
            numberInSurah: aNum,
            globalNumber: 1,
            juz: 1,
            page: 1,
            textUthmani: 'آية $key',
          ),
        );
        final note = s.ayahNotes[key];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.border),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ActiveMushafView(
                    appState: s,
                    initialPage: ayah.page,
                    initialSurah: sNum,
                    highlightAyah: aNum,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bookmark, color: p.accent, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      '${ayah.surahNameAr} • ${ayah.key}',
                      style: TextStyle(
                        color: p.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: p.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => s.toggleBookmark(key)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      ayah.textUthmani,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.textPrimary,
                        fontFamily: 'AmiriQuran',
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${s.tr("Page", "صفحة")} ${ayah.page} • ${s.tr("Juz", "الجزء")} ${ayah.juz}',
                  style: TextStyle(color: p.textSecondary, fontSize: 12),
                ),
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '📝 $note',
                    style: TextStyle(color: p.accent, fontSize: 12.5),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookmarkedSurahsList(AppState s, AppThemePalette p) {
    final list = s.bookmarkedSurahs.toList();
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final sNum = list[idx];
        final meta = s.surahs.firstWhere(
          (m) => m.number == sNum,
          orElse: () => SurahMeta(
            number: sNum,
            nameAr: 'سورة',
            nameEn: 'Surah $sNum',
            meaningEn: '',
            revelationType: 'Meccan',
            ayahCount: 7,
          ),
        );
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.border),
          ),
          child: ListTile(
            leading: RubElHizbBadge(
              label: '${meta.number}',
              size: 40,
              color: p.accent,
            ),
            title: Text(
              '${meta.nameAr} • ${meta.nameEn}',
              style: TextStyle(
                color: p.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${meta.ayahCount} ${s.tr("Verses", "آيات")} • ${s.tr("Page", "صفحة")} ${meta.startPage}',
              style: TextStyle(color: p.textSecondary),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: p.textSecondary),
              onPressed: () => setState(() => s.toggleSurahBookmark(sNum)),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ActiveMushafView(
                    appState: s,
                    initialPage: meta.startPage,
                    initialSurah: sNum,
                  ),
                ),
              );
            },
          ),
        );
      },
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
  void _showReciterPickerModal(AppState s, AppThemePalette p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: p.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        builder: (ctx, scrollCtrl) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s.tr("Reciter", "اختر القارئ")} (${s.reciters.length})',
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: s.reciters.length,
                    itemBuilder: (_, idx) {
                      final r = s.reciters[idx];
                      final isSelected = r.id == s.selectedReciter.id;
                      return Card(
                        color: p.card,
                        child: ListTile(
                          leading: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.record_voice_over_outlined,
                            color: isSelected ? p.accent : p.textSecondary,
                          ),
                          title: Text(
                            r.nameEn,
                            style: TextStyle(
                              color: p.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            r.nameAr,
                            style: TextStyle(color: p.accent, fontSize: 13),
                          ),
                          onTap: () {
                            setState(() => s.setReciter(r));
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMushafEditionPickerModal(AppState s, AppThemePalette p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: p.bg,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.tr(
                  'Select Mushaf Edition (King Fahd Complex)',
                  'اختر رواية المصحف (مجمع الملك فهد)',
                ),
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...s.mushafEditions.map((m) {
                final selected = m.id == s.selectedMushafId;
                return Card(
                  color: p.card,
                  child: ListTile(
                    leading: Icon(
                      selected ? Icons.check_circle : Icons.menu_book_outlined,
                      color: selected ? p.accent : p.textSecondary,
                    ),
                    title: Text(
                      m.nameEn,
                      style: TextStyle(color: p.textPrimary, fontSize: 14),
                    ),
                    subtitle: Text(
                      m.nameAr,
                      style: TextStyle(color: p.accent, fontSize: 12.5),
                    ),
                    onTap: () {
                      setState(() => s.setMushafEdition(m.id));
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePickerModal(AppState s, AppThemePalette p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: p.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (ctx, scrollCtrl) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.tr(
                    'App Interface & Translation Language (36+)',
                    'لغة واجهة التطبيق والترجمة (٣٦+ لغة)',
                  ),
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: s.globalLanguages.length,
                    itemBuilder: (_, idx) {
                      final lang = s.globalLanguages[idx];
                      final isSelected = lang.code == s.selectedLanguageCode;
                      return Card(
                        color: p.card,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: p.bg,
                            child: Text(
                              lang.code.toUpperCase(),
                              style: TextStyle(
                                color: p.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            '${lang.nameEn} (${lang.nativeName})',
                            style: TextStyle(
                              color: p.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            lang.defaultEdition,
                            style: TextStyle(
                              color: p.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: p.accent)
                              : null,
                          onTap: () async {
                            Navigator.pop(ctx);
                            await s.switchLanguageAndDownloadTranslation(lang);
                            if (mounted) setState(() {});
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _show184TafsirAndTranslationsModal(AppState s, AppThemePalette p) {
    s.fetchAll184CatalogEditionsOnline();
    showModalBottomSheet(
      context: context,
      backgroundColor: p.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (ctx, scrollCtrl) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.tr(
                    '184+ Tafsir & Translation Sources (${s.catalogEditions.length})',
                    'أكثر من ١٨٤ مصدر للتفسير والترجمة',
                  ),
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: s.catalogEditions.length,
                    itemBuilder: (_, idx) {
                      final ed = s.catalogEditions[idx];
                      return Card(
                        color: p.card,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: p.bg,
                            child: Text(
                              ed.language.toUpperCase(),
                              style: TextStyle(
                                color: p.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            ed.name,
                            style:
                                TextStyle(color: p.textPrimary, fontSize: 14),
                          ),
                          subtitle: Text(
                            '${ed.type.toUpperCase()} • ${ed.identifier}',
                            style: TextStyle(
                              color: p.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Icon(
                            Icons.cloud_download_outlined,
                            color: p.accent,
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Activated ${ed.name} (${ed.identifier})',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCleanSettingTile({
    required AppThemePalette p,
    required IconData icon,
    required String title,
    required String valueText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: p.accent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: p.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    valueText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.accent,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: p.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    final p = s.palette;
    final currentLang = s.globalLanguages.firstWhere(
      (l) => l.code == s.selectedLanguageCode,
      orElse: () => s.globalLanguages[1],
    );

    return Container(
      color: p.bg,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            s.tr('Theme Colors', 'ألوان ومظهر التطبيق'),
            style: TextStyle(
              color: p.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.border),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: s.themes.map((t) {
                final isSelected = t.id == s.selectedThemeId;
                return GestureDetector(
                  onTap: () => setState(() => s.setTheme(t.id)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: t.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? t.accent : t.border,
                        width: isSelected ? 2.2 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 8, backgroundColor: t.accent),
                        const SizedBox(width: 8),
                        Text(
                          s.isRtlLanguage ? t.nameAr : t.nameEn,
                          style: TextStyle(
                            color: t.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.tr('Audio Settings (65 Reciters)', 'إعدادات الصوت والقراء'),
            style: TextStyle(
              color: p.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.border),
            ),
            child: Column(
              children: [
                _buildCleanSettingTile(
                  p: p,
                  icon: Icons.record_voice_over,
                  title: s.tr('Reciter', 'القارئ'),
                  valueText:
                      '${s.selectedReciter.nameEn} (${s.selectedReciter.nameAr})',
                  onTap: () => _showReciterPickerModal(s, p),
                ),
                Divider(color: p.border, height: 1),
                _buildCleanSettingTile(
                  p: p,
                  icon: Icons.speed,
                  title: s.tr('Playback Speed', 'سرعة التلاوة'),
                  valueText: '${s.playbackSpeed}x',
                  onTap: () {
                    const speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
                    final next = speeds[
                        (speeds.indexOf(s.playbackSpeed) + 1) % speeds.length];
                    setState(() => s.setPlaybackSpeed(next));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.tr('Reading & Mushaf Settings', 'إعدادات المصحف واللغات والتفسير'),
            style: TextStyle(
              color: p.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.border),
            ),
            child: Column(
              children: [
                _buildCleanSettingTile(
                  p: p,
                  icon: Icons.menu_book,
                  title: s.tr(
                    'Mushaf Edition (Hafs & Warsh)',
                    'رواية المصحف (حفص وورش)',
                  ),
                  valueText: s.currentMushaf.nameEn,
                  onTap: () => _showMushafEditionPickerModal(s, p),
                ),
                Divider(color: p.border, height: 1),
                _buildCleanSettingTile(
                  p: p,
                  icon: Icons.public,
                  title: s.tr(
                    'App & Translation Language (36+)',
                    'لغة التطبيق والترجمة',
                  ),
                  valueText:
                      '${currentLang.nameEn} (${currentLang.nativeName})',
                  onTap: () => _showLanguagePickerModal(s, p),
                ),
                Divider(color: p.border, height: 1),
                _buildCleanSettingTile(
                  p: p,
                  icon: Icons.library_books_outlined,
                  title: s.tr(
                    '184+ Tafsir & Translation Sources',
                    '١٨٤+ مصدر للتفسير والترجمة',
                  ),
                  valueText: 'Ibn Kathir, Qurtubi, Jalalayn, Muyassar & more',
                  onTap: () => _show184TafsirAndTranslationsModal(s, p),
                ),
                Divider(color: p.border, height: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.format_size, color: p.accent, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        s.tr('Mushaf Font Size', 'حجم خط المصحف'),
                        style: TextStyle(
                          color: p.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          activeColor: p.accent,
                          min: 18.0,
                          max: 36.0,
                          value: s.quranFontSize,
                          onChanged: (v) =>
                              setState(() => s.updateFontSize(v)),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: p.border, height: 1),
                SwitchListTile(
                  activeColor: p.accent,
                  title: Text(
                    s.tr(
                      'Word Highlighting & Pronunciation',
                      'تظليل الكلمات والنطق الصوتي للمتعلمين',
                    ),
                    style: TextStyle(color: p.textPrimary, fontSize: 14),
                  ),
                  value: s.wordByWordEnabled,
                  onChanged: (_) => setState(() => s.toggleWordByWord()),
                ),
                Divider(color: p.border, height: 1),
                SwitchListTile(
                  activeColor: p.accent,
                  title: Text(
                    s.tr(
                      'Keep Screen On While Reading',
                      'إبقاء الشاشة مضاءة أثناء القراءة',
                    ),
                    style: TextStyle(color: p.textPrimary, fontSize: 14),
                  ),
                  value: s.keepScreenOn,
                  onChanged: (_) => setState(() => s.toggleKeepScreenOn()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.card,
                    foregroundColor: p.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.explore),
                  label: Text(s.tr('Prayer & Qibla', 'الصلاة والقبلة')),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            title:
                                Text(s.tr('Prayer & Qibla', 'الصلاة والقبلة')),
                          ),
                          body: PrayerQiblaScreen(appState: s),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.card,
                    foregroundColor: p.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.volunteer_activism),
                  label: Text(s.tr('Ad\'iyah', 'الأدعية والأذكار')),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            title: Text(s.tr('Ad\'iyah', 'الأدعية والأذكار')),
                          ),
                          body: AdiyahAndAzkarScreen(appState: s),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
