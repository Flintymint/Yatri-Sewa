import 'package:flutter/material.dart';
import 'package:yatrisewa/datasource/data_source.dart';
import 'package:yatrisewa/datasource/dummy_data_source.dart';
import 'package:yatrisewa/models/response_model.dart';

import '../models/bus_model.dart';
import '../models/bus_reservation.dart';
import '../models/bus_schedule.dart';
import '../models/bus_route.dart';

class AppDataProvider extends ChangeNotifier {
  List<Bus> _busList = [];
  List<BusRoute> _routeList = [];
  List<BusReservation> _reervationList = [];
  List<BusSchedule> _scheduleList = [];
  List<BusSchedule> get scheduleList => _scheduleList;
  List<Bus> get busList => _busList;
  List<BusRoute> get routeList => _routeList;
  List<BusReservation> get reservationList => _reervationList;
  final DataSource _dataSource = DummyDataSource();

  Future<ResponseModel> addReservation(BusReservation reservation) {
    return _dataSource.addReservation(reservation);
  }

  Future<BusRoute?> getRouteByCityFromAndCityTo(String cityFrom, String cityTo) {
    return _dataSource.getRouteByCityFromAndCityTo(cityFrom, cityTo);
  }

  Future<List<BusSchedule>> getSchedulesByRouteName(String routeName) async {
    return _dataSource.getSchedulesByRouteName(routeName);
  }

  Future<List<BusReservation>> getReservationsByScheduleAndDepartureDate(int scheduleId, String departureDate) {
    return _dataSource.getReservationsByScheduleAndDepartureDate(scheduleId, departureDate);
  }
}

