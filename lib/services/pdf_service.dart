import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class PdfService {
  static Future<void> exportToPdf(List<TaskGroup> groups, String username) async {
    final pdf = pw.Document();
    final dateStr = DateFormat("d MMMM yyyy, HH:mm").format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "JUST JEJE",
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "To-Do List & Productivity Summary",
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      "User: $username",
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      dateStr,
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.blue800),
            pw.SizedBox(height: 16),

            // Groups
            if (groups.isEmpty)
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(40),
                  child: pw.Text("Belum ada daftar tugas.", style: const pw.TextStyle(fontSize: 14)),
                ),
              )
            else
              ...groups.map((group) {
                final completedCount = group.tasks.where((t) => t.completed).length;
                final totalCount = group.tasks.length;

                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 20),
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            group.title,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey900,
                            ),
                          ),
                          pw.Text(
                            "$completedCount / $totalCount Selesai",
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: completedCount == totalCount && totalCount > 0
                                  ? PdfColors.green700
                                  : PdfColors.blue700,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Divider(color: PdfColors.grey200),
                      pw.SizedBox(height: 6),
                      if (group.tasks.isEmpty)
                        pw.Text(
                          "Tidak ada tugas di daftar ini.",
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                        )
                      else
                        ...group.tasks.map((task) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  width: 14,
                                  height: 14,
                                  margin: const pw.EdgeInsets.only(top: 2, right: 8),
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                      color: task.completed ? PdfColors.green600 : PdfColors.grey500,
                                      width: 1.5,
                                    ),
                                    borderRadius: pw.BorderRadius.circular(3),
                                    color: task.completed ? PdfColors.green100 : null,
                                  ),
                                  child: task.completed
                                      ? pw.Center(
                                          child: pw.Text("v",
                                              style: pw.TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: pw.FontWeight.bold,
                                                  color: PdfColors.green800)))
                                      : null,
                                ),
                                pw.Expanded(
                                  child: pw.Text(
                                    task.text,
                                    style: pw.TextStyle(
                                      fontSize: 11,
                                      color: task.completed ? PdfColors.grey500 : PdfColors.grey900,
                                      decoration: task.completed ? pw.TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                );
              }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "JUST_JEJE_${username}_Tasks.pdf",
    );
  }
}
