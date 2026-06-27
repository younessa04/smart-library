import 'package:flutter/material.dart';
import '../../../domain/entities/loan_entity.dart';
import '../../../domain/repositories/repository_interfaces.dart';

class LoanProvider extends ChangeNotifier {
  final LoanRepository _loanRepository;

  LoanProvider({required LoanRepository loanRepository})
      : _loanRepository = loanRepository;

  List<LoanEntity> _myLoans = [];
  List<LoanEntity> _allLoans = [];
  bool _isLoading = false;
  String? _error;

  List<LoanEntity> get myLoans => _myLoans;
  List<LoanEntity> get allLoans => _allLoans;
  List<LoanEntity> get pendingLoans => _allLoans.where((l) => l.isPending).toList();
  List<LoanEntity> get approvedLoans => _allLoans.where((l) => l.isApproved).toList();
  List<LoanEntity> get returnedLoans => _allLoans.where((l) => l.isReturned).toList();
  List<LoanEntity> get activeLoans => _myLoans.where((l) => l.isApproved).toList();
  List<LoanEntity> get historyLoans => _myLoans.where((l) => l.isReturned || l.status == 'rejected').toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyLoans(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _myLoans = await _loanRepository.getUserLoans(userId);
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllLoans() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allLoans = await _loanRepository.getAllLoans();
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> requestLoan(LoanEntity loan) async {
    try {
      await _loanRepository.requestLoan(loan);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> approveLoan(String loanId) async {
    await _loanRepository.approveLoan(loanId);
    await loadAllLoans();
  }

  Future<void> rejectLoan(String loanId) async {
    await _loanRepository.rejectLoan(loanId);
    await loadAllLoans();
  }

  Future<void> returnLoan(String loanId) async {
    await _loanRepository.returnLoan(loanId);
    await loadAllLoans();
  }

  Future<void> renewLoan(String loanId) async {
    await _loanRepository.renewLoan(loanId);
  }
}
