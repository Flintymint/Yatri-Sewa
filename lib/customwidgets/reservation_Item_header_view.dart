import 'package:flutter/material.dart';
import 'package:yatrisewa/models/reservation_expansion_item.dart';
import 'package:yatrisewa/utils/helper_functions.dart';

class ReservationItemHeaderView extends StatelessWidget {
  final ReservationExpansionHeader header;
  const ReservationItemHeaderView({Key? key, required this.header}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${header.departureDate} ${header.schedule.departureTime}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${header.schedule.busRoute.routeName} ${header.schedule.bus.busType}'),
          Text('Booking Time: ${getFormattedDate(DateTime.fromMillisecondsSinceEpoch(header.timestamp), pattern: 'EEE MMM dd yyyy HH:mm')} '),
        ],
      )
    );
  }
}
