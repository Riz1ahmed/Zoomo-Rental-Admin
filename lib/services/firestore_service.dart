import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client_model.dart';

/// All Firestore reads/writes go through here, so screens never touch
/// FirebaseFirestore directly. Makes it trivial to change collection
/// names or add caching later without hunting through every screen.
class FirestoreService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _clients => _db.collection('clients');
  CollectionReference<Map<String, dynamic>> get _admins => _db.collection('admins');

  // ---------- Admin login ----------
  Future<bool> checkAdminCredentials(String username, String password) async {
    final query = await _admins
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // ---------- Clients ----------
  Stream<List<ClientModel>> watchClients() {
    return _clients.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map(ClientModel.fromDoc).toList(),
        );
  }

  Future<ClientModel?> getClient(String id) async {
    final doc = await _clients.doc(id).get();
    if (!doc.exists) return null;
    return ClientModel.fromDoc(doc);
  }

  /// Creates a client with just login credentials + whatever the admin
  /// already knows. Everything else gets filled in later by the client
  /// or the admin.
  Future<void> createClient({
    required String username,
    required String password,
    String fullName = '',
    String phone = '',
    String bikeNumber = '',
  }) async {
    await _clients.add({
      'username': username,
      'password': password,
      'fullName': fullName,
      'phone': phone,
      'bikeNumber': bikeNumber,
      'battery1': '',
      'battery2': '',
      'rentalAmount': '',
      'referrerName': '',
      'referrerPhone': '',
      'address': '',
      'nextPaymentDate': null,
      'status': 'pendingInfo',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateClient(String id, Map<String, dynamic> fields) async {
    await _clients.doc(id).update(fields);
  }

  Future<void> setStatus(String id, ClientStatus status) async {
    await _clients.doc(id).update({'status': statusToString(status)});
  }

  Future<void> deleteClient(String id) async {
    await _clients.doc(id).delete();
  }

  // ---------- Notifications (per client) ----------
  Future<void> sendNotification(String clientId, String title, String message) async {
    await _clients.doc(clientId).collection('notifications').add({
      'title': title,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  Stream<List<Map<String, dynamic>>> watchNotifications(String clientId) {
    return _clients
        .doc(clientId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  // ---------- Dashboard summary ----------
  Future<Map<String, int>> getSummary() async {
    final snap = await _clients.get();
    int active = 0, blocked = 0, pending = 0;
    int dueSoon = 0;
    final now = DateTime.now();
    for (final doc in snap.docs) {
      final client = ClientModel.fromDoc(doc);
      switch (client.status) {
        case ClientStatus.active:
          active++;
          break;
        case ClientStatus.blocked:
          blocked++;
          break;
        default:
          pending++;
      }
      if (client.nextPaymentDate != null) {
        final diff = client.nextPaymentDate!.difference(now).inDays;
        if (diff >= 0 && diff <= 3) dueSoon++;
      }
    }
    return {
      'total': snap.docs.length,
      'active': active,
      'blocked': blocked,
      'pending': pending,
      'dueSoon': dueSoon,
    };
  }
}
