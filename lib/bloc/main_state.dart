part of 'main_bloc.dart';

enum Status { success, fail, loading, initial }

class MainState extends Equatable {
  Status status;
  AddressInfoResponse? address;

  @override
  List<Object?> get props => [status];

  MainState({
    this.status = Status.initial,
    this.address,
  });

  MainState copyWith({
    Status? status,
    AddressInfoResponse? address,
  }) {
    return MainState(
      status: status ?? this.status,
      address: address ?? this.address,
    );
  }
}
