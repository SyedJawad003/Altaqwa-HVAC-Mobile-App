import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'job_ops.dart';

class SiteDetails {
  const SiteDetails({
    required this.description,
    required this.photoUrls,
    required this.technicianName,
    this.technicianUid = '',
    this.customerName = '',
    this.serviceName = '',
    this.sharedAt,
    this.status = 'pending_review',
    this.createdAt,
    this.updatedAt,
  });

  final String description;
  final List<String> photoUrls;
  final String technicianName;
  final String technicianUid;
  final String customerName;
  final String serviceName;
  final DateTime? sharedAt;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SiteDetails.fromMap(Map<String, dynamic> data) {
    final photos = data['photoUrls'];
    final at = data['sharedAt'];
    final cat = data['createdAt'];
    final uat = data['updatedAt'];
    return SiteDetails(
      description: (data['description'] as String?)?.trim() ?? '',
      photoUrls: photos is List
          ? photos
                .map((item) => item.toString())
                .where((item) => item.trim().isNotEmpty)
                .toList()
          : const <String>[],
      technicianName:
          (data['technicianName'] as String?)?.trim() ?? 'Technician',
      technicianUid: (data['technicianUid'] as String?)?.trim() ?? '',
      customerName: (data['customerName'] as String?)?.trim() ?? '',
      serviceName: (data['serviceName'] as String?)?.trim() ?? '',
      sharedAt: at is Timestamp ? at.toDate() : null,
      status: (data['status'] as String?)?.trim() ?? 'pending_review',
      createdAt: cat is Timestamp ? cat.toDate() : null,
      updatedAt: uat is Timestamp ? uat.toDate() : null,
    );
  }

  Map<String, dynamic> toMap({bool forNested = false}) {
    final now = Timestamp.now();
    return {
      'description': description,
      'photoUrls': photoUrls,
      'technicianName': technicianName,
      'technicianUid': technicianUid,
      'customerName': customerName,
      'serviceName': serviceName,
      'sharedAt': sharedAt != null
          ? Timestamp.fromDate(sharedAt!)
          : (forNested ? now : FieldValue.serverTimestamp()),
      'status': status,
      if (!forNested)
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      if (!forNested)
        'updatedAt': updatedAt != null
            ? Timestamp.fromDate(updatedAt!)
            : FieldValue.serverTimestamp(),
    };
  }
}

class CostEstimate {
  const CostEstimate({
    required this.totalAmount,
    required this.breakdown,
    required this.supervisorName,
    this.supervisorUid,
    this.estimatedAt,
    this.notes = '',
  });

  final double totalAmount;
  final List<Map<String, dynamic>> breakdown;
  final String supervisorName;
  final String? supervisorUid;
  final DateTime? estimatedAt;
  final String notes;

