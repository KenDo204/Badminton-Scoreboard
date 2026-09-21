import 'dart:convert';

/// Model lưu thông tin một trận đấu đã hoàn thành
class MatchHistory {
  final int teamAScore;
  final int teamBScore;
  final String teamAName;
  final String teamBName;
  final String? winner; // 'a' hoặc 'b'
  final int durationInSeconds;
  final DateTime playedAt;

  MatchHistory({
    required this.teamAScore,
    required this.teamBScore,
    required this.teamAName,
    required this.teamBName,
    required this.winner,
    required this.durationInSeconds,
    required this.playedAt,
  });

  /// Tên đội thắng hiển thị
  String get winnerName {
    if (winner == 'a') return teamAName;
    if (winner == 'b') return teamBName;
    return '';
  }

  /// Format thời gian MM:SS
  String get formattedDuration {
    final minutes = durationInSeconds ~/ 60;
    final seconds = durationInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Serialize thành JSON Map
  Map<String, dynamic> toJson() => {
        'teamAScore': teamAScore,
        'teamBScore': teamBScore,
        'teamAName': teamAName,
        'teamBName': teamBName,
        'winner': winner,
        'durationInSeconds': durationInSeconds,
        'playedAt': playedAt.toIso8601String(),
      };

  /// Deserialize từ JSON Map
  factory MatchHistory.fromJson(Map<String, dynamic> json) => MatchHistory(
        teamAScore: json['teamAScore'] as int,
        teamBScore: json['teamBScore'] as int,
        teamAName: (json['teamAName'] as String?) ?? 'Đội A',
        teamBName: (json['teamBName'] as String?) ?? 'Đội B',
        winner: json['winner'] as String?,
        durationInSeconds: json['durationInSeconds'] as int,
        playedAt: DateTime.parse(json['playedAt'] as String),
      );

  /// Serialize list thành JSON string
  static String encodeList(List<MatchHistory> matches) =>
      jsonEncode(matches.map((m) => m.toJson()).toList());

  /// Deserialize list từ JSON string
  static List<MatchHistory> decodeList(String jsonStr) {
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((item) => MatchHistory.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
