import 'dart:convert';
import 'package:gsheets/gsheets.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import '../models/report_models.dart';

class MultiSheetSyncService {
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

  static const String _gradesSpreadsheetId = '1KpCOplQNw4C5ubyxlZcTGdLK4HszAujez7QjyEZfohM'; // Assignments
  static const String _followUpSpreadsheetId = '1pHuK4Jk1YUVQjcMbpSU0cvKGitmb9QeJrVV81r3OwiE'; // Follow up
  
  late final GSheets _gsheets;
  late final Future<Spreadsheet> _gradesSpreadsheetFuture;
  late final Future<Spreadsheet> _followUpSpreadsheetFuture;
  late final Future<sheets.SheetsApi> _sheetsApiFuture;

  MultiSheetSyncService() {
    _gsheets = GSheets(_credentials);
    _gradesSpreadsheetFuture = _gsheets.spreadsheet(_gradesSpreadsheetId);
    _followUpSpreadsheetFuture = _gsheets.spreadsheet(_followUpSpreadsheetId);
    _sheetsApiFuture = _initSheetsApi();
  }

  Future<sheets.SheetsApi> _initSheetsApi() async {
    final credentials = ServiceAccountCredentials.fromJson(_credentials);
    final client = await clientViaServiceAccount(credentials, [sheets.SheetsApi.spreadsheetsScope]);
    return sheets.SheetsApi(client);
  }

  /// Helper to insert a note (and optionally a value) into a specific cell using raw googleapis.
  Future<void> _insertNote(String targetSpreadsheetId, int sheetId, int rowIdx, int colIdx, String text, {String? value}) async {
    final api = await _sheetsApiFuture;
    final requests = <sheets.Request>[];
    
    var cellData = sheets.CellData(note: text);
    var fields = "note";
    
    if (value != null) {
      cellData.userEnteredValue = sheets.ExtendedValue(stringValue: value);
      fields = "note,userEnteredValue";
    }

    requests.add(
      sheets.Request(
        updateCells: sheets.UpdateCellsRequest(
          range: sheets.GridRange(
            sheetId: sheetId,
            startRowIndex: rowIdx,
            endRowIndex: rowIdx + 1,
            startColumnIndex: colIdx,
            endColumnIndex: colIdx + 1,
          ),
          rows: [
            sheets.RowData(values: [cellData]),
          ],
          fields: fields,
        ),
      ),
    );

    final batchRequest = sheets.BatchUpdateSpreadsheetRequest(requests: requests);
    await api.spreadsheets.batchUpdate(batchRequest, targetSpreadsheetId);
  }

  /// Returns true if a row's first cell is a header keyword like "email", "gmail", or "mail"
  /// — NOT an actual student email address (which contains "@").
  bool _isHeaderRow(List<dynamic> row) {
    if (row.isEmpty) return false;
    final first = row[0].toString().trim().toLowerCase();
    return (first == 'gmail' || first == 'email' || first == 'mail') && !first.contains('@');
  }

