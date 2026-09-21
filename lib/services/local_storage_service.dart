import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_history.dart';

/// Service quản lý lưu trữ local cho lịch sử trận đấu
class LocalStorageService {
  static const String _historyKey = 'match_history';
  static const int _maxMatches = 3;

  /// Lưu một trận đấu mới vào history
  /// Chỉ giữ tối đa 3 trận gần nhất
  Future<void> saveMatch(MatchHistory match) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getMatchHistory();

    // Thêm trận mới vào đầu danh sách
    history.insert(0, match);

    // Giới hạn 3 trận
    while (history.length > _maxMatches) {
      history.removeLast();
    }

    // Lưu vào shared_preferences
    await prefs.setString(_historyKey, MatchHistory.encodeList(history));
  }

  /// Lấy danh sách lịch sử trận đấu (mới nhất đầu tiên)
  Future<List<MatchHistory>> getMatchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_historyKey);

    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }

    try {
      return MatchHistory.decodeList(jsonStr);
    } catch (_) {
      return [];
    }
  }

  /// Xóa toàn bộ lịch sử
  Future<void> clearMatchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
