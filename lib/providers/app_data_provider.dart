import 'package:flutter/material.dart';
import 'package:yatrisewa/datasource/data_source.dart';
import 'package:yatrisewa/datasource/dummy_data_source.dart';
import 'package:yatrisewa/models/bus_route.dart';
import 'package:yatrisewa/models/bus_schedule.dart';

class AppDataProvider extends ChangeNotifier{
  List<BusSchedule> _scheduleList = [];
  List<BusSchedule> get scheduleList => _scheduleList;
  final DataSource _dataSource = DummyDataSource();

  Future<BusRoute?> getRouteByCityFromAndCityTo(String cityFrom, String cityTo){
    return _dataSource.getRouteByCityFromAndCityTo(cityFrom, cityTo);

  }

  Future<List<BusSchedule>> getSehedulesbyRouteName(String routeName) async{
    return _dataSource.getSchedulesByRouteName(routeName);
  }
}

