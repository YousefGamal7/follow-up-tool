import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

void main() {
  final chart = pw.Chart(
    grid: pw.PieGrid(),
    datasets: [
      pw.PieDataSet(value: 50, color: PdfColors.blue, legend: 'Android'),
      pw.PieDataSet(value: 30, color: PdfColors.orange, legend: 'React Native'),
      pw.PieDataSet(value: 20, color: PdfColors.red, legend: 'iOS'),
    ],
  );
  print('Chart created successfully');
}
