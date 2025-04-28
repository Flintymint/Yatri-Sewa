import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:drive/features/admin/presentation/pages/manage_bus_stops.dart';
import 'package:drive/features/admin/presentation/pages/manage_buses.dart';
import 'package:drive/features/admin/presentation/pages/manage_trips.dart';
import 'package:drive/features/driver/presentation/pages/current_drives_page.dart';
import 'package:drive/features/driver/presentation/pages/my_drives_page.dart';
import 'package:drive/features/traveller/presentation/pages/explore_trips_page.dart';
import 'package:drive/features/traveller/presentation/pages/notifications_page.dart';
import 'package:drive/features/traveller/presentation/pages/check_trip_status_page.dart';
import 'package:drive/features/profile/presentation/pages/profile_settings_page.dart';
import '../../../auth/data/user_session.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LatLng _currentPosition = LatLng(27.7172, 85.3240); // Kathmandu default

  List<Widget> _buildMenuItems() {
    final role = UserSession.role;
    final List<Widget> items = [];
    if (UserSession.isAuthenticated) {
      if (role == 'admin') {
        items.addAll([
          ListTile(
            leading: Icon(Icons.route, color: Theme.of(context).colorScheme.primary),
            title: const Text('Manage trips', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) {
                  return const ManageTripsPage();
                }),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.directions_bus, color: Theme.of(context).colorScheme.primary),
            title: const Text('Manage buses', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageBusesPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
            title: const Text('Manage bus stops', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageBusStopsPage()),
              );
            },
          ),
        ]);
      } else if (role == 'bus_driver') {
        items.addAll([
          ListTile(
            leading: Icon(Icons.drive_eta, color: Theme.of(context).colorScheme.primary),
            title: const Text('Current drive', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CurrentDrivesPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.directions_car_filled, color: Theme.of(context).colorScheme.primary),
            title: const Text('View my drives', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyDrivesPage()),
              );
            },
          ),
        ]);
      } else if (role == 'traveller') {
        items.addAll([
          ListTile(
            leading: Icon(Icons.explore, color: Theme.of(context).colorScheme.primary),
            title: const Text('Explore trips', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExploreTripsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
            title: const Text('View my bookings', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('History, current, upcoming', style: TextStyle(fontSize: 12)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/my-bookings');
            },
          ),
        ]);
      }
      items.addAll([
        ListTile(
          leading: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
          title: const Text('Profile Settings', style: TextStyle(fontWeight: FontWeight.w600)),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileSettingsPage()),
            );
          },
        ),
      ]);
      items.add(
        ListTile(
          leading: Icon(Icons.power_settings_new, color: Colors.red),
          title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
          subtitle: const Text('Logout from app', style: TextStyle(fontSize: 12)),
          onTap: () {
            Navigator.of(context).pop();
            UserSession.clear();
            Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
      );
    } else {
      items.addAll([
        ListTile(
          leading: Icon(Icons.explore, color: Theme.of(context).colorScheme.primary),
          title: const Text('Explore trips', style: TextStyle(fontWeight: FontWeight.w600)),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExploreTripsPage()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
          title: const Text('Check trip status', style: TextStyle(fontWeight: FontWeight.w600)),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CheckTripStatusPage()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.login, color: Theme.of(context).colorScheme.primary),
          title: const Text('Login', style: TextStyle(fontWeight: FontWeight.w600)),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
      ]);
    }
    return items;
  }

  Future<bool> hasUnreadNotifications() async {
    try {
      final token = UserSession.token;
      final response = await http.get(
        Uri.parse('${AppConfig.backendBaseUrl}/api/notifications/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['unread'] ?? 0) > 0;
      }
    } catch (_) {}
    return false;
  }

  Widget _getDrawerProfilePicture(BuildContext context, String initials) {
    final user = UserSession.currentUser;
    final profileImageUrl = user != null ? user['profileImageUrl'] as String? : null;
    String? fullUrl;
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      if (profileImageUrl.startsWith('http')) {
        fullUrl = profileImageUrl;
      } else if (profileImageUrl.startsWith('/')) {
        fullUrl = '${AppConfig.backendBaseUrl}${profileImageUrl}';
      } else {
        fullUrl = '${AppConfig.backendBaseUrl}/${profileImageUrl}';
      }
      return CircleAvatar(
        radius: 32,
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: NetworkImage(fullUrl),
      );
    } else {
      return CircleAvatar(
        radius: 32,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          initials,
          style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = UserSession.isAuthenticated;
    final fullName = UserSession.fullName ?? 'Guest';
    final role = UserSession.role ?? 'unauthenticated';
    final initials = UserSession.initials;
    final isLoggedIn = UserSession.token != null && (UserSession.token?.isNotEmpty ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Bus Stops'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        actions: [
          if (isLoggedIn)
            FutureBuilder<bool>(
              future: hasUnreadNotifications(),
              builder: (context, snapshot) {
                final hasUnread = snapshot.data ?? false;
                return Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      tooltip: 'Notifications',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NotificationsPage()),
                        );
                      },
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            )
        ],
      ),
      drawer: Drawer(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  margin: EdgeInsets.zero,
                  accountName: Text(
                    fullName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  accountEmail: Text(
                    isAuth ? role : 'Not signed in',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).toInt()),
                      fontSize: 14,
                    ),
                  ),
                  currentAccountPicture: _getDrawerProfilePicture(context, initials),
                ),
                ..._buildMenuItems(),
              ],
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary, size: 28),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                tooltip: 'Close',
              ),
            ),
          ],
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _currentPosition,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.drive',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentPosition,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
