extension AppDateUtils on DateTime {
  /// 남은 시간을 HH:MM:SS 문자열로 반환
  /// 음수 duration은 0으로 clamp하고, 시간은 24시간 초과도 그대로 표시한다
  /// (클라이언트 시계가 서버보다 느릴 때 wrap-around 방지)
  static String formatDuration(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final hours = safe.inHours.toString().padLeft(2, '0');
    final minutes = safe.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// 오늘 날짜를 'yyyy-MM-dd' 형식으로 반환 (출석 체크용)
  static String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
