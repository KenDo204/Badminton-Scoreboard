# Badminton Score App – Flutter Implementation

## 1. Mục tiêu

Tôi đang muốn xây dựng một app Flutter đơn giản dùng để **tính điểm thi đấu cầu lông cho 2 bên/2 đội**.

Tôi đã cung cấp **hình ảnh giao diện mẫu**. Hãy sử dụng hình ảnh đó làm **nguồn tham khảo chính cho UI/UX** và triển khai giao diện Flutter bám sát thiết kế hiện tại.

> **Quan trọng:** Không tự ý thêm các màn hình hoặc chức năng không cần thiết. Đây chỉ là một app tính điểm cầu lông đơn giản.

---

## 2. Công nghệ

Sử dụng:

* **Flutter**
* **Dart**
* Không cần backend
* Không cần database
* Không cần đăng nhập
* Không cần API
* Không cần lưu lịch sử trận đấu

Toàn bộ điểm số chỉ cần được quản lý trong state của ứng dụng.

---

## 3. Giao diện

Tôi đã cung cấp hình ảnh giao diện mẫu.

Hãy:

1. Phân tích hình ảnh giao diện.
2. Xác định:
   * Layout
   * Khoảng cách
   * Font chữ
   * Kích thước các thành phần
   * Button
   * Màu sắc
   * Border radius
   * Icon
   * Alignment
3. Implement lại bằng Flutter.
4. Ưu tiên giao diện giống hình ảnh mẫu nhất có thể.
5. Đảm bảo responsive để giao diện không bị vỡ trên các kích thước màn hình khác nhau.

### Bố cục chính

Ứng dụng có 2 bên:

```text
┌──────────────────────────────────────────┐
│              BADMINTON SCORE             │
│                                          │
│       TEAM A            TEAM B            │
│                                          │
│        0                   0              │
│                                          │
│      [-] [+]            [-] [+]          │
│                                          │
│                 RESET                    │
└──────────────────────────────────────────┘
```

Tên đội/người chơi và các thành phần cụ thể cần **bám theo hình ảnh giao diện đã cung cấp**.

---

# 4. Chức năng tính điểm

## 4.1. Điểm ban đầu

Khi app được mở:

```text
Team A = 0
Team B = 0
```

---

## 4.2. Button `+`

Mỗi bên có một button `+`.

Khi nhấn:

```text
Team A +
```

thì:

```text
Team A = Team A + 1
```

Tương tự với Team B.

Ví dụ:

```text
Team A: 10
Team B: 8

Nhấn + của Team A

=> Team A: 11
=> Team B: 8
```

---

## 4.3. Button `-`

Mỗi bên có một button `-`.

Khi nhấn:

```text
Team A -
```

thì:

```text
Team A = Team A - 1
```

Tuy nhiên:

> Điểm không được phép nhỏ hơn 0.

Ví dụ:

```text
Team A = 0

Nhấn -

=> Team A vẫn = 0
```

---

# 5. Luật xác định người thắng

Đây là phần logic quan trọng nhất của app.

## 5.1. Trường hợp bình thường

Nếu một bên đạt **21 điểm** trước và hai bên chưa bước vào trạng thái deuce, bên đó thắng.

Ví dụ:

```text
Team A = 21
Team B = 18

=> Team A WIN
```

Hoặc:

```text
Team A = 17
Team B = 21

=> Team B WIN
```

Khi xác định được người thắng:

* Hiển thị thông báo đội/người chơi thắng.
* Hiển thị biểu tượng chúc mừng.
* Khóa hoặc vô hiệu hóa các button `+` / `-` để không thể tiếp tục thay đổi điểm.
* Hiển thị button `RESET`.

---

# 6. Trường hợp hai bên hòa 20 - 20

Đây là logic đặc biệt cần xử lý chính xác.

**Chỉ kích hoạt luật deuce khi cả hai bên cùng đạt 20 điểm.**

Ví dụ:

```text
Team A = 20
Team B = 20
```

Lúc này:

```text
Không ai thắng ngay.
```

Hai bên phải tiếp tục thi đấu cho đến khi một bên **hơn bên còn lại 2 điểm**.

---

# 7. Logic deuce

Khi:

```text
Team A = 20
Team B = 20
```

thì trận đấu chuyển sang trạng thái deuce.

Từ thời điểm này:

> Một bên phải dẫn trước bên kia ít nhất **2 điểm** mới được xác định là thắng.

### Ví dụ 1

```text
20 - 20

21 - 20
```

Chưa thắng vì chỉ dẫn 1 điểm.

Tiếp tục:

```text
22 - 20
```

=> Team A thắng.

---

### Ví dụ 2

```text
20 - 20

21 - 21
```

Tiếp tục:

```text
22 - 21
```

Chưa thắng.

Tiếp tục:

```text
22 - 22
```

Vẫn chưa thắng.

Tiếp tục:

```text
23 - 22
```

Vẫn chưa thắng.

Tiếp tục:

```text
24 - 22
```

=> Team A thắng.

---

### Ví dụ 3

```text
20 - 20
21 - 21
22 - 22
23 - 23
24 - 23
25 - 23
```

=> Team A thắng.

---

# 8. Công thức xác định người thắng

Sau khi hai bên đạt `20 - 20`, có thể sử dụng logic:

```text
Nếu:
abs(teamA - teamB) >= 2

=> Bên có điểm cao hơn thắng.
```

