/// Trạng thái trận đấu cầu lông
class GameState {
  int teamAScore;
  int teamBScore;
  bool isGameOver;
  String? winner; // 'a' hoặc 'b'
  bool isDeuce;

  static const int winningScore = 21;

  GameState({
    this.teamAScore = 0,
    this.teamBScore = 0,
    this.isGameOver = false,
    this.winner,
    this.isDeuce = false,
  });

  /// Tăng/giảm điểm cho một đội
  void adjustScore(String team, int delta) {
    if (isGameOver) return;

    if (team == 'a') {
      teamAScore = (teamAScore + delta).clamp(0, 999);
    } else if (team == 'b') {
      teamBScore = (teamBScore + delta).clamp(0, 999);
    }

    _checkWinner();
  }

  /// Kiểm tra người thắng theo luật BWF
  void _checkWinner() {
    // Kiểm tra trạng thái deuce
    if (teamAScore >= 20 && teamBScore >= 20) {
      isDeuce = true;
    }

    if (isDeuce) {
      // Trong trạng thái deuce: phải dẫn 2 điểm
      final diff = (teamAScore - teamBScore).abs();
      if (diff >= 2) {
        if (teamAScore > teamBScore) {
          _setWinner('a');
        } else {
          _setWinner('b');
        }
      }
    } else {
      // Trường hợp bình thường: đạt 21 điểm
      if (teamAScore >= winningScore && teamAScore > teamBScore) {
        _setWinner('a');
      } else if (teamBScore >= winningScore && teamBScore > teamAScore) {
        _setWinner('b');
      }
    }
  }

  void _setWinner(String team) {
    winner = team;
    isGameOver = true;
  }

  /// Xác định tên đội thắng
  String? getWinner() => winner;

  /// Reset trận đấu
  void reset() {
    teamAScore = 0;
    teamBScore = 0;
    isGameOver = false;
    winner = null;
    isDeuce = false;
  }
}
