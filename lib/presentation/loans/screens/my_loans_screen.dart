import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/loan_provider.dart';

class MyLoansScreen extends StatefulWidget {
  const MyLoansScreen({super.key});
  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
        if (userId != null) {
          Provider.of<LoanProvider>(context, listen: false).loadMyLoans(userId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loanProvider = Provider.of<LoanProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Emprunts'),
          bottom: const TabBar(tabs: [Tab(text: 'En cours'), Tab(text: 'Historique')]),
        ),
        body: loanProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildLoanList(loanProvider.activeLoans, 'Aucun emprunt en cours'),
                  _buildLoanList(loanProvider.historyLoans, 'Aucun historique'),
                ],
              ),
      ),
    );
  }

  Widget _buildLoanList(List loans, String emptyMessage) {
    if (loans.isEmpty) {
      return EmptyStateWidget(icon: Icons.book_online_outlined, title: emptyMessage);
    }
    return RefreshIndicator(
      onRefresh: () => Provider.of<LoanProvider>(context, listen: false)
          .loadMyLoans(Provider.of<AuthProvider>(context, listen: false).user!.id),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: loans.length,
        itemBuilder: (context, index) {
          final loan = loans[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: loan.bookCover.isNotEmpty
                        ? CachedNetworkImage(imageUrl: loan.bookCover, width: 60, height: 80, fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(width: 60, height: 80, color: Colors.grey[300], child: const Icon(Icons.book)))
                        : Container(width: 60, height: 80, color: Colors.grey[300], child: const Icon(Icons.book)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loan.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('Emprunté le ${Formatters.formatDate(loan.borrowDate)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: loan.isOverdue ? AppColors.error : AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              Formatters.formatDaysRemaining(loan.dueDate),
                              style: TextStyle(fontSize: 12, color: loan.isOverdue ? AppColors.error : AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(loan.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_getStatusLabel(loan.status), style: TextStyle(fontSize: 11, color: _getStatusColor(loan.status), fontWeight: FontWeight.w600)),
                      ),
                      if (loan.canRenew)
                        TextButton(
                          onPressed: () {
                            Provider.of<LoanProvider>(context, listen: false).renewLoan(loan.id);
                          },
                          child: const Text('Renouveler', style: TextStyle(fontSize: 11)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.warning;
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.error;
      case 'returned': return AppColors.info;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'En attente';
      case 'approved': return 'Approuvé';
      case 'rejected': return 'Refusé';
      case 'returned': return 'Retourné';
      default: return status;
    }
  }
}