Ví dụ:

```text
22 - 20
=> Team A thắng

25 - 23
=> Team A thắng

30 - 28
=> Team A thắng
```

Nhưng:

```text
21 - 20
=> Chưa thắng

22 - 21
=> Chưa thắng

23 - 22
=> Chưa thắng
```

---

# 9. Lưu ý quan trọng về điều kiện deuce

**Không được áp dụng luật "dẫn 2 điểm" ngay từ đầu trận.**

Ví dụ:

```text
21 - 19
```

=> Team A **thắng ngay**.

Không yêu cầu Team A phải đạt 23.

---

Tương tự:

```text
21 - 18
```

=> Team A thắng.

---

Luật deuce chỉ được kích hoạt khi:

```text
Team A == 20 && Team B == 20
```

Sau khi đã đạt trạng thái này, trận đấu tiếp tục theo luật cách biệt 2 điểm.

---

# 10. Trạng thái trận đấu

Nên quản lý app bằng các state cơ bản:

```dart
int teamAScore = 0;
int teamBScore = 0;

bool isGameOver = false;
String? winner;
```

Có thể bổ sung:

```dart
bool isDeuce = false;
```

nếu cần thiết cho UI.

---

# 11. Logic kiểm tra chiến thắng

Có thể triển khai theo logic tương tự:

```text
IF game đã kết thúc
    Không cho thay đổi điểm

ELSE IF Team A == 20 AND Team B == 20
    Chuyển sang trạng thái deuce

ELSE IF Team A >= 21 AND Team A > Team B
    Team A thắng

ELSE IF Team B >= 21 AND Team B > Team A
    Team B thắng

Khi đang ở deuce:
    IF Team A - Team B >= 2
        Team A thắng

    ELSE IF Team B - Team A >= 2
        Team B thắng

    ELSE
        Tiếp tục trận đấu
```

Tuy nhiên hãy đảm bảo logic thực tế không có bug khi điểm tiếp tục tăng sau:

```text
20 - 20
```

---

# 12. Hiển thị người thắng

Khi có người thắng, giao diện cần hiển thị rõ ràng.

Ví dụ:

```text
🎉 TEAM A WINS! 🎉
```

Có thể sử dụng:

* Icon celebration
* Trophy icon
* Confetti
* Dialog
* Banner

Tùy theo hình ảnh UI mẫu đã cung cấp.

Ưu tiên giữ phong cách **đơn giản, hiện đại và phù hợp với giao diện hiện tại**.

Không cần tạo animation quá phức tạp nếu hình ảnh thiết kế không có.

---

# 13. Button RESET

Khi trận đấu kết thúc, hiển thị button:

```text
RESET
```

Khi nhấn:

```text
Team A = 0
Team B = 0

isGameOver = false

winner = null

isDeuce = false
```

Sau đó app quay lại trạng thái ban đầu.

Ví dụ:

```text
TEAM A          TEAM B

   0                0

  [-] [+]        [-] [+]

             RESET
```

---

# 14. UX khi trận đấu kết thúc

Khi có người thắng:

```text
Team A = 22
Team B = 20

=> TEAM A WINS
```

Sau đó:

* Không cho phép tăng điểm.
* Không cho phép giảm điểm.
* Không cho phép thay đổi trạng thái trận đấu.
* Chỉ cho phép nhấn `RESET`.

Mục đích là tránh trường hợp người dùng tiếp tục bấm `+` và làm thay đổi kết quả trận đấu đã kết thúc.

---

# 15. Kiến trúc code

Hãy giữ project đơn giản, không over-engineering.

Có thể tổ chức:

```text
lib/
├── main.dart
├── screens/
│   └── scoreboard_screen.dart
├── widgets/
│   ├── score_card.dart
│   ├── score_button.dart
│   └── winner_banner.dart
└── models/
    └── game_state.dart
```

Nếu project quá nhỏ, có thể sử dụng ít file hơn.

Không cần sử dụng:

* BLoC
* Riverpod
* Redux
* Provider

trừ khi project hiện tại đã sử dụng sẵn.

Với app đơn giản này, `StatefulWidget` hoặc state management đơn giản là đủ.

---

# 16. Yêu cầu về code

Code cần:

* Clean
* Dễ đọc
* Dễ bảo trì
* Không duplicate logic không cần thiết
* Tách UI và logic hợp lý
* Sử dụng null-safety của Dart
* Không hard-code logic chiến thắng rải rác ở nhiều widget.

Nên tạo một function riêng để kiểm tra người thắng, ví dụ:

```dart
void checkWinner()
```

hoặc tốt hơn là một hàm có trách nhiệm rõ ràng:

```dart
String? getWinner()
```

---

# 17. Quy trình thực hiện

Trước khi code:

### Step 1 – Phân tích UI

Đọc hình ảnh giao diện tôi cung cấp và phân tích:

* Layout
* Component
* Spacing
* Typography
* Color
* Button
* Icon
* Responsive behavior

### Step 2 – Kiểm tra Flutter project

Kiểm tra:

* Flutter version
* Dart version
* Existing project structure
* Existing dependencies

Không tự ý thay đổi dependency nếu không cần thiết.

### Step 3 – Implement UI

Xây dựng giao diện bám sát hình ảnh mẫu.

### Step 4 – Implement score logic

Implement:

* Increase score
* Decrease score
* Score >= 21
* Deuce 20 - 20
* Win by 2 points
* Winner state
* Reset

