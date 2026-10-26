import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../services/app_state.dart';

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

    final arch = Path()
      ..moveTo(w * 0.12, h)
      ..lineTo(w * 0.12, h * 0.45)
      ..quadraticBezierTo(w * 0.12, h * 0.18, w * 0.5, h * 0.04)
      ..quadraticBezierTo(w * 0.88, h * 0.18, w * 0.88, h * 0.45)
      ..lineTo(w * 0.88, h)
      ..close();

    canvas.drawPath(arch, archPaint);
    canvas.drawPath(arch, borderPaint);

    final moonPaint = Paint()..color = accent.withOpacity(0.85);
    canvas.drawCircle(Offset(w * 0.52, h * 0.30), w * 0.09, moonPaint);
    final cutPaint = Paint()..color = const Color(0xFF072820);
    canvas.drawCircle(Offset(w * 0.56, h * 0.27), w * 0.08, cutPaint);

    final silhouettePaint =
        Paint()..color = const Color(0xFF041A15).withOpacity(0.85);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.78),
        width: w * 0.38,
        height: h * 0.34,
      ),
      math.pi,
      math.pi,
      true,
      silhouettePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.18, h * 0.77, w * 0.64, h * 0.23),
      silhouettePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.22, h * 0.44, w * 0.05, h * 0.56),
      silhouettePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.73, h * 0.44, w * 0.05, h * 0.56),
      silhouettePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Saves the rendered Verse + Tafsir PNG image directly to the phone's public Download folder
