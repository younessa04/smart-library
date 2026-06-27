import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/loan.dart';
import '../services/database_service.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/state_widgets.dart';

class LoansManagementScreen extends StatefulWidget {
  const LoansManagementScreen({super.key});
  @override
  State<LoansManagementScreen> createState() => _LoansManagementScreenState();
}

class _LoansManagementScreenState extends State<LoansManagementScreen> {
  final _db = DatabaseService();

  List<Loan> _allLoans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    setState(() => _isLoading = true);
    try {
      final loans = await _db.getAllLoans();
      if (!mounted) return;
      setState(() {
        _allLoans = loans;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<Loan> get _pendingLoans =>
      _allLoans.where((l) => l.status == 'pending').toList();
  List<Loan> get _approvedLoans =>
      _allLoans.where((l) => l.status == 'approved').toList();
  List<Loan> get _returnedLoans =>
      _allLoans.where((l) => l.status == 'returned').toList();

  Future<void> _approveLoan(String id) async {
    await _db.approveLoan(id);
    await _loadLoans();
  }

  Future<void> _rejectLoan(String id) async {
    await _db.rejectLoan(id);
    await _loadLoans();
  }

  Future<void> _returnLoan(String id) async {
    await _db.returnLoan(id);
    await _loadLoans();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestion des Emprunts'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'En attente (${_pendingLoans.length})'),
              Tab(text: 'Approuvés (${_approvedLoans.length})'),
              Tab(text: 'Retournés (${_returnedLoans.length})'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildLoanList(_pendingLoans, 'pending'),
                  _buildLoanList(_approvedLoans, 'approved'),
                  _buildLoanList(_returnedLoans, 'returned'),
                ],
              ),
      ),
    );
  }

  Widget _buildLoanList(List<Loan> loans, String type) {
    if (loans.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.swap_horiz,
        title: 'Aucun emprunt',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadLoans,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: loans.length,
        itemBuilder: (context, index) {
          final loan = loans[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: loan.bookCover.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: loan.bookCover,
                                width: 50,
                                height: 70,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  width: 50, height: 70, color: Colors.grey[300],
                                  child: const Icon(Icons.book),
                                ),
                              )
                            : Container(
                                width: 50, height: 70, color: Colors.grey[300],
                                child: const Icon(Icons.book),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loan.bookTitle,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              loan.userName,
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                            Text(
                              'Emprunté: ${Formatters.formatDate(loan.borrowDate)}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                            Text(
                              'Retour: ${Formatters.formatDate(loan.dueDate)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: loan.isOverdue ? AppColors.error : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (type == 'pending') ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _rejectLoan(loan.id),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Refuser'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _approveLoan(loan.id),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Approuver'),
                        ),
                      ],
                    ),
                  ],
                  if (type == 'approved') ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _returnLoan(loan.id),
                          icon: const Icon(Icons.assignment_return, size: 16),
                          label: const Text('Marquer retourné'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
