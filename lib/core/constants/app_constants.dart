abstract final class AppConstants {
  /// 그룹 최소 인원
  static const int minGroupSize = 2;

  /// 그룹 최대 인원
  static const int maxGroupSize = 10;

  /// 참여코드 길이
  static const int joinCodeLength = 6;

  /// 폭탄 기본 제한시간 (초) — 24시간
  static const int defaultBombDurationSeconds = 86400;

  /// 게임 최소 진행 일수
  static const int minGameDays = 4;

  /// 게임 최대 진행 일수
  static const int maxGameDays = 7;

  /// Firestore 컬렉션명
  static const String groupsCollection = 'groups';
  static const String usersCollection = 'users';
  static const String missionsCollection = 'missions';
  static const String shopItemsCollection = 'shopItems';
}

abstract final class CurrencyConstants {
  /// 출석 체크 보상 재화
  static const int dailyCheckInReward = 10;

  /// 미션 완료 보상 재화
  static const int missionReward = 30;

  /// 아이템 기본 가격 — 순서 바꾸기
  static const int swapOrderPrice = 50;

  /// 아이템 기본 가격 — 폭탄 추가
  static const int addBombPrice = 80;

  /// 아이템 기본 가격 — 패널티 강화
  static const int enhancePenaltyPrice = 100;
}
