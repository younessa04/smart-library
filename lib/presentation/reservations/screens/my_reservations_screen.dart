import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/reservation_provider.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});
  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
        if (userId != null) {
          Provider.of<ReservationProvider>(context, listen: false).loadReservations(userId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final resProvider = Provider.of<ReservationProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Réservations')),
      body: resProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : resProvider.reservations.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.bookmark_outline,
                  title: 'Aucune réservation',
                  subtitle: 'Vos réservations apparaîtront ici',
                )
              : RefreshIndicator(
                  onRefresh: () => resProvider.loadReservations(authProvider.user!.id),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: resProvider.reservations.length,
                    itemBuilder: (context, index) {
                      final res = resProvider.reservations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(res.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Réservé le ${Formatters.formatDate(res.date)}'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getColor(res.status).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(_getLabel(res.status), style: TextStyle(fontSize: 11, color: _getColor(res.status), fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Position: #${res.position}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                ],
                              ),
                            ],
                          ),
                          trailing: res.isActive
                              ? IconButton(
                                  icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                                  onPressed: () {
                                    resProvider.cancelReservation(res.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Réservation annulée'), backgroundColor: AppColors.success),
                                    );
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _getColor(String status) {
    switch (status) {
      case 'active': return AppColors.primary;
      case 'cancelled': return AppColors.error;
      case 'completed': return AppColors.success;
      default: return Colors.grey;
    }
  }

  String _getLabel(String status) {
    switch (status) {
      case 'active': return 'Active';
      case 'cancelled': return 'Annulée';
      case 'completed': return 'Complétée';
      default: return status;
    }
  }
}
