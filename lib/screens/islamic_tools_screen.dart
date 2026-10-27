import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../services/app_state.dart';
import 'quran_reader_screen.dart';
import 'prayer_qibla_screen.dart';

/// PART 1: Interactive Hifz (Memorization) & Khatmah Planner Screen
class HifzAndKhatmaScreen extends StatefulWidget {
  final AppState appState;
  const HifzAndKhatmaScreen({super.key, required this.appState});

  @override
  State<HifzAndKhatmaScreen> createState() => _HifzAndKhatmaScreenState();
}

class _HifzAndKhatmaScreenState extends State<HifzAndKhatmaScreen> {
  final AudioPlayer _hifzAudioPlayer = AudioPlayer();
  int _selectedSurah = 114;
  int _hideMode = 1; // 0 = Show All, 1 = Hide Full Verse, 2 = Show First Word Only
  final Set<String> _temporarilyRevealed = {};
  String? _playingAyahKey;
  int _repeatTarget = 3;
  int _currentRepeatCount = 0;
  AyahItem? _activeHifzAyah;

  final List<Map<String, dynamic>> _khatmaPlans = const [
    {'titleEn': '15 Days Intensive Khatmah', 'titleAr': 'ختمة مكثفة (١٥ يوماً)', 'goal': 40},
    {'titleEn': '30 Days Khatmah Plan', 'titleAr': 'ختمة شهرية (٣٠ يوماً)', 'goal': 20},
    {'titleEn': '60 Days Khatmah Plan', 'titleAr': 'ختمة في شهرين (٦٠ يوماً)', 'goal': 10},
    {'titleEn': '120 Days Easy Khatmah', 'titleAr': 'ختمة ميسرة (١٢٠ يوماً)', 'goal': 5},
  ];

