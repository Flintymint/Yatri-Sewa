import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yatrisewa/providers/app_data_provider.dart';
import 'package:yatrisewa/models/bus_schedule.dart';

import '../drawers/main_drawer.dart';

class ViewBusSchedulePage extends StatelessWidget {
  const ViewBusSchedulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text('View Bus Schedules'),
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) {
          final schedules = provider.scheduleList;

          if (schedules.isEmpty) {
            return const Center(child: Text("No schedules available"));
          }

          return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('${schedule.bus.busName} - ${schedule.bus.busType}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Route: ${schedule.busRoute.routeName}'),
                      Text('Departure: ${schedule.departureTime}'),
                      Text('Price: Rs. ${schedule.ticketPrice}'),
                    ],
                  ),
                  trailing: const Icon(Icons.schedule),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
