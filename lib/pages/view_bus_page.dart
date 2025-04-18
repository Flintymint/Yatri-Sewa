import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yatrisewa/providers/app_data_provider.dart';
import 'package:yatrisewa/models/bus_model.dart';
import '../drawers/main_drawer.dart';

class ViewBusesPage extends StatelessWidget {
  const ViewBusesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final busList = Provider.of<AppDataProvider>(context).busList;

    return Scaffold(
      drawer: const MainDrawer(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('View Buses'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: busList.isEmpty
          ? const Center(
        child: Text(
          'No Buses Available',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: busList.length,
        itemBuilder: (context, index) {
          final bus = busList[index];
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.directions_bus, color: Colors.white),
              title: Text(
                bus.busName,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Bus No: ${bus.busNumber} | Type: ${bus.busType} | Seats: ${bus.totalSeat}',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          );
        },
      ),
    );
  }
}