  @override
  void initState() {
    super.initState();
    _hifzAudioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        if (_activeHifzAyah != null && _currentRepeatCount + 1 < _repeatTarget) {
          _currentRepeatCount++;
          _playHifzAyah(_activeHifzAyah!, resetCounter: false);
        } else {
          setState(() {
            _playingAyahKey = null;
            _currentRepeatCount = 0;
          });
        }
      }
    });
  }

  Future<void> _playHifzAyah(AyahItem item, {bool resetCounter = true}) async {
    final s = widget.appState;
    if (resetCounter) {
      _currentRepeatCount = 0;
    }
    setState(() {
      _activeHifzAyah = item;
      _playingAyahKey = item.key;
    });
    try {
      await _hifzAudioPlayer.setSpeed(s.playbackSpeed);
      await _hifzAudioPlayer.setUrl(
        s.audioUrlForAyah(item.surahNumber, item.numberInSurah),
      );
      await _hifzAudioPlayer.play();
    } catch (_) {
      if (!mounted) return;
      setState(() => _playingAyahKey = null);
    }
  }

  @override
  void dispose() {
    _hifzAudioPlayer.dispose();
    super.dispose();
  }

  String _formatHifzVerseText(AyahItem item, bool isRevealed) {
    if (_hideMode == 0 || isRevealed) {
      return '${item.textUthmani} ﴿${widget.appState.toArabicDigits(item.numberInSurah)}﴾';
    }
    final words = item.textUthmani.split(' ');
    if (_hideMode == 2 && words.isNotEmpty) {
      return '${words.first} •••••• ﴿${widget.appState.toArabicDigits(item.numberInSurah)}﴾';
    }
    return '•••••••••••• ﴿${widget.appState.toArabicDigits(item.numberInSurah)}﴾';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    final p = s.palette;
    final ayahs = s.surahMap[_selectedSurah] ?? [];
    final memorizedInSurah =
        ayahs.where((a) => s.memorizedAyahs.contains(a.key)).length;
    final progressRatio = (s.khatmaCompletedPages / 604.0).clamp(0.0, 1.0);
    final remainingPages = (604 - s.khatmaCompletedPages).clamp(0, 604);
    final daysLeft = (remainingPages / s.khatmaDailyGoalPages).ceil();

    return Container(
      color: p.bg,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Daily Streak & Consistency Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.border, width: 1.3),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.orangeAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${s.streakDays} ${s.tr("Day Streak", "أيام متتالية")}  •  ${s.tr("Best", "الأفضل")}: ${s.bestStreak}',
                        style: TextStyle(
                          color: p.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${s.tr("Memorized Verses", "الآيات المحفوظة")}: ${s.memorizedAyahs.length} / 6236',
                        style: TextStyle(color: p.accent, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Interactive Khatmah Planner Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.track_changes, color: p.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.tr('Interactive Khatmah Tracker', 'متابعة الختمة والورد اليومي'),
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${(progressRatio * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: p.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressRatio,
                    minHeight: 10,
                    backgroundColor: p.bg,
                    color: p.accent,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${s.khatmaCompletedPages} / 604 ${s.tr("Pages", "صفحة")}',
                      style: TextStyle(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      remainingPages == 0
                          ? s.tr('Khatmah Completed! 🎉', 'تمت الختمة بحمد الله! 🎉')
                          : '$daysLeft ${s.tr("days remaining", "يوماً متبقياً")}',
                      style: TextStyle(color: p.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Interactive Page Slider
                Slider(
                  activeColor: p.accent,
                  inactiveColor: p.border,
                  min: 0,
                  max: 604,
                  divisions: 604,
                  value: s.khatmaCompletedPages.toDouble(),
                  label: '${s.khatmaCompletedPages}',
                  onChanged: (val) {
                    setState(() {
                      s.updateKhatmaProgress(
                        val.round(),
                        s.khatmaDailyGoalPages,
                      );
                    });
                  },
                ),

                // Select Khatmah Plan Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _khatmaPlans.map((plan) {
                      final planGoal = plan['goal'] as int;
                      final isSelected = s.khatmaDailyGoalPages == planGoal;
                      final title = s.isRtlLanguage
                          ? plan['titleAr'] as String
                          : plan['titleEn'] as String;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: isSelected,
                          selectedColor: p.accent,
                          backgroundColor: p.bg,
                          label: Text(
                            '$title ($planGoal ${s.tr("p/day", "ص/يوم")})',
                            style: TextStyle(
                              color: isSelected ? Colors.black87 : p.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onSelected: (_) {
                            setState(() {
                              s.updateKhatmaProgress(
                                s.khatmaCompletedPages,
                                planGoal,
                                plan['titleEn'] as String,
                              );
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Action Buttons: -1 Page | +Daily Goal | Open Current Khatmah Page
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: p.textPrimary,
                        side: BorderSide(color: p.border),
                      ),
                      icon: const Icon(Icons.remove, size: 18),
                      label: Text(s.tr('-1 Page', '-١ صفحة')),
                      onPressed: () => setState(
                        () => s.updateKhatmaProgress(
                          s.khatmaCompletedPages - 1,
                          s.khatmaDailyGoalPages,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.accent,
                        foregroundColor: Colors.black87,
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(
                        '+${s.khatmaDailyGoalPages} ${s.tr("Pages (Complete Wird)", "صفحة (إتمام الورد)")}',
                      ),
                      onPressed: () => setState(
                        () => s.updateKhatmaProgress(
                          s.khatmaCompletedPages + s.khatmaDailyGoalPages,
                          s.khatmaDailyGoalPages,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: p.accent,
                        side: BorderSide(color: p.accent),
                      ),
                      icon: const Icon(Icons.menu_book, size: 18),
                      label: Text(
                        '${s.tr("Read Page", "اقرأ صفحة")} ${(s.khatmaCompletedPages + 1).clamp(1, 604)}',
                      ),
                      onPressed: () {
                        final targetPage =
                            (s.khatmaCompletedPages + 1).clamp(1, 604);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ActiveMushafView(
                              appState: s,
                              initialPage: targetPage,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Interactive Hifz (Memorization) Trainer Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: p.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.tr('Interactive Hifz Trainer', 'مدرب الحفظ والمراجعة التفاعلي'),
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: p.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: p.border),
                      ),
                      child: Text(
                        '$memorizedInSurah / ${ayahs.length}',
                        style: TextStyle(
                          color: p.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Surah Dropdown Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: p.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: p.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      dropdownColor: p.card,
                      value: _selectedSurah,
                      isExpanded: true,
                      items: s.surahs.map((surah) {
                        return DropdownMenuItem<int>(
                          value: surah.number,
                          child: Text(
                            '${surah.number}. ${surah.nameEn} (${surah.nameAr}) — ${surah.ayahCount} ${s.tr("Verses", "آيات")}',
                            style: TextStyle(color: p.textPrimary, fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _hifzAudioPlayer.stop();
                          setState(() {
                            _selectedSurah = val;
                            _temporarilyRevealed.clear();
                            _playingAyahKey = null;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Hiding Mode Pills & Audio Loop Counter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildHideModeChip(0, s.tr('Show All', 'إظهار الكل'), p),
                      const SizedBox(width: 6),
                      _buildHideModeChip(1, s.tr('Hide Verse', 'إخفاء الآية'), p),
                      const SizedBox(width: 6),
                      _buildHideModeChip(
                        2,
                        s.tr('First Word Hint', 'إظهار أول كلمة'),
                        p,
                      ),
                      const SizedBox(width: 10),
                      ActionChip(
                        backgroundColor: p.bg,
                        side: BorderSide(color: p.accent),
                        avatar: Icon(Icons.repeat, color: p.accent, size: 16),
                        label: Text(
                          '${s.tr("Loop", "تكرار")}: ${_repeatTarget}x',
                          style: TextStyle(color: p.accent, fontSize: 12),
                        ),
                        onPressed: () {
                          const options = [1, 3, 5, 10];
                          final next = options[
                              (options.indexOf(_repeatTarget) + 1) %
                                  options.length];
                          setState(() => _repeatTarget = next);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.tr(
                        'Tap any verse to reveal/hide • Tap play to loop audio',
                        'اضغط على الآية لإظهارها واختبار حفظك • اضغط تشغيل للتكرار',
                      ),
                      style: TextStyle(color: p.textSecondary, fontSize: 11.5),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (final a in ayahs) {
                            s.memorizedAyahs.add(a.key);
                          }
                          s.toggleMemorized(ayahs.first.key);
                          s.toggleMemorized(ayahs.first.key);
                        });
                      },
                      child: Text(
                        s.tr('Mark All', 'حفظ الكل'),
                        style: TextStyle(color: p.accent, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Divider(color: p.border),

                // Verses List for Selected Surah
                ...ayahs.map((item) {
                  final isMemorized = s.memorizedAyahs.contains(item.key);
                  final isRevealed = _temporarilyRevealed.contains(item.key);
                  final isPlayingThis = _playingAyahKey == item.key;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isPlayingThis
                          ? p.accent.withOpacity(0.12)
                          : p.bg.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPlayingThis ? p.accent : p.border,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      leading: IconButton(
                        tooltip: s.tr('Mark Memorized', 'تم الحفظ'),
                        icon: Icon(
                          isMemorized
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isMemorized ? p.accent : p.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => s.toggleMemorized(item.key)),
                      ),
                      title: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          _formatHifzVerseText(item, isRevealed),
                          style: TextStyle(
                            color: p.textPrimary,
                            fontFamily: 'AmiriQuran',
                            fontSize: s.quranFontSize - 2,
                            height: 1.85,
                          ),
                        ),
                      ),
                      subtitle: isPlayingThis
                          ? Text(
                              '${s.tr("Playing Loop", "جاري التكرار")} (${_currentRepeatCount + 1}/$_repeatTarget)',
                              style: TextStyle(color: p.accent, fontSize: 11.5),
                            )
                          : null,
                      trailing: IconButton(
                        icon: Icon(
                          isPlayingThis
                              ? Icons.stop_circle_outlined
                              : Icons.play_circle_outline,
                          color: p.accent,
                        ),
                        onPressed: () {
                          if (isPlayingThis) {
                            _hifzAudioPlayer.stop();
                            setState(() => _playingAyahKey = null);
                          } else {
                            _playHifzAyah(item);
                          }
                        },
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
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHideModeChip(int mode, String label, AppThemePalette p) {
    final selected = _hideMode == mode;
    return ChoiceChip(
      selected: selected,
      selectedColor: p.accent,
      backgroundColor: p.bg,
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.black87 : p.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      onSelected: (_) {
        setState(() {
          _hideMode = mode;
          _temporarilyRevealed.clear();
        });
      },
    );
  }
}

/// Bookmarks & Personal Reflections Screen
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
                      '${ayah.surahNameEn} • ${ayah.key}',
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
              '${meta.nameEn} • ${meta.nameAr}',
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
/// PART 2: Interactive Ad'iyah (أدعية), Azkar & Digital Tasbih Screen
typedef AdiyahScreen = AdiyahAndAzkarScreen;
typedef DuasScreen = AdiyahAndAzkarScreen;
typedef DuasAndAzkarScreen = AdiyahAndAzkarScreen;

class AdiyahAndAzkarScreen extends StatefulWidget {
  final AppState appState;
  const AdiyahAndAzkarScreen({super.key, required this.appState});

  @override
  State<AdiyahAndAzkarScreen> createState() => _AdiyahAndAzkarScreenState();
}

class _AdiyahAndAzkarScreenState extends State<AdiyahAndAzkarScreen> {
  String _selectedCategory = 'all';

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
      'translation':
          'My Lord, increase me in knowledge. (Ta-Ha 20:114)',
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
          'O Allah, have mercy on me through the Qur’an, and make it for me a leader, a light, a guidance, and a mercy. O Allah, remind me of what I have forgotten from it, teach me of what I am ignorant of from it, and grant me its recitation throughout the night and day.',
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
          // 1. Interactive Digital Tasbih Counter Card
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
                        Icon(Icons.spa_outlined. codePoint != 0 ? Icons.spa_outlined : Icons.circle, color: p.accent),
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

          // 2. Category Filter Pills
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
                _buildCatPill('azkar', s.tr('Morning & Evening', 'أذكار الصباح والمساء'), p),
                const SizedBox(width: 8),
                _buildCatPill('khatm', s.tr('Khatm Al-Quran', 'دعاء ختم القرآن'), p),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Interactive Duas & Azkar Cards
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
/// PART 3: Multi-Language Settings, 6 Themes, Hafs/Warsh, 36+ Languages & 184+ Tafsir Screen
typedef SettingsScreen = AzkarAndSettingsScreen;

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
                    fontSize: 17,
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
          // 1. Theme Colors Picker (6 Themes)
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

          // 2. Audio Settings Group
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

          // 3. Reading, Mushaf & Global Language Settings
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

          // 4. Quick Navigation Buttons to Prayer & Qibla and Ad'iyah
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

/// Fallback alias in case any file references HomeDashboardScreen
class HomeDashboardScreen extends StatelessWidget {
  final AppState appState;
  final ValueChanged<int>? onNavigateTab;

  const HomeDashboardScreen({
    super.key,
    required this.appState,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    return QuranReaderScreen(appState: appState);
  }
}
