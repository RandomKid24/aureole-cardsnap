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
  bool _loading = true;
  int _totalCards = 0;
  int _thisWeek = 0;
  int _streakDays = 0;
  List<int> _last7 = List.filled(7, 0);
  List<String> _last7Labels = List.filled(7, '');

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _loadStats() async {
    final contacts = await context.read<AppDatabase>().contactsDao.getAllContacts();
    final now = DateTime.now();
    final today = _dayKey(now);

    // Per-day scan counts.
    final byDay = <DateTime, int>{};
    for (final c in contacts) {
      final k = _dayKey(c.createdAt);
      byDay[k] = (byDay[k] ?? 0) + 1;
    }

    // Last 7 days (oldest -> newest), with short weekday labels.
    const weekdayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final last7 = <int>[];
    final labels = <String>[];
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      last7.add(byDay[day] ?? 0);
      labels.add(weekdayNames[day.weekday - 1]);
    }

    // Streak: consecutive days with >=1 scan, counting back from today
    // (or yesterday, so a quiet morning doesn't reset it).
    int streak = 0;
    var cursor = today;
    if ((byDay[cursor] ?? 0) == 0) cursor = cursor.subtract(const Duration(days: 1));
    while ((byDay[cursor] ?? 0) > 0) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));

    if (mounted) {
      setState(() {
        _loading = false;
        _totalCards = contacts.length;
        _thisWeek = contacts.where((c) => !c.createdAt.isBefore(startOfWeek)).length;
        _streakDays = streak;
        _last7 = last7;
        _last7Labels = labels;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxY = ((_last7.isEmpty ? 0 : _last7.reduce((a, b) => a > b ? a : b)) + 1)
        .clamp(4, 1000)
        .toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text("YOUR NETWORK")),
      body: DotGridBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _statCard("TOTAL CARDS", _totalCards.toString())),
                        const SizedBox(width: 16),
                        Expanded(child: _statCard("THIS WEEK", _thisWeek.toString())),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text("SCANS · LAST 7 DAYS",
                        style: GoogleFonts.bebasNeue(fontSize: 24, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _totalCards == 0
                              ? const Center(
                                  child: Text("No scans yet",
                                      style: TextStyle(color: AppTheme.stone)),
                                )
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: maxY,
                                    barTouchData: BarTouchData(enabled: true),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 24,
                                          getTitlesWidget: (value, meta) {
                                            final i = value.toInt();
                                            if (i < 0 || i >= _last7Labels.length) {
                                              return const SizedBox.shrink();
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Text(_last7Labels[i],
                                                  style: const TextStyle(
                                                      fontSize: 10, color: AppTheme.stone)),
                                            );
                                          },
                                        ),
                                      ),
                                      leftTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: true, reservedSize: 28, interval: 2)),
                                      topTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: [
                                      for (int i = 0; i < _last7.length; i++)
                                        BarChartGroupData(x: i, barRods: [
                                          BarChartRodData(
                                            toY: _last7[i].toDouble(),
                                            color: AppTheme.primaryBlue,
                                            width: 16,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ]),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _statCard("STREAK", _streakDays == 0
                        ? "0 DAYS"
                        : "$_streakDays DAY${_streakDays == 1 ? '' : 'S'} 🔥"),
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
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.stone,
                    letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }
}
