import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/state_widgets.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});
  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  final _authService = AuthService();
  final _db = DatabaseService();

  List<Reservation> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final reservations = await _db.getUserReservations(user.id);
        if (!mounted) return;
        setState(() {
          _reservations = reservations;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    await _db.cancelReservation(reservation.id);
    await _loadReservations();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Réservation annulée'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Réservations')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.bookmark_outline,
                  title: 'Aucune réservation',
                  subtitle: 'Vos réservations apparaîtront ici',
                )
              : RefreshIndicator(
                  onRefresh: _loadReservations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reservations.length,
                    itemBuilder: (context, index) {
                      final res = _reservations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            res.bookTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Réservé le ${Formatters.formatDate(res.date)}',
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getColor(res.status)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getLabel(res.status),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _getColor(res.status),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Position: #${res.position}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: res.status == 'active'
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.cancel_outlined,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () =>
                                      _cancelReservation(res),
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
      case 'active':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.error;
      case 'completed':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }

  String _getLabel(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'cancelled':
        return 'Annulée';
      case 'completed':
        return 'Complétée';
      default:
        return status;
    }
  }
}
