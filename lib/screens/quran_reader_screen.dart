import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../services/app_state.dart';

/// Draws the 8-pointed scalloped Islamic star badge from the design mockup
class RubElHizbBadge extends StatelessWidget {
  final String label;
  final double size;
  final Color color;

  const RubElHizbBadge({
    super.key,
    required this.label,
    this.size = 38,
    this.color = const Color(0xFF5CE1B6),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StarBadgePainter(color: color),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.34,
            ),
          ),
        ),
      ),
    );
  }
}

class _StarBadgePainter extends CustomPainter {
  final Color color;
  _StarBadgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.10)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width * 0.46;
    final innerR = size.width * 0.36;
    const points = 8;

    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * math.pi / points) - (math.pi / 2);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Draws the glowing Emerald Mosque Arch with Crescent Moon & Stars from the design
class MosqueArchIllustration extends StatelessWidget {
  final double width;
  final double height;
  final Color accent;

  const MosqueArchIllustration({
    super.key,
    this.width = 140,
    this.height = 135,
    this.accent = const Color(0xFF5CE1B6),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _MosqueArchPainter(accent: accent),
      ),
    );
  }
}

class _MosqueArchPainter extends CustomPainter {
  final Color accent;
  _MosqueArchPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final archPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withOpacity(0.32),
          accent.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final borderPaint = Paint()
      ..color = accent.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // Islamic pointed arch frame
    final arch = Path()
      ..moveTo(w * 0.12, h)
      ..lineTo(w * 0.12, h * 0.45)
      ..quadraticBezierTo(w * 0.12, h * 0.18, w * 0.5, h * 0.04)
      ..quadraticBezierTo(w * 0.88, h * 0.18, w * 0.88, h * 0.45)
      ..lineTo(w * 0.88, h)
      ..close();

    canvas.drawPath(arch, archPaint);
    canvas.drawPath(arch, borderPaint);

    // Crescent Moon
    final moonPaint = Paint()..color = accent.withOpacity(0.85);
    canvas.drawCircle(Offset(w * 0.52, h * 0.30), w * 0.09, moonPaint);
    final cutPaint = Paint()..color = const Color(0xFF072820);
    canvas.drawCircle(Offset(w * 0.56, h * 0.27), w * 0.08, cutPaint);

    // Mosque Dome & Minarets Silhouette
    final silhouettePaint = Paint()..color = const Color(0xFF041A15).withOpacity(0.85);
    // Center Dome
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.78), width: w * 0.38, height: h * 0.34),
      math.pi,
      math.pi,
      true,
      silhouettePaint,
    );
    // Base building
    canvas.drawRect(Rect.fromLTWH(w * 0.18, h * 0.77, w * 0.64, h * 0.23), silhouettePaint);
    // Left & Right Minarets
    canvas.drawRect(Rect.fromLTWH(w * 0.22, h * 0.44, w * 0.05, h * 0.56), silhouettePaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.73, h * 0.44, w * 0.05, h * 0.56), silhouettePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Shareable Verse + Tafsir Image Modal
