import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../providers/loan_provider.dart';

class LoansManagementScreen extends StatefulWidget {
  const LoansManagementScreen({super.key});
  @override
  State<LoansManagementScreen> createState() => _LoansManagementScreenState();
}

class _LoansManagementScreenState extends State<LoansManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<LoanProvider>(context, listen: false).loadAllLoans();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loanProvider = Provider.of<LoanProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestion des Emprunts'),
          bottom: TabBar(tabs: [
            Tab(text: 'En attente (${loanProvider.pendingLoans.length})'),
            Tab(text: 'Approuvés (${loanProvider.approvedLoans.length})'),
            Tab(text: 'Retournés (${loanProvider.returnedLoans.length})'),
          ]),
        ),
        body: loanProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildLoanList(loanProvider.pendingLoans, 'pending', loanProvider),
                  _buildLoanList(loanProvider.approvedLoans, 'approved', loanProvider),
                  _buildLoanList(loanProvider.returnedLoans, 'returned', loanProvider),
                ],
              ),
      ),
    );
  }

  Widget _buildLoanList(List loans, String type, LoanProvider provider) {
    if (loans.isEmpty) {
      return const EmptyStateWidget(icon: Icons.swap_horiz, title: 'Aucun emprunt');
    }
    return RefreshIndicator(
      onRefresh: () => provider.loadAllLoans(),
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
                            ? CachedNetworkImage(imageUrl: loan.bookCover, width: 50, height: 70, fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(width: 50, height: 70, color: Colors.grey[300], child: const Icon(Icons.book)))
                            : Container(width: 50, height: 70, color: Colors.grey[300], child: const Icon(Icons.book)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loan.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(loan.userName, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            Text('Emprunté: ${Formatters.formatDate(loan.borrowDate)}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                            Text('Retour: ${Formatters.formatDate(loan.dueDate)}', style: TextStyle(fontSize: 11, color: loan.isOverdue ? AppColors.error : Colors.grey[500])),
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
                          onPressed: () => provider.rejectLoan(loan.id),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Refuser'),
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => provider.approveLoan(loan.id),
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
                          onPressed: () => provider.returnLoan(loan.id),
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
