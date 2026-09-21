import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget hiển thị điểm số lớn cho mỗi đội
class ScoreCard extends StatelessWidget {
  final String teamName;
  final int score;
  final Color accentColor;
  final Color gradientEnd;
  final bool isWinner;
  final bool isGameOver;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onTapScore;
  final ValueChanged<String> onNameChanged;

  const ScoreCard({
    super.key,
    required this.teamName,
    required this.score,
    required this.accentColor,
    required this.gradientEnd,
    required this.isWinner,
    required this.isGameOver,
    required this.onIncrement,
    required this.onDecrement,
    required this.onTapScore,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isWinner
        ? const Color(0xFF34D399) // emerald-400
        : accentColor.withValues(alpha: 0.5);

    final glowColor = isWinner
        ? const Color(0xFF10B981).withValues(alpha: 0.45)
        : accentColor.withValues(alpha: 0.35);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xF20F172A), // slate-900/95
            Color(0xF2020617), // slate-950/95
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 35,
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // Top gradient bar
            Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, gradientEnd],
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  children: [
                    // Team name row
                    _buildTeamNameRow(),
                    // Score display
                    Expanded(child: _buildScoreDisplay()),
                    // Control buttons
                    _buildControlButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamNameRow() {
    return Row(
      children: [
        // Color dot
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Editable team name
        Expanded(
          child: TextField(
            controller: TextEditingController(text: teamName),
            onChanged: onNameChanged,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'Tên đội',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        // Winner badge
        if (isWinner)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
              ),
            ),
            child: const Text(
              'WINNER 🏆',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF34D399),
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScoreDisplay() {
    return GestureDetector(
      onTap: isGameOver ? null : onTapScore,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large score number
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$score',
                key: ValueKey<int>(score),
                style: GoogleFonts.chakraPetch(
                  fontSize: 160,
                  fontWeight: FontWeight.w800,
                  color: isWinner ? const Color(0xFF34D399) : accentColor,
                  height: 0.9,
                  shadows: [
                    Shadow(
                      color: (isWinner ? const Color(0xFF10B981) : accentColor)
                          .withValues(alpha: 0.35),
                      blurRadius: 25,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Hint text
          if (!isGameOver)
            Text(
              'CHẠM SỐ ĐỂ +1',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.3),
                letterSpacing: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          // Minus button
          SizedBox(
            width: 56,
            height: 48,
            child: ElevatedButton(
              onPressed: isGameOver ? null : onDecrement,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xE61E293B), // slate-800/90
                disabledBackgroundColor: const Color(0x801E293B),
                foregroundColor: const Color(0xFFCBD5E1), // slate-300
                disabledForegroundColor: const Color(0x80CBD5E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFF334155)), // slate-700
                ),
                elevation: 4,
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.remove, size: 26),
            ),
          ),
          const SizedBox(width: 8),
          // Plus button
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isGameOver ? null : onIncrement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  disabledBackgroundColor: accentColor.withValues(alpha: 0.4),
                  foregroundColor: const Color(0xFF020617), // slate-950
                  disabledForegroundColor: const Color(0x80020617),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 8,
                  shadowColor: accentColor.withValues(alpha: 0.25),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                icon: const Icon(Icons.add, size: 24),
                label: const Text(
                  'ĐIỂM +1',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
