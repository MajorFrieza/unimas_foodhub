import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));

    // Request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showOrderUpdate({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'order_updates',
        'Order Updates',
        channelDescription: 'Notifications for order status changes',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );
    await _plugin.show(0, title, body, details);
  }

  static String? _lastNotifiedStatus;

  static Future<void> notifyStatusChange(String stallName, String status) async {
    if (status == _lastNotifiedStatus) return;
    _lastNotifiedStatus = status;

    String title;
    String body;

    switch (status) {
      case 'confirmed':
        title = 'Order Confirmed!';
        body = '$stallName has confirmed your order.';
        break;
      case 'preparing':
        title = 'Order Being Prepared';
        body = '$stallName is now preparing your order.';
        break;
      case 'ready':
        title = 'Order Ready for Pickup!';
        body = 'Your order from $stallName is ready. Come pick it up!';
        break;
      case 'completed':
        title = 'Order Completed';
        body = 'Thanks for ordering from $stallName!';
        break;
      case 'cancelled':
        title = 'Order Cancelled';
        body = 'Your order from $stallName has been cancelled.';
        break;
      default:
        return;
    }

    await showOrderUpdate(title: title, body: body);
  }
}
