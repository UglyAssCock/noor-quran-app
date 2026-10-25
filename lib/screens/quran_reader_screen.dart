import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/app_state.dart';

class QuranReaderScreen extends StatefulWidget {
  final AppState appState;
  const QuranReaderScreen({super.key, required this.appState});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openReader({
    int? surahNum,
    int? juzNum,
    int? pageNum,
    int? startAyah,
    bool autoPlayFullSurah = false,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActiveMushafView(
          appState: widget.appState,
          initialSurah: surahNum,
          initialJuz: juzNum,
          initialPage: pageNum,
          highlightAyah: startAyah,
          autoPlayFullSurah: autoPlayFullSurah,
        ),
      ),
    );
  }

  Future<void> _handleSurahDownload(SurahMeta surah) async {
    final s = widget.appState;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          s.tr(
            'Downloading ${surah.nameEn} (${s.selectedReciter.nameEn})...',
            'جاري تحميل سورة ${surah.nameAr} (${s.selectedReciter.nameAr})...',
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    final ok = await s.downloadFullSurah(surah.number);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? s.tr(
                  '${surah.nameEn} saved for offline playback!',
                  'تم حفظ سورة ${surah.nameAr} للاستماع بدون إنترنت!',
                )
              : s.tr(
                  'Download failed. Please check your internet connection.',
                  'فشل التحميل. يرجى التحقق من الاتصال بالإنترنت.',
                ),
        ),
      ),
    );
  }

  void _showOfflineSurahOptions(SurahMeta surah) {
    final s = widget.appState;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.offline_pin, color: Colors.green),
              title: Text('${surah.nameEn} • ${surah.nameAr}'),
              subtitle: Text(
                s.tr(
                  'Saved offline (${s.selectedReciter.nameEn})',
                  'محفوظة بدون إنترنت (${s.selectedReciter.nameAr})',
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.play_circle_fill, color: Color(0xFF0B3B2E)),
              title: Text(
                s.tr('Play Full Surah Offline', 'تشغيل السورة كاملة بدون إنترنت'),
              ),
              onTap: () {
                Navigator.pop(context);
                _openReader(surahNum: surah.number, autoPlayFullSurah: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: Text(
                s.tr('Delete Offline MP3', 'حذف الملف الصوتي المحفوظ'),
              ),
              onTap: () async {
                Navigator.pop(context);
                await s.deleteOfflineSurah(surah.number);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      s.tr('Offline MP3 removed.', 'تم حذف الملف الصوتي.'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    return Column(
      children: [
        // Continue Where I Stopped Banner
        Container(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0B3B2E), Color(0xFF165B47)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: Color(0xFFD4AF37), size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.tr('Continue Where You Stopped', 'متابعة القراءة من حيث توقفت'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${s.tr("Surah", "سورة")} ${s.lastSurah} • ${s.tr("Verse", "آية")} ${s.lastAyah} (${s.tr("Page", "صفحة")} ${s.lastPage})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black87,
                ),
                onPressed: () => _openReader(
                  surahNum: s.lastSurah,
                  startAyah: s.lastAyah,
                ),
                child: Text(s.tr('Resume', 'متابعة')),
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: s.tr(
                'Search word or verse (e.g. 2:255 or mercy)...',
                'ابحث عن كلمة أو رقم آية (مثال 2:255 أو رحمة)...',
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        if (_searchQuery.isNotEmpty)
          Expanded(child: _buildSearchResults(s))
        else ...[
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: s.tr('Surah', 'السور')),
              Tab(text: s.tr('Juz', 'الأجزاء')),
              Tab(text: s.tr('Pages', 'الصفحات')),
              Tab(text: s.tr('Saved', 'المحفوظات')),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSurahList(s),
                _buildJuzList(s),
                _buildPageGrid(s),
                _buildSavedItemsList(s),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchResults(AppState s) {
    final q = _searchQuery.toLowerCase();
    final results = s.allAyahs.where((a) {
      if (a.key == q || '${a.surahNumber}:${a.numberInSurah}' == q) return true;
      return a.textUthmani.contains(_searchQuery) ||
          a.translationEn.toLowerCase().contains(q) ||
          a.translationFr.toLowerCase().contains(q) ||
          a.tafsirAr.contains(_searchQuery);
    }).take(100).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(s.tr('No matching verses found.', 'لم يتم العثور على آيات مطابقة.')),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, idx) {
        final item = results[idx];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: ListTile(
            title: Text(
              item.textUthmani,
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'AmiriQuran', fontSize: 20),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  '${item.surahNameEn} (${item.key}) • ${s.tr("Page", "صفحة")} ${item.page}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(item.translationEn, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
            onTap: () => _openReader(
              surahNum: item.surahNumber,
              startAyah: item.numberInSurah,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahList(AppState s) {
    return ListView.separated(
      itemCount: s.surahs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final surah = s.surahs[index];
        final isDownloaded = s.isSurahDownloaded(surah.number);
        final isDownloading = s.isDownloadingSurah(surah.number);
        final progress = s.getSurahDownloadProgress(surah.number);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF0B3B2E),
            foregroundColor: const Color(0xFFD4AF37),
            child: Text('${surah.number}'),
          ),
          title: Text(
            '${surah.nameEn} • ${surah.nameAr}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${surah.meaningEn} • ${surah.ayahCount} ${s.tr("Verses", "آيات")} (${surah.revelationType})',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDownloading)
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        color: const Color(0xFFD4AF37),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isDownloaded)
                IconButton(
                  tooltip: s.tr('Offline Ready (Tap for options)', 'متاح بدون إنترنت'),
                  icon: const Icon(Icons.offline_pin, color: Colors.green),
                  onPressed: () => _showOfflineSurahOptions(surah),
                )
              else
                IconButton(
                  tooltip: s.tr('Download Full Surah MP3', 'تحميل السورة كاملة MP3'),
                  icon: const Icon(
                    Icons.download_for_offline_outlined,
                    color: Color(0xFFD4AF37),
                  ),
                  onPressed: () => _handleSurahDownload(surah),
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () => _openReader(surahNum: surah.number),
        );
      },
    );
  }

  Widget _buildJuzList(AppState s) {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNum = index + 1;
        final ayahsInJuz = s.juzMap[juzNum] ?? [];
        final firstAyah = ayahsInJuz.isNotEmpty ? ayahsInJuz.first : null;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF165B47),
              foregroundColor: Colors.white,
              child: Text('$juzNum'),
            ),
            title: Text('${s.tr("Juz", "الجزء")} $juzNum'),
            subtitle: firstAyah != null
                ? Text('${s.tr("Starts at", "يبدأ من")} ${firstAyah.surahNameEn} ${firstAyah.key}')
                : null,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openReader(juzNum: juzNum),
          ),
        );
      },
    );
  }

  Widget _buildPageGrid(AppState s) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
      ),
      itemCount: 604,
      itemBuilder: (context, index) {
        final pageNum = index + 1;
        return InkWell(
          onTap: () => _openReader(pageNum: pageNum),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD4AF37)),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '${s.tr("P.", "ص")} $pageNum',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedItemsList(AppState s) {
    final allKeys = <String>{
      ...s.bookmarks,
      ...s.favorites,
      ...s.ayahNotes.keys,
    }.toList();

    if (allKeys.isEmpty) {
      return Center(
        child: Text(
          s.tr(
            'Bookmarks, favorites, and verse notes will appear here.',
            'ستظهر العلامات المرجعية والمفضلة والملاحظات هنا.',
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: allKeys.length,
      itemBuilder: (context, idx) {
        final key = allKeys[idx];
        final parts = key.split(':');
        final sNum = int.tryParse(parts[0]) ?? 1;
        final aNum = int.tryParse(parts[1]) ?? 1;
        final note = s.ayahNotes[key];
        final isBm = s.bookmarks.contains(key);
        final isFav = s.favorites.contains(key);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isBm) const Icon(Icons.bookmark, color: Color(0xFFD4AF37)),
                if (isFav) const Icon(Icons.favorite, color: Colors.redAccent),
              ],
            ),
            title: Text('${s.tr("Verse", "آية")} $key'),
            subtitle: note != null ? Text('${s.tr("Note", "ملاحظة")}: $note') : null,
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openReader(surahNum: sNum, startAyah: aNum),
          ),
        );
      },
    );
  }
}

