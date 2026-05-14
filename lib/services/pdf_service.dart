import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/report_models.dart';

class PdfService {
  static Future<void> generateAndPrintTeamReport({
    required Map<String, List<ReportAssignment>> allGroupAssignments,
    required List<WorkshopSession> workshops,
    required List<BranchAttendance> attendance,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          final assignmentWidgets = allGroupAssignments.entries.map((entry) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Group: ${entry.key}', style: pw.TextStyle(fontSize: 16, color: PdfColors.blue800, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                _buildAssignmentsSection(entry.value),
                pw.SizedBox(height: 16),
              ],
            );
          }).toList();

          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            ...assignmentWidgets,
            pw.SizedBox(height: 20),
            _buildWorkshopsSection(workshops),
            pw.SizedBox(height: 20),
            _buildAttendanceSection(attendance),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text('Advanced Team Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Generated on: ${DateTime.now().toString().split('.')[0]}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildAssignmentsSection(List<ReportAssignment> assignments) {
    if (assignments.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Assignments', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('No active assignments.'),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Assignments Status', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          context: null,
          headers: ['Assignment Name', 'Deadline', 'Submitted', 'Missing', 'Progress'],
          data: assignments.map((a) {
            final total = a.submitted + a.missing;
            final progress = total > 0 ? (a.submitted / total) * 100 : 0.0;
            return [
              a.name,
              a.deadline ?? 'N/A',
              a.submitted.toString(),
              a.missing.toString(),
              '${progress.toStringAsFixed(1)}%',
            ];
          }).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
          rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ],
    );
  }

  static pw.Widget _buildWorkshopsSection(List<WorkshopSession> workshops) {
    if (workshops.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Workshops & Sessions', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          context: null,
          headers: ['Topic', 'Date', 'Time', 'Attendance'],
          data: workshops.map((w) {
            return [
              w.topic,
              w.date,
              '${w.startTime} - ${w.endTime}',
              w.attendance.toString(),
            ];
          }).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
          rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ],
    );
  }

  static pw.Widget _buildAttendanceSection(List<BranchAttendance> attendance) {
    if (attendance.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Branch Attendance', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          context: null,
          headers: ['Week', 'Date', 'Day', 'Time Range'],
          data: attendance.map((a) {
            return [
              a.week,
              a.date,
              a.day,
              '${a.arriveTime} - ${a.endTime}',
            ];
          }).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple800),
          rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ],
    );
  }
}
