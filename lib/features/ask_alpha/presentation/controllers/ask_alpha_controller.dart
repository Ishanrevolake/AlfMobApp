import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ask_alpha_models.dart';
import '../../data/repositories/ask_alpha_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'dart:io';

class AskAlphaState {
  final List<AskAlphaOrder> orders;
  final List<AskAlphaThread> threads;
  final int credits;

  AskAlphaState({
    this.orders = const [],
    this.threads = const [],
    this.credits = 0,
  });

  AskAlphaState copyWith({
    List<AskAlphaOrder>? orders,
    List<AskAlphaThread>? threads,
    int? credits,
  }) {
    return AskAlphaState(
      orders: orders ?? this.orders,
      threads: threads ?? this.threads,
      credits: credits ?? this.credits,
    );
  }
}

class AskAlphaController extends AsyncNotifier<AskAlphaState> {
  late AskAlphaRepository _repository;
  late String _clientId;

  @override
  FutureOr<AskAlphaState> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return AskAlphaState();

    _clientId = user.id;
    _repository = ref.watch(askAlphaRepositoryProvider);

    final results = await Future.wait([
      _repository.getOrders(_clientId),
      _repository.getThreads(_clientId),
    ]);
    final orders = results[0] as List<AskAlphaOrder>;
    final threads = results[1] as List<AskAlphaThread>;
    final purchased = orders
        .where((order) => order.status == 'verified')
        .fold<int>(0, (sum, order) => sum + order.credits);
    return AskAlphaState(
      orders: orders,
      threads: threads,
      credits: (purchased - threads.length).clamp(0, 999),
    );
  }

  Future<void> buyCredits(
    String pack,
    String title,
    int credits,
    num amount,
    File? paymentSlip,
  ) async {
    state = const AsyncLoading();
    try {
      await _repository.submitOrder(
        userId: _clientId,
        pack: pack,
        title: title,
        credits: credits,
        amount: amount,
        paymentSlip: paymentSlip,
      );
      // Refresh state
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<AskAlphaThread> submitQuestion(String question) async {
    final current = state.requireValue;
    final usageByOrder = <String, int>{};
    for (final thread in current.threads) {
      usageByOrder.update(
        thread.orderId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    final order = current.orders.cast<AskAlphaOrder?>().firstWhere(
      (item) =>
          item!.status == 'verified' &&
          (usageByOrder[item.id] ?? 0) < item.credits,
      orElse: () => null,
    );
    if (order == null)
      throw StateError('No verified Ask Alpha credit is available.');
    final thread = await _repository.submitQuestion(
      userId: _clientId,
      order: order,
      question: question,
    );
    ref.invalidateSelf();
    return thread;
  }
}

final askAlphaControllerProvider =
    AsyncNotifierProvider<AskAlphaController, AskAlphaState>(() {
      return AskAlphaController();
    });
