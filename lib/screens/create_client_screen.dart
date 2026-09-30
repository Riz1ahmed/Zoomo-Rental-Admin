import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../theme.dart';

class CreateClientScreen extends StatefulWidget {
  const CreateClientScreen({super.key});

  @override
  State<CreateClientScreen> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends State<CreateClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _firestore = FirestoreService();
  bool _saving = false;
  String? _usernameTakenError;

  Future<void> _save() async {
    setState(() => _usernameTakenError = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _firestore.createClient(
        username: _usernameCtrl.text.trim().toLowerCase(),
        password: _passwordCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client created. Share the username and password with them.')),
      );
      Navigator.of(context).pop();
    } on DuplicateClientUsernameException {
      if (!mounted) return;
      setState(() => _usernameTakenError = 'This username is already taken.');
      _formKey.currentState!.validate();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Client')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Login Credentials', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Share these credentials with the client via WhatsApp or SMS.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
              onChanged: (_) {
                if (_usernameTakenError != null) {
                  setState(() => _usernameTakenError = null);
                }
              },
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                return _usernameTakenError;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('Create Client'),
            ),
          ],
        ),
      ),
    );
  }
}
