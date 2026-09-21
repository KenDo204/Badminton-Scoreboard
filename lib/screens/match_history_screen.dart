import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/match_history.dart';
import '../services/local_storage_service.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  final LocalStorageService _storage = LocalStorageService();
  List<MatchHistory> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _storage.getMatchHistory();
    setState(() {
      _matches = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617), // slate-950
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _matches.isEmpty
                      ? _buildEmptyState()
                      : _buildMatchList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF1E293B).withValues(alpha: 0.8),
          ),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'LỊCH SỬ TRẬN ĐẤU',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có trận đấu nào',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.4),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        final match = _matches[index];
        return _buildMatchCard(match, index + 1);
      },
    );
  }

  Widget _buildMatchCard(MatchHistory match, int matchIndex) {
    final bool isTeamAWinner = match.winner == 'a';
    final bool isTeamBWinner = match.winner == 'b';
    final dateStr = DateFormat('dd/MM/yyyy').format(match.playedAt);
    final timeStr = DateFormat('HH:mm').format(match.playedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E293B).withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Match Number Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'TRẬN GẦN NHẤT ${matchIndex > 1 ? '#$matchIndex' : ''}'.trim(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Teams and Score Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Team A
              Expanded(
                child: Column(
                  children: [
                    Text(
                      match.teamAName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isTeamAWinner ? FontWeight.w900 : FontWeight.w600,
                        color: isTeamAWinner
                            ? const Color(0xFF22D3EE) // cyan-400
                            : Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isTeamAWinner)
                      const Text('🏆', style: TextStyle(fontSize: 16))
                    else
                      const SizedBox(height: 16),
                  ],
                ),
              ),

              // Scores
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF020617).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF334155).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${match.teamAScore}',
                      style: GoogleFonts.chakraPetch(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: isTeamAWinner
                            ? const Color(0xFF22D3EE)
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '-',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    Text(
                      '${match.teamBScore}',
                      style: GoogleFonts.chakraPetch(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: isTeamBWinner
                            ? const Color(0xFFF59E0B) // amber-500
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Team B
              Expanded(
                child: Column(
                  children: [
                    Text(
                      match.teamBName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isTeamBWinner ? FontWeight.w900 : FontWeight.w600,
                        color: isTeamBWinner
                            ? const Color(0xFFF59E0B)
                            : Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isTeamBWinner)
                      const Text('🏆', style: TextStyle(fontSize: 16))
                    else
                      const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: const Color(0xFF334155).withValues(alpha: 0.5)),
          const SizedBox(height: 12),

          // Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Winner Text
              Text(
                '${match.winnerName} thắng',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981), // emerald-500
                ),
              ),
              // Time and Date
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    match.formattedDuration,
                    style: GoogleFonts.chakraPetch(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$timeStr - $dateStr',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
