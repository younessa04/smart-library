import 'package:flutter/material.dart';
import '../../../domain/entities/reservation_entity.dart';
import '../../../domain/repositories/repository_interfaces.dart';

class ReservationProvider extends ChangeNotifier {
  final ReservationRepository _reservationRepository;

  ReservationProvider({required ReservationRepository reservationRepository})
      : _reservationRepository = reservationRepository;

  List<ReservationEntity> _reservations = [];
  bool _isLoading = false;
  String? _error;

  List<ReservationEntity> get reservations => _reservations;
  List<ReservationEntity> get activeReservations => _reservations.where((r) => r.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReservations(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _reservations = await _reservationRepository.getUserReservations(userId);
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createReservation(ReservationEntity reservation) async {
    try {
      await _reservationRepository.createReservation(reservation);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelReservation(String reservationId) async {
    try {
      await _reservationRepository.cancelReservation(reservationId);
      _reservations.firstWhere((r) => r.id == reservationId).copyWith(status: 'cancelled');
      notifyListeners();
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
      notifyListeners();
    }
  }
}
