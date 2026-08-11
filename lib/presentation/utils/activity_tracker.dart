

/// Global Activity Tracker that records pointer interactions across the app
/// to accurately measure user inactivity.
class ActivityTracker {
  static DateTime _lastUserActivityTime = DateTime.now();

  static DateTime get lastUserActivityTime => _lastUserActivityTime;

  static void recordActivity() {
    _lastUserActivityTime = DateTime.now();
  }
}
