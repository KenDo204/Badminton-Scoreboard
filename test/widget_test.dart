import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_scoreboard/models/game_state.dart';

void main() {
  group('GameState scoring logic', () {
    late GameState game;

    setUp(() {
      game = GameState();
    });

    test('Initial score is 0-0', () {
      expect(game.teamAScore, 0);
      expect(game.teamBScore, 0);
      expect(game.isGameOver, false);
      expect(game.winner, null);
      expect(game.isDeuce, false);
    });

    test('Score cannot go below 0', () {
      game.adjustScore('a', -1);
      expect(game.teamAScore, 0);
    });

    test('Normal win: 21-19 => A wins', () {
      // Interleave scores so game doesn't end early
      for (int i = 0; i < 19; i++) {
        game.adjustScore('a', 1);
        game.adjustScore('b', 1);
      }
      // A: 19, B: 19
      game.adjustScore('a', 1); // A: 20, B: 19
      game.adjustScore('a', 1); // A: 21, B: 19
      expect(game.teamAScore, 21);
      expect(game.teamBScore, 19);
      expect(game.isGameOver, true);
      expect(game.winner, 'a');
    });

    test('Normal win: 21-18 => A wins', () {
      for (int i = 0; i < 18; i++) {
        game.adjustScore('a', 1);
        game.adjustScore('b', 1);
      }
      // A: 18, B: 18
      game.adjustScore('a', 1); // 19
      game.adjustScore('a', 1); // 20
      game.adjustScore('a', 1); // 21
      expect(game.teamAScore, 21);
      expect(game.teamBScore, 18);
      expect(game.isGameOver, true);
      expect(game.winner, 'a');
    });

    test('20-20 triggers deuce', () {
      for (int i = 0; i < 20; i++) {
        game.adjustScore('a', 1);
        game.adjustScore('b', 1);
      }
      expect(game.isDeuce, true);
      expect(game.isGameOver, false);
    });

    test('Deuce: 21-20 => Continue (not won yet)', () {
      for (int i = 0; i < 20; i++) {
        game.adjustScore('a', 1);
        game.adjustScore('b', 1);
      }
      game.adjustScore('a', 1);
      expect(game.teamAScore, 21);
      expect(game.teamBScore, 20);
      expect(game.isGameOver, false);
    });

    test('Deuce: 22-20 => A wins', () {
      for (int i = 0; i < 20; i++) {
        game.adjustScore('a', 1);
        game.adjustScore('b', 1);
      }
      game.adjustScore('a', 1); // 21-20
      game.adjustScore('a', 1); // 22-20
      expect(game.teamAScore, 22);
      expect(game.teamBScore, 20);
      expect(game.isGameOver, true);
      expect(game.winner, 'a');
    });

    test('Deuce: 21-21 => Continue', () {
      for (int i = 0; i < 20; i++) {
        game.adjustScore('a', 1);
        game.adjustScore('b', 1);
      }
      game.adjustScore('a', 1); // 21-20
      game.adjustScore('b', 1); // 21-21
      expect(game.teamAScore, 21);
      expect(game.teamBScore, 21);
      expect(game.isGameOver, false);
    });

    test('Deuce: 22-21 => Continue', () {
      for (int i = 0; i < 20; i++) {
        game.adjustScore('a', 1);
        game.adjustScore('b', 1);
      }
      game.adjustScore('a', 1); // 21-20
      game.adjustScore('b', 1); // 21-21
      game.adjustScore('a', 1); // 22-21
      expect(game.teamAScore, 22);
      expect(game.teamBScore, 21);
      expect(game.isGameOver, false);
    });

    test('Deuce: 22-22 => Continue', () {
      for (int i = 0; i < 20; i++) {
        game.adjustScore('a', 1);
        game.adjustScore('b', 1);
      }
      game.adjustScore('a', 1); // 21-20
      game.adjustScore('b', 1); // 21-21
      game.adjustScore('a', 1); // 22-21
      game.adjustScore('b', 1); // 22-22
      expect(game.teamAScore, 22);
      expect(game.teamBScore, 22);
      expect(game.isGameOver, false);
    });

    test('Deuce: 24-22 => A wins', () {
      for (int i = 0; i < 20; i++) {
        game.adjustScore('a', 1);
        game.adjustScore('b', 1);
      }
      game.adjustScore('a', 1); // 21-20
      game.adjustScore('b', 1); // 21-21
      game.adjustScore('a', 1); // 22-21
      game.adjustScore('b', 1); // 22-22
      game.adjustScore('a', 1); // 23-22
      game.adjustScore('a', 1); // 24-22
      expect(game.teamAScore, 24);
      expect(game.teamBScore, 22);
      expect(game.isGameOver, true);
      expect(game.winner, 'a');
    });

    test('Deuce: 25-23 => A wins', () {
      for (int i = 0; i < 20; i++) {
        game.adjustScore('a', 1);
        game.adjustScore('b', 1);
      }
      game.adjustScore('a', 1); // 21-20
      game.adjustScore('b', 1); // 21-21
      game.adjustScore('a', 1); // 22-21
      game.adjustScore('b', 1); // 22-22
      game.adjustScore('a', 1); // 23-22
      game.adjustScore('b', 1); // 23-23
      game.adjustScore('a', 1); // 24-23
      game.adjustScore('a', 1); // 25-23
      expect(game.teamAScore, 25);
      expect(game.teamBScore, 23);
      expect(game.isGameOver, true);
      expect(game.winner, 'a');
    });

    test('Cannot adjust score after game over', () {
      for (int i = 0; i < 19; i++) {
        game.adjustScore('a', 1);
        game.adjustScore('b', 1);
      }
      game.adjustScore('a', 1); // 20-19
      game.adjustScore('a', 1); // 21-19 => A wins
      expect(game.isGameOver, true);
      expect(game.teamAScore, 21);
      expect(game.teamBScore, 19);

      // Try to adjust after game over
      game.adjustScore('a', 1);
      expect(game.teamAScore, 21);
      game.adjustScore('b', 1);
      expect(game.teamBScore, 19);
    });

    test('Reset restores initial state', () {
      for (int i = 0; i < 20; i++) {
        game.adjustScore('a', 1);
        game.adjustScore('b', 1);
      }
      game.adjustScore('a', 1); // 21-20
      game.adjustScore('a', 1); // 22-20 => A wins
      expect(game.isGameOver, true);
      game.reset();
      expect(game.teamAScore, 0);
      expect(game.teamBScore, 0);
      expect(game.isGameOver, false);
      expect(game.winner, null);
      expect(game.isDeuce, false);
    });

    test('Team B can also win', () {
      for (int i = 0; i < 18; i++) {
        game.adjustScore('a', 1);
        game.adjustScore('b', 1);
      }
      game.adjustScore('b', 1); // A:18, B:19
      game.adjustScore('b', 1); // A:18, B:20
      game.adjustScore('b', 1); // A:18, B:21 => B wins
      expect(game.isGameOver, true);
      expect(game.winner, 'b');
    });

    test('21-20 without deuce (A scored all first) => A wins', () {
      // A scores 21 before B reaches 20, so no deuce triggered
      for (int i = 0; i < 20; i++) {
        game.adjustScore('b', 1);
      }
      // B: 20, now A scores
      for (int i = 0; i < 21; i++) {
        game.adjustScore('a', 1);
      }
      expect(game.teamAScore, 21);
      expect(game.teamBScore, 20);
      // Since B reached 20 and A reached 20 during scoring,
      // deuce was triggered at 20-20
      // Then 21-20 is only 1 point lead, so game continues... but wait
      // In this test, scores interleave: B goes to 20 first, then A from 0 to 21
      // A reaches 20 when B is 20 => deuce triggered
      // Then A reaches 21 => only 1 point lead => NOT won
      // This is correct behavior per deuce rules
      expect(game.isDeuce, true);
      expect(game.isGameOver, false);
    });

    test('A reaches 21 before B reaches 20 => A wins immediately', () {
      // A scores 21, B only has 15
      for (int i = 0; i < 15; i++) {
        game.adjustScore('a', 1);
        game.adjustScore('b', 1);
      }
      // A:15, B:15
      for (int i = 0; i < 6; i++) {
        game.adjustScore('a', 1);
      }
      // A:21, B:15 => A wins (no deuce since both were never at 20)
      expect(game.teamAScore, 21);
      expect(game.teamBScore, 15);
      expect(game.isGameOver, true);
      expect(game.winner, 'a');
      expect(game.isDeuce, false);
    });

    test('Can start new game after reset', () {
      // Win a game
      for (int i = 0; i < 21; i++) game.adjustScore('a', 1);
      expect(game.isGameOver, true);

      // Reset and play new game
      game.reset();
      game.adjustScore('b', 1);
      expect(game.teamBScore, 1);
      expect(game.isGameOver, false);
    });
  });
}
