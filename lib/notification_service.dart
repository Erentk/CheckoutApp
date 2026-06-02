import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Flutter'ın bildirim motorunu başlatan ana nesne
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Uygulama ilk açıldığında bildirim sistemini kuran fonksiyon
  static Future<void> init() async {
    // Android için uygulamanın kendi varsayılan ikonunu bildirim ikonu olarak ayarlıyoruz (Ücretsiz ve telifsiz)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Ayarları bildirim motoruna yüklüyoruz
    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Tüm kontroller bittiğinde ekrana çakılacak kalıcı bildirimi fırlatan fonksiyon
  static Future<void> showPersistentNotification(String time) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'checkout_channel_id',     // Kanal ID'si (Arka planda çalışması için zorunlu)
      'Ev Kontrol Özetleri',      // Telefon ayarlarında görünecek kanal ismi
      channelDescription: 'Evden çıkış kontrol özetini kalıcı olarak gösterir.',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,            // İŞTE EN KRİTİK AYAR! Bildirimin el ile silinmesini engeller, kalıcı yapar.
      autoCancel: false,         // Bildirime tıklanınca kendi kendine kaybolmasını engeller.
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    // Bildirimi gösteriyoruz
    await _notificationsPlugin.show(
      0, // Bildirim ID'si (Her sekansta aynı ID'yi kullanarak eski bildirimi güncelliyoruz)
      'Evin Güvende! 🎉',
      'Bugün saat $time yönünde tüm kontrolleri tamamlayıp çıktın.',
      platformDetails,
    );
  }

  // Kullanıcı eve dönüp "Yeni Çıkış" başlattığında eski bildirimi temizleyen fonksiyon
  static Future<void> cancelNotification() async {
    await _notificationsPlugin.cancel(0);
  }
}