Future<String?> _savePngBytesToPhoneDownloads(
  Uint8List pngBytes,
  String fileName,
) async {
  final candidateDirs = <String>[
    '/storage/emulated/0/Download',
    '/sdcard/Download',
    '/storage/emulated/0/Pictures',
    Directory.systemTemp.path,
  ];

  for (final dirPath in candidateDirs) {
    try {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(pngBytes, flush: true);
        return file.path;
      }
    } catch (_) {}
  }
  return null;
}

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
              appState.tr(
                'Share Verse & Tafsir as Image',
                'حفظ ومشاركة الآية والتفسير كصورة',
              ),
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
                  border: Border.all(
                    color: p.accent.withOpacity(0.6),
                    width: 1.5,
                  ),
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
                    label: Text(
                      appState.tr('Copy Text + Tafsir', 'نسخ النص والتفسير'),
                    ),
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
                            appState.tr(
                              'Copied Verse & Tafsir to clipboard!',
                              'تم نسخ الآية والتفسير إلى الحافظة!',
                            ),
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
                    icon: const Icon(Icons.download_rounded),
                    label: Text(
                      appState.tr('Save PNG Image', 'حفظ الصورة في الهاتف'),
                    ),
                    onPressed: () async {
                      try {
                        await Future.delayed(const Duration(milliseconds: 80));
                        final boundary = boundaryKey.currentContext
                            ?.findRenderObject() as RenderRepaintBoundary?;
                        if (boundary == null) return;
                        final ui.Image image =
                            await boundary.toImage(pixelRatio: 3.0);
                        final ByteData? byteData = await image.toByteData(
                          format: ui.ImageByteFormat.png,
                        );
                        if (byteData != null) {
                          final pngBytes = byteData.buffer.asUint8List();
                          final fileName =
                              'NoorQuran_${ayah.surahNumber}_${ayah.numberInSurah}.png';
                          final savedPath = await _savePngBytesToPhoneDownloads(
                            pngBytes,
                            fileName,
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                backgroundColor: p.card,
                                title: Text(
                                  appState.tr(
                                    'Image Saved Successfully!',
                                    'تم حفظ الصورة بنجاح!',
                                  ),
                                  style: TextStyle(color: p.accent),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        pngBytes,
                                        height: 180,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      savedPath != null
                                          ? 'Saved to:\n$savedPath'
                                          : 'Saved ($fileName)',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: p.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: p.accent,
                                      foregroundColor: Colors.black87,
                                    ),
                                    onPressed: () => Navigator.pop(dCtx),
                                    child: Text(appState.tr('Done', 'تم')),
                                  ),
                                ],
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
  String _revelationFilter = 'All';
  String _browseMode = 'Surahs';

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
                '${item.surahNameEn} (${item.key}) • Page ${item.page}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: p.textSecondary, fontSize: 12.5),
              ),
            ),
            onTap: () => _openReader(
              pageNum: item.page,
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
      separatorBuilder: (_, __) =>
          Divider(color: p.border.withOpacity(0.5), height: 1),
      itemBuilder: (context, index) {
        final surah = filtered[index];
        final isDownloaded = s.isSurahDownloaded(surah.number);
        final isDownloading = s.isDownloadingSurah(surah.number);
        final progress = s.getSurahDownloadProgress(surah.number);

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
            '${surah.ayahCount} ${s.tr("Verses", "آيات")} • ${s.tr("Page", "صفحة")} ${surah.startPage}',
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
          onTap: () => _openReader(
            surahNum: surah.number,
            pageNum: surah.startPage,
          ),
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
            leading:
                RubElHizbBadge(label: '$juzNum', size: 40, color: p.accent),
            title: Text(
              '${s.tr("Juz", "الجزء")} $juzNum',
              style:
                  TextStyle(color: p.textPrimary, fontWeight: FontWeight.bold),
            ),
            subtitle: firstAyah != null
                ? Text(
                    '${firstAyah.surahNameEn} (${firstAyah.key}) • ${s.tr("Page", "صفحة")} ${firstAyah.page}',
                    style: TextStyle(color: p.textSecondary),
                  )
                : null,
            trailing: Icon(Icons.chevron_right, color: p.accent),
            onTap: () => _openReader(
              juzNum: juzNum,
              pageNum: firstAyah?.page ?? 1,
            ),
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

/// Real 604-Page Printed Mushaf Reader (with hidden audio dock by default)
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
  late PageController _mushafPageController;

  bool _isBookMushafPageMode = true; // Default: Real 604-page printed Mushaf
  bool _showAudioPlayer = false; // Hidden by default as requested
  bool _repeatCurrentAyah = false;
  bool _continuousPlay = true;
  bool _isPlaying = false;
  bool _isPlayingFullSurahMode = false;

  late int _currentPageNumber;
  AyahItem? _selectedAyah;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _currentPageNumber = _resolveStartingPage();
    _mushafPageController =
        PageController(initialPage: _currentPageNumber - 1);
    _updatePageBookmark(_currentPageNumber);
    _setupAudioListeners();

    if (widget.autoPlayFullSurah) {
      _showAudioPlayer = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playFullSurahAudio();
      });
    }
  }

  int _resolveStartingPage() {
    final s = widget.appState;
    if (widget.initialPage != null) {
      return widget.initialPage!.clamp(1, 604);
    }
    if (widget.initialSurah != null) {
      final surahAyahs = s.surahMap[widget.initialSurah!] ?? [];
      if (widget.highlightAyah != null) {
        final match = surahAyahs.where(
          (a) => a.numberInSurah == widget.highlightAyah,
        );
        if (match.isNotEmpty) {
          _selectedAyah = match.first;
          return match.first.page;
        }
      }
      if (surahAyahs.isNotEmpty) {
        _selectedAyah = surahAyahs.first;
        return surahAyahs.first.page;
      }
    }
    if (widget.initialJuz != null) {
      final juzAyahs = s.juzMap[widget.initialJuz!] ?? [];
      if (juzAyahs.isNotEmpty) return juzAyahs.first.page;
    }
    return s.lastPage.clamp(1, 604);
  }

  void _updatePageBookmark(int pageNum) {
    final pageAyahs = widget.appState.pageMap[pageNum] ?? [];
    if (pageAyahs.isNotEmpty) {
      final first = pageAyahs.first;
      _selectedAyah ??= first;
      widget.appState.saveLastRead(
        surah: first.surahNumber,
        ayah: first.numberInSurah,
        page: pageNum,
      );
    }
  }

  void _setupAudioListeners() {
    _audioPlayer.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() => _position = pos);
    });

    _audioPlayer.durationStream.listen((dur) {
      if (!mounted || dur == null) return;
      setState(() => _duration = dur);
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state.playing);

      if (state.processingState == ProcessingState.completed) {
        if (_isPlayingFullSurahMode) {
          if (_repeatCurrentAyah) _playFullSurahAudio();
          return;
        }
        final pageAyahs = widget.appState.pageMap[_currentPageNumber] ?? [];
        if (_selectedAyah != null && pageAyahs.isNotEmpty) {
          final idx = pageAyahs
              .indexWhere((a) => a.globalNumber == _selectedAyah!.globalNumber);
          if (_repeatCurrentAyah) {
            _playSpecificAyah(_selectedAyah!);
          } else if (_continuousPlay &&
              idx != -1 &&
              idx + 1 < pageAyahs.length) {
            _playSpecificAyah(pageAyahs[idx + 1]);
          }
        }
      }
    });
  }

  Future<void> _playSpecificAyah(AyahItem ayah) async {
    final s = widget.appState;
    setState(() {
      _selectedAyah = ayah;
      _isPlayingFullSurahMode = false;
    });
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

  Future<void> _playFullSurahAudio() async {
    final pageAyahs = widget.appState.pageMap[_currentPageNumber] ?? [];
    if (pageAyahs.isEmpty) return;
    final s = widget.appState;
    final surahNum = (_selectedAyah ?? pageAyahs.first).surahNumber;
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

  void _showAyahActionBottomSheet(AyahItem ayah) {
    final s = widget.appState;
    final p = s.palette;
    setState(() => _selectedAyah = ayah);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isBookmarked = s.bookmarks.contains(ayah.key);
            final words = ayah.textUthmani.split(' ');

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              maxChildSize: 0.92,
              builder: (_, scrollCtrl) {
                return ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        RubElHizbBadge(
                          label: '${ayah.numberInSurah}',
                          size: 38,
                          color: p.accent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${ayah.surahNameEn} (${ayah.key}) • Page ${ayah.page}',
                            style: TextStyle(
                              color: p.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: s.tr('Play Verse Audio', 'تشغيل الآية'),
                          icon: Icon(Icons.play_circle_fill,
                              color: p.accent, size: 28),
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() => _showAudioPlayer = true);
                            _playSpecificAyah(ayah);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isBookmarked ? p.accent : p.textSecondary,
                          ),
                          onPressed: () {
                            s.toggleBookmark(ayah.key);
                            setModalState(() {});
                            setState(() {});
                          },
                        ),
                        IconButton(
                          tooltip: s.tr('Save/Share Image', 'حفظ كصورة'),
                          icon: Icon(Icons.image_outlined, color: p.accent),
                          onPressed: () {
                            Navigator.pop(ctx);
                            showShareVerseAsImageSheet(context, s, ayah);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        ayah.textUthmani,
                        style: TextStyle(
                          color: p.textPrimary,
                          fontFamily: 'AmiriQuran',
                          fontSize: 25,
                          height: 1.9,
                        ),
                      ),
                    ),
                    if (s.wordByWordEnabled) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: words.take(12).map((w) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: p.card,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: p.border),
                            ),
                            child: Text(
                              '$w : ${s.pronounceArabicWord(w)}',
                              style: TextStyle(color: p.accent, fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Text(
                      ayah.translationEn,
                      style: TextStyle(
                        color: p.textPrimary.withOpacity(0.92),
                        fontSize: 14.5,
                        height: 1.45,
                      ),
                    ),
                    Divider(height: 24, color: p.border),
                    Text(
                      s.getTafsirForAyah(ayah),
                      style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _mushafPageController.dispose();
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
    final pageAyahs = s.pageMap[_currentPageNumber] ?? [];
    final first = pageAyahs.isNotEmpty ? pageAyahs.first : null;
    final currentSurahNum = first?.surahNumber ?? 1;
    final isSurahSaved = s.bookmarkedSurahs.contains(currentSurahNum);

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
              first?.surahNameEn ?? 'Mushaf',
              style: TextStyle(
                color: p.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              '${s.tr("Page", "صفحة")} $_currentPageNumber  •  ${s.tr("Juz", "الجزء")} ${first?.juz ?? 1}',
              style: TextStyle(color: p.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          // Toggle Audio Player Bar (Hidden by default)
          IconButton(
            tooltip: s.tr('Show/Hide Audio Player', 'إظهار/إخفاء المشغل الصوتي'),
            icon: Icon(
              _showAudioPlayer ? Icons.headset_off : Icons.headphones_outlined,
              color: _showAudioPlayer ? p.accent : p.textPrimary,
            ),
            onPressed: () =>
                setState(() => _showAudioPlayer = !_showAudioPlayer),
          ),
          IconButton(
            icon: Icon(
              isSurahSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSurahSaved ? p.accent : p.textPrimary,
            ),
            onPressed: () =>
                setState(() => s.toggleSurahBookmark(currentSurahNum)),
          ),
          IconButton(
            tooltip: s.tr('Switch Mushaf / Tafsir List', 'تبديل المصحف / التفسير'),
            icon: Icon(
              _isBookMushafPageMode
                  ? Icons.view_agenda_outlined
                  : Icons.auto_stories,
              color: p.accent,
            ),
            onPressed: () => setState(
              () => _isBookMushafPageMode = !_isBookMushafPageMode,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isBookMushafPageMode
                ? PageView.builder(
                    controller: _mushafPageController,
                    reverse: true, // Right-to-left Arabic book page turning
                    itemCount: 604,
                    onPageChanged: (idx) {
                      setState(() {
                        _currentPageNumber = idx + 1;
                        _updatePageBookmark(_currentPageNumber);
                      });
                    },
                    itemBuilder: (context, pageIndex) {
                      final pageNum = pageIndex + 1;
                      final ayahsOnPage = s.pageMap[pageNum] ?? [];
                      return _buildSingleMushafBookPage(
                        s,
                        p,
                        pageNum,
                        ayahsOnPage,
                      );
                    },
                  )
                : _buildTafsirListModeForPage(s, p, pageAyahs),
          ),
          if (_showAudioPlayer) _buildBottomAudioPlayerDock(s, p),
        ],
      ),
    );
  }

  /// Renders a genuine printed Mushaf Page with continuous flowing verses & proper Basmala rules
  Widget _buildSingleMushafBookPage(
    AppState s,
    AppThemePalette p,
    int pageNum,
    List<AyahItem> ayahsOnPage,
  ) {
    if (ayahsOnPage.isEmpty) {
      return Center(
        child: Text(
          'Page $pageNum',
          style: TextStyle(color: p.textSecondary),
        ),
      );
    }

    // Group contiguous verses on this page by Surah so we can place the Surah Header & Basmala accurately
    final List<List<AyahItem>> surahBlocks = [];
    for (final ayah in ayahsOnPage) {
      if (surahBlocks.isEmpty ||
          surahBlocks.last.first.surahNumber != ayah.surahNumber) {
        surahBlocks.add([ayah]);
      } else {
        surahBlocks.last.add(ayah);
      }
    }

    final firstAyah = ayahsOnPage.first;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Margin of the Mushaf Page (Surah Name on Right, Juz on Left)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${s.tr("Juz", "الجزء")} ${firstAyah.juz}',
                style: TextStyle(
                  color: p.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                firstAyah.surahNameAr,
                style: TextStyle(
                  color: p.accent,
                  fontFamily: 'AmiriQuran',
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Divider(color: p.border, height: 14),

          // Main Scrollable Mushaf Page Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: surahBlocks.map((block) {
                  final blockFirst = block.first;
                  final startsNewSurah = blockFirst.numberInSurah == 1;
                  // Rule: Show decorative Basmala ONLY when a Surah starts on this page,
                  // AND it is NOT Surah 1 (Al-Fatiha, where Basmala is Ayah 1 itself)
                  // AND NOT Surah 9 (At-Tawbah, which has no Basmala).
                  final showDecorativeBasmala = startsNewSurah &&
                      blockFirst.surahNumber != 1 &&
                      blockFirst.surahNumber != 9;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (startsNewSurah) ...[
                        const SizedBox(height: 8),
                        _buildCompactMushafSurahHeader(s, p, blockFirst),
                        const SizedBox(height: 10),
                      ],
                      if (showDecorativeBasmala) ...[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: p.accent,
                                fontFamily: 'AmiriQuran',
                                fontSize: s.quranFontSize - 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                      // Flowing inline Mushaf verses for this Surah block
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            children: block.map((ayah) {
                              final isSelected = _selectedAyah?.globalNumber ==
                                  ayah.globalNumber;
                              final arNum =
                                  s.toArabicDigits(ayah.numberInSurah);
                              return TextSpan(
                                text: '${ayah.textUthmani} ﴿$arNum﴾ ',
                                style: TextStyle(
                                  fontFamily: 'AmiriQuran',
                                  fontSize: s.quranFontSize,
                                  height: 2.05,
                                  color:
                                      isSelected ? p.accent : p.textPrimary,
                                  backgroundColor: isSelected
                                      ? p.accent.withOpacity(0.14)
                                      : Colors.transparent,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap =
                                      () => _showAyahActionBottomSheet(ayah),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          Divider(color: p.border, height: 12),
          // Bottom Mushaf Page Number Footer + Next/Prev Page Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: pageNum < 604
                    ? () => _mushafPageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        )
                    : null,
                child: Row(
                  children: [
                    Icon(Icons.chevron_left, color: p.textSecondary, size: 18),
                    Text(
                      s.tr('Next Page', 'الصفحة التالية'),
                      style: TextStyle(color: p.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: p.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.border),
                ),
                child: Text(
                  '${s.toArabicDigits(pageNum)}  •  $pageNum',
                  style: TextStyle(
                    color: p.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              InkWell(
                onTap: pageNum > 1
                    ? () => _mushafPageController.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        )
                    : null,
                child: Row(
                  children: [
                    Text(
                      s.tr('Prev Page', 'الصفحة السابقة'),
                      style: TextStyle(color: p.textSecondary, fontSize: 12),
                    ),
                    Icon(Icons.chevron_right, color: p.textSecondary, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMushafSurahHeader(
    AppState s,
    AppThemePalette p,
    AyahItem first,
  ) {
    final surahMeta = s.surahs.firstWhere(
      (m) => m.number == first.surahNumber,
      orElse: () => SurahMeta(
        number: first.surahNumber,
        nameAr: first.surahNameAr,
        nameEn: first.surahNameEn,
        meaningEn: first.surahMeaningEn,
        revelationType: first.revelationType,
        ayahCount: 7,
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: p.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.accent.withOpacity(0.55), width: 1.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RubElHizbBadge(
            label: '${surahMeta.number}',
            size: 32,
            color: p.accent,
          ),
          Column(
            children: [
              Text(
                surahMeta.nameAr,
                style: TextStyle(
                  color: p.textPrimary,
                  fontFamily: 'AmiriQuran',
                  fontSize: 22,
                ),
              ),
              Text(
                '${surahMeta.nameEn} • ${surahMeta.ayahCount} ${s.tr("Verses", "آيات")} (${surahMeta.revelationType})',
                style: TextStyle(color: p.textSecondary, fontSize: 11.5),
              ),
            ],
          ),
          Icon(Icons.auto_awesome, color: p.accent, size: 20),
        ],
      ),
    );
  }

  Widget _buildTafsirListModeForPage(
    AppState s,
    AppThemePalette p,
    List<AyahItem> pageAyahs,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pageAyahs.length,
      itemBuilder: (context, index) {
        final item = pageAyahs[index];
        final isBookmarked = s.bookmarks.contains(item.key);
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.border),
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
                  const SizedBox(width: 10),
                  Text(
                    '${item.surahNameEn} (${item.key})',
                    style: TextStyle(
                      color: p.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.play_circle_outline, color: p.accent),
                    onPressed: () {
                      setState(() => _showAudioPlayer = true);
                      _playSpecificAyah(item);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? p.accent : p.textSecondary,
                    ),
                    onPressed: () => setState(() => s.toggleBookmark(item.key)),
                  ),
                  IconButton(
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
              const SizedBox(height: 10),
              Text(
                item.translationEn,
                style: TextStyle(
                  color: p.textPrimary.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              Divider(height: 20, color: p.border),
              Text(
                s.getTafsirForAyah(item),
                style: TextStyle(color: p.textSecondary, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomAudioPlayerDock(AppState s, AppThemePalette p) {
    final maxMs =
        _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0;
    final posMs = _position.inMilliseconds.toDouble().clamp(0.0, maxMs);
    final pageAyahs = s.pageMap[_currentPageNumber] ?? [];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: p.border, width: 1.3),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.mic, color: p.accent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${s.selectedReciter.nameEn} (${s.selectedReciter.nameAr})',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: s.tr('Hide Audio Player', 'إخفاء المشغل'),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: p.textSecondary,
                  ),
                  onPressed: () => setState(() => _showAudioPlayer = false),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  _formatDuration(_position),
                  style: TextStyle(color: p.textSecondary, fontSize: 11.5),
                ),
                Expanded(
                  child: Slider(
                    activeColor: p.accent,
                    inactiveColor: p.border,
                    min: 0.0,
                    max: maxMs,
                    value: posMs,
                    onChanged: (val) {
                      _audioPlayer.seek(Duration(milliseconds: val.toInt()));
                    },
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: TextStyle(color: p.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
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
                GestureDetector(
                  onTap: () {
                    if (_isPlaying) {
                      _audioPlayer.pause();
                    } else if (_selectedAyah != null) {
                      _playSpecificAyah(_selectedAyah!);
                    } else if (pageAyahs.isNotEmpty) {
                      _playSpecificAyah(pageAyahs.first);
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: p.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black87,
                      size: 28,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: s.tr('Play Full Surah', 'تشغيل السورة كاملة'),
                  icon: Icon(
                    Icons.format_list_bulleted,
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