### Step 5 – Test logic

Đặc biệt phải test các trường hợp:

```text
0 - 0
1 - 0
10 - 10
20 - 19
21 - 19      => A wins
21 - 20      => A wins
20 - 20      => Deuce
21 - 20      => Continue
22 - 20      => A wins
21 - 21      => Continue
22 - 21      => Continue
22 - 22      => Continue
23 - 22      => Continue
24 - 22      => A wins
23 - 23      => Continue
25 - 23      => A wins
```

### Step 6 – Kiểm tra RESET

Test:

```text
22 - 20
=> Team A wins

RESET

=> 0 - 0
=> Không còn trạng thái winner
=> Có thể bắt đầu trận mới
```

---

# 18. Điều không được làm

Không thêm nếu tôi không yêu cầu:

* Login
* Register
* Database
* Backend
* API
* Firebase
* Internet
* User account
* Match history
* Statistics
* Leaderboard
* Multiplayer online
* Ads
* Payment
* Notification

Đây chỉ là một **local badminton scoreboard app**.

---

# 19. Expected Result

Sau khi hoàn thành, app phải cho phép người dùng:

1. Mở app.
2. Nhìn thấy bảng điểm của 2 bên.
3. Nhấn `+` để cộng điểm.
4. Nhấn `-` để trừ điểm.
5. Điểm không được nhỏ hơn `0`.
6. Nếu một bên đạt `21` trước và không ở trạng thái deuce → thắng.
7. Nếu đạt `20 - 20` → kích hoạt luật deuce.
8. Trong deuce, phải hơn đối thủ **2 điểm** mới thắng.
9. Khi thắng → hiển thị thông báo + biểu tượng chúc mừng.
10. Khóa việc thay đổi điểm.
11. Nhấn `RESET` → toàn bộ điểm và trạng thái trận đấu trở về ban đầu.

## Quan trọng nhất

**Hãy ưu tiên 2 thứ:**

1. UI phải bám sát hình ảnh giao diện tôi đã cung cấp.
2. Logic tính điểm phải chính xác, đặc biệt là trường hợp `20 - 20` và luật thắng cách biệt 2 điểm.

Sau khi hoàn thành, hãy kiểm tra lại toàn bộ code và chạy/test app để đảm bảo không có lỗi Flutter/Dart và không có lỗi logic tính điểm.

# 20. Bổ sung bộ đếm thời gian

Hãy bổ sung thêm **bộ đếm thời gian (Timer/Stopwatch)** cho trận đấu.

## Yêu cầu

* Hiển thị thời gian trận đấu trên giao diện, phù hợp với layout hiện tại trong hình ảnh mẫu.
* Thời gian ban đầu là:

```text
00:00
```

* Khi người dùng nhấn button **"BẮT ĐẦU" / "START"**, bộ đếm thời gian mới bắt đầu chạy.
* Trước khi nhấn **START**, thời gian phải đứng yên ở `00:00`.
* Timer tăng theo thời gian thực, mỗi 1 giây tăng thêm 1 giây.

Ví dụ:

```text
00:00
↓ START
00:01
00:02
00:03
...
```

## Trạng thái Timer

Quản lý tối thiểu các trạng thái:

```dart
Duration elapsedTime = Duration.zero;
bool isTimerRunning = false;
Timer? timer;
```

Có thể sử dụng `Timer.periodic()` của Dart để thực hiện bộ đếm.

---

## Khi trận đấu kết thúc

Khi một bên thắng:

* Dừng Timer ngay lập tức.
* Giữ nguyên thời gian cuối cùng.
* Không cho Timer tiếp tục chạy.
* Hiển thị thời gian trận đấu đã diễn ra cùng với kết quả thắng.

Ví dụ:

```text
TEAM A WINS!

22 - 20

TIME
05:32
```

---

## Khi nhấn RESET

Khi người dùng nhấn **RESET**:

### Điểm số:

```text
Team A = 0
Team B = 0
```

### Trạng thái trận đấu:

```text
isGameOver = false
winner = null
isDeuce = false
```

### Timer:

```text
elapsedTime = Duration.zero
isTimerRunning = false
```

Hiển thị lại:

```text
00:00
```

Timer phải được **reset hoàn toàn** và không tự động chạy lại.

Người dùng phải nhấn **START** một lần nữa để bắt đầu trận đấu mới.

---

## Quy tắc quan trọng

### 1. Chưa nhấn START

```text
Score: 0 - 0
Timer: 00:00
```

Timer không chạy.

### 2. Nhấn START

```text
Timer bắt đầu:
00:01
00:02
00:03
...
```

### 3. Đang thi đấu

Timer tiếp tục chạy trong khi người dùng cộng/trừ điểm.

### 4. Có người thắng

Timer dừng lại.

### 5. Nhấn RESET

```text
Score: 0 - 0
Timer: 00:00
```

Timer dừng và chờ người dùng nhấn START.

---

## Button START

Thêm button **START** vào giao diện theo đúng phong cách của UI mẫu.

Button có thể có 3 trạng thái:

### Trạng thái chưa bắt đầu

```text
START
```

Cho phép người dùng bắt đầu trận đấu.

### Trạng thái đang chạy

Có thể hiển thị:

```text
RUNNING
```

hoặc disable button START để tránh việc tạo nhiều `Timer.periodic()` cùng lúc.