  factory CostEstimate.fromMap(Map<String, dynamic> data) {
    final items = data['breakdown'];
    final at = data['estimatedAt'];
    return CostEstimate(
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      breakdown: items is List
          ? items
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : const <Map<String, dynamic>>[],
      supervisorName:
          (data['supervisorName'] as String?)?.trim() ?? 'Supervisor',
      supervisorUid: (data['supervisorUid'] as String?)?.trim(),
      estimatedAt: at is Timestamp ? at.toDate() : null,
      notes: (data['notes'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toMap({bool forNested = false}) {
    final now = Timestamp.now();
    return {
      'totalAmount': totalAmount,
      'breakdown': breakdown,
      'supervisorName': supervisorName,
      if (supervisorUid != null && supervisorUid!.isNotEmpty)
        'supervisorUid': supervisorUid,
      'estimatedAt': estimatedAt != null
          ? Timestamp.fromDate(estimatedAt!)
          : (forNested ? now : FieldValue.serverTimestamp()),
      'notes': notes,
    };
  }
}

class Quotation {
  const Quotation({
    required this.totalAmount,
    required this.breakdown,
    required this.quotationNumber,
    required this.adminName,
    this.adminUid,
    this.createdAt,
    this.customerName = '',
    this.serviceName = '',
    this.notes = '',
    this.pdfUrl = '',
    this.status = 'draft',
    this.validityDays = 14,
    this.quotationId = '',
    this.requestId = '',
    this.customerUid = '',
    this.pdfBytes,
  });

  final double totalAmount;
  final List<Map<String, dynamic>> breakdown;
  final String quotationNumber;
  final String adminName;
  final String? adminUid;
  final DateTime? createdAt;
  final String customerName;
  final String serviceName;
  final String notes;
  final String pdfUrl;
  final String status;
  final int validityDays;
  final String quotationId;
  final String requestId;
  final String customerUid;
  final Uint8List? pdfBytes;

  factory Quotation.fromMap(Map<String, dynamic> data) {
    final items = data['breakdown'];
    final at = data['createdAt'];
    return Quotation(
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      breakdown: items is List
          ? items
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : const <Map<String, dynamic>>[],
      quotationNumber:
          (data['quotationNumber'] as String?)?.trim() ?? 'Q-000000',
      adminName: (data['adminName'] as String?)?.trim() ?? 'Admin',
      adminUid: (data['adminUid'] as String?)?.trim(),
      createdAt: at is Timestamp ? at.toDate() : null,
      customerName: (data['customerName'] as String?)?.trim() ?? '',
      serviceName: (data['serviceName'] as String?)?.trim() ?? '',
      notes: (data['notes'] as String?)?.trim() ?? '',
      pdfUrl: (data['pdfUrl'] as String?)?.trim() ?? '',
      status: (data['status'] as String?)?.trim() ?? 'draft',
      validityDays: (data['validityDays'] as num?)?.toInt() ?? 14,
      quotationId: (data['quotationId'] as String?)?.trim() ?? '',
      requestId: (data['requestId'] as String?)?.trim() ?? '',
      customerUid: (data['customerUid'] as String?)?.trim() ?? '',
      pdfBytes: data['pdfBytes'] is Blob
          ? (data['pdfBytes'] as Blob).bytes
          : data['pdfBytes'] is Uint8List
          ? data['pdfBytes'] as Uint8List
          : data['pdfBytes'] is List<int>
          ? Uint8List.fromList(data['pdfBytes'] as List<int>)
          : null,
    );
  }

  Map<String, dynamic> toMap({
    bool forNested = false,
    bool includePdfBytes = false,
  }) {
    final now = Timestamp.now();
    return {
      'totalAmount': totalAmount,
      'breakdown': breakdown,
      'quotationNumber': quotationNumber,
      'adminName': adminName,
      if (adminUid != null && adminUid!.isNotEmpty) 'adminUid': adminUid,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : (forNested ? now : FieldValue.serverTimestamp()),
      'customerName': customerName,
      'serviceName': serviceName,
      'notes': notes,
      'pdfUrl': pdfUrl,
      'status': status,
      'validityDays': validityDays,
      'quotationId': quotationId,
      'requestId': requestId,
      'customerUid': customerUid,
      if (!forNested && includePdfBytes && pdfBytes != null)
        'pdfBytes': Blob(pdfBytes!),
    };
  }

  Quotation copyWith({
    String? pdfUrl,
    String? status,
    String? quotationId,
    String? requestId,
    String? customerUid,
    Uint8List? pdfBytes,
  }) {
    return Quotation(
      totalAmount: totalAmount,
      breakdown: breakdown,
      quotationNumber: quotationNumber,
      adminName: adminName,
      adminUid: adminUid,
      createdAt: createdAt,
      customerName: customerName,
      serviceName: serviceName,
      notes: notes,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      status: status ?? this.status,
      validityDays: validityDays,
      quotationId: quotationId ?? this.quotationId,
      requestId: requestId ?? this.requestId,
      customerUid: customerUid ?? this.customerUid,
      pdfBytes: pdfBytes ?? this.pdfBytes,
    );
  }
}

class BookingRequest {
  const BookingRequest({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.serviceName,
    required this.preferredDate,
    required this.preferredTime,
    required this.notes,
    required this.status,
    this.technicianName,
    this.technicianUid,
    this.createdAt,
    this.progressStage = JobProgress.requested,
    this.priority = 'medium',
    this.verificationStatus = '',
    this.technicianNotes = '',
    this.materialsUsed = '',
    this.completionReport = '',
    this.customerFeedback = '',
    this.photoUrls = const <String>[],
    this.timeline = const <Map<String, dynamic>>[],
    this.supervisorAction = '',
    this.supervisorNotes = '',
    this.customerUid,
    this.customerEmail = '',
    this.isQuoteRequest = false,
    this.siteDetails,
    this.costEstimate,
    this.quotation,
  });

  final String id;
  final String customerName;
  final String phone;
  final String address;
  final String serviceName;
  final String preferredDate;
  final String preferredTime;
  final String notes;
  final String status;
  final String? technicianName;
  final String? technicianUid;
  final DateTime? createdAt;
  final String progressStage;
  final String priority;
  final String verificationStatus;
  final String technicianNotes;
  final String materialsUsed;
  final String completionReport;
  final String customerFeedback;
  final List<String> photoUrls;
  final List<Map<String, dynamic>> timeline;
  final String supervisorAction;
  final String supervisorNotes;
  final String? customerUid;
  final String customerEmail;
  final bool isQuoteRequest;
  final SiteDetails? siteDetails;
  final CostEstimate? costEstimate;
  final Quotation? quotation;

  BookingRequest copyWith({
    String? id,
    String? customerName,
    String? phone,
    String? address,
    String? serviceName,
    String? preferredDate,
    String? preferredTime,
    String? notes,
    String? status,
    String? technicianName,
    String? technicianUid,
    DateTime? createdAt,
    String? progressStage,
    String? priority,
    String? verificationStatus,
    String? technicianNotes,
    String? materialsUsed,
    String? completionReport,
    String? customerFeedback,
    List<String>? photoUrls,
    List<Map<String, dynamic>>? timeline,
    String? supervisorAction,
    String? supervisorNotes,
    String? customerUid,
    String? customerEmail,
    bool? isQuoteRequest,
    SiteDetails? siteDetails,
    bool clearSiteDetails = false,
    CostEstimate? costEstimate,
    bool clearCostEstimate = false,
    Quotation? quotation,
    bool clearQuotation = false,
  }) {
    return BookingRequest(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      serviceName: serviceName ?? this.serviceName,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTime: preferredTime ?? this.preferredTime,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      technicianName: technicianName ?? this.technicianName,
      technicianUid: technicianUid ?? this.technicianUid,
      createdAt: createdAt ?? this.createdAt,
      progressStage: progressStage ?? this.progressStage,
      priority: priority ?? this.priority,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      technicianNotes: technicianNotes ?? this.technicianNotes,
      materialsUsed: materialsUsed ?? this.materialsUsed,
      completionReport: completionReport ?? this.completionReport,
      customerFeedback: customerFeedback ?? this.customerFeedback,
      photoUrls: photoUrls ?? this.photoUrls,
      timeline: timeline ?? this.timeline,
      supervisorAction: supervisorAction ?? this.supervisorAction,
      supervisorNotes: supervisorNotes ?? this.supervisorNotes,
      customerUid: customerUid ?? this.customerUid,
      customerEmail: customerEmail ?? this.customerEmail,
      isQuoteRequest: isQuoteRequest ?? this.isQuoteRequest,
      siteDetails: clearSiteDetails ? null : siteDetails ?? this.siteDetails,
      costEstimate: clearCostEstimate
          ? null
          : costEstimate ?? this.costEstimate,
      quotation: clearQuotation ? null : quotation ?? this.quotation,
    );
  }

  DateTime? get appointmentAt => parseJobDate(preferredDate, preferredTime);

  bool get isClosed {
    final normalized = status.toLowerCase();
    return normalized == 'completed' ||
        normalized == 'verified' ||
        progressStage == JobProgress.verified;
  }

  bool get isVerified =>
      verificationStatus.toLowerCase() == 'verified' ||
      progressStage == JobProgress.verified;

  bool get needsVerification =>
      status.toLowerCase() == 'completed' && !isVerified;

  bool get isInProgress {
    const stages = {
      JobProgress.onTheWay,
      JobProgress.arrived,
      JobProgress.workStarted,
    };
    return stages.contains(progressStage) ||
        status.toLowerCase() == 'in_progress';
  }

  bool get isPendingAction {
    final normalized = status.toLowerCase();
    return (normalized == 'assigned' || normalized == 'confirmed') &&
        JobProgress.indexOf(progressStage) <=
            JobProgress.indexOf(JobProgress.accepted);
  }

  bool get isToday {
    final date = appointmentAt;
    return date != null && isSameDay(date, DateTime.now());
  }

  bool get isDelayed {
    if (isClosed || isVerified) return false;
    final date = appointmentAt;
    if (date == null) return false;
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get isUpcoming {
    final date = appointmentAt;
    if (date == null || isClosed) return false;
    final now = DateTime.now();
    return date.isAfter(DateTime(now.year, now.month, now.day, 23, 59));
  }

  String get displayPriority {
    if (priority.trim().isNotEmpty) return priority;
    return isDelayed ? 'high' : 'medium';
  }

  factory BookingRequest.fromMap(String id, Map<String, dynamic> data) {
    final createdAtValue = data['createdAt'];
    final status = (data['status'] as String?)?.trim() ?? 'pending';
    final storedStage = (data['progressStage'] as String?)?.trim() ?? '';
    final photos = data['photoUrls'];
    final events = data['timeline'];

    return BookingRequest(
      id: id,
      customerName:
          (data['customerName'] as String?)?.trim() ?? 'Unknown Customer',
      phone:
          (data['phone'] as String? ?? data['customerPhone'] as String?)
              ?.trim() ??
          '',
      address: (data['address'] as String?)?.trim() ?? '',
      serviceName: (data['serviceName'] as String?)?.trim() ?? 'HVAC Service',
      preferredDate: (data['preferredDate'] as String?)?.trim() ?? '',
      preferredTime: (data['preferredTime'] as String?)?.trim() ?? '',
      notes:
          (data['notes'] as String? ?? data['description'] as String?)
              ?.trim() ??
          '',
      status: status,
      technicianName: (data['technicianName'] as String?)?.trim(),
      technicianUid: (data['technicianUid'] as String?)?.trim(),
      createdAt: createdAtValue is Timestamp ? createdAtValue.toDate() : null,
      progressStage: storedStage.isEmpty
          ? JobProgress.fromLegacyStatus(status)
          : storedStage,
      priority: (data['priority'] as String?)?.trim() ?? 'medium',
      verificationStatus: (data['verificationStatus'] as String?)?.trim() ?? '',
      technicianNotes: (data['technicianNotes'] as String?)?.trim() ?? '',
      materialsUsed: (data['materialsUsed'] as String?)?.trim() ?? '',
      completionReport: (data['completionReport'] as String?)?.trim() ?? '',
      customerFeedback: (data['customerFeedback'] as String?)?.trim() ?? '',
      photoUrls: photos is List
          ? photos
                .map((item) => item.toString())
                .where((item) => item.trim().isNotEmpty)
                .toList()
          : const <String>[],
      timeline: events is List
          ? events
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : const <Map<String, dynamic>>[],
      supervisorAction: (data['supervisorAction'] as String?)?.trim() ?? '',
      supervisorNotes: (data['supervisorNotes'] as String?)?.trim() ?? '',
      customerUid: (data['customerUid'] as String?)?.trim(),
      customerEmail:
          (data['customerEmail'] as String? ?? data['email'] as String?)
              ?.trim() ??
          '',
      isQuoteRequest: (data['isQuoteRequest'] as bool?) ?? false,
      siteDetails: data['siteDetails'] is Map
          ? SiteDetails.fromMap(
              Map<String, dynamic>.from(data['siteDetails'] as Map),
            )
          : null,
      costEstimate: data['costEstimate'] is Map
          ? CostEstimate.fromMap(
              Map<String, dynamic>.from(data['costEstimate'] as Map),
            )
          : null,
      quotation: data['quotation'] is Map
          ? Quotation.fromMap(
              Map<String, dynamic>.from(data['quotation'] as Map),
            )
          : null,
    );
  }
}

class TechnicianProfile {
  const TechnicianProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.available = true,
    this.workStatus = 'active',
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final bool available;
  final String workStatus;

  factory TechnicianProfile.fromMap(String uid, Map<String, dynamic> data) {
    return TechnicianProfile(
      uid: uid,
      name: (data['name'] as String?)?.trim() ?? 'Unnamed Technician',
      email: (data['email'] as String?)?.trim() ?? '',
      phone: (data['phone'] as String?)?.trim() ?? '',
      available: data['available'] is bool ? data['available'] as bool : true,
      workStatus: (data['status'] as String?)?.trim().isNotEmpty == true
          ? (data['status'] as String).trim()
          : 'active',
    );
  }
}

class BookingService {
  static const String requestsCollectionName = 'customer_service_requests';
  static const String siteDetailsCollectionName = 'customer_site_details';
  static const String siteIssueCollectionName = 'site_issue';
  static const String customerQuoteRequestsCollectionName =
      'customer_quote_requests';

  BookingService({FirebaseFirestore? firestore})
    : _firestore =
          firestore ??
          (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);

  final FirebaseFirestore? _firestore;

  CollectionReference<Map<String, dynamic>> get _requestsCollection {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError('Firebase Firestore is not initialized.');
    }

    return firestore.collection(requestsCollectionName);
  }

  CollectionReference<Map<String, dynamic>> get _siteIssueCollection {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError('Firebase Firestore is not initialized.');
    }
    return firestore.collection(siteIssueCollectionName);
  }

  CollectionReference<Map<String, dynamic>> get _legacySiteDetailsCollection {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError('Firebase Firestore is not initialized.');
    }
    return firestore.collection(siteDetailsCollectionName);
  }

  CollectionReference<Map<String, dynamic>> get _techniciansCollection {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError('Firebase Firestore is not initialized.');
    }
    return firestore.collection('technicians');
  }

  CollectionReference<Map<String, dynamic>>
  get _customerQuoteRequestsCollection {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError('Firebase Firestore is not initialized.');
    }
    return firestore.collection(customerQuoteRequestsCollectionName);
  }

