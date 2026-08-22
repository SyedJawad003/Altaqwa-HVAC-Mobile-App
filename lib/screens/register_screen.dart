import 'package:flutter/material.dart';

import 'home_screen.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService().registerUser(
        name: _name.text,
        email: _email.text,
        phone: _phone.text,
        password: _password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your account is ready.')));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/regbg.png',
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) =>
              Container(decoration: BoxDecoration(gradient: navyGradient)),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(color: navy),
                      decoration: _fieldDecoration(
                        label: 'Full name',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your name.'
                          : null,
                    ),
                    const SizedBox(height: 7),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: navy),
                      decoration: _fieldDecoration(
                        label: 'Email address',
                        icon: Icons.email_outlined,
                      ),
                      validator: (value) =>
                          value != null &&
                              RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(value.trim())
                          ? null
                          : 'Enter a valid email.',
                    ),
                    const SizedBox(height: 7),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: navy),
                      decoration: _fieldDecoration(
                        label: 'Phone number',
                        icon: Icons.phone_outlined,
                      ),
                      validator: (value) =>
                          value == null || value.trim().length < 7
                          ? 'Enter a valid phone number.'
                          : null,
                    ),
                    const SizedBox(height: 7),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      style: const TextStyle(color: navy),
                      decoration: _fieldDecoration(
                        label: 'Password',
                        icon: Icons.lock_outline,
                      ),
                      validator: (value) => value != null && value.length >= 6
                          ? null
                          : 'Use at least 6 characters.',
                    ),
                    const SizedBox(height: 7),
                    TextFormField(
                      controller: _confirmation,
                      obscureText: true,
                      style: const TextStyle(color: navy),
                      decoration: _fieldDecoration(
                        label: 'Confirm password',
                        icon: Icons.verified_user_outlined,
                      ),
                      validator: (value) => value != _password.text
                          ? 'Passwords do not match.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton(
                        onPressed: _loading ? null : _register,
                        child: _loading
                            ? const SizedBox(
                                width: 19,
                                height: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('CREATE ACCOUNT'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
  }) => const InputDecoration().copyWith(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.black54),
    prefixIcon: Icon(icon, color: navy),
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Colors.black26),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Colors.black26),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: gold, width: 2),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Colors.red),
    ),
  );
}