### Trạng thái trận đấu kết thúc

START phải được disable vì trận đấu đã kết thúc.

Người dùng cần nhấn **RESET** để bắt đầu trận mới.

---

## Format thời gian

Hiển thị theo format:

```text
MM:SS
```

Ví dụ:

```text
00:00
00:05
01:23
05:42
12:08
```

Nếu trận đấu kéo dài hơn 59 phút, có thể tiếp tục tăng số phút:

```text
60:00
61:25
```

Không cần chuyển sang format giờ.

---

## Cleanup Timer

Đặc biệt chú ý tránh memory leak.

Khi Widget bị dispose, phải cancel Timer:

```dart
@override
void dispose() {
  timer?.cancel();
  super.dispose();
}
```

Không được tạo nhiều `Timer.periodic()` cùng lúc khi người dùng nhấn START nhiều lần.

---

## Kết hợp với logic tính điểm hiện tại

Timer phải hoạt động độc lập nhưng đồng bộ với trạng thái trận đấu:

```text
START
   ↓
Timer chạy
   ↓
Người chơi tính điểm
   ↓
20 - 20
   ↓
Deuce
   ↓
Một bên thắng
   ↓
Timer dừng
   ↓
Hiển thị Winner + thời gian
   ↓
RESET
   ↓
Score = 0 - 0
Timer = 00:00
   ↓
START để bắt đầu trận mới
```

### Quan trọng

Không thay đổi logic tính điểm cầu lông đã triển khai trước đó.

Chỉ bổ sung thêm Timer và đảm bảo:

**START → Timer chạy → Winner → Timer dừng → RESET → Timer về 00:00.

**

# 21. Bổ sung chức năng PAUSE / RESUME

Hãy bổ sung thêm chức năng **PAUSE** cho bộ đếm thời gian.

## 21.1. Mục đích

Trong lúc trận đấu đang diễn ra, người dùng có thể nhấn **PAUSE** để tạm dừng thời gian.

Khi PAUSE:

* Timer dừng đếm.
* Điểm số hiện tại được giữ nguyên.
* Trạng thái trận đấu được giữ nguyên.
* Không reset điểm.
* Không reset thời gian.
* Người dùng có thể nhấn **RESUME** để tiếp tục trận đấu từ đúng thời gian đã dừng.

---

## 21.2. Trạng thái Timer

Có 3 trạng thái chính:

```text
NOT_STARTED
RUNNING
PAUSED
```

Ngoài ra có trạng thái:

```text
GAME_OVER
```

Ví dụ:

```text
NOT_STARTED
    ↓ START
RUNNING
    ↓ PAUSE
PAUSED
    ↓ RESUME
RUNNING
    ↓ WINNER
GAME_OVER
```

---

## 21.3. Khi chưa bắt đầu

Ban đầu:

```text
Score
0 - 0

Timer
00:00

Button
START
```

Timer không chạy.

---

## 21.4. Khi nhấn START

Khi người dùng nhấn:

```text
START
```

thì:

```text
isTimerRunning = true
```

Timer bắt đầu chạy:

```text
00:01
00:02
00:03
00:04
...
```

Button START có thể chuyển thành:

```text
PAUSE
```

---

## 21.5. Khi nhấn PAUSE

Ví dụ:

```text
Score: 15 - 13
Timer: 03:25
```

Người dùng nhấn:

```text
PAUSE
```

Kết quả:

```text
Score: 15 - 13
Timer: 03:25
```

Timer phải **dừng hoàn toàn** tại `03:25`.

Không được reset về `00:00`.

Button chuyển thành:

```text
RESUME
```

---

## 21.6. Khi nhấn RESUME

Nếu đang ở trạng thái:

```text
PAUSED
```

người dùng nhấn:

```text
RESUME
```

Timer tiếp tục từ thời điểm đã dừng.

Ví dụ:

```text
PAUSE

03:25
```

Sau đó:

```text
RESUME

03:26
03:27
03:28
...
```

Không được bắt đầu lại từ `00:00`.

---

# 22. Điểm số khi PAUSE

Khi trận đấu đang PAUSE:

* Vẫn giữ nguyên điểm số.
* Không reset điểm.
* Không tự động thay đổi điểm.
* Không thay đổi trạng thái deuce.
* Không thay đổi winner.

Ví dụ:

```text
Team A = 20
Team B = 20

Timer = 08:42

PAUSE
```

Sau khi PAUSE:

```text
Team A = 20
Team B = 20
Timer = 08:42
```

Sau đó RESUME:

```text
Team A = 20
Team B = 20
Timer tiếp tục từ 08:42
```

---

# 23. PAUSE không được làm thay đổi luật tính điểm

Logic tính điểm cầu lông hiện tại vẫn giữ nguyên.

Ví dụ:

```text
20 - 20
```

đang ở deuce.

Nếu PAUSE:

```text
20 - 20
PAUSED
```

Sau RESUME:

```text
20 - 20
RUNNING
```

Vẫn tiếp tục áp dụng luật deuce.

---

# 24. Khi trận đấu kết thúc

Nếu một bên thắng:

```text
Team A = 22
Team B = 20
```

thì:

```text
GAME_OVER
```

Timer phải:

* Dừng lại.
* Giữ nguyên thời gian cuối cùng.
* Không cho PAUSE/RESUME nữa.
* Không cho cộng/trừ điểm nữa.

Ví dụ:

