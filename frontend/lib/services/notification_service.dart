import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/lamaran_model.dart';

/// Layanan notifikasi lokal untuk pengingat tenggat lamaran
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Inisialisasi basis data zona waktu
      tz.initializeTimeZones();

      // Pengaturan platform Android
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Pengaturan platform Darwin (iOS/macOS)
      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Pengaturan platform Windows / Linux
      const LinuxInitializationSettings linuxSettings =
          LinuxInitializationSettings(defaultActionName: 'Buka Notifikasi');

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notifikasi diklik: ${response.payload}');
        },
      );

      // Minta izin notifikasi untuk Android 13+
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Peringatan: Gagal menginisialisasi notifikasi lokal: $e');
    }
  }

  /// Jadwalkan ulang seluruh pengingat tenggat (H-3 dan H-1 pukul 08:00)
  Future<void> rescheduleAllReminders(List<LamaranModel> lamaranList) async {
    try {
      if (!_isInitialized) await init();

      // Batalkan semua jadwal sebelumnya agar tidak duplikasi
      await _notificationsPlugin.cancelAll();

      final now = DateTime.now();

      for (final lamaran in lamaranList) {
        // Hanya ingatkan untuk lamaran yang masih aktif/menunggu
        if (lamaran.status != 'menunggu') continue;

        DateTime deadline;
        try {
          deadline = DateTime.parse(lamaran.tenggat);
        } catch (_) {
          continue;
        }

        // 1. Jadwal H-3 pukul 08:00
        final hMinus3 = DateTime(deadline.year, deadline.month, deadline.day - 3, 8, 0, 0);
        if (hMinus3.isAfter(now)) {
          final notifId = (lamaran.id * 10) + 3;
          await _scheduleSingleNotification(
            id: notifId,
            title: 'Pengingat Tenggat: 3 Hari Lagi!',
            body: 'Lamaran di ${lamaran.namaPerusahaan} (${lamaran.posisi}) berakhir pada ${lamaran.tenggat}.',
            scheduledDate: hMinus3,
            payload: 'lamaran_${lamaran.id}',
          );
        }

        // 2. Jadwal H-1 pukul 08:00
        final hMinus1 = DateTime(deadline.year, deadline.month, deadline.day - 1, 8, 0, 0);
        if (hMinus1.isAfter(now)) {
          final notifId = (lamaran.id * 10) + 1;
          await _scheduleSingleNotification(
            id: notifId,
            title: 'Perhatian: Besok Tenggat Lamaran!',
            body: 'Besok adalah batas akhir lamaran di ${lamaran.namaPerusahaan} (${lamaran.posisi}). Periksa kelengkapan berkas Anda!',
            scheduledDate: hMinus1,
            payload: 'lamaran_${lamaran.id}',
          );
        }
      }
    } catch (e) {
      debugPrint('Gagal menjadwalkan notifikasi tenggat: $e');
    }
  }

  Future<void> _scheduleSingleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'tenggat_channel',
        'Pengingat Tenggat Lamaran',
        channelDescription: 'Notifikasi pengingat tenggat waktu lamaran magang (H-3 dan H-1)',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

      final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Gagal mengatur zonedSchedule notifikasi: $e');
    }
  }

  /// Tampilkan notifikasi instan (misal tes notifikasi)
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    try {
      if (!_isInitialized) await init();

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'instant_channel',
        'Pemberitahuan JejakMagang',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        id: 99999,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('Gagal menampilkan notifikasi instan: $e');
    }
  }
}
