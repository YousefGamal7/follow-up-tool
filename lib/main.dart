import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gsheets/gsheets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart'; // المكتبة الجديدة

void main() {
  runApp(const FinalWhatsAppApp());
}

class FinalWhatsAppApp extends StatelessWidget {
  const FinalWhatsAppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام متابعة الطلاب الذكي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF128C7E)),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      home: const DashboardScreen(),
    );
  }
}

class Student {
  final String name;
  final String phone;
  final String group;
  final String grade;
  final int missedCount;

  Student({
    required this.name,
    required this.phone,
    required this.group,
    required this.grade,
    required this.missedCount
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // بيانات الربط كما هي
  final String _credentials = r'''
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
  final String _spreadsheetId = '1aYwuForUA3dZxEJFA_SnZ1HKVYKosoTWPXo7z9lZqlc';
  final String _metaToken = '...';
  final String _phoneNumberId = '1002625639604062';

  String? selectedInstructor = 'Yousef Gamal';
  String? selectedGroup = 'الكل';
  String? selectedAssignment;
  String? selectedFilter = 'الكل';

  List<String> instructors = ['Ahmed Fyala', 'Abdelrahman Youssef', 'Ali Mohamed', 'Yousef Gamal', 'Rana Osama'];
  List<String> groups = ['الكل'];
  List<String> assignments = [];
  List<String> filters = ['الكل', 'المتأخرين فقط (late)', 'لم يتم التسليم (فارغ)', 'درجات أقل من 10', 'منذرين (فايتهم +6)'];

  List<Student> allStudents = [];
  List<Student> filteredStudents = [];
  List<Student> selectedStudents = [];
  bool isLoading = false;

  // --- متغيرات القوالب ---
  List<String> savedTemplates = [];
  String? selectedTemplate;
  final TextEditingController _templateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTemplates(); // تحميل الرسائل المحفوظة
    fetchDataFromSheets();
  }

  // --- دوال القوالب (Local Storage) ---
  Future<void> _loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedTemplates = prefs.getStringList('wa_templates') ?? [];
    });
  }

  Future<void> _saveTemplate() async {
    final text = _templateController.text.trim();
    if (text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    if (!savedTemplates.contains(text)) {
      savedTemplates.add(text);
      await prefs.setStringList('wa_templates', savedTemplates);
      setState(() {
        selectedTemplate = text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الرسالة بنجاح!'), backgroundColor: Colors.green),
      );
    }
  }

  // توليد الرسالة المخصصة للطالب
  String _generateMessage(Student s) {
    String template = _templateController.text;
    if (template.isEmpty) {
      template = "أهلاً يا [الاسم]، تقييمك هو [الدرجة]، وفايتك [الغياب] تاسكات."; // رسالة افتراضية
    }
    return template
        .replaceAll('[الاسم]', s.name)
        .replaceAll('[الدرجة]', s.grade.isEmpty ? 'لم يسلم' : s.grade)
        .replaceAll('[الغياب]', s.missedCount.toString());
  }

  // دالة فتح واتساب ويب بالرسالة المخصصة
  Future<void> launchWhatsAppWeb(Student s) async {
    final String msg = _generateMessage(s);
    final String url = "https://web.whatsapp.com/send?phone=${s.phone}&text=${Uri.encodeComponent(msg)}";
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> sendWhatsAppMessage(Student student) async {
    // كود الـ API (لاحظ إن الـ API بيستخدم Template معتمد من Meta، لو عايز تغير الرسالة لازم توافق عليها في Meta الأول)
    // ...
  }

  Future<void> fetchDataFromSheets() async {
    setState(() { isLoading = true; selectedStudents = []; });
    try {
      final gsheets = GSheets(_credentials);
      final ss = await gsheets.spreadsheet(_spreadsheetId);
      final sheet = ss.worksheetByTitle(selectedInstructor!);
      if (sheet == null) return;

      final allRows = await sheet.values.allRows();
      List<Student> tempList = [];
      Set<String> foundGroups = {'الكل'};
      List<String> foundAssignments = [];

      int headerRowIndex = -1;
      int firstTaskColIndex = -1;

      for (int i = 0; i < 15 && i < allRows.length; i++) {
        for (int j = 0; j < allRows[i].length; j++) {
          if (allRows[i][j].toString().contains("(if condition)")) {
            headerRowIndex = i;
            firstTaskColIndex = j;
            break;
          }
        }
        if (headerRowIndex != -1) break;
      }

      if (headerRowIndex == -1) { setState(() => isLoading = false); return; }

      var headerRow = allRows[headerRowIndex];
      for (int j = firstTaskColIndex; j < headerRow.length; j++) {
        String taskName = headerRow[j].toString().trim();
        if (taskName.isNotEmpty && !taskName.contains("Full Mark")) {
          foundAssignments.add(taskName);
        }
      }

      if (selectedAssignment == null || !foundAssignments.contains(selectedAssignment)) {
        selectedAssignment = foundAssignments.isNotEmpty ? foundAssignments[0] : null;
      }

      int targetTaskColIndex = firstTaskColIndex;
      if (selectedAssignment != null) {
        for (int j = firstTaskColIndex; j < headerRow.length; j++) {
          if (headerRow[j].toString().trim() == selectedAssignment) {
            targetTaskColIndex = j; break;
          }
        }
      }

      String currentGroup = "بدون جروب";
      for (int i = headerRowIndex + 1; i < allRows.length; i++) {
        var row = allRows[i];
        if (row.isEmpty) continue;
        String firstCell = row[0].toString().trim();

        if (firstCell.toLowerCase().contains("group")) {
          currentGroup = firstCell; foundGroups.add(currentGroup); continue;
        }

        if (row.length > 2 && row[1].toString().isNotEmpty && !firstCell.contains("Gmail")) {
          String name = row[1].toString();
          String rawPhone = row[2].toString();
          String currentGrade = row.length > targetTaskColIndex ? row[targetTaskColIndex].toString() : "";

          int misses = 0;
          for (int k = firstTaskColIndex; k < row.length; k++) {
            String gradeInRow = row[k].toString().toLowerCase().trim();
            if (gradeInRow == "" || gradeInRow == "late") {
              misses++;
            }
          }

          String phone = _processPhone(rawPhone);
          if (phone.isNotEmpty) {
            tempList.add(Student(
                name: name, phone: phone, group: currentGroup, grade: currentGrade, missedCount: misses
            ));
          }
        }
      }

      setState(() {
        allStudents = tempList;
        groups = foundGroups.toList();
        assignments = foundAssignments;
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e"); setState(() => isLoading = false);
    }
  }

  String _processPhone(String raw) {
    String first = raw.split(RegExp(r'[-/|]'))[0].replaceAll(RegExp(r'\D'), '');
    if (first.isEmpty) return "";
    if (first.startsWith('0')) return '2$first';
    if (first.startsWith('1')) return '20$first';
    return first;
  }

  void _applyFilters() {
    setState(() {
      filteredStudents = allStudents.where((s) {
        bool groupMatch = selectedGroup == 'الكل' || s.group == selectedGroup;
        bool filterMatch = true;
        if (selectedFilter == 'المتأخرين فقط (late)') filterMatch = s.grade.toLowerCase().contains('late');
        else if (selectedFilter == 'لم يتم التسليم (فارغ)') filterMatch = s.grade.trim().isEmpty;
        else if (selectedFilter == 'درجات أقل من 10') {
          double? g = double.tryParse(s.grade);
          filterMatch = g != null && g < 10;
        }
        else if (selectedFilter == 'منذرين (فايتهم +6)') filterMatch = s.missedCount > 6;

        return groupMatch && filterMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('نظام إدارة الطلاب الاحترافي'), backgroundColor: const Color(0xFF128C7E), foregroundColor: Colors.white),
      body: Row(
        children: [
          // شريط الفلاتر والرسائل
          Container(
            width: 320,
            decoration: BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: Colors.grey[300]!))),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildDrop("المدرس", instructors, selectedInstructor, (v) { selectedInstructor = v; fetchDataFromSheets(); }),
                      _buildDrop("الجروب", groups, selectedGroup, (v) { selectedGroup = v; _applyFilters(); }),
                      _buildDrop("التاسك", assignments, selectedAssignment, (v) { selectedAssignment = v; fetchDataFromSheets(); }),
                      _buildDrop("الفلترة", filters, selectedFilter, (v) { selectedFilter = v; _applyFilters(); }),

                      const Divider(height: 30, thickness: 2),
                      const Text("📝 صياغة الرسالة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
                      const SizedBox(height: 10),

                      // اختيار رسالة محفوظة
                      if (savedTemplates.isNotEmpty)
                        DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('اختر رسالة محفوظة...'),
                          value: savedTemplates.contains(selectedTemplate) ? selectedTemplate : null,
                          items: savedTemplates.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (v) {
                            setState(() {
                              selectedTemplate = v;
                              _templateController.text = v ?? '';
                            });
                          },
                        ),
                      const SizedBox(height: 10),

                      // مكان كتابة الرسالة
                      TextField(
                        controller: _templateController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: "اكتب رسالتك هنا...\nمثال: يا [الاسم] فايتك [الغياب] مهام",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text("استخدم: [الاسم], [الدرجة], [الغياب]", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 10),

                      // زر الحفظ
                      ElevatedButton.icon(
                        onPressed: _saveTemplate,
                        icon: const Icon(Icons.save),
                        label: const Text('حفظ الرسالة كقالب'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ),
                // زرار الإرسال تحت خالص
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("${selectedStudents.length} طلاب محددين", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: isLoading || selectedStudents.isEmpty ? null : () async {
                          // كود الإرسال الآلي
                        },
                        icon: const Icon(Icons.send),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                        label: const Text('إرسال آلي للمحددين'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          // جدول البيانات
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: DataTable(
                showCheckboxColumn: true,
                headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                columns: const [
                  DataColumn(label: Text('الاسم')),
                  DataColumn(label: Text('الفايت')),
                  DataColumn(label: Text('الدرجة')),
                  DataColumn(label: Text('إرسال واتساب')),
                ],
                rows: filteredStudents.map((s) {
                  final isSelected = selectedStudents.contains(s);
                  final isWarning = s.missedCount > 6;
                  return DataRow(
                    selected: isSelected,
                    color: isWarning ? WidgetStateProperty.all(Colors.red[50]) : null,
                    onSelectChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) selectedStudents.add(s);
                        else selectedStudents.remove(s);
                      });
                    },
                    cells: [
                      DataCell(Text(s.name, style: TextStyle(fontWeight: isWarning ? FontWeight.bold : FontWeight.normal))),
                      DataCell(Text("${s.missedCount}", style: TextStyle(color: isWarning ? Colors.red : Colors.black))),
                      DataCell(Text(s.grade, style: TextStyle(color: s.grade.contains('late') ? Colors.red : Colors.green, fontWeight: FontWeight.bold))),
                      DataCell(
                        ElevatedButton.icon(
                          onPressed: () => launchWhatsAppWeb(s), // التعديل هنا ليرسل الكائن كله
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('رسالة'),
                          style: ElevatedButton.styleFrom(backgroundColor: isWarning ? Colors.red : Colors.blue, foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrop(String label, List<String> items, String? val, Function(String?) onChange) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
      const SizedBox(height: 5),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
              isExpanded: true,
              value: (items.contains(val)) ? val : (items.isNotEmpty ? items[0] : null),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
              onChanged: onChange
          ),
        ),
      ),
      const SizedBox(height: 15),
    ]);
  }
}