```text
🎉 TEAM A WINS!

22 - 20

TIME
08:35
```

Chỉ còn:

```text
RESET
```

---

# 25. RESET

Khi nhấn RESET, phải reset toàn bộ:

```text
Team A = 0
Team B = 0

Timer = 00:00

Game State = NOT_STARTED
```

Sau RESET:

```text
START
```

được hiển thị lại.

Người dùng phải nhấn START để bắt đầu trận đấu mới.

---

# 26. UI Button

Tùy theo trạng thái:

### Chưa bắt đầu

```text
┌───────────┐
│   START   │
└───────────┘
```

### Đang chạy

```text
┌───────────┐
│   PAUSE   │
└───────────┘
```

### Đang pause

```text
┌───────────┐
│  RESUME   │
└───────────┘
```

### Trận đấu kết thúc

Ẩn hoặc disable PAUSE/RESUME và chỉ hiển thị:

```text
┌───────────┐
│   RESET   │
└───────────┘
```

Hãy thiết kế button theo đúng style của hình ảnh giao diện tôi đã cung cấp.

---

# 27. State đề xuất

Có thể sử dụng enum để quản lý trạng thái rõ ràng:

```dart
enum GameStatus {
  notStarted,
  running,
  paused,
  gameOver,
}
```

Các state chính:

```dart
int teamAScore = 0;
int teamBScore = 0;

Duration elapsedTime = Duration.zero;

GameStatus gameStatus = GameStatus.notStarted;

Timer? timer;

String? winner;
```

---

# 28. Quy tắc quan trọng

### START

```text
notStarted → running
```

Bắt đầu Timer.

### PAUSE

```text
running → paused
```

Dừng Timer nhưng giữ nguyên `elapsedTime`.

### RESUME

```text
paused → running
```

Tiếp tục Timer từ `elapsedTime` hiện tại.

### WINNER

```text
running → gameOver
```

Dừng Timer.

### RESET

```text
gameOver / paused / running / notStarted
        ↓
    notStarted
```

Reset:

```text
Score = 0 - 0
Timer = 00:00
Winner = null
```

---

# 29. Không được tạo nhiều Timer

Đặc biệt chú ý trường hợp người dùng:

```text
START
PAUSE
RESUME
PAUSE
RESUME
...
```

Không được tạo thêm nhiều `Timer.periodic()` chồng lên nhau.

Mỗi thời điểm chỉ được có **một Timer đang chạy**.

Khi PAUSE phải cancel Timer hiện tại.

Khi RESUME phải tạo lại Timer từ `elapsedTime` hiện tại.

Khi RESET hoặc GAME\_OVER phải cancel Timer.

Khi Widget dispose phải cancel Timer:

```dart
@override
void dispose() {
  timer?.cancel();
  super.dispose();
}
```

---

# 30. Luồng hoạt động hoàn chỉnh

```text
                APP OPEN
                   │
                   ▼
             0 - 0 / 00:00
                   │
                   ▼
                START
                   │
                   ▼
                RUNNING
             Timer đang chạy
                   │
            ┌──────┴──────┐
            │             │
          PAUSE          WIN
            │             │
            ▼             ▼
         PAUSED       GAME_OVER
            │             │
         RESUME          RESET
            │             │
            ▼             │
         RUNNING          │
            │             │
            └──────┬──────┘
                   │
                 RESET
                   │
                   ▼
             0 - 0 / 00:00
                   │
                   ▼
                 START
```

**Mục tiêu cuối cùng:** App phải có đầy đủ **Score + START + PAUSE + RESUME + RESET + Timer + Winner**, nhưng vẫn giữ giao diện đơn giản và bám sát hình ảnh thiết kế ban đầu.

# 31. Bổ sung chức năng lưu lịch sử trận đấu Local

Hãy bổ sung thêm chức năng **lưu lịch sử 3 ván đấu gần nhất** bằng local storage trên thiết bị.

## 31.1. Mục tiêu

Ứng dụng cần lưu lại thông tin của tối đa **3 ván đấu đã hoàn thành gần nhất**.

Không cần:

* Backend
* Database server
* API
* Firebase
* Tài khoản người dùng
* Đồng bộ cloud

Dữ liệu chỉ cần lưu **local trên thiết bị**.

---

# 32. Công nghệ lưu local

Có thể sử dụng một package Flutter phù hợp, ưu tiên:

```text
shared_preferences
```

Nếu cần lưu object/list phức tạp hơn, có thể serialize dữ liệu thành JSON trước khi lưu.

Không cần sử dụng SQLite/Drift/Hive nếu `shared_preferences` đã đáp ứng đủ nhu cầu.

---

# 33. Thông tin cần lưu của mỗi ván

Mỗi trận đấu nên lưu tối thiểu:

```dart
class MatchHistory {
  int teamAScore;
  int teamBScore;
  String? winner;
  int durationInSeconds;
  DateTime playedAt;
}
```

Trong đó:

* `teamAScore`: điểm cuối cùng của Team A.
* `teamBScore`: điểm cuối cùng của Team B.
* `winner`: đội thắng.
* `durationInSeconds`: thời gian thi đấu cuối cùng.
* `playedAt`: thời điểm trận đấu kết thúc.

Ví dụ:

```json
{
  "teamAScore": 22,
  "teamBScore": 20,
  "winner": "Team A",
  "durationInSeconds": 512,
  "playedAt": "2026-09-22T21:30:00"
}
```

