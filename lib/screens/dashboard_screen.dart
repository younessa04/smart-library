import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firestore = FirebaseFirestore.instance;

  int _totalBooks = 0;
  int _availableBooks = 0;
  int _activeLoans = 0;
  int _totalUsers = 0;
  int _activeReservations = 0;
  int _pendingLoans = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _firestore.collection('books').count().get(),
        _firestore
            .collection('books')
            .where('available', isEqualTo: true)
            .count()
            .get(),
        _firestore
            .collection('loans')
            .where('status', isEqualTo: 'approved')
            .count()
            .get(),
        _firestore.collection('users').count().get(),
        _firestore
            .collection('reservations')
            .where('status', isEqualTo: 'active')
            .count()
            .get(),
        _firestore
            .collection('loans')
            .where('status', isEqualTo: 'pending')
            .count()
            .get(),
      ]);
      if (!mounted) return;
      setState(() {
        _totalBooks = (results[0] as AggregateQuerySnapshot).count ?? 0;
        _availableBooks = (results[1] as AggregateQuerySnapshot).count ?? 0;
        _activeLoans = (results[2] as AggregateQuerySnapshot).count ?? 0;
        _totalUsers = (results[3] as AggregateQuerySnapshot).count ?? 0;
        _activeReservations = (results[4] as AggregateQuerySnapshot).count ?? 0;
        _pendingLoans = (results[5] as AggregateQuerySnapshot).count ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.menu_book_rounded,
                            label: 'Total Livres',
                            value: _totalBooks,
                            gradientColors: [
                              const Color(0xFF1E88E5),
                              const Color(0xFF42A5F5),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.check_circle_rounded,
                            label: 'Disponibles',
                            value: _availableBooks,
                            gradientColors: [
                              const Color(0xFF43A047),
                              const Color(0xFF66BB6A),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.book_online_rounded,
                            label: 'Empruntés',
                            value: _activeLoans,
                            gradientColors: [
                              const Color(0xFFEF6C00),
                              const Color(0xFFFFA726),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.people_alt_rounded,
                            label: 'Utilisateurs',
                            value: _totalUsers,
                            gradientColors: [
                              const Color(0xFF00838F),
                              const Color(0xFF26C6DA),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.bookmark_add_rounded,
                            label: 'Réservations',
                            value: _activeReservations,
                            gradientColors: [
                              const Color(0xFF8E24AA),
                              const Color(0xFFAB47BC),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.hourglass_empty_rounded,
                            label: 'En attente',
                            value: _pendingLoans,
                            gradientColors: [
                              const Color(0xFFE53935),
                              const Color(0xFFEF5350),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Activité récente'),
                    const SizedBox(height: 12),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenue',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 2),
              Text(
                'Vue d\'ensemble',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int value,
    required List<Color> gradientColors,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                Text(
                  value >= 1000
                      ? '${(value / 1000).toStringAsFixed(1)}k'
                      : value.toString(),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: gradientColors.first,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors
                      .map((c) => c.withValues(alpha: 0.4))
                      .toList(),
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('loans')
          .orderBy('borrowDate', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: 40,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'Aucune activité récente',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final statusColors = _getStatusColors(d['status'] ?? '');
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                leading: CircleAvatar(
                  backgroundColor: statusColors['bg'],
                  child: Icon(
                    Icons.book,
                    color: statusColors['fg'],
                    size: 20,
                  ),
                ),
                title: Text(
                  d['bookTitle'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  d['userName'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColors['bg'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (d['status'] ?? '').toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColors['fg'],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Map<String, Color> _getStatusColors(String status) {
    switch (status) {
      case 'approved':
        return {
          'bg': Colors.green.shade50,
          'fg': Colors.green.shade700,
        };
      case 'pending':
        return {
          'bg': Colors.orange.shade50,
          'fg': Colors.orange.shade700,
        };
      case 'returned':
        return {
          'bg': Colors.blue.shade50,
          'fg': Colors.blue.shade700,
        };
      case 'rejected':
        return {
          'bg': Colors.red.shade50,
          'fg': Colors.red.shade700,
        };
      default:
        return {
          'bg': Colors.grey.shade100,
          'fg': Colors.grey.shade700,
        };
    }
  }
}
