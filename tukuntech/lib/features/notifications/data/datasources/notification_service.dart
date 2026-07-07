import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:tukuntech/core/api_client.dart';
import 'package:tukuntech/core/environment_config.dart';
import 'package:tukuntech/features/notifications/data/models/notification_model.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Solicitar permisos de notificación (especialmente necesario en iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Obtener el token FCM de este dispositivo
    try {
      String? token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      // TODO: Enviar este token al backend si es necesario para registrar el dispositivo
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
    }

    // Manejar mensajes recibidos en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
      }
    });
  }

  // Consumir el endpoint para obtener el historial de notificaciones
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final url = Uri.parse('${EnvironmentConfig.baseUrl}/notifications/me');
      // ApiClient se encarga de inyectar el token de autorización
      final response = await ApiClient.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      throw Exception('Error fetching notifications: $e');
    }
  }
}

// Handler de mensajes en segundo plano (debe ser una función de nivel superior)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}
