part of 'main_bloc.dart';

class MainEvent {}

class GetAddressInfo extends MainEvent {
  String lat;
  String lon;

  GetAddressInfo({
    required this.lat,
    required this.lon,
  });
}
