import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../client_profile/data/models/profile_models.dart';
import '../../data/repositories/clients_repository.dart';

class ClientsController extends AsyncNotifier<List<ClientProfile>> {
  late ClientsRepository _repository;

  @override
  FutureOr<List<ClientProfile>> build() async {
    _repository = ref.watch(clientsRepositoryProvider);
    return _repository.getClients();
  }
}

final clientsControllerProvider =
    AsyncNotifierProvider<ClientsController, List<ClientProfile>>(() {
      return ClientsController();
    });