---

# 34. Khi nào lưu lịch sử?

Chỉ lưu trận đấu khi trận đấu **thực sự kết thúc**.

Ví dụ:

```text
Team A = 22
Team B = 20
```

→ Team A thắng.

Lúc này mới tạo một `MatchHistory` và lưu local.

---

# 35. Không lưu khi PAUSE

Nếu người dùng:

```text
START
↓
PAUSE
```

thì **không lưu lịch sử**.

Ví dụ:

```text
15 - 12
TIME: 05:30
PAUSED
```

Không được tạo một history record.

---

# 36. Không lưu khi RESET giữa trận

Nếu người dùng đang đánh:

```text
17 - 15
TIME: 04:20
```

sau đó nhấn RESET:

```text
0 - 0
00:00
```

thì **không lưu trận đấu này vào lịch sử**, vì trận chưa kết thúc.

Chỉ lưu khi hệ thống đã xác định được winner.

---

# 37. Giới hạn 3 trận gần nhất

Chỉ giữ tối đa:

```text
3 trận
```

Ví dụ lịch sử hiện tại:

```text
Match 1
Match 2
Match 3
```

Khi có trận thứ 4:

```text
Match 1  ← Xóa
Match 2
Match 3
Match 4  ← Thêm mới
```

Kết quả cuối cùng:

```text
3 trận gần nhất
```

---

# 38. Thứ tự hiển thị

Lịch sử phải được sắp xếp theo thời gian:

```text
Mới nhất
   ↓
Trận gần nhất
   ↓
Trận trước đó
   ↓
Trận cũ nhất
```

Ví dụ:

```text
┌─────────────────────────────┐
│ Match History               │
├─────────────────────────────┤
│ 🏆 Team A    22 - 20 Team B │
│    08:32 • 22/09/2026       │
├─────────────────────────────┤
│ 🏆 Team B    21 - 18 Team A │
│    06:15 • 22/09/2026       │
├─────────────────────────────┤
│ 🏆 Team A    25 - 23 Team B │
│    10:42 • 21/09/2026       │
└─────────────────────────────┘
```

Hãy thiết kế phần History theo phong cách UI hiện tại và **không làm giao diện trở nên quá phức tạp**.

---

# 39. Hiển thị thời gian trận đấu

Chuyển:

```text
durationInSeconds
```

thành:

```text
MM:SS
```

Ví dụ:

```text
512 seconds
```

hiển thị:

```text
08:32
```

---

# 40. Hiển thị ngày giờ

Sử dụng `playedAt` để hiển thị thời điểm trận đấu.

Ví dụ:

```text
22/09/2026 • 21:30
```

Không cần hiển thị quá nhiều thông tin.

---

# 41. Khi mở lại app

Dữ liệu lịch sử phải vẫn còn.

Ví dụ:

```text
Đóng app
↓
Mở lại app
↓
History vẫn còn 3 trận gần nhất
```

Không được mất dữ liệu chỉ vì app bị đóng hoặc khởi động lại.

---

# 42. RESET không xóa History

Đây là điểm quan trọng.

Khi người dùng nhấn:

```text
RESET
```

chỉ reset **ván đấu hiện tại**:

```text
Score = 0 - 0
Timer = 00:00
GameStatus = notStarted
Winner = null
```

Không được xóa lịch sử 3 trận trước đó.

Ví dụ:

```text
History:

Team A 22 - 20 Team B
Team B 21 - 18 Team A
```

Sau khi RESET:

```text
Current Game:
0 - 0
00:00

History:
Team A 22 - 20 Team B
Team B 21 - 18 Team A
```

---

# 43. Chức năng xóa lịch sử

Không bắt buộc phải có chức năng xóa history.

Nếu UI cần đơn giản, chỉ cần hiển thị 3 trận gần nhất.

Nếu muốn thêm chức năng này, có thể thêm:

```text
Clear History
```

nhưng không cần thiết nếu chưa có trong thiết kế UI.

**Ưu tiên giữ UI đơn giản.**

---

# 44. Xử lý trường hợp chưa có lịch sử

Khi người dùng mới cài/mở app lần đầu:

```text
History
```

có thể hiển thị:

```text
No matches yet
```

hoặc:

```text
Chưa có trận đấu nào
```

Không hiển thị card trống.

---

# 45. Data flow

Luồng lưu history:

```text
START
   ↓
RUNNING
   ↓
PAUSE / RESUME
   ↓
Tính điểm
   ↓
Xác định WINNER
   ↓
GAME_OVER
   ↓
Tạo MatchHistory
   ↓
Save Local
   ↓
Hiển thị History
```

---

# 46. Khi có trận mới

Ví dụ:

```text
History hiện tại:

1. 22 - 20
2. 21 - 18
3. 25 - 23
```

Trận mới:

```text
21 - 15
```

Sau khi lưu:

```text
1. 21 - 15  ← mới nhất
2. 22 - 20
3. 21 - 18
```

Trận:

```text
25 - 23
```

bị loại khỏi danh sách vì chỉ giữ 3 trận gần nhất.

---

# 47. Không ảnh hưởng logic tính điểm

Chức năng History phải hoạt động độc lập với logic tính điểm.

Không được thay đổi các luật đã yêu cầu trước đó:

### Normal game

```text
21 - 19
→ Team A thắng
```

### Deuce

