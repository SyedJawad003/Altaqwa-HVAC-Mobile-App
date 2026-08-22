import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Al-Taqwa'),
      backgroundColor: Colors.transparent,
    ),
    body: const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WELCOME TO AL-TAQWA HVAC',
            style: TextStyle(color: Colors.teal, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Comfort and climate, handled.',
            style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 28),
          Card(
            color: Color(0xFF12312B),
            child: Padding(
              padding: EdgeInsets.all(22),
              child: Text(
                'Schedule maintenance, request a repair, or manage your HVAC service visits in one place.',
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