  /// Full sync: reads ALL assignment columns from the Grades sheet.
  /// Matches students by email to existing rows in the Follow-up sheet.
  /// Writes "Submitted" if the grade cell has data, "No Answer" if empty.
  Future<int> syncAllAssignmentsToFollowUp({required String sheetName}) async {
    // ── Step 1: Read the Grades sheet ──────────────────────────────────────
    final gradesSs = await _gradesSpreadsheetFuture;
    final gradesSheet = gradesSs.worksheetByTitle(sheetName);
    if (gradesSheet == null) throw Exception("Sheet '$sheetName' not found in Grades spreadsheet.");

    final gradesRows = await gradesSheet.values.allRows();

    // Find the header row: the row that has "name" in col 1 (same logic as GoogleSheetsService)
    int gHeaderRow = -1;
    int firstTaskCol = -1;
    for (int i = 0; i < gradesRows.length && i < 20; i++) {
      for (int j = 0; j < gradesRows[i].length; j++) {
        if (gradesRows[i][j].toString().trim().toLowerCase() == 'name') {
          gHeaderRow = i;
          break;
        }
      }
      if (gHeaderRow != -1) break;
    }
    if (gHeaderRow == -1) throw Exception("Header row not found in Grades sheet '$sheetName'.");

    final gradesHeaderRow = gradesRows[gHeaderRow];

    // Find submission col (to determine where tasks start)
    int submissionCol = -1;
    for (int j = 0; j < gradesHeaderRow.length; j++) {
      if (gradesHeaderRow[j].toString().trim().toLowerCase() == 'submission') {
        submissionCol = j;
        break;
      }
    }
    firstTaskCol = (submissionCol != -1) ? submissionCol + 1 : 4;

    // ── Step 2: Read the Follow-up sheet ───────────────────────────────────
    final followUpSs = await _followUpSpreadsheetFuture;
    final followSheet = followUpSs.worksheetByTitle(sheetName);
    if (followSheet == null) throw Exception("Sheet '$sheetName' not found in Follow-up spreadsheet.");

    final followRows = await followSheet.values.allRows();

    // Find header row in Follow-up sheet (first col = "email" or "gmail")
    int fHeaderRow = -1;
    for (int i = 0; i < followRows.length && i < 10; i++) {
      if (followRows[i].isNotEmpty) {
        final first = followRows[i][0].toString().trim().toLowerCase();
        if (first == 'email' || first == 'gmail' || first == 'mail') {
          fHeaderRow = i;
          break;
        }
      }
    }
    if (fHeaderRow == -1) throw Exception("Header row not found in Follow-up sheet '$sheetName'.");

    final followHeaders = followRows[fHeaderRow];

    // Build: assignmentName → column index in Follow-up sheet
    final Map<String, int> followColByName = {};
    for (int j = 0; j < followHeaders.length; j++) {
      final h = followHeaders[j].toString().trim();
      if (h.isNotEmpty) followColByName[h] = j;
    }

    // Build: assignment names ordered by position (from Follow-up headers, skipping email/name/number)
    // These correspond positionally to Grades sheet task columns
    final List<String> orderedAssignNames = [];
    final List<int> orderedFollowColIdx = [];
    for (int j = 0; j < followHeaders.length; j++) {
      final h = followHeaders[j].toString().trim();
      final hl = h.toLowerCase();
      if (h.isEmpty || hl == 'email' || hl == 'gmail' || hl == 'name' || hl == 'number' || hl == 'whatsapp') continue;
      orderedAssignNames.add(h);
      orderedFollowColIdx.add(j);
    }

    // Build email → row index map for Follow-up sheet
    final Map<String, int> emailToFollowRow = {};
    for (int i = fHeaderRow + 1; i < followRows.length; i++) {
      if (followRows[i].isEmpty) continue;
      final email = followRows[i][0].toString().trim().toLowerCase();
      if (email.isNotEmpty) emailToFollowRow[email] = i;
    }

    // ── Step 3: Build batch update requests ────────────────────────────────
    final api = await _sheetsApiFuture;
    final requests = <sheets.Request>[];

    // Iterate student rows in Grades sheet
    for (int i = gHeaderRow + 1; i < gradesRows.length; i++) {
      final row = gradesRows[i];
      if (row.isEmpty) continue;
      final email = row[0].toString().trim().toLowerCase();
      if (email.isEmpty || email.contains('group') || !email.contains('@')) continue;

      final followRowIdx = emailToFollowRow[email];
      if (followRowIdx == null) continue; // not in Follow-up sheet

      // Match assignment values by position
      // Grades cols starting at firstTaskCol map to orderedAssignNames[0], [1], [2]...
      for (int k = 0; k < orderedAssignNames.length; k++) {
        final gradesColIdx = firstTaskCol + k;
        final followColIdx = orderedFollowColIdx[k];
        final gradeVal = gradesColIdx < row.length ? row[gradesColIdx].toString().trim() : '';
        final status = gradeVal.isNotEmpty ? 'Submitted' : 'No Answer';

        requests.add(sheets.Request(
          updateCells: sheets.UpdateCellsRequest(
            range: sheets.GridRange(
              sheetId: followSheet.id,
              startRowIndex: followRowIdx,
              endRowIndex: followRowIdx + 1,
              startColumnIndex: followColIdx,
              endColumnIndex: followColIdx + 1,
            ),
            rows: [sheets.RowData(values: [
              sheets.CellData(
                userEnteredValue: sheets.ExtendedValue(stringValue: status),
                userEnteredFormat: sheets.CellFormat(
                  backgroundColor: status == 'Submitted'
                      ? sheets.Color(red: 0.18, green: 0.8, blue: 0.44)
                      : sheets.Color(red: 0.91, green: 0.30, blue: 0.24),
                  textFormat: sheets.TextFormat(
                    foregroundColor: sheets.Color(red: 1, green: 1, blue: 1),
                    bold: true,
                  ),
                ),
              )
            ])],
            fields: 'userEnteredValue,userEnteredFormat.backgroundColor,userEnteredFormat.textFormat',
          ),
        ));
      }
    }

    if (requests.isEmpty) throw Exception("No matching students found to update.");

    // Send in batches of 500 (API limit per request)
    const batchSize = 500;
    for (int i = 0; i < requests.length; i += batchSize) {
      final end = (i + batchSize > requests.length) ? requests.length : i + batchSize;
      await api.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(requests: requests.sublist(i, end)),
        _followUpSpreadsheetId,
      );
    }

