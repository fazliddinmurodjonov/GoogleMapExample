import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_map_with_bottom_sheet/models/address_info_response.dart';

part 'main_event.dart';

part 'main_state.dart';

class FakeAddress {
  String name;
  String lat;
  String lon;

  FakeAddress({
    required this.name,
    required this.lat,
    required this.lon,
  });
}

class MainBloc extends Bloc<MainEvent, MainState> {
  final String _exampleApiKey = "1eff89edbcc1a3400cb73d9d5a655724";
  final String _baseUrl = "https://nominatim.openstreetmap.org/";

  final List<FakeAddress> _fakeAddresses = [
    FakeAddress(name: "Namangan", lat: "40.993599", lon: "71.677452"),
    FakeAddress(name: "Tashkent", lat: "41.299496", lon: "69.240074"),
    FakeAddress(name: "Samarkand", lat: "39.954868", lon: "66.312073"),
  ];

  List<FakeAddress> get fakeAddresses => _fakeAddresses;

  MainBloc() : super(MainState()) {
    on<MainEvent>((event, emit) async {
      if (event is GetAddressInfo) {
        emit(MainState().copyWith(status: Status.loading));
        await _getAddressInfo(event.lat, event.lon, emit);
      }
    });
  }

  Future<void> _getAddressInfo(String lat, String lon, Emitter emitter) async {
    try {
      var response = await HttpClient()
          .getUrl(Uri.parse(
              '$_baseUrl/reverse?format=json&access_key=$_exampleApiKey&lat=$lat&lon=$lon'))
          .then((request) => request.close());

      await for (var contents in response.transform(const Utf8Decoder())) {
        var addressInfoResponse = AddressInfoResponse.fromJson(jsonDecode(contents));
        emitter(MainState().copyWith(status: Status.success, address: addressInfoResponse));
      }
    } catch (e) {
      emitter(MainState().copyWith(status: Status.fail, address: null));
    }
  }
}
