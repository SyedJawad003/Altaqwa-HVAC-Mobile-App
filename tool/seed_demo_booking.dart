import 'dart:io';

import 'package:altaqwa_app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  await firestore.collection('customer_service_requests').add({
    'customerName': 'Ahmed Rahman',
    'phone': '+971 50 123 4567',
    'address': 'Villa 24, Sharjah, UAE',
    'serviceName': 'AC Installation',
    'preferredDate': '04/09/2026',
    'preferredTime': '10:30 AM',
    'notes': 'Need installation for 2-bedroom villa with 2 indoor units.',
    'status': 'pending',
    'technicianName': '',
    'createdAt': FieldValue.serverTimestamp(),
  });

  stdout.writeln('Demo booking added to Firestore.');
}