```text
20 - 20
21 - 20
→ Chưa thắng

22 - 20
→ Team A thắng
```

### Deuce tiếp tục

```text
23 - 23
24 - 23
→ Chưa thắng

25 - 23
→ Team A thắng
```

Khi xác định winner → lưu kết quả.

---

# 48. Không lưu duplicate

Mỗi trận chỉ được lưu **một lần**.

Không được xảy ra trường hợp:

```text
Team A thắng
↓
checkWinner()
↓
checkWinner()
↓
checkWinner()
```

và tạo ra nhiều history giống nhau.

Cần đảm bảo mỗi game chỉ tạo **một MatchHistory record**.

Có thể dùng:

```dart
bool isMatchSaved = false;
```

hoặc một cơ chế tương tự.

Khi game bắt đầu lại bằng RESET:

```dart
isMatchSaved = false;
```

---

# 49. Architecture đề xuất

Có thể tách phần local storage thành service riêng:

```text
lib/
├── main.dart
├── screens/
│   └── scoreboard_screen.dart
├── widgets/
│   ├── score_card.dart
│   ├── score_button.dart
│   ├── winner_banner.dart
│   └── match_history.dart
├── models/
│   ├── game_state.dart
│   └── match_history.dart
└── services/
    └── local_storage_service.dart
```

Ví dụ service:

```dart
class LocalStorageService {
  Future<void> saveMatch(MatchHistory match);

  Future<List<MatchHistory>> getMatchHistory();

  Future<void> clearMatchHistory();
}
```

Không cần over-engineering nếu project hiện tại quá nhỏ.

---

# 50. Kiểm thử bắt buộc

Sau khi implement, hãy test các trường hợp sau:

### Test 1 – Trận bình thường

```text
21 - 18
```

Expected:

```text
Team A wins
History +1
```

### Test 2 – Deuce

```text
20 - 20
21 - 20
22 - 20
```

Expected:

```text
Team A wins
History +1
```

### Test 3 – Deuce kéo dài

```text
20 - 20
21 - 21
22 - 22
23 - 23
24 - 23
25 - 23
```

Expected:

```text
Team A wins
History +1
```

### Test 4 – Pause

```text
Score = 15 - 12
Timer = 05:30
PAUSE
```

Expected:

```text
Score = 15 - 12
Timer = 05:30
History = unchanged
```

### Test 5 – Resume

```text
PAUSE
↓
RESUME
```

Expected:

```text
Timer tiếp tục từ 05:30
```

### Test 6 – Reset giữa trận

```text
15 - 12
↓
RESET
```

Expected:

```text
Score = 0 - 0
Timer = 00:00
History = unchanged
```

### Test 7 – Giới hạn 3 trận

Tạo 4 trận:

```text
Match 1
Match 2
Match 3
Match 4
```

Expected:

```text
History:

Match 4
Match 3
Match 2
```

Match 1 phải bị xóa khỏi local history.

### Test 8 – Đóng và mở lại app

Sau khi hoàn thành 3 trận:

```text
Close App
↓
Open App
```

Expected:

```text
3 trận gần nhất vẫn còn.
```

---

# 51. Kết quả cuối cùng

Sau khi hoàn thiện, app cần có đầy đủ:

```text
┌─────────────────────────────────┐
│        BADMINTON SCORE          │
│                                 │
│     TEAM A       TEAM B         │
│        0            0            │
│                                 │
│     [-] [+]     [-] [+]         │
│                                 │
│            00:00                │
│                                 │
│           START                 │
│                                 │
│        MATCH HISTORY            │
│                                 │
│   Team A  22 - 20  Team B      │
│   Team B  21 - 18  Team A      │
│   Team A  25 - 23  Team B      │
└─────────────────────────────────┘
```

Các chức năng cuối cùng cần có:

* ✅ Cộng điểm
* ✅ Trừ điểm
* ✅ Không cho điểm < 0
* ✅ Luật thắng 21 điểm
* ✅ Luật deuce 20 - 20
* ✅ Phải hơn 2 điểm khi deuce
* ✅ Winner state
* ✅ Celebration
* ✅ START
* ✅ PAUSE
* ✅ RESUME
* ✅ RESET
* ✅ Timer
* ✅ Lưu 3 trận gần nhất
* ✅ Lưu local trên thiết bị
* ✅ History không mất khi đóng/mở app
* ✅ RESET không xóa History
* ✅ Chỉ lưu trận đã kết thúc
* ✅ Không lưu duplicate
* ✅ Tự động loại trận cũ khi vượt quá 3 trận

Hãy implement chức năng này theo hướng **đơn giản, ổn định và dễ bảo trì**, đồng thời giữ nguyên UI/UX của hình ảnh thiết kế ban đầu.


# 52. Tách lịch sử trận đấu thành trang riêng

Hãy chỉnh sửa UI hiện tại theo yêu cầu sau:

## 52.1. Không hiển thị History trong màn hình tính điểm

**Không được hiển thị danh sách lịch sử trận đấu trực tiếp bên dưới khu vực tính điểm.**

Màn hình chính chỉ tập trung vào:

* Điểm Team 1
* Điểm Team 2
* `+`
* `-`
* Timer
* `START`
* `PAUSE`
* `RESUME`
* `RESET`
* Button `LỊCH SỬ`

Không đặt các card lịch sử trận đấu trên màn hình chính.

---

# 53. Button LỊCH SỬ

