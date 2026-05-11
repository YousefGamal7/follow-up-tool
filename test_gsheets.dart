import 'package:gsheets/gsheets.dart';

const String credentials = r'''
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

const gradesId  = '1KpCOplQNw4C5ubyxlZcTGdLK4HszAujez7QjyEZfohM';
const followUpId = '1pHuK4Jk1YUVQjcMbpSU0cvKGitmb9QeJrVV81r3OwiE';
const sheetName = 'Yousef Gamal';

void main() async {
  final gsheets = GSheets(credentials);

  print('\n====== GRADES SHEET ======');
  final gradesSs = await gsheets.spreadsheet(gradesId);
  final gradesSheet = gradesSs.worksheetByTitle(sheetName)!;
  final gradesRows = await gradesSheet.values.allRows();

  // Find header row
  int gHeaderRow = -1;
  for (int i = 0; i < gradesRows.length && i < 10; i++) {
    if (gradesRows[i].isNotEmpty && gradesRows[i][0].toLowerCase().contains('gmail')) {
      gHeaderRow = i;
      break;
    }
  }
  print('Grades header row index: $gHeaderRow');
  if (gHeaderRow != -1) {
    print('Grades FULL header row:');
    for (int j = 0; j < gradesRows[gHeaderRow].length; j++) {
      print('  col $j = "${gradesRows[gHeaderRow][j]}"');
    }
    // Also print the row BEFORE the header (row 0 and 1 context)
    print('\nRow before header (row ${gHeaderRow - 1}):');
    if (gHeaderRow > 0) print('  ${gradesRows[gHeaderRow - 1]}');
    print('\nFirst student row (row ${gHeaderRow + 1}):');
    print('  ${gradesRows[gHeaderRow + 1]}');
  }

  print('\n====== FOLLOW-UP SHEET ======');
  final followSs = await gsheets.spreadsheet(followUpId);
  final followSheet = followSs.worksheetByTitle(sheetName);
  if (followSheet == null) {
    print('ERROR: Sheet "$sheetName" NOT FOUND in Follow-up spreadsheet!');
    print('Available sheets:');
    for (var s in followSs.sheets) { print('  - "${s.title}"'); }
    return;
  }
  final followRows = await followSheet.values.allRows();

  int fHeaderRow = -1;
  for (int i = 0; i < followRows.length && i < 10; i++) {
    if (followRows[i].isNotEmpty) {
      final first = followRows[i][0].toLowerCase().trim();
      if (first.contains('mail') || first.contains('email')) {
        fHeaderRow = i;
        break;
      }
    }
  }
  print('Follow-up header row index: $fHeaderRow');
  if (fHeaderRow != -1) {
    print('Follow-up headers: ${followRows[fHeaderRow]}');
    print('\nFirst 3 student emails from Follow-up:');
    for (int i = fHeaderRow + 1; i < fHeaderRow + 4 && i < followRows.length; i++) {
      print('  row $i email="${followRows[i][0]}"');
    }
  }

  // Check if any emails overlap
  print('\n====== EMAIL MATCH CHECK ======');
  if (gHeaderRow != -1 && fHeaderRow != -1) {
    final gradesEmails = <String>{};
    for (int i = gHeaderRow + 1; i < gradesRows.length; i++) {
      if (gradesRows[i].isNotEmpty) gradesEmails.add(gradesRows[i][0].toLowerCase().trim());
    }
    int matches = 0;
    for (int i = fHeaderRow + 1; i < followRows.length; i++) {
      if (followRows[i].isEmpty) continue;
      final fe = followRows[i][0].toLowerCase().trim();
      if (gradesEmails.contains(fe)) matches++;
    }
    print('Grades emails found: ${gradesEmails.length}');
    print('Follow-up rows: ${followRows.length - fHeaderRow - 1}');
    print('MATCHED emails: $matches');

    // Check column name matches
    print('\nFollow-up assignment columns:');
    for (int j = 0; j < followRows[fHeaderRow].length; j++) {
      print('  col $j = "${followRows[fHeaderRow][j]}"');
    }
    print('\nGrades assignment columns (from col 4+):');
    for (int j = 4; j < gradesRows[gHeaderRow].length; j++) {
      print('  col $j = "${gradesRows[gHeaderRow][j]}"');
    }
  }
}
