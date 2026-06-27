import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vue d\'ensemble', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                StatCard(icon: Icons.book, label: 'Total Livres', value: '0', color: AppColors.primary),
                StatCard(icon: Icons.check_circle, label: 'Disponibles', value: '0', color: AppColors.success),
                StatCard(icon: Icons.book_online, label: 'Empruntés', value: '0', color: AppColors.warning),
                StatCard(icon: Icons.people, label: 'Utilisateurs', value: '0', color: AppColors.info),
                StatCard(icon: Icons.bookmark, label: 'Réservations', value: '0', color: AppColors.secondary),
                StatCard(icon: Icons.pending, label: 'En attente', value: '0', color: AppColors.error),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Emprunts par mois', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(6, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (i + 1) * 5.0, color: AppColors.primary, width: 20)])),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun'][v.toInt()]))),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Catégories populaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: 30, color: AppColors.primary, title: 'Info', radius: 60),
                    PieChartSectionData(value: 25, color: AppColors.secondary, title: 'IA', radius: 60),
                    PieChartSectionData(value: 20, color: AppColors.success, title: 'Math', radius: 60),
                    PieChartSectionData(value: 15, color: AppColors.warning, title: 'Physique', radius: 60),
                    PieChartSectionData(value: 10, color: AppColors.error, title: 'Autre', radius: 60),
                  ],
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Activité récente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: List.generate(5, (i) => ListTile(
                  leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: Icon(Icons.book, color: AppColors.primary, size: 20)),
                  title: Text('Activité ${i + 1}'),
                  subtitle: Text('Description de l\'activité'),
                  trailing: Text('${i + 1}h', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
