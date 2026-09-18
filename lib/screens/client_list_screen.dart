import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import 'client_detail_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final _firestore = FirestoreService();
  String _query = '';

  List<ClientModel> _filter(List<ClientModel> clients) {
    if (_query.trim().isEmpty) return clients;
    final q = _query.toLowerCase();
    return clients.where((c) {
      return c.fullName.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          c.bikeNumber.toLowerCase().contains(q) ||
          c.username.toLowerCase().contains(q);
    }).toList();
  }

  Color _statusColor(ClientStatus status) {
    switch (status) {
      case ClientStatus.active:
        return AppColors.primary;
      case ClientStatus.blocked:
        return AppColors.danger;
      case ClientStatus.pendingConfirmation:
        return AppColors.warning;
      case ClientStatus.pendingInfo:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(ClientStatus status) {
    switch (status) {
      case ClientStatus.active:
        return 'Active';
      case ClientStatus.blocked:
        return 'Blocked';
      case ClientStatus.pendingConfirmation:
        return 'Needs Confirmation';
      case ClientStatus.pendingInfo:
        return 'Info Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Clients')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search by name, phone, bike number...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ClientModel>>(
              stream: _firestore.watchClients(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final clients = _filter(snapshot.data!);
                if (clients.isEmpty) {
                  return const Center(child: Text('No clients found', style: TextStyle(color: AppColors.textSecondary)));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: clients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final c = clients[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(c.fullName.isEmpty ? c.username : c.fullName, style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text(
                          [if (c.phone.isNotEmpty) c.phone, if (c.bikeNumber.isNotEmpty) 'Bike: ${c.bikeNumber}'].join(' • '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor(c.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_statusLabel(c.status), style: TextStyle(color: _statusColor(c.status), fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ClientDetailScreen(clientId: c.id)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