  Future<int> countJobsForTechnician({
    required String uid,
    required String name,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return 0;
    try {
      final byUid = await _requestsCollection
          .where('technicianUid', isEqualTo: uid)
          .count()
          .get();
      int total = byUid.count ?? 0;
      if (name.trim().isNotEmpty) {
        final byName = await _requestsCollection
            .where('technicianName', isEqualTo: name.trim())
            .count()
            .get();
        total += byName.count ?? 0;
      }
      return total;
    } catch (_) {
      final all = await _requestsCollection.get();
      int c = 0;
      for (final d in all.docs) {
        final map = d.data();
        final tUid = map['technicianUid'] as String?;
        final tName = map['technicianName'] as String?;
        if ((uid.isNotEmpty && tUid == uid) ||
            (name.trim().isNotEmpty && tName == name.trim())) {
          c++;
        }
      }
      return c;
    }
  }

  Future<void> toggleTechnicianAvailable(String uid, bool currentValue) async {
    final firestore = _firestore;
    if (firestore == null) return;
    await _techniciansCollection.doc(uid).set(<String, dynamic>{
      'available': !currentValue,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String> submitBooking({
    required String customerName,
    required String phone,
    required String address,
    required String serviceName,
    required String preferredDate,
    required String preferredTime,
    required String notes,
    String? customerUid,
  }) async {
    final ref = await _requestsCollection.add({
      'customerName': customerName.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
      'serviceName': serviceName.trim(),
      'preferredDate': preferredDate.trim(),
      'preferredTime': preferredTime.trim(),
      'notes': notes.trim(),
      'status': 'pending',
      'progressStage': JobProgress.requested,
      'priority': 'medium',
      'verificationStatus': '',
      'timeline': [
        {
          'stage': JobProgress.requested,
          'label': JobProgress.labelFor(JobProgress.requested),
          'at': Timestamp.now(),
          'byRole': 'customer',
        },
      ],
      'technicianName': '',
      'customerUid': customerUid ?? FirebaseAuth.instance.currentUser?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    try {
      await _notifyAdmins(
        requestId: ref.id,
        type: 'new_booking',
        title: 'New Service Booking',
        message:
            '${customerName.trim()} booked ${serviceName.trim()} on ${preferredDate.trim()} at ${preferredTime.trim()}.',
      );
    } catch (_) {}

    try {
      await _notifySupervisors(
        requestId: ref.id,
        type: 'new_booking',
        title: 'New Service Booking',
        message:
            '${customerName.trim()} booked ${serviceName.trim()} on ${preferredDate.trim()} at ${preferredTime.trim()}.',
      );
    } catch (_) {}

    return ref.id;
  }

  Stream<List<BookingRequest>> watchBookings() {
    final firestore = _firestore;
    if (firestore == null) {
      return Stream.value(const <BookingRequest>[]);
    }

    return firestore.collection(requestsCollectionName).snapshots().map((
      snapshot,
    ) {
      final requests = snapshot.docs
          .map((doc) => BookingRequest.fromMap(doc.id, doc.data()))
          .toList();
      requests.sort((left, right) {
        final leftDate = left.createdAt;
        final rightDate = right.createdAt;
        if (leftDate == null && rightDate == null) return 0;
        if (leftDate == null) return 1;
        if (rightDate == null) return -1;
        return rightDate.compareTo(leftDate);
      });
      return requests;
    });
  }

  Stream<List<BookingRequest>> watchTechnicianBookings(
    String technicianUid, {
    String? technicianName,
  }) {
    final firestore = _firestore;
    if (firestore == null) return Stream.value(const <BookingRequest>[]);

    final collection = firestore.collection(requestsCollectionName);
    final uidQuery = collection.where(
      'technicianUid',
      isEqualTo: technicianUid,
    );
    final name = technicianName?.trim();
    if (name == null || name.isEmpty) {
      return uidQuery.snapshots().map(_mapBookingDocs);
    }

    return _mergeBookingStreams(
      uidQuery.snapshots(),
      collection.where('technicianName', isEqualTo: name).snapshots(),
    );
  }

  List<BookingRequest> _mapBookingDocs(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final requests = snapshot.docs
        .map((doc) => BookingRequest.fromMap(doc.id, doc.data()))
        .toList();
    requests.sort((left, right) {
      final leftDate = left.createdAt;
      final rightDate = right.createdAt;
      if (leftDate == null && rightDate == null) return 0;
      if (leftDate == null) return 1;
      if (rightDate == null) return -1;
      return rightDate.compareTo(leftDate);
    });
    return requests;
  }

  Stream<List<BookingRequest>> _mergeBookingStreams(
    Stream<QuerySnapshot<Map<String, dynamic>>> first,
    Stream<QuerySnapshot<Map<String, dynamic>>> second,
  ) {
    final controller = StreamController<List<BookingRequest>>();
    var left = <BookingRequest>[];
    var right = <BookingRequest>[];

    void emit() {
      final merged = <String, BookingRequest>{};
      for (final job in [...left, ...right]) {
        merged[job.id] = job;
      }
      if (!controller.isClosed) {
        controller.add(_mapBookingDocsFromList(merged.values.toList()));
      }
    }

    final firstSub = first.listen((snapshot) {
      left = snapshot.docs
          .map((doc) => BookingRequest.fromMap(doc.id, doc.data()))
          .toList();
      emit();
    }, onError: controller.addError);
    final secondSub = second.listen(
      (snapshot) {
        right = snapshot.docs
            .map((doc) => BookingRequest.fromMap(doc.id, doc.data()))
            .toList();
        emit();
      },
      onError: (_) {
        right = const <BookingRequest>[];
        emit();
      },
    );

    controller.onCancel = () async {
      await firstSub.cancel();
      await secondSub.cancel();
    };
    return controller.stream;
  }

  List<BookingRequest> _mapBookingDocsFromList(List<BookingRequest> requests) {
    requests.sort((left, right) {
      final leftDate = left.createdAt;
      final rightDate = right.createdAt;
      if (leftDate == null && rightDate == null) return 0;
      if (leftDate == null) return 1;
      if (rightDate == null) return -1;
      return rightDate.compareTo(leftDate);
    });
    return requests;
  }

  Stream<TechnicianProfile?> watchTechnicianProfile(String uid) {
    final firestore = _firestore;
    if (firestore == null) return Stream.value(null);
    return firestore.collection('technicians').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return TechnicianProfile.fromMap(doc.id, data);
    });
  }

  Stream<List<TechnicianProfile>> watchTechnicians() {
    final firestore = _firestore;
    if (firestore == null) return Stream.value(const <TechnicianProfile>[]);

    return firestore.collection('technicians').snapshots().map((snapshot) {
      final technicians = snapshot.docs
          .map((doc) => TechnicianProfile.fromMap(doc.id, doc.data()))
          .where((technician) => technician.name.isNotEmpty)
          .toList();
      technicians.sort(
        (left, right) =>
            left.name.toLowerCase().compareTo(right.name.toLowerCase()),
      );
      return technicians;
    });
  }

  Future<String?> _resolveTechnicianUid({
    String? technicianUid,
    required String technicianName,
  }) async {
    final uid = technicianUid?.trim();
    if (uid != null && uid.isNotEmpty) return uid;

    final name = technicianName.trim();
    if (name.isEmpty) return null;

    final firestore = _firestore;
    if (firestore == null) return null;

    final exact = await firestore
        .collection('technicians')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    if (exact.docs.isNotEmpty) return exact.docs.first.id;

    final all = await firestore.collection('technicians').get();
    for (final doc in all.docs) {
      final storedName = (doc.data()['name'] as String?)?.trim().toLowerCase();
      if (storedName == name.toLowerCase()) return doc.id;
    }
    return null;
  }

  Future<void> assignTechnician({
    required String requestId,
    required String technicianName,
    String? technicianUid,
  }) async {
    if (technicianName.trim().isEmpty) return;

    final requestSnapshot = await _requestsCollection.doc(requestId).get();
    final requestData = requestSnapshot.data() ?? <String, dynamic>{};
    final resolvedUid = await _resolveTechnicianUid(
      technicianUid: technicianUid,
      technicianName: technicianName,
    );
    if (resolvedUid == null) {
      throw Exception(
        'That technician could not be matched to a registered account.',
      );
    }
    await _requestsCollection.doc(requestId).update({
      'technicianName': technicianName.trim(),
      'technicianUid': resolvedUid,
      'status': 'assigned',
      'progressStage': JobProgress.assigned,
      'updatedAt': FieldValue.serverTimestamp(),
      'timeline': FieldValue.arrayUnion([
        {
          'stage': JobProgress.assigned,
          'label': JobProgress.labelFor(JobProgress.assigned),
          'at': Timestamp.now(),
          'byRole': 'admin',
          'note': 'Assigned to $technicianName',
        },
      ]),
    });
    await _createAssignmentNotification(
      requestId,
      technicianName.trim(),
      resolvedUid,
    );
    await _notifySupervisors(
      requestId: requestId,
      type: 'job_assigned',
      title: 'Technician assigned',
      message:
          '$technicianName was assigned to ${requestData['serviceName'] ?? 'a service request'}.',
    );
    final customerUid = requestData['customerUid'] as String?;
    if (customerUid != null && customerUid.isNotEmpty) {
      await _firestore!.collection('notifications').add({
        'recipientUid': customerUid,
        'requestId': requestId,
        'type': 'technician_assigned',
        'title': 'Technician assigned',
        'message':
            '$technicianName will handle ${requestData['serviceName'] ?? 'your service'} on ${requestData['preferredDate'] ?? 'the scheduled date'} at ${requestData['preferredTime'] ?? 'the scheduled time'}.',
        'technicianName': technicianName,
        'serviceName': requestData['serviceName'] ?? '',
        'preferredDate': requestData['preferredDate'] ?? '',
        'preferredTime': requestData['preferredTime'] ?? '',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> confirmBooking({
    required String requestId,
    required String technicianName,
    String? technicianUid,
  }) async {
    if (technicianName.trim().isEmpty) {
      throw Exception(
        'Please assign a technician before confirming the booking.',
      );
    }

    final resolvedUid = await _resolveTechnicianUid(
      technicianUid: technicianUid,
      technicianName: technicianName,
    );

    await _requestsCollection.doc(requestId).update({
      'technicianName': technicianName.trim(),
      if (resolvedUid != null) 'technicianUid': resolvedUid,
      'status': 'confirmed',
      'progressStage': JobProgress.accepted,
      'updatedAt': FieldValue.serverTimestamp(),
      'timeline': FieldValue.arrayUnion([
        {
          'stage': JobProgress.accepted,
          'label': JobProgress.labelFor(JobProgress.accepted),
          'at': Timestamp.now(),
          'byRole': 'admin',
        },
      ]),
    });
  }

  Future<void> _createAssignmentNotification(
    String requestId,
    String technicianName,
    String? technicianUid,
  ) async {
    if (technicianUid == null) return;
    await _firestore!.collection('notifications').add({
      'recipientUid': technicianUid,
      'requestId': requestId,
      'type': 'assignment',
      'title': 'New job assigned',
      'message': 'A new HVAC request was assigned to you.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchNotifications(String recipientUid) {
    return _firestore!
        .collection('notifications')
        .where('recipientUid', isEqualTo: recipientUid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> completeBooking({
    required String requestId,
    String? completedBy,
    String technicianNotes = '',
    String materialsUsed = '',
    String completionReport = '',
    List<String> photoUrls = const <String>[],
  }) async {
    await _requestsCollection.doc(requestId).update({
      'status': 'completed',
      'progressStage': JobProgress.completed,
      'verificationStatus': 'pending',
      'completedAt': FieldValue.serverTimestamp(),
      'completedBy': completedBy ?? FirebaseAuth.instance.currentUser?.uid,
      'technicianNotes': technicianNotes.trim(),
      'materialsUsed': materialsUsed.trim(),
      'completionReport': completionReport.trim(),
      if (photoUrls.isNotEmpty) 'photoUrls': photoUrls,
      'updatedAt': FieldValue.serverTimestamp(),
      'timeline': FieldValue.arrayUnion([
        {
          'stage': JobProgress.completed,
          'label': JobProgress.labelFor(JobProgress.completed),
          'at': Timestamp.now(),
          'byRole': 'technician',
        },
      ]),
    });
    await _notifySupervisors(
      requestId: requestId,
      type: 'job_completed',
      title: 'Job ready for verification',
      message: 'A technician marked a job complete. Please review the work.',
    );
  }

  Future<void> updateJobProgress({
    required String requestId,
    required String stage,
    String? note,
  }) async {
    final normalized = stage.trim();
    if (!JobProgress.stages.contains(normalized)) return;
    final status = switch (normalized) {
      JobProgress.onTheWay ||
      JobProgress.arrived ||
      JobProgress.workStarted => 'in_progress',
      JobProgress.accepted => 'confirmed',
      _ => null,
    };
    await _requestsCollection.doc(requestId).update({
      'progressStage': normalized,
      if (status != null) 'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
      'timeline': FieldValue.arrayUnion([
        {
          'stage': normalized,
          'label': JobProgress.labelFor(normalized),
          'at': Timestamp.now(),
          'byRole': 'technician',
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      ]),
    });
  }

  Future<void> supervisorReviewJob({
    required String requestId,
    required String action,
    required String notes,
  }) async {
    final normalized = action.trim().toLowerCase();
    final payload = <String, dynamic>{
      'supervisorAction': normalized,
      'supervisorNotes': notes.trim(),
      'supervisorReviewedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    switch (normalized) {
      case 'verify':
        payload['verificationStatus'] = 'verified';
        payload['progressStage'] = JobProgress.verified;
        payload['status'] = 'completed';
        payload['timeline'] = FieldValue.arrayUnion([
          {
            'stage': JobProgress.verified,
            'label': JobProgress.labelFor(JobProgress.verified),
            'at': Timestamp.now(),
            'byRole': 'supervisor',
            'note': notes.trim(),
          },
        ]);
      case 'rework':
        payload['verificationStatus'] = 'rework';
        payload['status'] = 'assigned';
        payload['progressStage'] = JobProgress.assigned;
        payload['timeline'] = FieldValue.arrayUnion([
          {
            'stage': JobProgress.assigned,
            'label': 'Rework requested',
            'at': Timestamp.now(),
            'byRole': 'supervisor',
            'note': notes.trim(),
          },
        ]);
      case 'revisit':
        payload['verificationStatus'] = 'revisit';
        payload['status'] = 'assigned';
        payload['progressStage'] = JobProgress.assigned;
        payload['timeline'] = FieldValue.arrayUnion([
          {
            'stage': JobProgress.assigned,
            'label': 'Revisit requested',
            'at': Timestamp.now(),
            'byRole': 'supervisor',
            'note': notes.trim(),
          },
        ]);
      case 'escalate':
        payload['verificationStatus'] = 'escalated';
    }

    final request = await _requestsCollection.doc(requestId).get();
    await _requestsCollection.doc(requestId).update(payload);
    final data = request.data() ?? <String, dynamic>{};
    final technicianUid = (data['technicianUid'] as String?)?.trim();
    if (technicianUid != null && technicianUid.isNotEmpty) {
      await _notifyUser(
        recipientUid: technicianUid,
        requestId: requestId,
        type: 'supervisor_$normalized',
        title: switch (normalized) {
          'verify' => 'Job verified',
          'rework' => 'Rework requested',
          'revisit' => 'Revisit requested',
          'escalate' => 'Job escalated to admin',
          _ => 'Supervisor update',
        },
        message: notes.trim().isEmpty
            ? 'Your supervisor updated this job.'
            : notes.trim(),
      );
    }
    if (normalized == 'escalate') {
      await createJobIssue(
        requestId: requestId,
        type: 'escalation',
        title: 'Escalated to admin',
        description: notes.trim().isEmpty
            ? 'Supervisor escalated this job to admin.'
            : notes.trim(),
        customerName: (data['customerName'] as String?) ?? '',
        technicianName: (data['technicianName'] as String?) ?? '',
        serviceName: (data['serviceName'] as String?) ?? '',
      );
    }
    if (normalized == 'revisit' || normalized == 'rework') {
      await createJobIssue(
        requestId: requestId,
        type: normalized,
        title: normalized == 'revisit'
            ? 'Revisit requested'
            : 'Rework requested',
        description: notes.trim(),
        customerName: (data['customerName'] as String?) ?? '',
        technicianName: (data['technicianName'] as String?) ?? '',
        serviceName: (data['serviceName'] as String?) ?? '',
      );
    }
  }

  Future<void> createJobIssue({
    required String requestId,
    required String type,
    required String title,
    required String description,
    String customerName = '',
    String technicianName = '',
    String serviceName = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = _firestore!;
    await firestore.collection('job_issues').add({
      'requestId': requestId,
      'type': type,
      'title': title.trim(),
      'description': description.trim(),
      'status': 'open',
      'customerName': customerName,
      'technicianName': technicianName,
      'serviceName': serviceName,
      'createdBy': user?.uid,
      'createdByName': user?.displayName ?? 'Supervisor',
      'createdByEmail': user?.email ?? '',
      'createdByRole': 'supervisor',
      'visibleToAdmin': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await firestore.collection('notifications').add({
      'audience': 'admins',
      'senderUid': user?.uid,
      'requestId': requestId,
      'type': 'supervisor_issue',
      'title': 'Supervisor logged an issue',
      'message':
          '${user?.displayName ?? 'A supervisor'} reported: ${title.trim()}',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<JobIssue>> watchJobIssues() {
    final firestore = _firestore;
    if (firestore == null) return Stream.value(const <JobIssue>[]);
    return firestore.collection('job_issues').snapshots().map((snapshot) {
      final issues = snapshot.docs.map((doc) {
        final data = doc.data();
        final created = data['createdAt'];
        return JobIssue(
          id: doc.id,
          requestId: (data['requestId'] as String?) ?? '',
          type: (data['type'] as String?) ?? 'issue',
          title: (data['title'] as String?) ?? 'Issue',
          description: (data['description'] as String?) ?? '',
          status: (data['status'] as String?) ?? 'open',
          technicianName: (data['technicianName'] as String?) ?? '',
          customerName: (data['customerName'] as String?) ?? '',
          serviceName: (data['serviceName'] as String?) ?? '',
          createdByName: (data['createdByName'] as String?) ?? 'Supervisor',
          createdByEmail: (data['createdByEmail'] as String?) ?? '',
          createdByRole: (data['createdByRole'] as String?) ?? 'supervisor',
          createdAt: created is Timestamp ? created.toDate() : null,
        );
      }).toList();
      issues.sort((left, right) {
        final leftDate = left.createdAt;
        final rightDate = right.createdAt;
        if (leftDate == null && rightDate == null) return 0;
        if (leftDate == null) return 1;
        if (rightDate == null) return -1;
        return rightDate.compareTo(leftDate);
      });
      return issues;
    });
  }

  Future<void> resolveJobIssue(String issueId) async {
    await _firestore!.collection('job_issues').doc(issueId).update({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchSupervisorNotifications(String uid) {
    final firestore = _firestore;
    if (firestore == null) {
      return Stream.value(const <Map<String, dynamic>>[]);
    }
    final personal = firestore
        .collection('notifications')
        .where('recipientUid', isEqualTo: uid)
        .snapshots();
    final broadcast = firestore
        .collection('notifications')
        .where('audience', isEqualTo: 'supervisors')
        .snapshots();
    final controller = StreamController<List<Map<String, dynamic>>>();
    var left = <Map<String, dynamic>>[];
    var right = <Map<String, dynamic>>[];
    void emit() {
      final merged = <String, Map<String, dynamic>>{};
      for (final item in [...left, ...right]) {
        merged[item['id'] as String] = item;
      }
      final list = merged.values.toList();
      list.sort((a, b) {
        final leftAt = a['createdAt'];
        final rightAt = b['createdAt'];
        if (leftAt is Timestamp && rightAt is Timestamp) {
          return rightAt.compareTo(leftAt);
        }
        return 0;
      });
      if (!controller.isClosed) controller.add(list);
    }

    final first = personal.listen((snapshot) {
      left = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      emit();
    }, onError: controller.addError);
    final second = broadcast.listen(
      (snapshot) {
        right = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        emit();
      },
      onError: (_) {
        right = const <Map<String, dynamic>>[];
        emit();
      },
    );
    controller.onCancel = () async {
      await first.cancel();
      await second.cancel();
    };
    return controller.stream;
  }

  Future<void> shareSiteDetails({
    required String requestId,
    required String description,
    required List<String> photoUrls,
    required String technicianName,
    String? technicianUid,
    String customerName = '',
    String serviceName = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final resolvedTechName = technicianName.trim().isNotEmpty
        ? technicianName.trim()
        : (user?.displayName ?? 'Technician');
    final resolvedTechUid = (technicianUid ?? user?.uid ?? '').trim();
    final cleanDescription = description.trim();
    final cleanPhotos = photoUrls
        .where((item) => item.trim().isNotEmpty)
        .toList(growable: false);
    final now = Timestamp.now();

    final siteIssuePayload = <String, dynamic>{
      'requestId': requestId,
      'description': cleanDescription,
      'photoUrls': cleanPhotos,
      'technicianName': resolvedTechName,
      'technicianUid': resolvedTechUid,
      'customerName': customerName.trim(),
      'serviceName': serviceName.trim(),
      'sharedAt': FieldValue.serverTimestamp(),
      'status': 'pending_review',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final bookingMirror = <String, dynamic>{
      'requestId': requestId,
      'description': cleanDescription,
      'photoUrls': cleanPhotos,
      'technicianName': resolvedTechName,
      'technicianUid': resolvedTechUid,
      'customerName': customerName.trim(),
      'serviceName': serviceName.trim(),
      'sharedAt': now,
      'status': 'pending_review',
    };

    await _siteIssueCollection
        .doc(requestId)
        .set(siteIssuePayload, SetOptions(merge: true));

    try {
      await _legacySiteDetailsCollection
          .doc(requestId)
          .set(bookingMirror, SetOptions(merge: true));
    } catch (_) {}

    try {
      await _requestsCollection.doc(requestId).update({
        'siteDetails': bookingMirror,
        'updatedAt': FieldValue.serverTimestamp(),
        'timeline': FieldValue.arrayUnion([
          <String, dynamic>{
            'stage': 'site_inspected',
            'label': 'Site details shared with supervisor',
            'at': now,
            'byRole': 'technician',
            'note': cleanDescription.isNotEmpty
                ? cleanDescription
                : 'Site inspection & photos shared',
          },
        ]),
      });
    } catch (_) {}

    try {
      await _notifySupervisors(
        requestId: requestId,
        type: 'site_details_shared',
        title: 'Site details received',
        message:
            '$resolvedTechName shared site analysis and photos for ${customerName.isNotEmpty ? customerName : 'customer'} (${serviceName.isNotEmpty ? serviceName : 'service'}).',
      );
    } catch (_) {
      // Notifications are best-effort; never let a permission/rule issue
      // here prevent the technician from seeing a successful submit.
    }
  }

  Stream<SiteDetails?> watchSiteDetailsForRequest(String requestId) {
    final firestore = _firestore;
    if (firestore == null) return Stream.value(null);

    final newStream = _siteIssueCollection.doc(requestId).snapshots().map((
      snap,
    ) {
      if (!snap.exists) return null;
      final data = snap.data();
      return data == null ? null : SiteDetails.fromMap(data);
    });

    return newStream.transform(
      StreamTransformer<SiteDetails?, SiteDetails?>.fromHandlers(
        handleData: (value, sink) {
          if (value != null) {
            sink.add(value);
            return;
          }
          _legacySiteDetailsCollection
              .doc(requestId)
              .get()
              .then((legacySnap) {
                if (!legacySnap.exists) {
                  sink.add(null);
                  return;
                }
                final data = legacySnap.data();
                sink.add(data == null ? null : SiteDetails.fromMap(data));
              })
              .catchError((_) {
                sink.add(null);
              });
        },
        handleError: (error, _, sink) {
          try {
            _legacySiteDetailsCollection
                .doc(requestId)
                .get()
                .then((legacySnap) {
                  if (!legacySnap.exists) {
                    sink.add(null);
                    return;
                  }
                  final data = legacySnap.data();
                  sink.add(data == null ? null : SiteDetails.fromMap(data));
                })
                .catchError((_) {
                  sink.add(null);
                });
          } catch (_) {
            sink.add(null);
          }
        },
      ),
    );
  }

  Future<SiteDetails?> getSiteDetailsForRequest(String requestId) async {
    SiteDetails? result;
    try {
      final snap = await _siteIssueCollection.doc(requestId).get();
      if (snap.exists) {
        final data = snap.data();
        result = data == null ? null : SiteDetails.fromMap(data);
      }
    } catch (_) {
      result = null;
    }
    if (result != null) return result;
    try {
      final legacySnap = await _legacySiteDetailsCollection
          .doc(requestId)
          .get();
      if (!legacySnap.exists) return null;
      final data = legacySnap.data();
      return data == null ? null : SiteDetails.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> _notifyUser({
    required String recipientUid,
    required String requestId,
    required String type,
    required String title,
    required String message,
  }) async {
    await _firestore!.collection('notifications').add({
      'recipientUid': recipientUid,
      'senderUid': FirebaseAuth.instance.currentUser?.uid,
      'requestId': requestId,
      'type': type,
      'title': title,
      'message': message,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _notifySupervisors({
    required String requestId,
    required String type,
    required String title,
    required String message,
  }) async {
    await _firestore!.collection('notifications').add({
      'audience': 'supervisors',
      'senderUid': FirebaseAuth.instance.currentUser?.uid,
      'requestId': requestId,
      'type': type,
      'title': title,
      'message': message,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _notifyAdmins({
    required String requestId,
    required String type,
    required String title,
    required String message,
  }) async {
    await _firestore!.collection('notifications').add({
      'audience': 'admins',
      'senderUid': FirebaseAuth.instance.currentUser?.uid,
      'requestId': requestId,
      'type': type,
      'title': title,
      'message': message,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitCostEstimate({
    required String requestId,
    required double totalAmount,
    required List<Map<String, dynamic>> breakdown,
    required String supervisorName,
    String? supervisorUid,
    String notes = '',
  }) async {
    final estimate = CostEstimate(
      totalAmount: totalAmount,
      breakdown: breakdown,
      supervisorName: supervisorName,
      supervisorUid: supervisorUid ?? FirebaseAuth.instance.currentUser?.uid,
      notes: notes.trim(),
    );
    await _requestsCollection.doc(requestId).update({
      'costEstimate': estimate.toMap(forNested: true),
      'updatedAt': FieldValue.serverTimestamp(),
      'timeline': FieldValue.arrayUnion([
        <String, dynamic>{
          'stage': 'cost_estimated',
          'label': 'Cost estimated by supervisor',
          'at': Timestamp.now(),
          'byRole': 'supervisor',
          'note':
              'Estimated total: ${_formatMoney(totalAmount)} • ${notes.trim().isEmpty ? 'View breakdown in estimate' : notes.trim()}',
        },
      ]),
    });
    final snap = await _requestsCollection.doc(requestId).get();
    final data = snap.data() ?? <String, dynamic>{};
    await _notifyAdmins(
      requestId: requestId,
      type: 'cost_estimate_ready',
      title: 'Cost estimate ready',
      message:
          '$supervisorName submitted a cost estimate of ${_formatMoney(totalAmount)} for ${data['customerName'] ?? 'a customer'} (${data['serviceName'] ?? 'service'}).',
    );
  }

  Future<String> _nextQuotationNumber() async {
    final snap = await _firestore!
        .collection('quotations')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    final nextNum = snap.docs.isEmpty ? 1 : snap.docs.length + 1;
    final stamp = DateTime.now();
    return 'Q-${stamp.year}${stamp.month.toString().padLeft(2, '0')}${stamp.day.toString().padLeft(2, '0')}-${nextNum.toString().padLeft(4, '0')}';
  }

  Future<Quotation> createQuotation({
    required String requestId,
    required double totalAmount,
    required List<Map<String, dynamic>> breakdown,
    required String adminName,
    String? adminUid,
    String customerName = '',
    String serviceName = '',
    String notes = '',
    int validityDays = 14,
    String status = 'draft',
    String pdfUrl = '',
    String quotationId = '',
    String customerUid = '',
  }) async {
    final collection = _firestore!.collection('quotations');
    final ref = quotationId.isEmpty
        ? collection.doc()
        : collection.doc(quotationId);
    final qNumber = quotationId.isEmpty
        ? await _nextQuotationNumber()
        : (await ref.get()).data()?['quotationNumber'] as String? ??
              await _nextQuotationNumber();
    final resolvedCustomerUid = customerUid.trim().isNotEmpty
        ? customerUid.trim()
        : ((await _requestsCollection.doc(requestId).get())
                      .data()?['customerUid']
                  as String? ??
              '');
    final quotation = Quotation(
      totalAmount: totalAmount,
      breakdown: breakdown,
      quotationNumber: qNumber,
      adminName: adminName,
      adminUid: adminUid ?? FirebaseAuth.instance.currentUser?.uid,
      customerName: customerName,
      serviceName: serviceName,
      notes: notes.trim(),
      pdfUrl: pdfUrl,
      status: status,
      validityDays: validityDays,
      quotationId: ref.id,
      requestId: requestId,
      customerUid: resolvedCustomerUid,
    );
    await ref.set({
      ...quotation.toMap(),
      'requestId': requestId,
      'customerUid': resolvedCustomerUid,
    });
    await _requestsCollection.doc(requestId).update({
      'quotation': quotation.toMap(forNested: true),
      'updatedAt': FieldValue.serverTimestamp(),
      'timeline': FieldValue.arrayUnion([
        <String, dynamic>{
          'stage': 'quotation_created',
          'label': 'Quotation created by admin',
          'at': Timestamp.now(),
          'byRole': 'admin',
          'note': 'Quotation $qNumber • Total: ${_formatMoney(totalAmount)}',
        },
      ]),
    });
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('notifications').add({
        'audience': 'admins',
        'senderUid': uid,
        'requestId': requestId,
        'type': 'quotation_created',
        'title': 'Quotation created',
        'message':
            'Quotation $qNumber created for $customerName ($serviceName) for ${_formatMoney(totalAmount)}.',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return quotation;
  }

  Future<Quotation> sendQuotation({
    required String requestId,
    required Quotation quotation,
    required Uint8List pdfBytes,
  }) async {
    if (quotation.customerUid.isEmpty) {
      throw StateError('This request is not linked to a customer account.');
    }
    if (pdfBytes.isEmpty) {
      throw StateError('The generated quotation PDF is empty.');
    }
    if (pdfBytes.lengthInBytes > 800 * 1024) {
      throw StateError(
        'The generated quotation PDF is too large to store in Firestore '
        '(maximum 800 KB).',
      );
    }

    final quotationId = quotation.quotationId.isEmpty
        ? _firestore!.collection('quotations').doc().id
        : quotation.quotationId;
    final sentQuotation = quotation.copyWith(
      status: 'sent',
      quotationId: quotationId,
      requestId: requestId,
      pdfBytes: pdfBytes,
    );
    final quotationRef = _firestore!.collection('quotations').doc(quotationId);
    final batch = _firestore.batch();
    batch.set(quotationRef, {
      ...sentQuotation.toMap(includePdfBytes: true),
      'requestId': requestId,
      'customerUid': quotation.customerUid,
      'sentAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.update(_requestsCollection.doc(requestId), {
      'quotation': sentQuotation.toMap(forNested: true),
      'updatedAt': FieldValue.serverTimestamp(),
      'timeline': FieldValue.arrayUnion([
        <String, dynamic>{
          'stage': 'quotation_sent',
          'label': 'Quotation sent to customer',
          'at': Timestamp.now(),
          'byRole': 'admin',
          'note':
              'Quotation ${quotation.quotationNumber} • Total: ${_formatMoney(quotation.totalAmount)}',
        },
      ]),
    });
    batch.set(_firestore.collection('notifications').doc(), {
      'audience': 'customer',
      'recipientUid': quotation.customerUid,
      'senderUid': FirebaseAuth.instance.currentUser?.uid,
      'requestId': requestId,
      'type': 'quotation_sent',
      'title': 'Your quotation is ready',
      'message':
          'Quotation ${quotation.quotationNumber} for ${quotation.serviceName} is ready to view.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit().timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException(
        'Saving the quotation to Firestore timed out. Check the connection '
        'and Firestore rules, then try again.',
      ),
    );
    return sentQuotation;
  }

  Stream<List<Quotation>> watchCustomerQuotations(String customerUid) {
    final firestore = _firestore;
    if (firestore == null || customerUid.trim().isEmpty) {
      return Stream.value(const <Quotation>[]);
    }
    return firestore
        .collection('quotations')
        .where('customerUid', isEqualTo: customerUid.trim())
        .snapshots()
        .map((snapshot) {
          final quotations = snapshot.docs
              .map(
                (doc) =>
                    Quotation.fromMap({...doc.data(), 'quotationId': doc.id}),
              )
              .where(
                (quotation) =>
                    quotation.status == 'sent' &&
                    quotation.pdfBytes != null &&
                    quotation.pdfBytes!.isNotEmpty,
              )
              .toList();
          quotations.sort((left, right) {
            final leftDate = left.createdAt;
            final rightDate = right.createdAt;
            if (leftDate == null && rightDate == null) return 0;
            if (leftDate == null) return 1;
            if (rightDate == null) return -1;
            return rightDate.compareTo(leftDate);
          });
          return quotations;
        });
  }

  static String _formatMoney(num amount) {
    final a = amount.toDouble();
    final whole = a.truncate();
    final dec = ((a - whole) * 100).round().toString().padLeft(2, '0');
    return 'AED ${whole.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m.group(1)},')}.$dec';
  }

  Future<String> submitCustomerQuoteRequest({
    required String serviceName,
    required String description,
    required List<String> photoUrls,
    required String customerName,
    String? customerUid,
    String customerPhone = '',
    String customerEmail = '',
    String address = '',
    String status = 'pending',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final resolvedCustomerUid = (customerUid ?? user?.uid ?? '').trim();
    final cleanServiceName = serviceName.trim().isNotEmpty
        ? serviceName.trim()
        : 'HVAC Quote';
    final cleanDescription = description.trim();
    final cleanPhotos = photoUrls
        .where((item) => item.trim().isNotEmpty)
        .toList(growable: false);
    final cleanName = customerName.trim().isNotEmpty
        ? customerName.trim()
        : (user?.displayName ?? 'Customer');
    final cleanPhone = customerPhone.trim();
    final cleanEmail = customerEmail.trim().isNotEmpty
        ? customerEmail.trim()
        : (user?.email ?? '');
    final cleanAddress = address.trim();
    final now = Timestamp.now();

    // 1. Primary document in customer_service_requests (the shared collection for Admin & Supervisor)
    final docRef = _requestsCollection.doc();
    final serviceRequestPayload = <String, dynamic>{
      'customerName': cleanName,
      'phone': cleanPhone,
      'customerPhone': cleanPhone,
      'email': cleanEmail,
      'customerEmail': cleanEmail,
      'address': cleanAddress,
      'serviceName': cleanServiceName,
      'preferredDate': 'Quote Requested',
      'preferredTime': 'Flexible',
      'notes': cleanDescription,
      'description': cleanDescription,
      'photoUrls': cleanPhotos,
      'status': status,
      'progressStage': JobProgress.requested,
      'priority': 'medium',
      'verificationStatus': '',
      'isQuoteRequest': true,
      'technicianName': '',
      'technicianUid': '',
      'customerUid': resolvedCustomerUid,
      'timeline': [
        <String, dynamic>{
          'stage': JobProgress.requested,
          'label': 'Quote requested by customer',
          'at': now,
          'byRole': 'customer',
          'note': cleanDescription.isNotEmpty
              ? cleanDescription
              : 'Customer requested a free quote with details and photos',
        },
      ],
      if (cleanPhotos.isNotEmpty || cleanDescription.isNotEmpty)
        'siteDetails': <String, dynamic>{
          'description': cleanDescription,
          'photoUrls': cleanPhotos,
          'technicianName': '$cleanName (Customer Quote Request)',
          'technicianUid': resolvedCustomerUid,
          'customerName': cleanName,
          'serviceName': cleanServiceName,
          'sharedAt': now,
          'status': 'quote_request',
        },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(serviceRequestPayload);

    // 2. Also save to site_issue so watchSiteDetailsForRequest immediately picks up the inspection photos
    if (cleanPhotos.isNotEmpty || cleanDescription.isNotEmpty) {
      try {
        await _siteIssueCollection.doc(docRef.id).set(<String, dynamic>{
          'requestId': docRef.id,
          'description': cleanDescription,
          'photoUrls': cleanPhotos,
          'technicianName': '$cleanName (Customer Quote Request)',
          'technicianUid': resolvedCustomerUid,
          'customerName': cleanName,
          'serviceName': cleanServiceName,
          'sharedAt': FieldValue.serverTimestamp(),
          'status': 'quote_request',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }

    // 3. Mirror into customer_quote_requests for compatibility with any dedicated quote screens
    try {
      await _customerQuoteRequestsCollection.doc(docRef.id).set(
        <String, dynamic>{
          'serviceName': cleanServiceName,
          'description': cleanDescription,
          'photoUrls': cleanPhotos,
          'customerName': cleanName,
          'customerUid': resolvedCustomerUid,
          'customerPhone': cleanPhone,
          'customerEmail': cleanEmail,
          'address': cleanAddress,
          'status': status,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (_) {}

    // 4. Send notification to Admins
    try {
      await _notifyAdmins(
        requestId: docRef.id,
        type: 'customer_quote_request',
        title: 'New Quote Request',
        message:
            '$cleanName submitted a quote request for $cleanServiceName. ${cleanDescription.isNotEmpty ? (cleanDescription.length > 80 ? '${cleanDescription.substring(0, 80)}...' : cleanDescription) : ''}',
      );
    } catch (_) {}

    // 5. Send notification to Supervisors
    try {
      await _notifySupervisors(
        requestId: docRef.id,
        type: 'customer_quote_request',
        title: 'New Quote Request',
        message:
            '$cleanName submitted a quote request for $cleanServiceName. Please review.',
      );
    } catch (_) {}

    return docRef.id;
  }

  Stream<List<CustomerQuoteRequest>> watchCustomerQuoteRequests({
    String statusFilter = '',
  }) {
    final firestore = _firestore;
    if (firestore == null) return Stream.value(const <CustomerQuoteRequest>[]);
    Query<Map<String, dynamic>> query = _customerQuoteRequestsCollection
        .orderBy('createdAt', descending: true);
    if (statusFilter.trim().isNotEmpty) {
      query = query.where('status', isEqualTo: statusFilter.trim());
    }
    return query.snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return CustomerQuoteRequest.fromMap(doc.id, data);
      }).toList();
    });
  }

  Stream<int> watchPendingCustomerQuoteRequestCount() {
    final firestore = _firestore;
    if (firestore == null) return Stream.value(0);
    return _customerQuoteRequestsCollection
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> updateCustomerQuoteRequestStatus(
    String requestId,
    String status,
  ) async {
    await _customerQuoteRequestsCollection.doc(requestId).update({
      'status': status.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

class CustomerQuoteRequest {
  const CustomerQuoteRequest({
    required this.id,
    required this.serviceName,
    required this.description,
    required this.photoUrls,
    required this.customerName,
    this.customerUid = '',
    this.customerPhone = '',
    this.customerEmail = '',
    this.address = '',
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String serviceName;
  final String description;
  final List<String> photoUrls;
  final String customerName;
  final String customerUid;
  final String customerPhone;
  final String customerEmail;
  final String address;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isReviewed => status.toLowerCase() == 'reviewed';
  bool get isQuoted => status.toLowerCase() == 'quoted';

  factory CustomerQuoteRequest.fromMap(String id, Map<String, dynamic> data) {
    final photos = data['photoUrls'];
    final cat = data['createdAt'];
    final uat = data['updatedAt'];
    return CustomerQuoteRequest(
      id: id,
      serviceName: (data['serviceName'] as String?)?.trim() ?? '',
      description: (data['description'] as String?)?.trim() ?? '',
      photoUrls: photos is List
          ? photos
                .map((item) => item.toString())
                .where((item) => item.trim().isNotEmpty)
                .toList()
          : const <String>[],
      customerName: (data['customerName'] as String?)?.trim() ?? 'Customer',
      customerUid: (data['customerUid'] as String?)?.trim() ?? '',
      customerPhone: (data['customerPhone'] as String?)?.trim() ?? '',
      customerEmail: (data['customerEmail'] as String?)?.trim() ?? '',
      address: (data['address'] as String?)?.trim() ?? '',
      status: (data['status'] as String?)?.trim() ?? 'pending',
      createdAt: cat is Timestamp ? cat.toDate() : null,
      updatedAt: uat is Timestamp ? uat.toDate() : null,
    );
  }
}
