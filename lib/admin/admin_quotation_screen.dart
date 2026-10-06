import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../customer/services/booking_service.dart';
import '../customer/theme/app_theme.dart';
import 'admin_theme.dart';

class AdminQuotationScreen extends StatefulWidget {
  const AdminQuotationScreen({
    super.key,
    required this.request,
    this.sendOnly = false,
  });
  final BookingRequest request;
  final bool sendOnly;

  @override
  State<AdminQuotationScreen> createState() => _AdminQuotationScreenState();
}

class _AdminQuotationScreenState extends State<AdminQuotationScreen> {
  late final List<Map<String, dynamic>> items;
  late final TextEditingController notesCtrl;
  late final TextEditingController validityCtrl;
  late final TextEditingController adminNameCtrl;
  final ValueNotifier<double> totalNotifier = ValueNotifier<double>(0);
  bool _saving = false;
  String _savingMessage = 'Preparing...';

  @override
  void initState() {
    super.initState();
    final existingQ = widget.request.quotation;
    final existingEstimate = widget.request.costEstimate;
    final source = existingQ != null && existingQ.breakdown.isNotEmpty
        ? existingQ.breakdown
        : existingEstimate != null && existingEstimate.breakdown.isNotEmpty
        ? existingEstimate.breakdown
        : [
            {'label': 'Service / Labor', 'quantity': 1, 'unitPrice': 150.0},
            {'label': 'Materials', 'quantity': 1, 'unitPrice': 0.0},
          ];
    items = List<Map<String, dynamic>>.from(
      source.map((e) => Map<String, dynamic>.from(e)),
    );
    notesCtrl = TextEditingController(
      text: (existingQ?.notes ?? '').isNotEmpty ? existingQ!.notes : 'All prices are in AED. Services include standard warranty parts and labor.',
    );
    validityCtrl = TextEditingController(
      text: (existingQ?.validityDays ?? 14).toString(),
    );
    adminNameCtrl = TextEditingController(
      text:
          (existingQ?.adminName ??
                  FirebaseAuth.instance.currentUser?.displayName ??
                  'Admin')
              .trim(),
    );
    recalc();
  }

  @override
  void dispose() {
    notesCtrl.dispose();
    validityCtrl.dispose();
    adminNameCtrl.dispose();
    totalNotifier.dispose();
    super.dispose();
  }

  void recalc() {
    double t = 0;
    for (final it in items) {
      final qty = (it['quantity'] as num?)?.toDouble() ?? 1;
      final price =
          (it['unitPrice'] as num?)?.toDouble() ??
          (it['amount'] as num?)?.toDouble() ??
          0;
      t += qty * price;
    }
    totalNotifier.value = t;
  }