class ActiveMushafView extends StatefulWidget {
  final AppState appState;
  final int? initialSurah;
  final int? initialJuz;
  final int? initialPage;
  final int? highlightAyah;
  final bool autoPlayFullSurah;

  const ActiveMushafView({
    super.key,
    required this.appState,
    this.initialSurah,
    this.initialJuz,
    this.initialPage,
    this.highlightAyah,
    this.autoPlayFullSurah = false,
  });

  @override
  State<ActiveMushafView> createState() => _ActiveMushafViewState();
}

class _ActiveMushafViewState extends State<ActiveMushafView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMushafPageMode = false;
  bool _repeatCurrentAyah = false;
  bool _continuousPlay = true;
  bool _isPlaying = false;
  bool _isPlayingFullSurahMode = false;
  int _activeIndex = 0;

  late List<AyahItem> _currentAyahs;

  @override
  void initState() {
    super.initState();
    _loadAyahSet();
    _setupAudioListener();
    if (widget.autoPlayFullSurah) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playFullSurahAudio();
      });
    }
  }

  void _loadAyahSet() {
    final s = widget.appState;
    if (widget.initialPage != null) {
      _currentAyahs = s.pageMap[widget.initialPage!] ?? [];
      _isMushafPageMode = true;
    } else if (widget.initialJuz != null) {
      _currentAyahs = s.juzMap[widget.initialJuz!] ?? [];
    } else {
      final surahNum = widget.initialSurah ?? 1;
      _currentAyahs = s.surahMap[surahNum] ?? [];
    }

    if (widget.highlightAyah != null) {
      final idx = _currentAyahs.indexWhere(
        (a) => a.numberInSurah == widget.highlightAyah,
      );
      if (idx != -1) _activeIndex = idx;
    }

    if (_currentAyahs.isNotEmpty) {
      final first = _currentAyahs[_activeIndex];
      s.saveLastRead(
        surah: first.surahNumber,
        ayah: first.numberInSurah,
        page: first.page,
      );
    }
  }

  void _setupAudioListener() {
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state.playing);

      if (state.processingState == ProcessingState.completed) {
        if (_isPlayingFullSurahMode) {
          if (_repeatCurrentAyah) {
            _playFullSurahAudio();
          }
          return;
        }
        if (_repeatCurrentAyah) {
          _playAyahAtIndex(_activeIndex);
        } else if (_continuousPlay && _activeIndex + 1 < _currentAyahs.length) {
          _playAyahAtIndex(_activeIndex + 1);
        }
      }
    });
  }

  Future<void> _playFullSurahAudio() async {
    if (_currentAyahs.isEmpty) return;
    final s = widget.appState;
    final surahNum = _currentAyahs.first.surahNumber;
    setState(() => _isPlayingFullSurahMode = true);

    try {
      if (s.isSurahDownloaded(surahNum)) {
        final localPath = s.localSurahFilePath(surahNum);
        await _audioPlayer.setFilePath(localPath);
      } else {
        final remoteUrl = s.fullSurahRemoteUrl(surahNum);
        await _audioPlayer.setUrl(remoteUrl);
      }
      await _audioPlayer.play();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.tr(
              'Download this Surah first or connect to the internet.',
              'يرجى تحميل السورة أولاً أو الاتصال بالإنترنت.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _playAyahAtIndex(int index) async {
    if (index < 0 || index >= _currentAyahs.length) return;
    setState(() {
      _activeIndex = index;
      _isPlayingFullSurahMode = false;
    });
    final ayah = _currentAyahs[index];
    widget.appState.saveLastRead(
      surah: ayah.surahNumber,
      ayah: ayah.numberInSurah,
      page: ayah.page,
    );
    final url = widget.appState.audioUrlForAyah(
      ayah.surahNumber,
      ayah.numberInSurah,
    );
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      // Fallback to offline Full Surah MP3 if saved
      if (widget.appState.isSurahDownloaded(ayah.surahNumber)) {
        await _playFullSurahAudio();
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.appState.tr(
              'Check internet connection or tap Download to save Surah offline.',
              'تحقق من الإنترنت أو قم بتحميل السورة للاستماع بدون إنترنت.',
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showNoteDialog(AyahItem item) {
    final ctrl = TextEditingController(
      text: widget.appState.ayahNotes[item.key] ?? '',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${widget.appState.tr("Note for", "ملاحظة للآية")} ${item.key}'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: widget.appState.tr('Write your reflection...', 'اكتب تدبرك أو ملاحظتك...'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.appState.tr('Cancel', 'إلغاء')),
          ),
          ElevatedButton(
            onPressed: () {
              widget.appState.saveNote(item.key, ctrl.text);
              Navigator.pop(context);
              setState(() {});
            },
            child: Text(widget.appState.tr('Save', 'حفظ')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    final currentSurahNum =
        _currentAyahs.isNotEmpty ? _currentAyahs.first.surahNumber : 1;
    final isOfflineReady = s.isSurahDownloaded(currentSurahNum);
    final isDownloading = s.isDownloadingSurah(currentSurahNum);

    final titleText = _currentAyahs.isNotEmpty
        ? '${_currentAyahs.first.surahNameEn} • ${_currentAyahs.first.surahNameAr}'
        : s.tr('Quran Reader', 'المصحف الشريف');

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText, style: const TextStyle(fontSize: 16)),
        actions: [
          if (isDownloading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFFD4AF37),
                ),
              ),
            )
          else
            IconButton(
              tooltip: isOfflineReady
                  ? s.tr('Saved Offline (Tap to Play Full Surah)', 'محفوظة بدون إنترنت')
                  : s.tr('Download Full Surah MP3', 'تحميل السورة كاملة MP3'),
              icon: Icon(
                isOfflineReady ? Icons.offline_pin : Icons.download_for_offline_outlined,
                color: isOfflineReady ? Colors.greenAccent : const Color(0xFFD4AF37),
              ),
              onPressed: () async {
                if (isOfflineReady) {
                  await _playFullSurahAudio();
                } else {
                  await s.downloadFullSurah(currentSurahNum);
                  if (mounted) setState(() {});
                }
              },
            ),
          IconButton(
            tooltip: s.tr('Switch Page / List Mode', 'تبديل وضع الصفحة / القائمة'),
            icon: Icon(_isMushafPageMode ? Icons.view_list : Icons.auto_stories),
            onPressed: () => setState(() => _isMushafPageMode = !_isMushafPageMode),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate),
            onSelected: (val) => setState(() => s.setTranslationEdition(val)),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'en', child: Text('English (Saheeh International)')),
              const PopupMenuItem(value: 'fr', child: Text('Français (Hamidullah)')),
              const PopupMenuItem(value: 'ar_tafsir', child: Text('التفسير الميسر (Al-Muyassar)')),
              const PopupMenuItem(value: 'ibn_kathir', child: Text('تفسير ابن كثير + الميسر (Ibn Kathir)')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isMushafPageMode
                ? _buildMushafPageView(s)
                : _buildVerseByVerseListView(s),
          ),
          _buildAudioControlBar(s, isOfflineReady),
        ],
      ),
    );
  }

  Widget _buildMushafPageView(AppState s) {
    final combinedText = _currentAyahs
        .map((a) => '${a.textUthmani} ﴿${a.numberInSurah}﴾')
        .join(' ');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: s.isDarkMode ? const Color(0xFF132A23) : const Color(0xFFFFFDF7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        ),
        child: Column(
          children: [
            if (_currentAyahs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${_currentAyahs.first.surahNameAr} • ${s.tr("Page", "صفحة")} ${_currentAyahs.first.page} • ${s.tr("Juz", "الجزء")} ${_currentAyahs.first.juz}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ),
            const Divider(color: Color(0xFFD4AF37)),
            const SizedBox(height: 10),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                combinedText,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'AmiriQuran',
                  fontSize: s.quranFontSize,
                  height: 2.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseByVerseListView(AppState s) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _currentAyahs.length,
      itemBuilder: (context, index) {
        final item = _currentAyahs[index];
        final isSelected = index == _activeIndex;
        final isBookmarked = s.bookmarks.contains(item.key);
        final isFav = s.favorites.contains(item.key);
        final note = s.ayahNotes[item.key];

        String subText = item.translationEn;
        if (s.selectedTranslation == 'fr') {
          subText = item.translationFr;
        } else if (s.selectedTranslation == 'ar_tafsir') {
          subText = 'التفسير الميسر: ${item.tafsirAr}';
        } else if (s.selectedTranslation == 'ibn_kathir') {
          subText =
              'خلاصة ابن كثير والميسر (${item.key}): ${item.tafsirAr}\n\n[EN]: ${item.translationEn}';
        }

        return Card(
          color: isSelected
              ? (s.isDarkMode ? const Color(0xFF1D4438) : const Color(0xFFEAF5F0))
              : null,
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B3B2E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.key,
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.play_circle_outline),
                      onPressed: () => _playAyahAtIndex(index),
                    ),
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? const Color(0xFFD4AF37) : null,
                      ),
                      onPressed: () => setState(() => s.toggleBookmark(item.key)),
                    ),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.redAccent : null,
                      ),
                      onPressed: () => setState(() => s.toggleFavorite(item.key)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_note),
                      onPressed: () => _showNoteDialog(item),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    item.textUthmani,
                    style: TextStyle(
                      fontFamily: 'AmiriQuran',
                      fontSize: s.quranFontSize,
                      height: 2.0,
                    ),
                  ),
                ),
                const Divider(height: 20),
                Text(
                  subText,
                  style: const TextStyle(fontSize: 15, height: 1.45),
                ),
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('📝 $note'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudioControlBar(AppState s, bool isOfflineReady) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3B2E),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.record_voice_over, color: Color(0xFFD4AF37), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ReciterOption>(
                      dropdownColor: const Color(0xFF0B3B2E),
                      value: s.selectedReciter,
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      items: s.reciters
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text('${r.nameEn} (${r.nameAr})'),
                            ),
                          )
                          .toList(),
                      onChanged: (r) {
                        if (r != null) {
                          setState(() => s.setReciter(r));
                          if (_isPlaying) {
                            if (_isPlayingFullSurahMode) {
                              _playFullSurahAudio();
                            } else {
                              _playAyahAtIndex(_activeIndex);
                            }
                          }
                        }
                      },
                    ),
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isOfflineReady ? Colors.greenAccent : const Color(0xFFD4AF37),
                  ),
                  icon: Icon(
                    isOfflineReady ? Icons.offline_pin : Icons.album,
                    size: 18,
                  ),
                  label: Text(
                    isOfflineReady
                        ? s.tr('Play Offline', 'تشغيل بدون نت')
                        : s.tr('Full Surah', 'السورة كاملة'),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: _playFullSurahAudio,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  tooltip: s.tr('Repeat', 'تكرار'),
                  icon: Icon(
                    Icons.repeat_one,
                    color: _repeatCurrentAyah ? const Color(0xFFD4AF37) : Colors.white70,
                  ),
                  onPressed: () =>
                      setState(() => _repeatCurrentAyah = !_repeatCurrentAyah),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: _activeIndex > 0
                      ? () => _playAyahAtIndex(_activeIndex - 1)
                      : null,
                ),
                CircleAvatar(
                  backgroundColor: const Color(0xFFD4AF37),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      if (_isPlaying) {
                        _audioPlayer.pause();
                      } else if (_isPlayingFullSurahMode) {
                        _audioPlayer.play();
                      } else {
                        _playAyahAtIndex(_activeIndex);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  onPressed: _activeIndex + 1 < _currentAyahs.length
                      ? () => _playAyahAtIndex(_activeIndex + 1)
                      : null,
                ),
                IconButton(
                  tooltip: s.tr('Continuous Play', 'تشغيل متواصل'),
                  icon: Icon(
                    Icons.playlist_play,
                    color: _continuousPlay ? const Color(0xFFD4AF37) : Colors.white70,
                  ),
                  onPressed: () => setState(() => _continuousPlay = !_continuousPlay),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
