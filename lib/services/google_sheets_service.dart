import 'package:gsheets/gsheets.dart';
import '../models/student.dart';

class GoogleSheetsService {
  // ⚠️ WARNING: Hardcoding service account keys in the app is not recommended for production security.
  static const String _credentials = r'''
  {
  "type": "service_account",
  "project_id": "send-message-488923",
  "private_key_id": "36e42308778ca06a508fb0d3ac93ebc3ae893aea",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC/RWnZ43ZehYNq\nHSUBowWYY/eEwYyiCTLfSi7qTkUlKf3JY9LrlZdD2UNcsQ+S27Dqrd1T51ELpOgY\nLUE2fYqifXhhui5UQkua8M2mRUYAdGrJvy+/oRgGprTyAhmek01lvPx3DwP/vplM\naHXRQazjYOO0GLZvs46UDS+g7GolTEgZgfVaeM5cQ1CQbIeBCNPJKHx+Y/gVAt3t\nW7I1wfqmLmYptxBn+YhJPalm5N2BzDuYz36EKRw+4OSzoep53kOTeJx+zYUVenu9\nM5O3JMVCEIaNQz1arTO5WHBxDoCj1DtHbOqTraR9IJGoeBTxbNpJ7er5/7SzbimF\njbzy7kVbAgMBAAECggEAL4JX2QG5WKAUNMrZcs8h6CjIheanfmYHh1P/VD6tyR3l\nhlzvuomVIYq5QzBNvH4qMxiNlbYquNg0uDChdp33TgYZXTjoIhC3g9xVUHv7d8hy\n7/q3qwMiGyDUaBpib7OJ8X/gO9h0d1VJ8aMuxJPqFC5wUL8krZktjJO75V5jvTCH\nG79gULE+jy65eR8q9KILxAZ5BN1/BYJ7aIGA46MHMSrvet9z9oOj0H1pjtZfy2dV\nCILv8kmPPK/hvzaXNmsTQEt20Iggog06/ksSpE4RCjSIIF6a9Uz4pqmLJUIEGPJ/\nP6CaYMo58sRw7jjW7mRy1pt/lMllyy8u3KJJbd1IHQKBgQD6yfOwWTrAkeplJ7py\nDXXvDRK0/A4aO27LFAyZMe5cnw54RPGJoQvlr5+NXqzaEMghsBAk8Q2HSx6iBnid\nHTw7Ev+o5a37JvH2uq4/7mKTrxCW5Xk7Ry7aHqdd8uQeMx0FeCkh66zjpWmRJIdI\nAtAcEpbqhfpCkD3Po9wnL/lfVQKBgQDDPtzQOngmjXVpwZYM7lM8M/x5npZgpSmn\nwNETsn/ir4UB7I6g8C87awJfHc3d8BUOG+vTDnbnZKvqGsalBxvmt0x31R6r17d0\nMraBG/aEcoYdg8e4/2eEKE27gZFYvuGvCpw0ZAZG/uICnsHtDKCz0fqRU7I+qgKw\nbRbGUGMx7wKBgQDm/lSivc1LyhqniWxF2Pgjc1sjsHYc21k1XAYupLr0PNzLElWX\neurGaHkBcY6sXIC55r04CX94ekyA2I0HygHMN7ecDdGuXzTHGTOeVygc90bEdiCv\n5OTWqx1lf292EYZNn1vjjnv0Qkt2ELs6LL0a3lR7N2RHIyyLsFX7EkkS8QKBgQCG\n4nrycDJpj/i5oz/ilxNx2AhojSMeiXwJpK/Mh9jJ5rBg7+hpTwWSaw8sXw7GcQJa\nyPdWy/thSK9sACuT/yFLdv6hGt8hoNngsNhcwdDBF82Hvm7QY8JEDwQEsjKTuOt5\nXj8kAqZDjfreDIe1GLA9CqeslsHhgNpywCqnvwmIiQKBgEP2cetr0HbbyVg1+yPL\n7MZEJcSfUYuEARSRg0HOC4dE5PePHtVwkI0N2vvROSB8HiiVvkx9GWZyOqLOv/Y5\nQocwTC+R0wux21A6qfGhT4cl04ZNbnrQCYcmBfYco/BixlhG9kqsSCuDXhMrxVRx\nyswSm3YHLF+wYm7ihaTOfrVl\n-----END PRIVATE KEY-----\n",
  "client_email": "send-message@send-message-488923.iam.gserviceaccount.com",
  "client_id": "108737732166410784118",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/send-message%40send-message-488923.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';

  static const String _spreadsheetId = '1KpCOplQNw4C5ubyxlZcTGdLK4HszAujez7QjyEZfohM';

  final GSheets _gsheets;

  GoogleSheetsService() : _gsheets = GSheets(_credentials);

  Future<Map<String, dynamic>?> fetchInstructorData(
      String instructorName, String? selectedAssignment) async {
    try {
      final ss = await _gsheets.spreadsheet(_spreadsheetId);
      final sheet = ss.worksheetByTitle(instructorName);
      if (sheet == null) return null;

      final allRows = await sheet.values.allRows();
      if (allRows.isEmpty) return null;

      List<Student> tempList = [];
      Set<String> foundGroups = {'All'};
      List<String> foundAssignments = [];

      int headerRowIndex = -1;
      int firstTaskColIndex = -1;

      for (int i = 0; i < 20 && i < allRows.length; i++) {
        var row = allRows[i];
        int nameIdx = -1;
        int submissionIdx = -1;

        for (int j = 0; j < row.length; j++) {
          String val = row[j].toString().trim().toLowerCase();
          if (val == 'name') nameIdx = j;
          if (val == 'submission') submissionIdx = j;
        }

        if (nameIdx != -1) {
          headerRowIndex = i;
          firstTaskColIndex = (submissionIdx != -1) ? submissionIdx + 1 : 5;
          break;
        }
      }

      if (headerRowIndex == -1) return null;

      var headerRow = allRows[headerRowIndex];
      for (int j = firstTaskColIndex; j < headerRow.length; j++) {
        String taskName = headerRow[j].toString().trim();
        if (taskName.isNotEmpty && !taskName.contains("Full Mark")) {
          foundAssignments.add(taskName);
        }
      }

      String? currentSelectedAssignment = selectedAssignment;
      if (currentSelectedAssignment == null || !foundAssignments.contains(currentSelectedAssignment)) {
        currentSelectedAssignment = foundAssignments.isNotEmpty ? foundAssignments[0] : null;
      }

      int targetTaskColIndex = firstTaskColIndex;
      if (currentSelectedAssignment != null) {
        for (int j = firstTaskColIndex; j < headerRow.length; j++) {
          if (headerRow[j].toString().trim() == currentSelectedAssignment) {
            targetTaskColIndex = j;
            break;
          }
        }
      }

      String currentGroup = "No Group";
      for (int i = headerRowIndex + 1; i < allRows.length; i++) {
        var row = allRows[i];
        if (row.isEmpty) continue;
        String firstCell = row[0].toString().trim();

        if (firstCell.toLowerCase().contains("group")) {
          currentGroup = firstCell;
          foundGroups.add(currentGroup);
          continue;
        }

        if (row.length > 2 && row[1].toString().trim().isNotEmpty && !firstCell.contains("Gmail")) {
          String name = row[1].toString();
          String email = firstCell; // First cell usually contains the email in Grades sheet.
          String rawPhone = row[2].toString();
          String currentGrade = row.length > targetTaskColIndex ? row[targetTaskColIndex].toString() : "";

          int misses = 0;
          Map<String, String> studentAllGrades = {};

          for (int k = firstTaskColIndex; k < headerRow.length; k++) {
            String taskName = headerRow[k].toString().trim();
            if (taskName.isEmpty || taskName.contains("Full Mark")) continue;

            String cellValue = k < row.length ? row[k].toString() : "";
            studentAllGrades[taskName] = cellValue;

            if (cellValue.trim() == "") {
              misses++;
            }
          }

          String phone = _processPhone(rawPhone);
          if (phone.isNotEmpty) {
            tempList.add(
              Student(
                name: name,
                email: email,
                phone: phone,
                group: currentGroup,
                grade: currentGrade,
                missedCount: misses,
                allGrades: studentAllGrades,
              ),
            );
          }
        }
      }

      return {
        'students': tempList,
        'groups': foundGroups.toList(),
        'assignments': foundAssignments,
        'selectedAssignment': currentSelectedAssignment,
      };
    } catch (e) {
      print("Error in fetchInstructorData: $e");
      return null;
    }
  }

  String _processPhone(String raw) {
    String first = raw.split(RegExp(r'[-/|]'))[0].replaceAll(RegExp(r'\D'), '');
    if (first.isEmpty) return "";
    if (first.startsWith('0')) return '2$first';
    if (first.startsWith('1')) return '20$first';
    return first;
  }

  /// New Method: Process Student Tickets from "Tickets Sheet"
  Future<void> processStudentTickets(String instructorSheetName, String assignmentColumnName) async {
    try {
      final ss = await _gsheets.spreadsheet(_spreadsheetId);
      
      // 1. Fetch emails from Tickets Sheet
      final ticketsSheet = ss.worksheetByTitle('Yousef Gamal');
      if (ticketsSheet == null) {
        throw Exception("Tickets Sheet not found.");
      }

      final ticketRows = await ticketsSheet.values.allRows();
      if (ticketRows.isEmpty) return;
      
      int ticketEmailIdx = -1;
      for (int j = 0; j < ticketRows[0].length; j++) {
        if (ticketRows[0][j].toString().trim().toLowerCase() == 'email') {
          ticketEmailIdx = j;
          break;
        }
      }

      if (ticketEmailIdx == -1) {
        // Fallback to 0 if not found
        ticketEmailIdx = 0;
      }

      Set<String> excusedEmails = {};
      for (int i = 1; i < ticketRows.length; i++) {
        if (ticketRows[i].length > ticketEmailIdx) {
          String email = ticketRows[i][ticketEmailIdx].toString().trim().toLowerCase();
          if (email.isNotEmpty) {
            excusedEmails.add(email);
          }
        }
      }

      // 2. Iterate through Main Sheet
      final mainSheet = ss.worksheetByTitle(instructorSheetName);
      if (mainSheet == null) {
        throw Exception("Main Sheet ($instructorSheetName) not found.");
      }

      final mainRows = await mainSheet.values.allRows();
      if (mainRows.isEmpty) return;

      int headerRowIndex = -1;
      int emailColIndex = -1; // Assuming it's column 0 based on 'Gmail'
      int assignmentColIndex = -1;

      for (int i = 0; i < 20 && i < mainRows.length; i++) {
        var row = mainRows[i];
        int nameIdx = -1;
        for (int j = 0; j < row.length; j++) {
          String val = row[j].toString().trim().toLowerCase();
          if (val == 'name') nameIdx = j;
          if (val == 'email' || val == 'gmail') emailColIndex = j;
        }
        if (nameIdx != -1) {
          headerRowIndex = i;
          if (emailColIndex == -1) emailColIndex = 0; // fallback to 0
          for (int j = 0; j < row.length; j++) {
            if (row[j].toString().trim() == assignmentColumnName) {
              assignmentColIndex = j;
              break;
            }
          }
          break;
        }
      }

      if (headerRowIndex == -1 || assignmentColIndex == -1) {
        throw Exception("Could not find headers or assignment column.");
      }

      // 3. Update 'Excused'
      for (int i = headerRowIndex + 1; i < mainRows.length; i++) {
        var row = mainRows[i];
        if (row.length > emailColIndex) {
          String email = row[emailColIndex].toString().trim().toLowerCase();
          if (excusedEmails.contains(email)) {
             String currentValue = row.length > assignmentColIndex ? row[assignmentColIndex].toString().trim() : "";
             if (currentValue.isEmpty) {
                // Update cell (row + 1 because gsheets is 1-indexed for rows, and col + 1 for cols)
                await mainSheet.values.insertValue('Excused', column: assignmentColIndex + 1, row: i + 1);
             }
          }
        }
      }

    } catch (e) {
      print("Error processing tickets: $e");
      rethrow;
    }
  }
}
