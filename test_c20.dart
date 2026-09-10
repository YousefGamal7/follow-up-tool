import 'package:gsheets/gsheets.dart';

void main() async {
  final credentials = r'''
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
  
  final gsheets = GSheets(credentials);
  try {
    final ss = await gsheets.spreadsheet('1uA-iN3wOPr9NMZWKCWz6dYQzl0Cq7xHimHdZAjQpMQs');
    final sheet = ss.worksheetByTitle('Yousef Gamal');
    if (sheet == null) {
      print('Sheet not found');
      return;
    }
    
    final allRows = await sheet.values.allRows();
    if (allRows.isEmpty) {
      print('Sheet is empty');
      return;
    }
    
    print('Fetched ${allRows.length} rows.');
    
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
    
    print('Header row index: $headerRowIndex, First task col: $firstTaskColIndex');
    
    Set<String> foundGroups = {'All'};
    for (int i = headerRowIndex + 1; i < allRows.length; i++) {
        var row = allRows[i];
        if (row.isEmpty) continue;
        
        String rowText = row.take(3).join(" ").toLowerCase();

        if (rowText.contains("group")) {
          String currentGroup = row.take(3).firstWhere((c) => c.toString().toLowerCase().contains("group"), orElse: () => row[0]).toString().trim();
          foundGroups.add(currentGroup);
          continue;
        }
    }
    
    print('Found groups: $foundGroups');
  } catch (e) {
    print('Error: $e');
  }
}
