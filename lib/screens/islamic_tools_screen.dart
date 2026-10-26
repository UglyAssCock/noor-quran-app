import 'package:flutter/material.dart';
import '../services/app_state.dart';
import 'quran_reader_screen.dart';
import 'prayer_qibla_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final AppState appState;
  final ValueChanged<int> onNavigateTab;

  const HomeDashboardScreen({
    super.key,
    required this.appState,
    required this.onNavigateTab,
  });

  void _openSurah(BuildContext context, int surahNum, [int? ayahNum]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActiveMushafView(
          appState: appState,
          initialSurah: surahNum,
          highlightAyah: ayahNum,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = appState;
    final p = s.palette;
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final dailyAyah = s.allAyahs.isNotEmpty
        ? s.allAyahs[dayOfYear % s.allAyahs.length]
        : null;

    return Container(
      color: p.bg,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () => _openSurah(context, 1, 1),
            child: Container(
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.border, width: 1.3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned(
                      right: -8,
                      bottom: -8,
                      child: MosqueArchIllustration(
                        width: 135,
                        height: 130,
                        accent: p.accent,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                            style: TextStyle(
                              color: p.textPrimary,
                              fontFamily: 'AmiriQuran',
                              fontSize: 25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'In the name of Allah, the Entirely Merciful,\nthe Especially Merciful.',
                            style: TextStyle(
                              color: p.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Al-Fatiha • 1:1  (${s.currentMushaf.riwayah})',
                            style: TextStyle(
                              color: p.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildQuickActionCard(
                p,
                icon: Icons.menu_book_rounded,
                label: s.tr('Read\nQuran', 'قراءة\nالمصحف'),
                onTap: () => onNavigateTab(1),
              ),
              const SizedBox(width: 10),
              _buildQuickActionCard(
                p,
                icon: Icons.headphones_rounded,
                label: s.tr('Listen\nAudio', 'الاستماع\nللتلاوة'),
                onTap: () => _openSurah(context, s.lastSurah, s.lastAyah),
              ),
              const SizedBox(width: 10),
              _buildQuickActionCard(
                p,
                icon: Icons.bookmark_border_rounded,
                label: s.tr('Saved &\nBookmarks', 'العلامات\nوالمحفوظات'),
                onTap: () => onNavigateTab(2),
              ),
              const SizedBox(width: 10),
              _buildQuickActionCard(
                p,
                icon: Icons.settings_outlined,
                label: s.tr('Themes &\nSettings', 'المظهر\nوالإعدادات'),
                onTap: () => onNavigateTab(3),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.tr('Continue Reading', 'متابعة القراءة'),
                style: TextStyle(
                  color: p.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () => onNavigateTab(1),
                child: Text(
                  s.tr('View All >', 'عرض الكل >'),
                  style: TextStyle(color: p.accent, fontSize: 13),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _openSurah(context, s.lastSurah, s.lastAyah),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: p.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: p.accent,
                    child: const Icon(Icons.menu_book, color: Colors.black87),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${s.tr("Page", "صفحة")} ${s.lastPage} • ${s.tr("Surah", "سورة")} ${s.lastSurah}:${s.lastAyah}',
                          style: TextStyle(
                            color: p.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${s.selectedReadingPlan} • ${s.khatmaCompletedPages}/604 Pages',
                          style: TextStyle(color: p.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value:
                                (s.khatmaCompletedPages / 604.0).clamp(0.05, 1.0),
                            minHeight: 6,
                            backgroundColor: p.bg,
                            color: p.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.chevron_right, color: p.accent),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.tr('Daily Verse', 'آية اليوم'),
            style: TextStyle(
              color: p.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (dailyAyah != null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: p.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${dailyAyah.surahNameEn} • ${dailyAyah.key}',
                        style: TextStyle(
                          color: p.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        tooltip: s.tr('Share as Image', 'حفظ كصورة'),
                        icon: Icon(Icons.share_outlined,
                            color: p.accent, size: 20),
                        onPressed: () =>
                            showShareVerseAsImageSheet(context, s, dailyAyah),
                      ),
                    ],
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      dailyAyah.textUthmani,
                      style: TextStyle(
                        color: p.textPrimary,
                        fontFamily: 'AmiriQuran',
                        fontSize: 22,
                        height: 1.85,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dailyAyah.translationEn,
                    style: TextStyle(
                      color: p.textSecondary,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    AppThemePalette p, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: p.accent, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
                      '${ayah.surahNameEn} • ${ayah.key}',
                      style: TextStyle(
                        color: p.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: p.textSecondary),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      ayah.textUthmani,
                      maxLines: 1,
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
                  'Page ${ayah.page} • Juz ${ayah.juz}',
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
              '${meta.ayahCount} Verses • Page ${meta.startPage}',
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

/// Fixed Settings Screen (No squished vertical text — uses clean tap-to-open selection modals)
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
                  s.tr(
                    'Select Reciter (${s.reciters.length} Famous Reciters)',
                    'اختر القارئ (${s.reciters.length} قارئاً)',
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
        initialChildSize: 0.72,
        builder: (ctx, scrollCtrl) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.tr(
                    'Select Global Language (${s.globalLanguages.length}+ Languages)',
                    'اختر لغة الترجمة والواجهة',
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
                            style: TextStyle(color: p.textPrimary),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: p.accent)
                              : null,
                          onTap: () {
                            s.switchLanguageAndDownloadTranslation(lang);
                            Navigator.pop(ctx);
                            setState(() {});
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
                    '184+ Tafsir & Translation Sources (${s.catalogEditions.length} Loaded)',
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
                          s.isArabicUi ? t.nameAr : t.nameEn,
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

          // 2. Audio Settings Group (Fixed wide row layout)
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

          // 3. Reading & Mushaf Settings Group
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
                    'Global Languages (36+ Languages)',
                    'لغات العالم والترجمة',
                  ),
                  valueText:
                      'Active Language: ${s.selectedLanguageCode.toUpperCase()}',
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
                  icon: const Icon(Icons.school),
                  label: Text(s.tr('Hifz & Khatmah', 'الحفظ والختمة')),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            title:
                                Text(s.tr('Hifz & Khatmah', 'الحفظ والختمة')),
                          ),
                          body: HifzAndKhatmaScreen(appState: s),
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

class HifzAndKhatmaScreen extends StatefulWidget {
  final AppState appState;
  const HifzAndKhatmaScreen({super.key, required this.appState});

  @override
  State<HifzAndKhatmaScreen> createState() => _HifzAndKhatmaScreenState();
}

class _HifzAndKhatmaScreenState extends State<HifzAndKhatmaScreen> {
  int _selectedSurah = 1;
  bool _hideTextForTesting = true;
  final Set<String> _temporarilyRevealed = {};

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    final p = s.palette;
    final ayahs = s.surahMap[_selectedSurah] ?? [];
    final progressRatio = (s.khatmaCompletedPages / 604.0).clamp(0.0, 1.0);

    return Container(
      color: p.bg,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.tr(
                    'Quran Reading Plans & Khatmah',
                    'خطط ختم القرآن والورد اليومي',
                  ),
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progressRatio,
                  minHeight: 10,
                  backgroundColor: p.bg,
                  color: p.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 10),
                Text(
                  '${s.khatmaCompletedPages} / 604 Pages (${(progressRatio * 100).toStringAsFixed(1)}%)',
                  style: TextStyle(color: p.textSecondary),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.accent,
                    foregroundColor: Colors.black87,
                  ),
                  icon: const Icon(Icons.add),
                  label: Text('+${s.khatmaDailyGoalPages} Pages Completed'),
                  onPressed: () => setState(
                    () => s.updateKhatmaProgress(
                      s.khatmaCompletedPages + s.khatmaDailyGoalPages,
                      s.khatmaDailyGoalPages,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
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
                    Expanded(
                      child: Text(
                        s.tr('Hifz Memorization Mode', 'وضع الحفظ والمراجعة'),
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                      activeColor: p.accent,
                      value: _hideTextForTesting,
                      onChanged: (v) => setState(() {
                        _hideTextForTesting = v;
                        _temporarilyRevealed.clear();
                      }),
                    ),
                  ],
                ),
                ...ayahs.take(25).map((item) {
                  final isHidden = _hideTextForTesting &&
                      !_temporarilyRevealed.contains(item.key);
                  return ListTile(
                    title: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        isHidden
                            ? '•••••• ﴿${item.numberInSurah}﴾ (Tap to reveal)'
                            : '${item.textUthmani} ﴿${item.numberInSurah}﴾',
                        style: TextStyle(
                          color: p.textPrimary,
                          fontFamily: 'AmiriQuran',
                          fontSize: 22,
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
        ],
      ),
    );
  }
}
