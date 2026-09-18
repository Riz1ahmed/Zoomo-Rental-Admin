import 'package:cloud_firestore/cloud_firestore.dart';

/// Lifecycle of a client account.
/// pendingInfo        -> client hasn't filled the info form yet
/// pendingConfirmation-> client submitted, waiting for admin to confirm
/// active             -> confirmed, cycle handed over, in good standing
/// blocked            -> payment issue, cycle access blocked
enum ClientStatus { pendingInfo, pendingConfirmation, active, blocked }

ClientStatus statusFromString(String? value) {
  switch (value) {
    case 'pendingConfirmation':
      return ClientStatus.pendingConfirmation;
    case 'active':
      return ClientStatus.active;
    case 'blocked':
      return ClientStatus.blocked;
    default:
      return ClientStatus.pendingInfo;
  }
}

String statusToString(ClientStatus status) => status.name;

class ClientModel {
  final String id; // Firestore doc id
  final String username;
  final String password; // plain text by design (see README note)
  final String fullName;
  final String phone;
  final String bikeNumber;
  final String battery1;
  final String battery2;
  final String rentalAmount;
  final String referrerName;
  final String referrerPhone;
  final String address;
  final String passportUrl;
  final String recepisseUrl;
  final String domicileUrl;
  final DateTime? nextPaymentDate;
  final ClientStatus status;
  final DateTime? createdAt;

  ClientModel({
    required this.id,
    required this.username,
    required this.password,
    this.fullName = '',
    this.phone = '',
    this.bikeNumber = '',
    this.battery1 = '',
    this.battery2 = '',
    this.rentalAmount = '',
    this.referrerName = '',
    this.referrerPhone = '',
    this.address = '',
    this.passportUrl = '',
    this.recepisseUrl = '',
    this.domicileUrl = '',
    this.nextPaymentDate,
    this.status = ClientStatus.pendingInfo,
    this.createdAt,
  });

  factory ClientModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ClientModel(
      id: doc.id,
      username: data['username'] ?? '',
      password: data['password'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      bikeNumber: data['bikeNumber'] ?? '',
      battery1: data['battery1'] ?? '',
      battery2: data['battery2'] ?? '',
      rentalAmount: data['rentalAmount'] ?? '',
      referrerName: data['referrerName'] ?? '',
      referrerPhone: data['referrerPhone'] ?? '',
      address: data['address'] ?? '',
      passportUrl: data['passportUrl'] ?? '',
      recepisseUrl: data['recepisseUrl'] ?? '',
      domicileUrl: data['domicileUrl'] ?? '',
      nextPaymentDate: (data['nextPaymentDate'] as Timestamp?)?.toDate(),
      status: statusFromString(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'fullName': fullName,
      'phone': phone,
      'bikeNumber': bikeNumber,
      'battery1': battery1,
      'battery2': battery2,
      'rentalAmount': rentalAmount,
      'referrerName': referrerName,
      'referrerPhone': referrerPhone,
      'address': address,
      'passportUrl': passportUrl,
      'recepisseUrl': recepisseUrl,
      'domicileUrl': domicileUrl,
      'nextPaymentDate': nextPaymentDate != null ? Timestamp.fromDate(nextPaymentDate!) : null,
      'status': statusToString(status),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  ClientModel copyWith({
    String? fullName,
    String? phone,
    String? bikeNumber,
    String? battery1,
    String? battery2,
    String? rentalAmount,
    String? referrerName,
    String? referrerPhone,
    String? address,
    DateTime? nextPaymentDate,
    ClientStatus? status,
  }) {
    return ClientModel(
      id: id,
      username: username,
      password: password,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      bikeNumber: bikeNumber ?? this.bikeNumber,
      battery1: battery1 ?? this.battery1,
      battery2: battery2 ?? this.battery2,
      rentalAmount: rentalAmount ?? this.rentalAmount,
      referrerName: referrerName ?? this.referrerName,
      referrerPhone: referrerPhone ?? this.referrerPhone,
      address: address ?? this.address,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
