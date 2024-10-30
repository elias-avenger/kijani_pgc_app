class TimeProvider {
  DateTime now = DateTime.now();

  // greeting
  String greeting() {
    if (now.hour >= 0 && now.hour < 12) {
      return 'Good Morning,';
    } else if (now.hour >= 12 && now.hour < 16) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }
}