Thêm một button:

```text
LỊCH SỬ
```

hoặc:

```text
MATCH HISTORY
```

Tùy theo ngôn ngữ và style hiện tại của giao diện.

Button này phải được thiết kế đồng nhất với UI hiện tại.

Khi người dùng nhấn button:

```text
LỊCH SỬ
   ↓
History Screen
```

Ứng dụng chuyển sang **một màn hình/trang riêng** để hiển thị lịch sử các trận đấu.

Có thể sử dụng:

```dart
Navigator.push(...)
```

hoặc cách navigation phù hợp với architecture hiện tại.

---

# 54. Trang Match History

Tạo một màn hình riêng:

```text
MatchHistoryScreen
```

Trang này chỉ có nhiệm vụ hiển thị lịch sử các trận đấu đã lưu.

Bố cục đề xuất:

```text
┌────────────────────────────────────┐
│ ←       LỊCH SỬ TRẬN ĐẤU          │
├────────────────────────────────────┤
│                                    │
│            ĐỘI 1   ĐỘI 2           │
│                                    │
│  🏆   22       -       20          │
│                                    │
│       Đội 1 thắng                  │
│       08:32 • 22/09/2026           │
│                                    │
├────────────────────────────────────┤
│                                    │
│       ĐỘI 1   ĐỘI 2               │
│                                    │
│       18       -       21          │
│                                    │
│       Đội 2 thắng                  │
│       06:15 • 22/09/2026           │
│                                    │
└────────────────────────────────────┘
```

Hãy điều chỉnh bố cục thực tế để phù hợp với hình ảnh UI hiện tại.

---

# 55. Chia lịch sử theo Đội 1 và Đội 2

Mỗi trận đấu phải hiển thị rõ:

```text
ĐỘI 1        ĐỘI 2
 22     -      20
```

Trong đó:

* Điểm của Đội 1 nằm về phía Đội 1.
* Điểm của Đội 2 nằm về phía Đội 2.
* Đội thắng cần được highlight rõ ràng.
* Có thể sử dụng icon `🏆` hoặc icon trophy bên cạnh đội thắng.
* Không thay đổi dữ liệu lịch sử hiện tại.

Ví dụ:

```text
┌─────────────────────────────┐
│          TRẬN #1            │
│                             │
│      ĐỘI 1    ĐỘI 2         │
│        22  -  20             │
│        🏆                    │
│     Đội 1 thắng              │
│                             │
│  08:32 • 22/09/2026          │
└─────────────────────────────┘
```

---

# 56. Hiển thị 3 trận gần nhất

Trang History chỉ hiển thị tối đa **3 trận đấu gần nhất** đã được lưu local.

Thứ tự:

```text
Trận mới nhất
↓
Trận gần nhất thứ 2
↓
Trận gần nhất thứ 3
```

Không được hiển thị quá 3 trận.

Logic lưu local đã triển khai trước đó vẫn giữ nguyên.

---

# 57. Nút Back

Trang lịch sử phải có nút quay lại ở góc trên:

```text
←
```

Khi nhấn:

```text
History Screen
      ↓
Scoreboard Screen
```

Quay lại đúng màn hình tính điểm.

Không reset trận đấu hiện tại khi người dùng chỉ mở rồi quay lại trang History.

---

# 58. Trạng thái không có lịch sử

Nếu chưa có trận đấu nào:

```text
┌─────────────────────────────┐
│ ←     LỊCH SỬ TRẬN ĐẤU      │
│                             │
│                             │
│        📋                   │
│                             │
│   Chưa có trận đấu nào      │
│                             │
│                             │
└─────────────────────────────┘
```

Không hiển thị các card trống.

---

# 59. Giữ nguyên dữ liệu Local Storage

Không thay đổi cơ chế lưu local đã triển khai.

History Screen chỉ đọc dữ liệu từ `LocalStorageService`.

Ví dụ:

```dart
final history = await localStorageService.getMatchHistory();
```

Không tạo một cơ chế lưu trữ mới.

---

# 60. Navigation Architecture

Tách rõ hai màn hình:

```text
lib/
├── screens/
│   ├── scoreboard_screen.dart
│   └── match_history_screen.dart
```

Luồng navigation:

```text
ScoreboardScreen
      │
      │ Nhấn "LỊCH SỬ"
      ▼
MatchHistoryScreen
      │
      │ Nhấn Back
      ▼
ScoreboardScreen
```

---

# 61. Yêu cầu quan trọng

Không làm thay đổi các chức năng đang có:

* Tính điểm
* Luật 21 điểm
* Luật deuce `20 - 20`
* Thắng cách biệt 2 điểm
* START
* PAUSE
* RESUME
* Timer
* RESET
* Lưu 3 trận gần nhất
* Local Storage

Chỉ thay đổi **cách hiển thị và truy cập History**:

### Trước:

```text
Scoreboard
├── Score
├── Timer
├── Controls
└── Match History
```

### Sau:

```text
Scoreboard
├── Score
├── Timer
├── Controls
└── [LỊCH SỬ]

                 ↓

          Match History Screen
          ├── Match 1
          ├── Match 2
          └── Match 3
```

Mục tiêu là màn hình tính điểm phải **gọn, tập trung vào trận đấu hiện tại**, còn lịch sử trận đấu được quản lý ở **một trang riêng** và hiển thị rõ ràng kết quả của **Đội 1 vs Đội 2**.
