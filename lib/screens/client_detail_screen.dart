import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';
import '../theme.dart';

class ClientDetailScreen extends StatefulWidget {
  final String clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final _firestore = FirestoreService();
  ClientModel? _client;
  bool _loading = true;
  bool _saving = false;

  // Controllers, filled once the client loads.
  late TextEditingController _fullNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bikeNumberCtrl;
  late TextEditingController _battery1Ctrl;
  late TextEditingController _battery2Ctrl;
  late TextEditingController _rentalAmountCtrl;
  late TextEditingController _referrerNameCtrl;
  late TextEditingController _referrerPhoneCtrl;
  late TextEditingController _addressCtrl;
  DateTime? _nextPaymentDate;

  final _notifTitleCtrl = TextEditingController();
  final _notifMessageCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final client = await _firestore.getClient(widget.clientId);
    if (client == null || !mounted) return;
    setState(() {
      _client = client;
      _fullNameCtrl = TextEditingController(text: client.fullName);
      _phoneCtrl = TextEditingController(text: client.phone);
      _bikeNumberCtrl = TextEditingController(text: client.bikeNumber);
      _battery1Ctrl = TextEditingController(text: client.battery1);
      _battery2Ctrl = TextEditingController(text: client.battery2);
      _rentalAmountCtrl = TextEditingController(text: client.rentalAmount);
      _referrerNameCtrl = TextEditingController(text: client.referrerName);
      _referrerPhoneCtrl = TextEditingController(text: client.referrerPhone);
      _addressCtrl = TextEditingController(text: client.address);
      _nextPaymentDate = client.nextPaymentDate;
      _loading = false;
    });
  }

  Future<void> _saveInfo() async {
    setState(() => _saving = true);
    try {
      await _firestore.updateClient(widget.clientId, {
        'fullName': _fullNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'bikeNumber': _bikeNumberCtrl.text.trim(),
        'battery1': _battery1Ctrl.text.trim(),
        'battery2': _battery2Ctrl.text.trim(),
        'rentalAmount': _rentalAmountCtrl.text.trim(),
        'referrerName': _referrerNameCtrl.text.trim(),
        'referrerPhone': _referrerPhoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        if (_nextPaymentDate != null) 'nextPaymentDate': _nextPaymentDate,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes saved')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmClient() async {
    await _firestore.setStatus(widget.clientId, ClientStatus.active);
    await _load();
    if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Client confirmed — dashboard is now unlocked')));
  }

  Future<void> _toggleBlock() async {
    final newStatus = _client!.status == ClientStatus.blocked ? ClientStatus.active : ClientStatus.blocked;
    await _firestore.setStatus(widget.clientId, newStatus);
    await _load();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextPaymentDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _nextPaymentDate = picked);
  }

  Future<void> _sendNotification() async {
    if (_notifTitleCtrl.text.trim().isEmpty) return;
    await _firestore.sendNotification(widget.clientId, _notifTitleCtrl.text.trim(), _notifMessageCtrl.text.trim());
    _notifTitleCtrl.clear();
    _notifMessageCtrl.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification sent')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _client == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final client = _client!;
    return Scaffold(
      appBar: AppBar(title: Text(client.fullName.isEmpty ? client.username : client.fullName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusBanner(client: client, onConfirm: _confirmClient, onToggleBlock: _toggleBlock),
          const SizedBox(height: 20),

          Text('Client Information', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(controller: _fullNameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
          const SizedBox(height: 12),
          TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
          const SizedBox(height: 12),
          TextField(controller: _bikeNumberCtrl, decoration: const InputDecoration(labelText: 'Bike Number')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _battery1Ctrl, decoration: const InputDecoration(labelText: 'Battery No. 1'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _battery2Ctrl, decoration: const InputDecoration(labelText: 'Battery No. 2'))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _rentalAmountCtrl, decoration: const InputDecoration(labelText: 'Rental Amount')),
          const SizedBox(height: 12),
          TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Full Address'), maxLines: 2),
          const SizedBox(height: 12),
          TextField(controller: _referrerNameCtrl, decoration: const InputDecoration(labelText: 'Referer Full Name')),
          const SizedBox(height: 12),
          TextField(controller: _referrerPhoneCtrl, decoration: const InputDecoration(labelText: 'Referer Phone Number')),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Next Payment Date'),
              child: Text(
                _nextPaymentDate != null ? DateFormat('dd MMM yyyy').format(_nextPaymentDate!) : 'Select date',
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saving ? null : _saveInfo,
            child: _saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Save Info'),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text('Send Notification', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(controller: _notifTitleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(controller: _notifMessageCtrl, decoration: const InputDecoration(labelText: 'Message'), maxLines: 3),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _sendNotification,
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Send'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.border),
              foregroundColor: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 24),
          Text('Documents', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _DocumentRow(label: 'Passport Copy', url: client.passportUrl),
          const SizedBox(height: 8),
          _DocumentRow(label: 'Récépissé / Séjour Copy', url: client.recepisseUrl),
          const SizedBox(height: 8),
          _DocumentRow(label: 'Domicile / Proof of Address', url: client.domicileUrl),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final ClientModel client;
  final VoidCallback onConfirm;
  final VoidCallback onToggleBlock;

  const _StatusBanner({required this.client, required this.onConfirm, required this.onToggleBlock});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _label(client.status),
                style: TextStyle(color: _color(client.status), fontWeight: FontWeight.w600),
              ),
            ),
            if (client.status == ClientStatus.pendingConfirmation)
              ElevatedButton(onPressed: onConfirm, child: const Text('Confirm')),
            if (client.status == ClientStatus.active || client.status == ClientStatus.blocked)
              OutlinedButton(
                onPressed: onToggleBlock,
                style: OutlinedButton.styleFrom(
                  foregroundColor: client.status == ClientStatus.blocked ? AppColors.primary : AppColors.danger,
                  side: BorderSide(color: client.status == ClientStatus.blocked ? AppColors.primary : AppColors.danger),
                ),
                child: Text(client.status == ClientStatus.blocked ? 'Unblock' : 'Block'),
              ),
          ],
        ),
      ),
    );
  }

  String _label(ClientStatus s) {
    switch (s) {
      case ClientStatus.pendingInfo:
        return 'Waiting for client to fill info';
      case ClientStatus.pendingConfirmation:
        return 'Client submitted — needs your confirmation';
      case ClientStatus.active:
        return 'Active';
      case ClientStatus.blocked:
        return 'Blocked';
    }
  }

  Color _color(ClientStatus s) {
    switch (s) {
      case ClientStatus.pendingInfo:
        return AppColors.textSecondary;
      case ClientStatus.pendingConfirmation:
        return AppColors.warning;
      case ClientStatus.active:
        return AppColors.primary;
      case ClientStatus.blocked:
        return AppColors.danger;
    }
  }
}

class _DocumentRow extends StatelessWidget {
  final String label;
  final String url;
  const _DocumentRow({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    final hasFile = url.isNotEmpty;
    return Card(
      child: ListTile(
        leading: Icon(hasFile ? Icons.description : Icons.description_outlined, color: hasFile ? AppColors.primary : AppColors.textSecondary),
        title: Text(label),
        subtitle: Text(hasFile ? 'Uploaded by client' : 'Not uploaded yet', style: const TextStyle(fontSize: 12)),
        trailing: hasFile
            ? TextButton(
          onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          child: const Text('Open'),
        )
            : null,
      ),
    );
  }
}
