import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<void> generateAndSavePdf({
    required String title,
    required String content,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        header: (context) => pw.Text(
          title,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Text(content),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: "${title.replaceAll(' ', '_')}.pdf",
    );
  }
}
