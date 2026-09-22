import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../models/match_history.dart';
import '../services/local_storage_service.dart';
import '../widgets/score_card.dart';
import 'match_history_screen.dart';

/// Trạng thái tổng thể của trận đấu
enum GameStatus {
  notStarted,
  running,
  paused,
  gameOver,
}

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen>
    with TickerProviderStateMixin {
  final GameState _game = GameState();
  final LocalStorageService _storage = LocalStorageService();

  String _teamAName = 'Đội A';
  String _teamBName = 'Đội B';

  // Confetti animation
  late AnimationController _confettiController;

  // Timer state
  Duration _elapsedTime = Duration.zero;
  GameStatus _gameStatus = GameStatus.notStarted;
  Timer? _timer;
  bool _isMatchSaved = false;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  /// Lưu trận đấu vào lịch sử
  Future<void> _saveMatch() async {
    if (_isMatchSaved) return; // Tránh lưu duplicate
    _isMatchSaved = true;

    final match = MatchHistory(
      teamAScore: _game.teamAScore,
      teamBScore: _game.teamBScore,
      teamAName: _teamAName.trim().isEmpty ? 'Đội A' : _teamAName,
      teamBName: _teamBName.trim().isEmpty ? 'Đội B' : _teamBName,
      winner: _game.winner,
      durationInSeconds: _elapsedTime.inSeconds,
      playedAt: DateTime.now(),
    );

    await _storage.saveMatch(match);
  }

  /// Format Duration thành MM:SS
  String _formatTime(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ── Timer controls ──

  void _startTimer() {
    if (_gameStatus != GameStatus.notStarted) return;
    setState(() {
      _gameStatus = GameStatus.running;
    });
    _createTimer();
  }

  void _pauseTimer() {
    if (_gameStatus != GameStatus.running) return;
    _timer?.cancel();
    _timer = null;
    setState(() {
      _gameStatus = GameStatus.paused;
    });
  }

  void _resumeTimer() {
    if (_gameStatus != GameStatus.paused) return;
    setState(() {
      _gameStatus = GameStatus.running;
    });
    _createTimer();
  }

  void _createTimer() {
    _timer?.cancel(); // Safety: đảm bảo chỉ 1 Timer
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedTime += const Duration(seconds: 1);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ── Score controls ──

  void _adjustScore(String team, int delta) {
    if (_gameStatus != GameStatus.running) return;
    HapticFeedback.lightImpact();
    setState(() {
      _game.adjustScore(team, delta);
      if (_game.isGameOver) {
        _stopTimer();
        _gameStatus = GameStatus.gameOver;
        _confettiController.forward(from: 0);
        HapticFeedback.heavyImpact();
        _saveMatch();
      }
    });
  }

  void _resetScores() {
    HapticFeedback.mediumImpact();
    setState(() {
      _game.reset();
      _stopTimer();
      _elapsedTime = Duration.zero;
      _gameStatus = GameStatus.notStarted;
      _isMatchSaved = false;
      _confettiController.reset();
    });
  }

  /// Xử lý nhấn nút START/PAUSE/RESUME
  void _onTimerButtonPressed() {
    switch (_gameStatus) {
      case GameStatus.notStarted:
        _startTimer();
        break;
      case GameStatus.running:
        _pauseTimer();
        break;
      case GameStatus.paused:
        _resumeTimer();
        break;
      case GameStatus.gameOver:
        break; // Disabled
    }
  }

  String get _winnerDisplayName {
    if (_game.winner == 'a') {
      return _teamAName.trim().isEmpty ? 'ĐỘI A' : _teamAName.toUpperCase();
    } else if (_game.winner == 'b') {
      return _teamBName.trim().isEmpty ? 'ĐỘI B' : _teamBName.toUpperCase();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF020617),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFF020617), // slate-950
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 6),
              // Main scoreboard
              Expanded(
                child: Stack(
                  children: [
                    _buildScoreboard(),
                    _buildCenterOverlay(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E293B).withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        children: [
          // Brand icon
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.sports_tennis,
              color: Color(0xFF22D3EE),
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          // Title
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'BADMINTON ',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                TextSpan(
                  text: 'SCOREBOARD',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF22D3EE),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            style: TextStyle(fontSize: 13),
          ),
          const Spacer(),
          // Status badge
          _buildStatusBadge(),
          const SizedBox(width: 8),
          // Timer control button (START/PAUSE/RESUME)
          _buildTimerControlButton(),
          const SizedBox(width: 8),
          // History button
          _buildHistoryButton(),
          const SizedBox(width: 8),
          // Reset button
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (_gameStatus == GameStatus.gameOver) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆 ', style: TextStyle(fontSize: 12)),
            Text(
              '$_winnerDisplayName THẮNG!',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    // Live / Ready / Paused badge
    String label;
    Color dotColor;
    Color textColor;

    switch (_gameStatus) {
      case GameStatus.running:
        label = _game.isDeuce ? 'DEUCE' : 'LIVE';
        dotColor = _game.isDeuce
            ? const Color(0xFFFBBF24)
            : const Color(0xFF34D399);
        textColor = dotColor;
        break;
      case GameStatus.paused:
        label = 'PAUSED';
        dotColor = const Color(0xFFFBBF24);
        textColor = const Color(0xFFFBBF24);
        break;
      default:
        label = 'READY';
        dotColor = const Color(0xFF64748B);
        textColor = const Color(0xFF64748B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 1.5,
            ),
          ),
          const Text(
            ' • 21 PTS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFFCBD5E1),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerControlButton() {
    String label;
    IconData icon;
    Color bgColor;
    Color textColor;
    Color borderColor;
    bool enabled;

    switch (_gameStatus) {
      case GameStatus.notStarted:
        label = 'START';
        icon = Icons.play_arrow_rounded;
        bgColor = const Color(0xFF10B981).withValues(alpha: 0.2);
        textColor = const Color(0xFF34D399);
        borderColor = const Color(0xFF10B981).withValues(alpha: 0.5);
        enabled = true;
        break;
      case GameStatus.running:
        label = 'PAUSE';
        icon = Icons.pause_rounded;
        bgColor = const Color(0xFFFBBF24).withValues(alpha: 0.15);
        textColor = const Color(0xFFFBBF24);
        borderColor = const Color(0xFFFBBF24).withValues(alpha: 0.4);
        enabled = true;
        break;
      case GameStatus.paused:
        label = 'RESUME';
        icon = Icons.play_arrow_rounded;
        bgColor = const Color(0xFF10B981).withValues(alpha: 0.2);
        textColor = const Color(0xFF34D399);
        borderColor = const Color(0xFF10B981).withValues(alpha: 0.5);
        enabled = true;
        break;
      case GameStatus.gameOver:
        label = 'KẾT THÚC';
        icon = Icons.flag_rounded;
        bgColor = const Color(0xFF1E293B).withValues(alpha: 0.5);
        textColor = const Color(0xFF64748B);
        borderColor = const Color(0xFF334155).withValues(alpha: 0.5);
        enabled = false;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? _onTimerButtonPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MatchHistoryScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.history_rounded,
                size: 14,
                color: Color(0xFF60A5FA),
              ),
              const SizedBox(width: 6),
              const Text(
                'LỊCH SỬ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF93C5FD),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _resetScores,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                size: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              const Text(
                'RESET',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFCBD5E1),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreboard() {
    return Row(
      children: [
        // Team A card
        Expanded(
          child: ScoreCard(
            teamName: _teamAName,
            score: _game.teamAScore,
            accentColor: const Color(0xFF06B6D4),
            gradientEnd: const Color(0xFF3B82F6),
            isWinner: _game.winner == 'a',
            isScoreEnabled: _gameStatus == GameStatus.running,
            onIncrement: () => _adjustScore('a', 1),
            onDecrement: () => _adjustScore('a', -1),
            onTapScore: () => _adjustScore('a', 1),
            onNameChanged: (name) => setState(() => _teamAName = name),
          ),
        ),
        const SizedBox(width: 8),
        // Team B card
        Expanded(
          child: ScoreCard(
            teamName: _teamBName,
            score: _game.teamBScore,
            accentColor: const Color(0xFFF59E0B),
            gradientEnd: const Color(0xFFF97316),
            isWinner: _game.winner == 'b',
            isScoreEnabled: _gameStatus == GameStatus.running,
            onIncrement: () => _adjustScore('b', 1),
            onDecrement: () => _adjustScore('b', -1),
            onTapScore: () => _adjustScore('b', 1),
            onNameChanged: (name) => setState(() => _teamBName = name),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterOverlay() {
    final bool isPaused = _gameStatus == GameStatus.paused;
    final bool isRunning = _gameStatus == GameStatus.running;
    final bool isOver = _gameStatus == GameStatus.gameOver;

    return Center(
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timer display
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF020617).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isPaused
                      ? const Color(0xFFFBBF24).withValues(alpha: 0.5)
                      : isRunning
                          ? const Color(0xFF10B981).withValues(alpha: 0.5)
                          : isOver
                              ? const Color(0xFF34D399).withValues(alpha: 0.6)
                              : const Color(0xFF334155).withValues(alpha: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isPaused
                        ? const Color(0xFFFBBF24).withValues(alpha: 0.1)
                        : isRunning
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Timer label
                  Text(
                    isOver
                        ? 'TIME'
                        : isPaused
                            ? 'TẠM DỪNG'
                            : 'THỜI GIAN',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: isPaused
                          ? const Color(0xFFFBBF24).withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Timer value
                  Text(
                    _formatTime(_elapsedTime),
                    style: GoogleFonts.chakraPetch(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isOver
                          ? const Color(0xFF34D399)
                          : isPaused
                              ? const Color(0xFFFBBF24)
                              : isRunning
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // VS badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF020617).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF334155).withValues(alpha: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Text(
                'VS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFCBD5E1),
                  letterSpacing: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