    return emailToFollowRow.length;
  }

  /// Syncs grades from the 'Grades' sheet to the 'Tracking' sheet if numerical.
  Future<int> syncGradesToStatus(String assignmentCol, {required String sheetName}) async {
    final gradesSs = await _gradesSpreadsheetFuture;
    final sheet = gradesSs.worksheetByTitle(sheetName);

    if (sheet == null) {
      throw Exception("Required sheet '$sheetName' not found.");
    }

    final allRows = await sheet.values.allRows();
    int headerRowIndex = -1;
    for (int i = 0; i < allRows.length; i++) {
      if (_isHeaderRow(allRows[i])) {
        headerRowIndex = i;
        break;
      }
    }

    if (headerRowIndex == -1) throw Exception("Header row with 'Gmail' not found in $sheetName.");

    final headers = allRows[headerRowIndex];
    final lowerHeaders = headers.map((e) => e.toString().toLowerCase().trim()).toList();

    // FIX 1: Dynamically find the email column in the source sheet instead of hardcoding to 0
    int emailCol = lowerHeaders.indexOf('gmail');
    if (emailCol == -1) emailCol = lowerHeaders.indexOf('mail');
    if (emailCol == -1) emailCol = 0; // Fallback to 0 only if not found

    final assignCol = lowerHeaders.indexOf(assignmentCol.toLowerCase().trim());

    if (assignCol == -1) {
      throw Exception("Required column '$assignmentCol' not found in $sheetName sheet.");
    }

    // Use the same sheetName (instructor tab) in the Follow Up spreadsheet
    String trackingSheetName = sheetName;
    final followUpSs = await _followUpSpreadsheetFuture;
    var trackingSheet = followUpSs.worksheetByTitle(trackingSheetName);

    if (trackingSheet == null) {
      trackingSheet = await followUpSs.addWorksheet(trackingSheetName);
      await trackingSheet.values.insertRow(1, ['email', assignmentCol]);
    }

    // Fetch tracking rows, use var so we can update it if it was empty
    var trackingAllRows = await trackingSheet.values.allRows();
    int tHeaderRowIndex = -1;
    for (int i = 0; i < trackingAllRows.length; i++) {
      if (_isHeaderRow(trackingAllRows[i])) {
        tHeaderRowIndex = i;
        break;
      }
    }

    if (tHeaderRowIndex == -1) {
      tHeaderRowIndex = 0;
      if (trackingAllRows.isEmpty) {
        await trackingSheet.values.insertRow(1, ['Gmail', assignmentCol]);
        // Update trackingAllRows so our length calculation below is correct
        trackingAllRows = [['Gmail', assignmentCol]];
      }
    }

    final trackingHeaders = trackingAllRows[tHeaderRowIndex];
    final trackingLowerHeaders = trackingHeaders.map((e) => e.toString().toLowerCase().trim()).toList();

    int tEmailCol = trackingLowerHeaders.indexOf('gmail');
    if (tEmailCol == -1) tEmailCol = trackingLowerHeaders.indexOf('mail');
    if (tEmailCol == -1) tEmailCol = 0;

    int tAssignCol = trackingLowerHeaders.indexOf(assignmentCol.toLowerCase().trim());

    if (tAssignCol == -1) {
      tAssignCol = trackingHeaders.length;
      await trackingSheet.values.insertValue(assignmentCol, column: tAssignCol + 1, row: tHeaderRowIndex + 1);
    }

    final trackingEmailToRow = <String, int>{};
    for (int i = tHeaderRowIndex + 1; i < trackingAllRows.length; i++) {
      if (trackingAllRows[i].length > tEmailCol) {
        final email = trackingAllRows[i][tEmailCol].toString().toLowerCase().trim();
        if (email.isNotEmpty) trackingEmailToRow[email] = i;
      }
    }

    int updatedCount = 0;
    List<String> trackingAssigns = await trackingSheet.values.column(tAssignCol + 1);

    // FIX 2: Create a variable to track the actual next available row at the very bottom
    int nextAvailableRowIdx = trackingAllRows.length;

    for (int i = headerRowIndex + 1; i < allRows.length; i++) {
      final row = allRows[i];
      if (row.length > assignCol) {
        final gradeVal = row[assignCol].toString().trim();

        if (gradeVal.isNotEmpty) {
          final email = row[emailCol].toString().toLowerCase().trim();
          if (email.isNotEmpty) {
            int tIdx;

            if (trackingEmailToRow.containsKey(email)) {
              tIdx = trackingEmailToRow[email]!;
            } else {
              // Assign the new student to the absolute bottom row
              tIdx = nextAvailableRowIdx;
              nextAvailableRowIdx++; // Increment for the next potential new student

              // insertValue uses 1-based indexing, so add 1 to tIdx
              await trackingSheet.values.insertValue(email, column: tEmailCol + 1, row: tIdx + 1);
              trackingEmailToRow[email] = tIdx;
            }

            // Pad the assignments column list if it's too short
            if (trackingAssigns.length <= tIdx) {
              trackingAssigns.addAll(List.filled(tIdx - trackingAssigns.length + 1, ''));
            }

            if (trackingAssigns[tIdx].toLowerCase() != 'submitted') {
              trackingAssigns[tIdx] = 'Submitted';
              updatedCount++;
            }
          }
        }
      }
    }

    if (updatedCount > 0) {
      await trackingSheet.values.insertColumn(tAssignCol + 1, trackingAssigns, fromRow: 1);
    }

    return updatedCount;
  }

  /// Adds 'Excused' status and a Note to multiple assignments.
  Future<void> addExcusedStatus({
    required String email, 
    required List<String> assignments, 
    required String reason,
    required String sheetName,
  }) async {
    final ss = await _followUpSpreadsheetFuture;
    final sheet = ss.worksheetByTitle(sheetName);
    if (sheet == null) throw Exception("Sheet '$sheetName' not found.");

    final allRows = await sheet.values.allRows();
    int headerRowIndex = -1;
    for (int i = 0; i < allRows.length; i++) {
      if (_isHeaderRow(allRows[i])) {
        headerRowIndex = i;
        break;
      }
    }

    if (headerRowIndex == -1) throw Exception("Header row with 'Gmail' not found.");

    final headers = allRows[headerRowIndex];
    final lowerHeaders = headers.map((e) => e.toString().toLowerCase().trim()).toList();
    
    // First column is gmail
    final emailCol = 0; 
    
    int rowIdx = -1;
    for (int i = headerRowIndex + 1; i < allRows.length; i++) {
      if (allRows[i].isNotEmpty && allRows[i][0].toString().toLowerCase().trim() == email.toLowerCase().trim()) {
        rowIdx = i;
        break;
      }
    }
    
    if (rowIdx == -1) {
      throw Exception("Email '$email' not found in sheet.");
    }

    final api = await _sheetsApiFuture;
    final requests = <sheets.Request>[];

    for (String assignment in assignments) {
      final colIdx = lowerHeaders.indexOf(assignment.toLowerCase().trim());
      if (colIdx != -1) {
        var cellData = sheets.CellData(
          note: reason,
          userEnteredValue: sheets.ExtendedValue(stringValue: 'Excused')
        );
        requests.add(
          sheets.Request(
            updateCells: sheets.UpdateCellsRequest(
              range: sheets.GridRange(
                sheetId: sheet.id,
                startRowIndex: rowIdx,
                endRowIndex: rowIdx + 1,
                startColumnIndex: colIdx,
                endColumnIndex: colIdx + 1,
              ),
              rows: [sheets.RowData(values: [cellData])],
              fields: "note,userEnteredValue",
            ),
          ),
        );
      } else {
        print("Warning: Assignment column '$assignment' not found.");
      }
    }

    if (requests.isNotEmpty) {
      final batchRequest = sheets.BatchUpdateSpreadsheetRequest(requests: requests);
      await api.spreadsheets.batchUpdate(batchRequest, _followUpSpreadsheetId);
    }
  }

  /// Marks as 'Followed up' and inserts the message as a Note.
  Future<void> markAsFollowedUp({
    required String email, 
    required String messageSent, 
    required String sheetName,
    required List<String> assignments,
  }) async {
    final ss = await _followUpSpreadsheetFuture;
    final sheet = ss.worksheetByTitle(sheetName);
    if (sheet == null) throw Exception("Sheet '$sheetName' not found.");

    final allRows = await sheet.values.allRows();
    int headerRowIndex = -1;
    for (int i = 0; i < allRows.length; i++) {
      if (_isHeaderRow(allRows[i])) {
        headerRowIndex = i;
        break;
      }
    }

    if (headerRowIndex == -1) throw Exception("Header row with 'Gmail' not found.");

    final headers = allRows[headerRowIndex];
    final lowerHeaders = headers.map((e) => e.toString().toLowerCase().trim()).toList();
    
    int rowIdx = -1;
    for (int i = headerRowIndex + 1; i < allRows.length; i++) {
      if (allRows[i].isNotEmpty && allRows[i][0].toString().toLowerCase().trim() == email.toLowerCase().trim()) {
        rowIdx = i;
        break;
      }
    }

    if (rowIdx == -1) {
      print("Warning: Email '$email' not found for follow up.");
      return;
    }

    if (assignments.isEmpty) {
      // Fallback to the 'Follow-up' column if no specific assignments are selected
      int followUpCol = lowerHeaders.indexOf('follow-up'); 
      
      if (followUpCol == -1) {
         // Create the 'Follow-up' column if it doesn't exist
         followUpCol = headers.length;
         await sheet.values.insertValue('Follow-up', column: followUpCol + 1, row: headerRowIndex + 1);
         print("Created 'Follow-up' column at index $followUpCol.");
      }

      await _insertNote(_followUpSpreadsheetId, sheet.id, rowIdx, followUpCol, messageSent, value: 'Followed up');
    } else {
      // Update specific assignments using batchUpdate
      final api = await _sheetsApiFuture;
      final requests = <sheets.Request>[];

      for (String assignment in assignments) {
        final colIdx = lowerHeaders.indexOf(assignment.toLowerCase().trim());
        if (colIdx != -1) {
          var cellData = sheets.CellData(
            note: messageSent,
            userEnteredValue: sheets.ExtendedValue(stringValue: 'Followed up')
          );
          requests.add(
            sheets.Request(
              updateCells: sheets.UpdateCellsRequest(
                range: sheets.GridRange(
                  sheetId: sheet.id,
                  startRowIndex: rowIdx,
                  endRowIndex: rowIdx + 1,
                  startColumnIndex: colIdx,
                  endColumnIndex: colIdx + 1,
                ),
                rows: [sheets.RowData(values: [cellData])],
                fields: "note,userEnteredValue",
              ),
            ),
          );
        } else {
          print("Warning: Assignment column '$assignment' not found for follow up.");
        }
      }

      if (requests.isNotEmpty) {
        final batchRequest = sheets.BatchUpdateSpreadsheetRequest(requests: requests);
        await api.spreadsheets.batchUpdate(batchRequest, _followUpSpreadsheetId);
      }
    }
  }

  /// Applies 'Done' to [taskName] for all students found in the 'Tickets' sheet.
  Future<void> applyTickets({
    required String taskName,
    required String gradesSheetName,
    String ticketsSheetName = 'Tickets',
  }) async {
    try {
      final ss = await _gradesSpreadsheetFuture;

      final ticketsSheet = ss.worksheetByTitle(ticketsSheetName);
      if (ticketsSheet == null) {
        throw Exception("Worksheet '$ticketsSheetName' could not be found.");
      }
      
      final ticketRows = await ticketsSheet.values.allRows();
      if (ticketRows.isEmpty || ticketRows.length == 1) return;

      int ticketEmailIdx = -1;
      final ticketHeaders = ticketRows[0].map((e) => e.toString().toLowerCase().trim()).toList();
      ticketEmailIdx = ticketHeaders.indexOf('email');
      if (ticketEmailIdx == -1) ticketEmailIdx = ticketHeaders.indexOf('gmail');
      if (ticketEmailIdx == -1) ticketEmailIdx = ticketHeaders.indexOf('mail');
      if (ticketEmailIdx == -1) ticketEmailIdx = 0; 

      Set<String> cleanTicketEmails = {};
      for (int i = 1; i < ticketRows.length; i++) {
        if (ticketRows[i].length > ticketEmailIdx) {
          String email = ticketRows[i][ticketEmailIdx].toString().trim().toLowerCase();
          if (email.isNotEmpty) cleanTicketEmails.add(email);
        }
      }

      if (cleanTicketEmails.isEmpty) return;

      final gradesSheet = ss.worksheetByTitle(gradesSheetName);
      if (gradesSheet == null) {
        throw Exception("Worksheet '$gradesSheetName' could not be found.");
      }

      final allRows = await gradesSheet.values.allRows();
      int headerRowIndex = -1;
      for (int i = 0; i < allRows.length; i++) {
        if (_isHeaderRow(allRows[i])) {
          headerRowIndex = i;
          break;
        }
      }

      if (headerRowIndex == -1) throw Exception("Header row with 'Gmail' not found in $gradesSheetName.");

      final headers = allRows[headerRowIndex];
      if (headers.isEmpty) return;

      final lowercaseHeaders = headers.map((h) => h.toString().toLowerCase().trim()).toList();

      final int mailColIndex = 0; // Since Gmail is column 0
      final int taskListIndex = lowercaseHeaders.indexOf(taskName.toLowerCase().trim());
      if (taskListIndex == -1) throw Exception("Target column '$taskName' could not be found.");
      final int taskColIndex = taskListIndex;

      List<String> targetColumnValues = await gradesSheet.values.column(taskColIndex + 1);

      // Map emails to row index
      final Map<String, int> emailToRowIndex = {};
      for (int i = headerRowIndex + 1; i < allRows.length; i++) {
        if (allRows[i].isNotEmpty) {
          final email = allRows[i][mailColIndex].toString().trim().toLowerCase();
          if (email.isNotEmpty) {
            emailToRowIndex[email] = i; 
          }
        }
      }

      int updatedCount = 0;

      for (String ticketEmail in cleanTicketEmails) {
        if (emailToRowIndex.containsKey(ticketEmail)) {
          final int index = emailToRowIndex[ticketEmail]!;
          
          if (targetColumnValues.length <= index) {
            targetColumnValues.addAll(List.filled(index - targetColumnValues.length + 1, ""));
          }
          
          final String currentValue = targetColumnValues[index].trim();
          if (currentValue.isEmpty || currentValue.toLowerCase() == 'excused') {
            targetColumnValues[index] = 'Done';
            updatedCount++;
          }
        }
      }

      if (updatedCount > 0) {
        await gradesSheet.values.insertColumn(
          taskColIndex + 1, 
          targetColumnValues,
          fromRow: 1,
        );
      }
    } catch (e) {
      print("Error in applyTickets: $e");
      rethrow;
    }
  }

  Future<Map<String, List<ReportAssignment>>> getAllGroupAssignmentsReport(String sheetName, List<String> availableGroups) async {
    Map<String, List<ReportAssignment>> allGroupsMap = {};
    for (String group in availableGroups) {
      if (group == 'All') continue;
      allGroupsMap[group] = await getAssignmentsReport(sheetName, groupName: group);
    }
    return allGroupsMap;
  }

  Future<List<ReportAssignment>> getAssignmentsReport(String sheetName, {String? groupName}) async {
    final gradesSs = await _gradesSpreadsheetFuture;
    final sheet = gradesSs.worksheetByTitle(sheetName);
    if (sheet == null) throw Exception("Sheet '$sheetName' not found.");

    final allRows = await sheet.values.allRows();
    int headerRowIndex = -1;
    for (int i = 0; i < allRows.length; i++) {
      if (_isHeaderRow(allRows[i])) {
        headerRowIndex = i;
        break;
      }
    }
    
    if (headerRowIndex == -1) throw Exception("Header row not found.");

    final headers = allRows[headerRowIndex];
    
    int firstTaskCol = -1;
    for (int j = 0; j < headers.length; j++) {
      if (headers[j].toString().trim().toLowerCase() == 'submission') {
        firstTaskCol = j + 1;
        break;
      }
    }
    if (firstTaskCol == -1) firstTaskCol = 4;

    List<ReportAssignment> assignments = [];
    
    for (int j = firstTaskCol; j < headers.length; j++) {
      String taskName = headers[j].toString().trim();
      if (taskName.isEmpty || taskName.contains("Full Mark")) continue;

      int submitted = 0;
      int missing = 0;
      String deadline = '';

      String currentGroup = "No Group";
      bool isDeadlinesRow = false;

      for (int i = headerRowIndex + 1; i < allRows.length; i++) {
         if (allRows[i].isEmpty) continue;
         String firstCell = allRows[i][0].toString().trim();
         
         if (firstCell.toLowerCase().contains("group")) {
           currentGroup = firstCell;
           isDeadlinesRow = true; // The row immediately after a group header is the deadlines row
           continue; 
         }
         
         if (isDeadlinesRow) {
           isDeadlinesRow = false;
           // Only grab the deadline if we are in the target group (or if no group is specified, we grab the first one we see)
           if (groupName == null || groupName == 'All' || currentGroup == groupName) {
             if (deadline.isEmpty && allRows[i].length > j) {
               String rawDeadline = allRows[i][j].toString().trim();
               // Serial date format check (e.g. 46150)
               if (int.tryParse(rawDeadline) != null) {
                  // convert serial date to string roughly, or just display as is if we can't.
                  // For now, let's format it or keep it empty if it's a huge number.
                  // Actually, let's just keep the raw value or map it. A proper serial date conversion:
                  int days = int.parse(rawDeadline);
                  if (days > 40000) {
                     DateTime date = DateTime(1899, 12, 30).add(Duration(days: days));
                     deadline = "${date.day}/${date.month}";
                  } else {
                     deadline = rawDeadline;
                  }
               } else {
                 deadline = rawDeadline;
               }
             }
           }
           continue; 
         }

         if (firstCell.isEmpty || firstCell.toLowerCase() == "gmail") continue;
         
         if (groupName != null && groupName != 'All' && currentGroup != groupName) {
           continue;
         }

         String val = allRows[i].length > j ? allRows[i][j].toString().trim() : '';
         if (val.isNotEmpty) {
            submitted++;
         } else {
            missing++;
         }
      }

      assignments.add(ReportAssignment(
         name: taskName,
         submitted: submitted,
         missing: missing,
         deadline: deadline,
      ));
    }

    return assignments;
  }
}
