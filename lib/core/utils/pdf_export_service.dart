import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../domain/entities/loan_entity.dart';
import '../../../domain/entities/book_entity.dart';

class PdfExportService {
  /// Export a list of loans as PDF
  static Future<void> exportLoansAsPdf(List<LoanEntity> loans, String title) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            text: title,
          ),
          pw.Paragraph(text: 'Généré le: ${_formatDate(DateTime.now())}'),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            context: context,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
            cellHeight: 30,
            cellStyle: const pw.TextStyle(fontSize: 10),
            headers: ['Livre', 'Emprunteur', 'Date emprunt', 'Date retour', 'Statut'],
            data: loans.map((loan) => [
              loan.bookTitle,
              loan.userName,
              _formatDate(loan.borrowDate),
              _formatDate(loan.dueDate),
              _getStatusLabel(loan.status),
            ]).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Paragraph(text: 'Total: ${loans.length} emprunts'),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// Export a single book as PDF report
  static Future<void> exportBookReport(BookEntity book) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, text: 'Fiche Livre'),
            pw.Divider(),
            pw.SizedBox(height: 10),
            _buildInfoRow('Titre:', book.title),
            _buildInfoRow('Auteur:', book.author),
            _buildInfoRow('ISBN:', book.isbn),
            _buildInfoRow('Catégorie:', book.categoryName),
            _buildInfoRow('Langue:', book.language),
            _buildInfoRow('Pages:', '${book.pages}'),
            _buildInfoRow('Date de publication:', book.publishDate != null ? _formatDate(book.publishDate!) : 'Non renseigné'),
            _buildInfoRow('Disponibilité:', book.available ? 'Disponible (${book.availableCopies} copies)' : 'Indisponible'),
            _buildInfoRow('Note:', '${book.rating.toStringAsFixed(1)} / 5.0 (${book.ratingCount} avis)'),
            _buildInfoRow('Likes:', '${book.likes}'),
            _buildInfoRow('Dislikes:', '${book.dislikes}'),
            pw.SizedBox(height: 20),
            pw.Header(level: 1, text: 'Description'),
            pw.Paragraph(text: book.description),
            pw.SizedBox(height: 20),
            pw.Paragraph(text: 'Généré le: ${_formatDate(DateTime.now())}'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// Export user profile as PDF
  static Future<void> exportUserProfile({
    required String fullName,
    required String email,
    required String? phone,
    required String? studyLevel,
    required DateTime registrationDate,
    required int points,
    required List<String> badges,
    required int totalLoans,
    required int activeLoans,
    required int favoritesCount,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, text: 'Profil Utilisateur'),
            pw.Divider(),
            pw.SizedBox(height: 10),
            _buildInfoRow('Nom:', fullName),
            _buildInfoRow('Email:', email),
            _buildInfoRow('Téléphone:', phone ?? 'Non renseigné'),
            _buildInfoRow('Niveau d\'études:', studyLevel ?? 'Non renseigné'),
            _buildInfoRow('Membre depuis:', _formatDate(registrationDate)),
            pw.SizedBox(height: 15),
            pw.Header(level: 1, text: 'Statistiques'),
            _buildInfoRow('Points:', '$points'),
            _buildInfoRow('Badges:', badges.isEmpty ? 'Aucun' : badges.join(', ')),
            _buildInfoRow('Total emprunts:', '$totalLoans'),
            _buildInfoRow('Emprunts actifs:', '$activeLoans'),
            _buildInfoRow('Favoris:', '$favoritesCount'),
            pw.SizedBox(height: 20),
            pw.Paragraph(text: 'Généré le: ${_formatDate(DateTime.now())}'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String _getStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'En attente';
      case 'approved': return 'Approuvé';
      case 'rejected': return 'Refusé';
      case 'returned': return 'Retourné';
      default: return status;
    }
  }
}
