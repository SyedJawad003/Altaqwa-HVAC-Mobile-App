import 'dart:typed_data';

import 'package:altaqwa_app/customer/services/booking_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Quotation Firestore serialization', () {
    test('stores the PDF bytes only on the quotation document', () {
      final bytes = Uint8List.fromList([37, 80, 68, 70]);
      const quotation = Quotation(
        totalAmount: 150,
        breakdown: [],
        quotationNumber: 'Q-20261006-0001',
        adminName: 'Admin',
        status: 'sent',
        customerUid: 'customer-1',
        quotationId: 'quotation-1',
      );

      final document = quotation
          .copyWith(pdfBytes: bytes)
          .toMap(includePdfBytes: true);
      final nestedRequest = quotation
          .copyWith(pdfBytes: bytes)
          .toMap(forNested: true, includePdfBytes: true);

      expect((document['pdfBytes'] as Blob).bytes, orderedEquals(bytes));
      expect(nestedRequest.containsKey('pdfBytes'), isFalse);
      expect(Quotation.fromMap(document).pdfBytes, orderedEquals(bytes));
    });
  });
}