  String _fmt(num v) {
    final a = v.toDouble();
    final whole = a.truncate();
    final dec = ((a - whole) * 100).round().toString().padLeft(2, '0');
    return 'AED ${whole.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m.group(1)},')}.$dec';
  }

  Future<pw.Document> _buildPdf(Quotation q, BookingRequest req) async {
    final doc = pw.Document();
    final validUntil = DateTime.now().add(Duration(days: q.validityDays));
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
    final validStr =
        '${validUntil.day.toString().padLeft(2, '0')}/'
        '${validUntil.month.toString().padLeft(2, '0')}/${validUntil.year}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(26),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [PdfColors.blueGrey800, PdfColors.indigo900],
              begin: pw.Alignment.centerLeft,
              end: pw.Alignment.centerRight,
            ),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'AL-TAQWA HVAC SERVICES',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber100,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Professional Heating, Ventilation & Air Conditioning',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.blue50,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'QUOTATION',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.amber200,
                    ),
                  ),
                  pw.Text(
                    q.quotationNumber,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Date: $dateStr',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.blue50),
                  ),
                ],
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Al-Taqwa HVAC  |  www.altaqwa-hvac.example  |  +1 (555) 010-0000',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 22),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'QUOTED FOR:',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey600,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        q.customerName.isEmpty
                            ? 'Valued Customer'
                            : q.customerName,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo900,
                        ),
                      ),
                      if (req.phone.isNotEmpty) ...[
                        pw.SizedBox(height: 3),
                        pw.Text(
                          req.phone,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                      if (req.address.isNotEmpty) ...[
                        pw.SizedBox(height: 3),
                        pw.Text(
                          req.address,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber50,
                    borderRadius: pw.BorderRadius.circular(10),
                    border: pw.Border.all(color: PdfColors.amber300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SERVICE',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.amber700,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        q.serviceName.isEmpty ? req.serviceName : q.serviceName,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.brown900,
                        ),
                      ),
                      pw.SizedBox(height: 14),
                      pw.Text(
                        'VALID UNTIL:',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.amber700,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        validStr,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.amber900,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'STATUS:  ${q.status.toUpperCase()}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 22),
          pw.Text(
            'BREAKDOWN OF COSTS',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.indigo900,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.7),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 10,
            ),
            headerDecoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [PdfColors.blueGrey700, PdfColors.indigo800],
              ),
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.8),
              4: const pw.FlexColumnWidth(2),
            },
            headers: const ['Item / Description', 'Qty', 'Unit Rate', 'Amount'],
            data: [
              ...q.breakdown.map((it) {
                final label = (it['label'] as String?) ?? 'Item';
                final qty = (it['quantity'] as num?)?.toDouble() ?? 1;
                final rate =
                    (it['unitPrice'] as num?)?.toDouble() ??
                    (it['amount'] as num?)?.toDouble() ??
                    0;
                final amt = (it['amount'] as num?)?.toDouble() ?? (qty * rate);
                return [
                  label,
                  qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 2),
                  _fmt(rate),
                  _fmt(amt),
                ];
              }),
              ['', '', 'TOTAL', _fmt(q.totalAmount)],
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(12),
              width: 220,
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [PdfColors.amber100, PdfColors.amber200],
                ),
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColors.amber400),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'TOTAL QUOTED AMOUNT',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.amber800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    _fmt(q.totalAmount),
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.brown900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (q.notes.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'NOTES & TERMS',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo900,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    q.notes,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      height: 1.45,
                      color: PdfColors.grey800,
                    ),
                  ),
                ],
              ),
            ),
          ],
          pw.SizedBox(height: 34),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SUPERVISOR / COST ESTIMATE',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey500,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      width: 180,
                      height: 1,
                      color: PdfColors.grey400,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      req.costEstimate?.supervisorName ?? '',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'AUTHORIZED SIGNATURE (ADMIN)',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey500,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      width: 220,
                      height: 1,
                      color: PdfColors.grey400,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      q.adminName,
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Al-Taqwa HVAC Management',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return doc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AdminGradientAppBar(
        title: widget.sendOnly ? 'Send Quotation' : 'Create Quotation',
        subtitle: widget.sendOnly
            ? 'Review the quotation and send its PDF to the customer.'
            : 'Finalize pricing, save, and generate a PDF.',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF334155)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: goldLight.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: goldLight,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.request.customerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.request.serviceName,
                                style: const TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quotation Line Items',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Add, remove, or edit line items to finalize the quotation.',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    'Item / Description',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                SizedBox(
                                  width: 72,
                                  child: Text(
                                    'Qty',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    'Unit \$',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                SizedBox(
                                  width: 96,
                                  child: Text(
                                    'Amount',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                SizedBox(width: 36),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 6),
                          ...items.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final it = entry.value;
                            final labelCtrl = TextEditingController(
                              text: (it['label'] as String?) ?? '',
                            );
                            final qtyNum =
                                (it['quantity'] as num?)?.toDouble() ?? 1;
                            final priceNum =
                                (it['unitPrice'] as num?)?.toDouble() ??
                                (it['amount'] as num?)?.toDouble() ??
                                0;
                            final qtyCtrl = TextEditingController(
                              text: qtyNum.toString(),
                            );
                            final priceCtrl = TextEditingController(
                              text: priceNum.toStringAsFixed(2),
                            );
                            final lineAmount =
                                (it['amount'] as num?)?.toDouble() ??
                                qtyNum * priceNum;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: TextField(
                                      controller: labelCtrl,
                                      onChanged: (v) {
                                        items[idx]['label'] = v.trim();
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Item description',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 12,
                                        ),
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: navy,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 72,
                                    child: TextField(
                                      controller: qtyCtrl,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      onChanged: (v) {
                                        final n = num.tryParse(v) ?? 0;
                                        items[idx]['quantity'] = n.toDouble();
                                        recalc();
                                        setState(() {});
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Qty',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 12,
                                        ),
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: navy,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: priceCtrl,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      onChanged: (v) {
                                        final n = num.tryParse(v) ?? 0;
                                        items[idx]['unitPrice'] = n.toDouble();
                                        recalc();
                                        setState(() {});
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Unit \$',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 12,
                                        ),
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: navy,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 96,
                                    child: Text(
                                      _fmt(lineAmount),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: navy,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 36,
                                    child: IconButton(
                                      onPressed: () {
                                        if (items.length > 1) {
                                          items.removeAt(idx);
                                          recalc();
                                          setState(() {});
                                        }
                                      },
                                      style: IconButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFDC2626),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                items.add({
                                  'label': '',
                                  'quantity': 1,
                                  'unitPrice': 0.0,
                                });
                                setState(() {});
                              },
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text(
                                'Add line item',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          ValueListenableBuilder<double>(
                            valueListenable: totalNotifier,
                            builder: (_, total, __) => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFF3B0),
                                    Color(0xFFFFE082),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFF0C419),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'QUOTATION TOTAL',
                                    style: TextStyle(
                                      color: navy,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _fmt(total),
                                    style: const TextStyle(
                                      color: Color(0xFFB45309),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Admin / Prepared by',
                                      style: TextStyle(
                                        color: navy,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: adminNameCtrl,
                                      decoration: InputDecoration(
                                        hintText: 'Admin name',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 12,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: navy,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              SizedBox(
                                width: 120,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Validity (days)',
                                      style: TextStyle(
                                        color: navy,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: validityCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: '14',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: navy,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Notes / Terms & Conditions',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: notesCtrl,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Enter terms, warranty info, payment terms, etc.',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                            style: const TextStyle(
                              color: navy,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _saving
                                      ? null
                                      : () => Navigator.pop(context, false),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: FilledButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : () async {
                                          final cleaned = items
                                              .where(
                                                (i) =>
                                                    ((i['label'] as String?) ??
                                                            '')
                                                        .trim()
                                                        .isNotEmpty,
                                              )
                                              .toList();
                                          if (cleaned.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Add at least one line item.',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          double t = 0;
                                          for (final it in cleaned) {
                                            final qty =
                                                (it['quantity'] as num?)
                                                    ?.toDouble() ??
                                                1;
                                            final p =
                                                (it['unitPrice'] as num?)
                                                    ?.toDouble() ??
                                                0;
                                            it['amount'] = qty * p;
                                            t += qty * p;
                                          }
                                          final admin =
                                              adminNameCtrl.text.trim().isEmpty
                                              ? 'Admin'
                                              : adminNameCtrl.text.trim();
                                          final valid =
                                              int.tryParse(
                                                validityCtrl.text.trim(),
                                              ) ??
                                              14;
                                          setState(() {
                                            _saving = true;
                                            _savingMessage =
                                                'Generating quotation PDF...';
                                          });
                                          try {
                                            final user = FirebaseAuth
                                                .instance
                                                .currentUser;
                                            final existing =
                                                widget.request.quotation;
                                            final Quotation quote;
                                            if (widget.sendOnly) {
                                              if (existing == null) {
                                                throw StateError(
                                                  'Generate the quotation before sending it.',
                                                );
                                              }
                                              quote = Quotation(
                                                totalAmount: t,
                                                breakdown: cleaned,
                                                quotationNumber:
                                                    existing.quotationNumber,
                                                adminName: admin,
                                                adminUid: user?.uid,
                                                createdAt: existing.createdAt,
                                                customerName: widget
                                                    .request
                                                    .customerName,
                                                serviceName: widget
                                                    .request
                                                    .serviceName,
                                                notes: notesCtrl.text.trim(),
                                                validityDays: valid,
                                                quotationId:
                                                    existing.quotationId,
                                                requestId: widget.request.id,
                                                customerUid:
                                                    widget.request.customerUid ??
                                                    '',
                                              );
                                            } else {
                                              quote = await BookingService()
                                                  .createQuotation(
                                                    requestId:
                                                        widget.request.id,
                                                    totalAmount: t,
                                                    breakdown: cleaned,
                                                    adminName: admin,
                                                    adminUid: user?.uid,
                                                    customerName: widget
                                                        .request
                                                        .customerName,
                                                    serviceName: widget
                                                        .request
                                                        .serviceName,
                                                    notes: notesCtrl.text
                                                        .trim(),
                                                    validityDays: valid,
                                                    status: 'draft',
                                                    quotationId:
                                                        existing?.quotationId ??
                                                        '',
                                                    customerUid:
                                                        widget
                                                            .request
                                                            .customerUid ??
                                                        '',
                                                  );
                                            }
                                            final pdf = await _buildPdf(
                                              quote,
                                              widget.request,
                                            );
                                            if (!context.mounted) return;
                                            final bytes = await pdf.save();
                                            if (widget.sendOnly) {
                                              setState(
                                                () => _savingMessage =
                                                    'Saving PDF and quotation to Firestore...',
                                              );
                                              final sentQuotation =
                                                  await BookingService()
                                                      .sendQuotation(
                                                        requestId:
                                                            widget.request.id,
                                                        quotation: quote,
                                                        pdfBytes: bytes,
                                                      );
                                              if (context.mounted) {
                                                Navigator.pop(
                                                  context,
                                                  sentQuotation,
                                                );
                                              }
                                            } else {
                                              setState(
                                                () => _savingMessage =
                                                    'Opening PDF...',
                                              );
                                              await Printing.layoutPdf(
                                                onLayout: (format) async =>
                                                    bytes,
                                                name:
                                                    '${quote.quotationNumber}_${widget.request.customerName.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_')}.pdf',
                                              );
                                              if (context.mounted) {
                                                Navigator.pop(context, quote);
                                              }
                                            }
                                          } catch (err) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    widget.sendOnly
                                                        ? 'Could not send quotation: $err'
                                                        : 'Could not create quotation: $err',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          } finally {
                                            if (mounted) {
                                              setState(() => _saving = false);
                                            }
                                          }
                                        },
                                  icon: _saving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(
                                          widget.sendOnly
                                              ? Icons.send_rounded
                                              : Icons.picture_as_pdf_rounded,
                                          size: 18,
                                        ),
                                  label: Text(
                                    _saving
                                        ? _savingMessage
                                        : widget.sendOnly
                                        ? 'Send Quotation to Customer'
                                        : 'Save & Generate PDF',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: navy,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
