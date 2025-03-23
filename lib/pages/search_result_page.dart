import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yatrisewa/models/bus_route.dart';
import 'package:yatrisewa/models/bus_schedule.dart';
import 'package:yatrisewa/providers/app_data_provider.dart';
import 'package:yatrisewa/utils/constants.dart';

class SearchResultPage extends StatelessWidget {
  const SearchResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final argList = ModalRoute.of(context)!.settings.arguments as List;
    final BusRoute route = argList[0];
    final String departureDate = argList[1];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Showing results for ${route.cityFrom} to ${route.cityTo} on $departureDate',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<AppDataProvider>(
                builder: (context, provider, _) => FutureBuilder<List<BusSchedule>>(
                  future: provider.getSchedulesByRouteName(route.routeName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Failed to fetch data', style: TextStyle(fontSize: 16, color: Colors.red)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => provider.getSchedulesByRouteName(route.routeName),
                              child: const Text('Retry'),
                            )
                          ],
                        ),
                      );
                    }
                    final scheduleList = snapshot.data ?? [];
                    if (scheduleList.isEmpty) {
                      return const Center(
                        child: Text('No buses available', style: TextStyle(fontSize: 16)),
                      );
                    }
                    return ListView.builder(
                      itemCount: scheduleList.length,
                      itemBuilder: (context, index) {
                        return ScheduleItemView(schedule: scheduleList[index], date: departureDate);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleItemView extends StatelessWidget {
  final String date;
  final BusSchedule schedule;

  const ScheduleItemView({Key? key, required this.schedule, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        routeNameSeatPlanPage,
        arguments: [schedule, date],
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  schedule.bus.busName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(schedule.bus.busType, style: const TextStyle(fontSize: 15)),
                trailing: Text(
                  '$currency${schedule.ticketPrice}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoTile(Icons.location_on, 'From', schedule.busRoute.cityFrom),
                  _infoTile(Icons.location_on, 'To', schedule.busRoute.cityTo),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoTile(Icons.access_time, 'Departure', schedule.departureTime),
                  _infoTile(Icons.event_seat, 'Seats', '${schedule.bus.totalSeat}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
