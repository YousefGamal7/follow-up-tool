import 'dart:typed_data';

import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/report_models.dart';

class PdfService {
  static Future<void> generateAndShareTeamReport({
    required Map<String, List<ReportAssignment>> allGroupAssignments,
    required List<WorkshopSession> workshops,
    required List<BranchAttendance> attendance,
  }) async {
    final pdf = pw.Document();

    pw.ImageProvider? logoImage;
    try {
      final ByteData logoData = await rootBundle.load('assets/images/route.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      logoImage = pw.MemoryImage(logoBytes);
    } catch (e) {
      print('error = $e');
      // Ignore if logo not found
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          final List<pw.Widget> content = [];

          content.addAll(_buildHeader(logoImage));
          content.add(pw.SizedBox(height: 20));

          for (var entry in allGroupAssignments.entries) {
            content.add(
              pw.Text(
                'Group: ${entry.key}',
                style: pw.TextStyle(
                  fontSize: 16,
                  color: PdfColors.blue800,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
            content.add(pw.SizedBox(height: 8));
            content.addAll(_buildAssignmentsSection(entry.value));
            content.add(pw.SizedBox(height: 20));
          }

          content.addAll(_buildWorkshopsSection(workshops));
          if (workshops.isNotEmpty) {
            content.add(pw.SizedBox(height: 20));
          }

          content.addAll(_buildAttendanceSection(attendance));

          return content;
        },
      ),
    );

    final bytes = await pdf.save();
    
    final dateStr = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    final fileName = 'yousef gamal report $dateStr.pdf';

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        final filePath = '${docsDir.path}${Platform.pathSeparator}$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        // On desktop, saving directly to Documents without a prompt is preferred by the user.
      } catch (e) {
        // Fallback to share/save dialog
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      }
    } else {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    }
  }

  static List<pw.Widget> _buildHeader(pw.ImageProvider? logo) {
    return [
      if (logo != null) pw.Center(child: pw.Image(logo, height: 60)),
      if (logo != null) pw.SizedBox(height: 16),
      pw.Center(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'Advanced Team Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Generated on: ${DateTime.now().toString().split('.')[0]}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Divider(),
    ];
  }

  static List<pw.Widget> _buildAssignmentsSection(
    List<ReportAssignment> assignments,
  ) {
    if (assignments.isEmpty) {
      return [
        pw.Text(
          'Assignments Status',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text('No active assignments.'),
      ];
    }

    return [
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
        headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
        rowDecoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
        ),
        cellAlignment: pw.Alignment.centerLeft,
      ),
    ];
  }

  static List<pw.Widget> _buildWorkshopsSection(
    List<WorkshopSession> workshops,
  ) {
    if (workshops.isEmpty) return [];

    return [
      pw.Text(
        'Workshops & Sessions',
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
      ),
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
        headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
        rowDecoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
        ),
        cellAlignment: pw.Alignment.centerLeft,
      ),
    ];
  }

  static List<pw.Widget> _buildAttendanceSection(
    List<BranchAttendance> attendance,
  ) {
    if (attendance.isEmpty) return [];

    return [
      pw.Text(
        'Branch Attendance',
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 8),
      pw.TableHelper.fromTextArray(
        context: null,
        headers: ['Week', 'Date', 'Day', 'Time Range'],
        data: attendance.map((a) {
          return [a.week, a.date, a.day, '${a.arriveTime} - ${a.endTime}'];
        }).toList(),
        headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        headerDecoration: const pw.BoxDecoration(
          color: PdfColors.deepPurple800,
        ),
        rowDecoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
        ),
        cellAlignment: pw.Alignment.centerLeft,
      ),
    ];
  }
}
