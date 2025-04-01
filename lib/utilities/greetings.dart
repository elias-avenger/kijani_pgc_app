class Greetings {
  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}

  // static String _formattedDate() {
  //   final now = DateTime.now();
  //   return "${_getWeekday(now.weekday)}, ${now.day.toString().padLeft(2, '0')} ${_getMonth(now.month)}";
  // }

  // static String _getWeekday(int weekday) {
  //   const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  //   return weekdays[weekday - 1];
  // }

  // static String _getMonth(int month) {
  //   const months = [
  //     'Jan',
  //     'Feb',
  //     'Mar',
  //     'Apr',
  //     'May',
  //     'Jun',
  //     'Jul',
  //     'Aug',
  //     'Sep',
  //     'Oct',
  //     'Nov',
  //     'Dec'
  //   ];
  //   return months[month - 1];
  // }

