import 'package:json_annotation/json_annotation.dart';

part 'address_info_response.g.dart';

@JsonSerializable()
class AddressInfoResponse {
  @JsonKey(name: "display_name")
  String displayName;
  Address address;

  AddressInfoResponse({
    required this.displayName,
    required this.address,
  });

  factory AddressInfoResponse.fromJson(Map<String, dynamic> srcJson) =>
      _$AddressInfoResponseFromJson(srcJson);
}

@JsonSerializable()
class Address {
  String country;

  Address({
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> srcJson) => _$AddressFromJson(srcJson);
}
