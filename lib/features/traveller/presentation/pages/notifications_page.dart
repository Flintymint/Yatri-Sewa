import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../auth/data/user_session.dart';
import '../../../../config.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<Map<String, dynamic>>> _futureNotifications;

  @override
  void initState() {
    super.initState();
    _futureNotifications = fetchNotifications();
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final token = UserSession.token;
    final url = '${AppConfig.backendBaseUrl}/api/notifications/my';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> notifications = json.decode(response.body);
      return notifications.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load notifications: status=${response.statusCode}, body=${response.body}');
    }
  }

  Future<void> markAllAsRead() async {
    final token = UserSession.token;
    final url = '${AppConfig.backendBaseUrl}/api/notifications/mark-seen';
    // Fetch the current notifications (from the future)
    List<Map<String, dynamic>> notifications = [];
    try {
      final snapshot = await _futureNotifications;
      notifications = snapshot;
    } catch (e) {
      // fallback: try to fetch again if needed
      try {
        notifications = await fetchNotifications();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch notifications: $e')),
        );
        return;
      }
    }
    final ids = notifications.map((n) => n['id'] ?? n['notificationId']).where((id) => id != null).toList();
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(ids),
    );
    if (response.statusCode == 200) {
      setState(() {
        _futureNotifications = fetchNotifications();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark as read: status=${response.statusCode}, body=${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read_outlined),
            tooltip: 'Mark all as read',
            onPressed: markAllAsRead,
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureNotifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          }

          final notifications = snapshot.data!;
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final title = notification['title'] ?? 'Notification';
              final body = notification['message'] ?? '';
              final createdAt = notification['createdAt']?.toString() ?? '-';
              final read = notification['read'] == true;
              return ListTile(
                leading: Icon(
                  read ? Icons.notifications_none : Icons.notifications_active,
                  color: read ? Colors.grey : Colors.redAccent,
                ),
                title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: read ? Colors.grey : Colors.white)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(body),
                    Text('Received: $createdAt', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                trailing: read ? null : const Icon(Icons.brightness_1, color: Colors.redAccent, size: 12),
              );
            },
          );
        },
      ),
    );
  }
}
