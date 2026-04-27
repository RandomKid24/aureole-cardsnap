import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/database/database.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/dot_grid_painter.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int totalCards = 0;
  int thisWeek = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final contacts = await context.read<AppDatabase>().contactsDao.getAllContacts();
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    if (mounted) {
      setState(() {
        totalCards = contacts.length;
        thisWeek = contacts.where((c) => c.createdAt.isAfter(startOfWeek)).length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("YOUR NETWORK")),
      body: DotGridBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: _statCard("TOTAL CARDS", totalCards.toString())),
                  const SizedBox(width: 16),
                  Expanded(child: _statCard("THIS WEEK", thisWeek.toString())),
                ],
              ),
              const SizedBox(height: 32),
              Text("SCANS OVER TIME", style: GoogleFonts.bebasNeue(fontSize: 24, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 10,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: const FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 2)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: AppTheme.primaryBlue, width: 16, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 4, color: AppTheme.primaryBlue, width: 16, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 6, color: AppTheme.primaryBlue, width: 16, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 2, color: AppTheme.primaryBlue, width: 16, borderRadius: BorderRadius.circular(4))]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _statCard("STREAK", "0 DAYS 🔥"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.bebasNeue(fontSize: 48, color: AppTheme.primaryBlue)),
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.stone, letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }
}
