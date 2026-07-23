class CycleConfig {
  final String name;
  final String gradesSpreadsheetId;
  final String followUpSpreadsheetId;

  const CycleConfig({
    required this.name,
    required this.gradesSpreadsheetId,
    required this.followUpSpreadsheetId,
  });
}

const List<CycleConfig> availableCycles = [
  CycleConfig(
    name: 'C19',
    gradesSpreadsheetId: '1KpCOplQNw4C5ubyxlZcTGdLK4HszAujez7QjyEZfohM',
    followUpSpreadsheetId: '1pHuK4Jk1YUVQjcMbpSU0cvKGitmb9QeJrVV81r3OwiE',
  ),
  CycleConfig(
    name: 'C20',
    gradesSpreadsheetId: '1uA-iN3wOPr9NMZWKCWz6dYQzl0Cq7xHimHdZAjQpMQs',
    followUpSpreadsheetId: '1hDQXRgKQ0XHwiEx9bBmCXsaIvjcQWOVhP8SN5tL0akM',
  ),
];
