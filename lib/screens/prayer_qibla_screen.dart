import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_state.dart';

class PrayerQiblaScreen extends StatefulWidget {
  final AppState appState;
  const PrayerQiblaScreen({super.key, required this.appState});

  @override
  State<PrayerQiblaScreen> createState() => _PrayerQiblaScreenState();
}

class _PrayerQiblaScreenState extends State<PrayerQiblaScreen> {
  Map<String, String> _timings = {
    'Fajr': '05:10',
    'Sunrise': '06:35',
    'Dhuhr': '12:30',
    'Asr': '15:45',
    'Maghrib': '18:25',
    'Isha': '19:50',
  };
  String _locationLabel = 'Makkah (Default / Offline)';
  double _qiblaAngle = 135.0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCachedOrFetchPrayerTimes();
  }

  Future<void> _loadCachedOrFetchPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_prayer_times');
    if (cached != null) {
      final decoded = jsonDecode(cached) as Map<String, dynamic>;
      setState(() {
        _timings = decoded.map((k, v) => MapEntry(k, v.toString()));
        _locationLabel = prefs.getString('cached_location_label') ?? _locationLabel;
        _qiblaAngle = prefs.getDouble('cached_qibla_angle') ?? 135.0;
      });
    }
    await _refreshLocationAndTimes();
  }

  Future<void> _refreshLocationAndTimes() async {
    setState(() => _loading = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        final qibla = _calculateQiblaBearing(pos.latitude, pos.longitude);
        final url = Uri.parse(
          'https://api.aladhan.com/v1/timings?latitude=${pos.latitude}&longitude=${pos.longitude}&method=3',
        );
        final res = await http.get(url);
        if (res.statusCode == 200) {
          final rawTimings =
              jsonDecode(res.body)['data']['timings'] as Map<String, dynamic>;
          final updated = <String, String>{
            'Fajr': rawTimings['Fajr'].toString(),
            'Sunrise': rawTimings['Sunrise'].toString(),
            'Dhuhr': rawTimings['Dhuhr'].toString(),
            'Asr': rawTimings['Asr'].toString(),
            'Maghrib': rawTimings['Maghrib'].toString(),
            'Isha': rawTimings['Isha'].toString(),
          };
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_prayer_times', jsonEncode(updated));
          final locLabel =
              'GPS (${pos.latitude.toStringAsFixed(2)}, ${pos.longitude.toStringAsFixed(2)})';
          await prefs.setString('cached_location_label', locLabel);
          await prefs.setDouble('cached_qibla_angle', qibla);

          if (mounted) {
            setState(() {
              _timings = updated;
              _locationLabel = locLabel;
              _qiblaAngle = qibla;
            });
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  double _calculateQiblaBearing(double lat, double lon) {
    const kaabaLat = 21.422487 * math.pi / 180.0;
    const kaabaLon = 39.826206 * math.pi / 180.0;
    final phi = lat * math.pi / 180.0;
    final lam = lon * math.pi / 180.0;

    final y = math.sin(kaabaLon - lam);
    final x = math.cos(phi) * math.tan(kaabaLat) -
        math.sin(phi) * math.cos(kaabaLon - lam);
    final bearing = math.atan2(y, x) * 180.0 / math.pi;
    return (bearing + 360.0) % 360.0;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_filled, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.tr('Prayer Times', 'مواقيت الصلاة'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      onPressed: _refreshLocationAndTimes,
                    ),
                  ],
                ),
                Text(
                  _locationLabel,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Divider(height: 20),
                ..._timings.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          e.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.notifications_active),
                    label: Text(
                      s.tr(
                        'Enable & Test Adhan Notification',
                        'تفعيل واختبار إشعار الأذان',
                      ),
                    ),
                    onPressed: () {
                      s.triggerInstantReminder(
                        s.tr('Hayya \'ala-s-Salah', 'حي على الصلاة'),
                        s.tr(
                          'Adhan alerts are active for your local prayer schedule.',
                          'تم تفعيل تنبيهات الأذان لمواقيت صلاتك المحلية.',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  s.tr('Qibla Compass', 'بوصلة القبلة'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${s.tr("Kaaba Bearing", "اتجاه الكعبة")}: ${_qiblaAngle.toStringAsFixed(1)}°',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: StreamBuilder<CompassEvent>(
                    stream: FlutterCompass.events,
                    builder: (context, snapshot) {
                      final heading = snapshot.data?.heading ?? 0.0;
                      final diffRadians =
                          ((_qiblaAngle - heading) * (math.pi / 180.0));
                      return Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFD4AF37),
                                  width: 3,
                                ),
                              ),
                            ),
                            Transform.rotate(
                              angle: diffRadians,
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.navigation,
                                    size: 64,
                                    color: Color(0xFFD4AF37),
                                  ),
                                  Text(
                                    'KAABA',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