Future<void> showShareVerseAsImageSheet(
  BuildContext context,
  AppState appState,
  AyahItem ayah,
) async {
  final boundaryKey = GlobalKey();
  final p = appState.palette;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
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
            Text(
              appState.tr('Share Verse & Tafsir as Image', 'مشاركة الآية والتفسير كصورة'),
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            RepaintBoundary(
              key: boundaryKey,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [p.card, p.bg],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.accent.withOpacity(0.6), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        RubElHizbBadge(
                          label: '${ayah.numberInSurah}',
                          size: 36,
                          color: p.accent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${ayah.surahNameEn} (${ayah.key})',
                            style: TextStyle(
                              color: p.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          ayah.surahNameAr,
                          style: TextStyle(
                            color: p.textPrimary,
                            fontFamily: 'AmiriQuran',
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        ayah.textUthmani,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: p.textPrimary,
                          fontFamily: 'AmiriQuran',
                          fontSize: 24,
                          height: 1.9,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      ayah.translationEn,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                    const Divider(height: 22, color: Color(0xFF195A4B)),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        'التفسير: ${ayah.tafsirAr}',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.textPrimary.withOpacity(0.9),
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: p.accent,
                      side: BorderSide(color: p.accent),
                    ),
                    icon: const Icon(Icons.copy),
                    label: Text(appState.tr('Copy Text + Tafsir', 'نسخ النص والتفسير')),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text:
                              '${ayah.textUthmani} [${ayah.surahNameEn} ${ayah.key}]\n\n${ayah.translationEn}\n\nالتفسير: ${ayah.tafsirAr}',
                        ),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            appState.tr('Copied Verse & Tafsir!', 'تم نسخ الآية والتفسير!'),
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
                      backgroundColor: p.accent,
                      foregroundColor: Colors.black87,
                    ),
                    icon: const Icon(Icons.image),
                    label: Text(appState.tr('Save PNG Image', 'حفظ كصورة PNG')),
                    onPressed: () async {
                      try {
                        final boundary = boundaryKey.currentContext!
                            .findRenderObject() as RenderRepaintBoundary;
                        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
                        final ByteData? byteData =
                            await image.toByteData(format: ui.ImageByteFormat.png);
                        if (byteData != null) {
                          final pngBytes = byteData.buffer.asUint8List();
                          final path =
                              '${Directory.systemTemp.path}/quran_verse_${ayah.surahNumber}_${ayah.numberInSurah}.png';
                          final file = File(path);
                          await file.writeAsBytes(pngBytes);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  appState.tr(
                                    'High-res PNG saved (${(pngBytes.length / 1024).toStringAsFixed(0)} KB)!',
                                    'تم حفظ بطاقة الآية والتفسير كصورة عالية الدقة!',
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      } catch (_) {}
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class QuranReaderScreen extends StatefulWidget {
  final AppState appState;
  const QuranReaderScreen({super.key, required this.appState});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _revelationFilter = 'All'; // 'All', 'Meccan', 'Medinan'
  String _browseMode = 'Surahs'; // 'Surahs', 'Juz', 'Pages'

  @override
  void dispose() {
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
              : s.tr('Download failed. Check internet.', 'فشل التحميل.'),
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
      child: Column(
        children: [
          // Smart Spelling-Based Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: p.textPrimary),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: s.tr(
                  'Smart Search: word, root, or verse (e.g. 2:255, mercy, الحمد)...',
                  'البحث الذكي: كلمة أو آية بدون تشكيل (مثال 2:255 أو الحمد)...',
                ),
                hintStyle: TextStyle(color: p.textSecondary, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: p.accent),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: p.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: p.card,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: p.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: p.accent),
                ),
              ),
            ),
          ),

          // Filter Pills matching Screenshot 2 top-right (All | Meccan | Medinan + Juz | Pages)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterPill('All', s.tr('All', 'الكل'), p),
                const SizedBox(width: 8),
                _buildFilterPill('Meccan', s.tr('Meccan', 'مكية'), p),
                const SizedBox(width: 8),
                _buildFilterPill('Medinan', s.tr('Medinan', 'مدنية'), p),
                const SizedBox(width: 14),
                _buildBrowsePill('Juz', s.tr('30 Juz', 'الأجزاء'), p),
                const SizedBox(width: 8),
                _buildBrowsePill('Pages', s.tr('604 Pages', 'الصفحات'), p),
              ],
            ),
          ),

          if (_searchQuery.isNotEmpty)
            Expanded(child: _buildSmartSearchResults(s, p))
          else if (_browseMode == 'Juz')
            Expanded(child: _buildJuzList(s, p))
          else if (_browseMode == 'Pages')
            Expanded(child: _buildPageGrid(s, p))
          else
            Expanded(child: _buildSurahList(s, p)),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String key, String label, AppThemePalette p) {
    final selected = _browseMode == 'Surahs' && _revelationFilter == key;
    return GestureDetector(
      onTap: () => setState(() {
        _browseMode = 'Surahs';
        _revelationFilter = key;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? p.accent : p.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? p.accent : p.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black87 : p.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildBrowsePill(String mode, String label, AppThemePalette p) {
    final selected = _browseMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _browseMode = mode),
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
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSmartSearchResults(AppState s, AppThemePalette p) {
    final qLower = _searchQuery.toLowerCase();
    final qNormAr = s.normalizeArabicForSearch(_searchQuery);

    final results = s.allAyahs.where((a) {
      if (a.key == qLower) return true;
      if (a.surahNameEn.toLowerCase().contains(qLower)) return true;
      if (a.translationEn.toLowerCase().contains(qLower) ||
          a.translationFr.toLowerCase().contains(qLower)) {
        return true;
      }
      if (qNormAr.isNotEmpty) {
        final normUthmani = s.normalizeArabicForSearch(a.textUthmani);
        final normTafsir = s.normalizeArabicForSearch(a.tafsirAr);
        if (normUthmani.contains(qNormAr) || normTafsir.contains(qNormAr)) {
          return true;
        }
      }
      return false;
    }).take(100).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          s.tr('No matching verses found.', 'لم يتم العثور على آيات مطابقة.'),
          style: TextStyle(color: p.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: results.length,
      itemBuilder: (context, idx) {
        final item = results[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.border),
          ),
          child: ListTile(
            leading: RubElHizbBadge(
              label: '${item.numberInSurah}',
              size: 36,
              color: p.accent,
            ),
            title: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                item.textUthmani,
                style: TextStyle(
                  color: p.textPrimary,
                  fontFamily: 'AmiriQuran',
                  fontSize: 20,
                ),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${item.surahNameEn} (${item.key}) • ${item.translationEn}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: p.textSecondary, fontSize: 12.5),
              ),
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

  Widget _buildSurahList(AppState s, AppThemePalette p) {
    final filtered = s.surahs.where((surah) {
      if (_revelationFilter == 'All') return true;
      return surah.revelationType.toLowerCase() ==
          _revelationFilter.toLowerCase();
    }).toList();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => Divider(color: p.border.withOpacity(0.5), height: 1),
      itemBuilder: (context, index) {
        final surah = filtered[index];
        final isDownloaded = s.isSurahDownloaded(surah.number);
        final isDownloading = s.isDownloadingSurah(surah.number);
        final progress = s.getSurahDownloadProgress(surah.number);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          leading: RubElHizbBadge(
            label: '${surah.number}',
            size: 42,
            color: p.accent,
          ),
          title: Text(
            surah.nameEn,
            style: TextStyle(
              color: p.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            '${surah.ayahCount} ${s.tr("Verses", "آيات")} • ${surah.revelationType}',
            style: TextStyle(color: p.textSecondary, fontSize: 12.5),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                surah.nameAr.replaceAll('سُورَةُ ', ''),
                style: TextStyle(
                  color: p.textPrimary,
                  fontFamily: 'AmiriQuran',
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 8),
              if (isDownloading)
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2.5,
                    color: p.accent,
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    isDownloaded
                        ? Icons.offline_pin
                        : Icons.download_for_offline_outlined,
                    color: isDownloaded ? p.accent : p.textSecondary,
                    size: 22,
                  ),
                  onPressed: () => _handleSurahDownload(surah),
                ),
              Icon(Icons.chevron_right, color: p.textSecondary, size: 18),
            ],
          ),
          onTap: () => _openReader(surahNum: surah.number),
        );
      },
    );
  }

  Widget _buildJuzList(AppState s, AppThemePalette p) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNum = index + 1;
        final ayahsInJuz = s.juzMap[juzNum] ?? [];
        final firstAyah = ayahsInJuz.isNotEmpty ? ayahsInJuz.first : null;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.border),
          ),
          child: ListTile(
            leading: RubElHizbBadge(label: '$juzNum', size: 40, color: p.accent),
            title: Text(
              '${s.tr("Juz", "الجزء")} $juzNum',
              style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.bold),
            ),
            subtitle: firstAyah != null
                ? Text(
                    '${firstAyah.surahNameEn} (${firstAyah.key}) • ${s.tr("Page", "صفحة")} ${firstAyah.page}',
                    style: TextStyle(color: p.textSecondary),
                  )
                : null,
            trailing: Icon(Icons.chevron_right, color: p.accent),
            onTap: () => _openReader(juzNum: juzNum),
          ),
        );
      },
    );
  }

  Widget _buildPageGrid(AppState s, AppThemePalette p) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.35,
      ),
      itemCount: 604,
      itemBuilder: (context, index) {
        final pageNum = index + 1;
        return InkWell(
          onTap: () => _openReader(pageNum: pageNum),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.border),
            ),
            alignment: Alignment.center,
            child: Text(
              '${s.tr("Page", "ص")} $pageNum',
              style: TextStyle(
                color: p.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Full Surah & Mushaf Reader Screen matching Image 1 (Centered Mushaf) & Image 2 (List + Tafsir)
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
  final ScrollController _scrollController = ScrollController();

  bool _isCenteredMushafMode = true; // True = Image 1 Centered Mushaf, False = Image 2 List + Tafsir
  bool _repeatCurrentAyah = false;
  bool _continuousPlay = true;
  bool _isPlaying = false;
  bool _isPlayingFullSurahMode = false;
  bool _isAutoScrolling = false;

  int _activeIndex = 0;
  int _highlightedWordIndex = -1;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(seconds: 15);
  Timer? _autoScrollTimer;

  late int _currentSurahNumber;
  late List<AyahItem> _currentAyahs;

  @override
  void initState() {
    super.initState();
    _currentSurahNumber = widget.initialSurah ?? 1;
    _loadAyahSet();
    _setupAudioListeners();
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
    } else if (widget.initialJuz != null) {
      _currentAyahs = s.juzMap[widget.initialJuz!] ?? [];
    } else {
      _currentAyahs = s.surahMap[_currentSurahNumber] ?? [];
    }

    if (_currentAyahs.isNotEmpty) {
      _currentSurahNumber = _currentAyahs.first.surahNumber;
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

  void _switchToSurah(int newSurahNum) {
    if (newSurahNum < 1 || newSurahNum > 114) return;
    _audioPlayer.stop();
    setState(() {
      _currentSurahNumber = newSurahNum;
      _activeIndex = 0;
      _highlightedWordIndex = -1;
      _currentAyahs = widget.appState.surahMap[newSurahNum] ?? [];
    });
  }

  void _setupAudioListeners() {
    _audioPlayer.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() {
        _position = pos;
        // Synchronize Word-by-Word Highlighting with audio progress
        if (_isPlaying &&
            !_isPlayingFullSurahMode &&
            _activeIndex < _currentAyahs.length &&
            _duration.inMilliseconds > 200) {
          final words = _currentAyahs[_activeIndex].textUthmani.split(' ');
          final ratio =
              (pos.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 0.99);
          _highlightedWordIndex = (ratio * words.length).floor();
        }
      });
    });

    _audioPlayer.durationStream.listen((dur) {
      if (!mounted || dur == null) return;
      setState(() => _duration = dur);
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state.playing);

      if (state.processingState == ProcessingState.completed) {
        setState(() => _highlightedWordIndex = -1);
        if (_isPlayingFullSurahMode) {
          if (_repeatCurrentAyah) _playFullSurahAudio();
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

  void _toggleAutoScroll() {
    setState(() => _isAutoScrolling = !_isAutoScrolling);
    _autoScrollTimer?.cancel();
    if (_isAutoScrolling) {
      _autoScrollTimer =
          Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (!_scrollController.hasClients) return;
        final maxExtent = _scrollController.position.maxScrollExtent;
        final nextOffset =
            _scrollController.offset + widget.appState.autoScrollSpeed;
        if (nextOffset >= maxExtent) {
          _toggleAutoScroll();
        } else {
          _scrollController.jumpTo(nextOffset);
        }
      });
    }
  }

  Future<void> _playFullSurahAudio() async {
    if (_currentAyahs.isEmpty) return;
    final s = widget.appState;
    final surahNum = _currentAyahs.first.surahNumber;
    setState(() => _isPlayingFullSurahMode = true);

    try {
      await _audioPlayer.setSpeed(s.playbackSpeed);
      if (s.isSurahDownloaded(surahNum)) {
        await _audioPlayer.setFilePath(s.localSurahFilePath(surahNum));
      } else {
        await _audioPlayer.setUrl(s.fullSurahRemoteUrl(surahNum));
      }
      await _audioPlayer.play();
    } catch (_) {}
  }

  Future<void> _playAyahAtIndex(int index) async {
    if (index < 0 || index >= _currentAyahs.length) return;
    final s = widget.appState;
    setState(() {
      _activeIndex = index;
      _isPlayingFullSurahMode = false;
      _highlightedWordIndex = 0;
    });
    final ayah = _currentAyahs[index];
    s.saveLastRead(
      surah: ayah.surahNumber,
      ayah: ayah.numberInSurah,
      page: ayah.page,
    );
    try {
      await _audioPlayer.setSpeed(s.playbackSpeed);
      await _audioPlayer.setUrl(
        s.audioUrlForAyah(ayah.surahNumber, ayah.numberInSurah),
      );
      await _audioPlayer.play();
    } catch (_) {
      if (s.isSurahDownloaded(ayah.surahNumber)) {
        await _playFullSurahAudio();
      }
    }
  }

  void _cycleSpeed() {
    const speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
    final currentIdx = speeds.indexOf(widget.appState.playbackSpeed);
    final nextSpeed = speeds[(currentIdx + 1) % speeds.length];
    widget.appState.setPlaybackSpeed(nextSpeed);
    _audioPlayer.setSpeed(nextSpeed);
    setState(() {});
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    final p = s.palette;
    final first = _currentAyahs.isNotEmpty ? _currentAyahs.first : null;
    final isSurahSaved = s.bookmarkedSurahs.contains(_currentSurahNumber);

    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: p.textPrimary, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              first?.surahNameEn ?? 'Al-Fatiha',
              style: TextStyle(
                color: p.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${first?.surahMeaningEn ?? "The Opening"}  •  ${_currentAyahs.length} Verses',
              style: TextStyle(color: p.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: s.tr('Auto-Scroll Page', 'التمرير التلقائي'),
            icon: Icon(
              _isAutoScrolling
                  ? Icons.pause_circle_filled
                  : Icons.swap_vert_circle_outlined,
              color: _isAutoScrolling ? p.accent : p.textPrimary,
            ),
            onPressed: _toggleAutoScroll,
          ),
          IconButton(
            icon: Icon(
              isSurahSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSurahSaved ? p.accent : p.textPrimary,
            ),
            onPressed: () =>
                setState(() => s.toggleSurahBookmark(_currentSurahNumber)),
          ),
          IconButton(
            tooltip: s.tr('Switch Mushaf / List Mode', 'تبديل وضع المصحف / التفسير'),
            icon: Icon(
              _isCenteredMushafMode ? Icons.view_agenda_outlined : Icons.menu_book,
              color: p.accent,
            ),
            onPressed: () =>
                setState(() => _isCenteredMushafMode = !_isCenteredMushafMode),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // 1. Surah Banner Card with Mosque Silhouette Arch (Exact match to Image 1)
                if (first != null) _buildSurahHeroBanner(s, p, first),
                const SizedBox(height: 12),

                // 2. < Previous Surah | Book Icon | Next Surah > Bar (Exact match to Image 1)
                _buildPreviousNextSurahBar(s, p),
                const SizedBox(height: 18),

                // 3. Decorative Bismillah Header
                _buildDecorativeBismillah(p),
                const SizedBox(height: 18),

                // 4. Either Centered Mushaf Mode (Image 1) OR Interactive List + Tafsir Mode (Image 2)
                if (_isCenteredMushafMode)
                  ..._buildCenteredMushafVerses(s, p)
                else
                  ..._buildInteractiveListVerses(s, p),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // 5. Floating Rounded Audio Player Dock (Exact match to bottom of Image 1)
          _buildBottomAudioPlayerDock(s, p),
        ],
      ),
    );
  }

  Widget _buildSurahHeroBanner(
      AppState s, AppThemePalette p, AyahItem first) {
    return Container(
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
              right: -4,
              bottom: -4,
              child: MosqueArchIllustration(
                width: 155,
                height: 150,
                accent: p.accent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RubElHizbBadge(
                        label: '${first.surahNumber}',
                        size: 46,
                        color: p.accent,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              first.surahNameAr,
                              style: TextStyle(
                                color: p.textPrimary,
                                fontFamily: 'AmiriQuran',
                                fontSize: 28,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              first.surahNameEn,
                              style: TextStyle(
                                color: p.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              first.surahMeaningEn,
                              style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(color: p.border, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.menu_book_outlined, color: p.accent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${_currentAyahs.length} ${s.tr("Verses", "آيات")}',
                        style: TextStyle(color: p.textPrimary, fontSize: 12.5),
                      ),
                      const SizedBox(width: 18),
                      Icon(Icons.description_outlined, color: p.accent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        first.revelationType,
                        style: TextStyle(color: p.textPrimary, fontSize: 12.5),
                      ),
                      const SizedBox(width: 18),
                      Icon(Icons.hub_outlined, color: p.accent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Juz ${first.juz} • Page ${first.page}',
                        style: TextStyle(color: p.textPrimary, fontSize: 12.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousNextSurahBar(AppState s, AppThemePalette p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: p.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: _currentSurahNumber > 1
                ? () => _switchToSurah(_currentSurahNumber - 1)
                : null,
            child: Row(
              children: [
                Icon(Icons.chevron_left, color: p.textSecondary, size: 18),
                const SizedBox(width: 4),
                Text(
                  s.tr('Previous Surah', 'السورة السابقة'),
                  style: TextStyle(color: p.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                setState(() => _isCenteredMushafMode = !_isCenteredMushafMode),
            child: Icon(Icons.menu_book_rounded, color: p.accent, size: 22),
          ),
          InkWell(
            onTap: _currentSurahNumber < 114
                ? () => _switchToSurah(_currentSurahNumber + 1)
                : null,
            child: Row(
              children: [
                Text(
                  s.tr('Next Surah', 'السورة التالية'),
                  style: TextStyle(color: p.textSecondary, fontSize: 13),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: p.textSecondary, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeBismillah(AppThemePalette p) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: p.border),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: TextStyle(
              color: p.textPrimary,
              fontFamily: 'AmiriQuran',
              fontSize: 24,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: p.border),
        ),
      ],
    );
  }

  /// Centered Mushaf View matching Image 1 with Word-by-Word Highlighting & Pronunciation
  List<Widget> _buildCenteredMushafVerses(AppState s, AppThemePalette p) {
    return List.generate(_currentAyahs.length, (index) {
      final ayah = _currentAyahs[index];
      final isSelected = index == _activeIndex;
      final words = ayah.textUthmani.split(' ');

      return GestureDetector(
        onTap: () => _playAyahAtIndex(index),
        onLongPress: () => showShareVerseAsImageSheet(context, s, ayah),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? p.card.withOpacity(0.8) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isSelected ? Border.all(color: p.border) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RubElHizbBadge(
                label: '${ayah.numberInSurah}',
                size: 36,
                color: p.accent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(words.length, (wIdx) {
                      final word = words[wIdx];
                      final isWordHighlighted =
                          isSelected && _highlightedWordIndex == wIdx;
                      return GestureDetector(
                        onTap: () {
                          final pron = s.pronounceArabicWord(word);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: p.card,
                              duration: const Duration(seconds: 2),
                              content: Text(
                                '$word  →  "$pron"',
                                style: TextStyle(
                                  color: p.accent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                          _playAyahAtIndex(index);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isWordHighlighted
                                ? p.accent.withOpacity(0.28)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            word,
                            style: TextStyle(
                              color: isWordHighlighted ? p.accent : p.textPrimary,
                              fontFamily: 'AmiriQuran',
                              fontSize: s.quranFontSize,
                              height: 1.85,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Interactive List + Tafsir View matching Image 2 (Ibn Kathir | Qurtubi | Jalalayn pills)
  List<Widget> _buildInteractiveListVerses(AppState s, AppThemePalette p) {
    return [
      // Quick Tafsir Scholar Selector Pills (matching Image 2 bottom-3rd screen)
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            _buildTafsirScholarPill(s, p, 'ibn_kathir', 'Ibn Kathir'),
            const SizedBox(width: 8),
            _buildTafsirScholarPill(s, p, 'qurtubi', 'Qurtubi'),
            const SizedBox(width: 8),
            _buildTafsirScholarPill(s, p, 'jalalayn', 'Jalalayn'),
            const SizedBox(width: 8),
            _buildTafsirScholarPill(s, p, 'muyassar', 'Al-Muyassar'),
          ],
        ),
      ),
      ...List.generate(_currentAyahs.length, (index) {
        final item = _currentAyahs[index];
        final isBookmarked = s.bookmarks.contains(item.key);
        final note = s.ayahNotes[item.key];
        final words = item.textUthmani.split(' ');

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: index == _activeIndex ? p.accent : p.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  RubElHizbBadge(
                    label: '${item.numberInSurah}',
                    size: 36,
                    color: p.accent,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.play_circle_outline, color: p.accent),
                    onPressed: () => _playAyahAtIndex(index),
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? p.accent : p.textSecondary,
                    ),
                    onPressed: () => setState(() => s.toggleBookmark(item.key)),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_note, color: p.textSecondary),
                    onPressed: () => _showNoteDialog(item),
                  ),
                  IconButton(
                    tooltip: s.tr('Share as Image', 'مشاركة كصورة'),
                    icon: Icon(Icons.share_outlined, color: p.accent, size: 20),
                    onPressed: () =>
                        showShareVerseAsImageSheet(context, s, item),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  item.textUthmani,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontFamily: 'AmiriQuran',
                    fontSize: s.quranFontSize,
                    height: 1.95,
                  ),
                ),
              ),
              if (s.wordByWordEnabled) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: words.take(10).map((w) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: p.bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: p.border),
                      ),
                      child: Text(
                        '$w : ${s.pronounceArabicWord(w)}',
                        style: TextStyle(color: p.accent, fontSize: 11.5),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                item.translationEn,
                style: TextStyle(
                  color: p.textPrimary.withOpacity(0.9),
                  fontSize: 14.5,
                  height: 1.45,
                ),
              ),
              Divider(height: 22, color: p.border),
              Text(
                s.getTafsirForAyah(item),
                style: TextStyle(
                  color: p.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              if (note != null && note.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: p.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '📝 $note',
                    style: TextStyle(color: p.textPrimary, fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    ];
  }

  Widget _buildTafsirScholarPill(
      AppState s, AppThemePalette p, String id, String label) {
    final active = s.activeQuickTafsirTab == id;
    return GestureDetector(
      onTap: () => setState(() => s.setQuickTafsirTab(id)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? p.accent : p.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? p.accent : p.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black87 : p.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _showNoteDialog(AyahItem item) {
    final s = widget.appState;
    final p = s.palette;
    final ctrl = TextEditingController(text: s.ayahNotes[item.key] ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: p.card,
        title: Text(
          '${s.tr("Reflection on", "تدبر الآية")} ${item.key}',
          style: TextStyle(color: p.textPrimary),
        ),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          style: TextStyle(color: p.textPrimary),
          decoration: InputDecoration(
            hintText: s.tr('Write your personal insight...', 'اكتب ملاحظتك أو تدبرك...'),
            hintStyle: TextStyle(color: p.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.tr('Cancel', 'إلغاء')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: p.accent,
              foregroundColor: Colors.black87,
            ),
            onPressed: () {
              s.saveNote(item.key, ctrl.text);
              Navigator.pop(context);
              setState(() {});
            },
            child: Text(s.tr('Save', 'حفظ')),
          ),
        ],
      ),
    );
  }

  /// Bottom Audio Player Card matching Image 1
  Widget _buildBottomAudioPlayerDock(AppState s, AppThemePalette p) {
    final maxMs = _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0;
    final posMs = _position.inMilliseconds.toDouble().clamp(0.0, maxMs);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.border, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Reciter Avatar + Dropdown (65 Reciters) + 1.0x Speed Pill
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: p.bg,
                  child: Icon(Icons.mic, color: p.accent, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ReciterOption>(
                      dropdownColor: p.card,
                      value: s.selectedReciter,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: p.textSecondary),
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                      items: s.reciters
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                '${r.nameEn} (${r.nameAr})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (r) {
                        if (r != null) {
                          setState(() => s.setReciter(r));
                          if (_isPlaying) _playAyahAtIndex(_activeIndex);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _cycleSpeed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: p.bg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: p.border),
                    ),
                    child: Text(
                      '${s.playbackSpeed}x >',
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Progress Slider Row (0:45 —●———— 3:21)
            Row(
              children: [
                Text(
                  _formatDuration(_position),
                  style: TextStyle(color: p.textSecondary, fontSize: 12),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: p.accent,
                      inactiveTrackColor: p.border,
                      thumbColor: p.accent,
                      trackHeight: 3.0,
                    ),
                    child: Slider(
                      min: 0.0,
                      max: maxMs,
                      value: posMs,
                      onChanged: (val) {
                        _audioPlayer.seek(Duration(milliseconds: val.toInt()));
                      },
                    ),
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: TextStyle(color: p.textSecondary, fontSize: 12),
                ),
              ],
            ),

            // Playback Transport Controls Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.repeat,
                    color: _repeatCurrentAyah ? p.accent : p.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _repeatCurrentAyah = !_repeatCurrentAyah),
                ),
                IconButton(
                  icon: Icon(Icons.skip_previous, color: p.textPrimary, size: 28),
                  onPressed: _activeIndex > 0
                      ? () => _playAyahAtIndex(_activeIndex - 1)
                      : null,
                ),
                GestureDetector(
                  onTap: () {
                    if (_isPlaying) {
                      _audioPlayer.pause();
                    } else {
                      _playAyahAtIndex(_activeIndex);
                    }
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: p.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black87,
                      size: 32,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.skip_next, color: p.textPrimary, size: 28),
                  onPressed: _activeIndex + 1 < _currentAyahs.length
                      ? () => _playAyahAtIndex(_activeIndex + 1)
                      : null,
                ),
                IconButton(
                  tooltip: s.tr('Play Full Surah', 'تشغيل السورة كاملة'),
                  icon: Icon(
                    Icons.FormatListBulleted,
                    color: _isPlayingFullSurahMode ? p.accent : p.textSecondary,
                  ),
                  onPressed: _playFullSurahAudio,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
