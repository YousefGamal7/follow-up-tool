class ReportAssignment {
  final String name;
  final int submitted;
  final int missing;
  final String? deadline;

  ReportAssignment({
    required this.name,
    required this.submitted,
    required this.missing,
    this.deadline,
  });
}

class WorkshopSession {
  final String topic;
  final String date;
  final int attendance;
  final String startTime;
  final String endTime;

  WorkshopSession({
    required this.topic,
    required this.date,
    required this.attendance,
    required this.startTime,
    required this.endTime,
  });

  factory WorkshopSession.fromJson(Map<String, dynamic> json) {
    return WorkshopSession(
      topic: json['topic'] ?? '',
      date: json['date'] ?? '',
      attendance: json['attendance'] ?? 0,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'date': date,
      'attendance': attendance,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

class BranchAttendance {
  final String week;
  final String date;
  final String day;
  final String arriveTime;
  final String endTime;
  final String branchName;

  BranchAttendance({
    required this.week,
    required this.date,
    required this.day,
    required this.arriveTime,
    required this.endTime,
    required this.branchName,
  });

  factory BranchAttendance.fromJson(Map<String, dynamic> json) {
    return BranchAttendance(
      week: json['week'] ?? '',
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      arriveTime: json['arriveTime'] ?? '',
      endTime: json['endTime'] ?? '',
      branchName: json['branchName'] ?? 'Unknown Branch',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'date': date,
      'day': day,
      'arriveTime': arriveTime,
      'endTime': endTime,
      'branchName': branchName,
    };
  }
}
