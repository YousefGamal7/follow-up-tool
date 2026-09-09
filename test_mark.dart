import 'package:send_message/services/multi_sheet_sync_service.dart';

void main() async {
  print('=== Testing markAsFollowedUp in C19 ===');
  final service = MultiSheetSyncService();
  service.setSpreadsheetIds(
    '1KpCOplQNw4C5ubyxlZcTGdLK4HszAujez7QjyEZfohM',
    '1pHuK4Jk1YUVQjcMbpSU0cvKGitmb9QeJrVV81r3OwiE',
  );
  try {
    await service.markAsFollowedUp(
      email: 'Mazintarek3@gmail.com',
      messageSent: 'Test follow up message',
      sheetName: 'Yousef Gamal',
      assignments: ['Assignment 1'],
    );
    print('SUCCESS: C19 markAsFollowedUp completed!');
  } catch (e, st) {
    print('C19 ERROR: $e');
    print(st);
  }

  print('\n=== Testing markAsFollowedUp in C20 ===');
  service.setSpreadsheetIds(
    '1uA-iN3wOPr9NMZWKCWz6dYQzl0Cq7xHimHdZAjQpMQs',
    '1hDQXRgKQ0XHwiEx9bBmCXsaIvjcQWOVhP8SN5tL0akM',
  );
  try {
    await service.markAsFollowedUp(
      email: 'Mazintarek3@gmail.com',
      messageSent: 'Test follow up message',
      sheetName: 'Yousef Gamal',
      assignments: ['Assignment 1'],
    );
    print('SUCCESS: C20 markAsFollowedUp completed!');
  } catch (e, st) {
    print('C20 ERROR: $e');
    print(st);
  }
}
