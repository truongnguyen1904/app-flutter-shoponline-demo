import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class Customer {
  final String id;
  final String firstname;
  final String lastname;
  final String phone;
  final String address;
  final String email;
  final String img;
  final DateTime? dateOfBirth;
  final bool role;

  Customer({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.address,
    required this.email,
    required this.img,
    this.dateOfBirth,
    required this.role,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      firstname: map['firstname'] ?? '',
      lastname: map['lastname'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      img: map['img'] ?? '',
      dateOfBirth: map['dateofbirth'] != null
          ? DateTime.tryParse(map['dateofbirth'])
          : null,
      role: map['role'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'address': address,
      'email': email,
      'img': img,
      'dateofbirth': dateOfBirth?.toIso8601String(),
      'role': role,
    };
  }

  static final client = Supabase.instance.client;

  static Future<Map<String, dynamic>?> getCustomerById(String userId) async {
    final response = await client
        .from('Customer')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  static Future<String> uploadImage(File image, String userId) async {
    final imageName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    await client.storage.from('avatars').upload('public/$userId/$imageName', image);
    final publicUrl = client.storage.from('avatars').getPublicUrl('public/$userId/$imageName');
    return publicUrl;
  }

  static Future<void> insertCustomer({
    required String userId,
    required String firstname,
    required String lastname,
    required String phone,
    required String address,
    required String email,
    required String img,
    required DateTime? dateofbirth,
  }) async {
    await client.from('Customer').upsert({
      'id': userId,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'address': address,
      'email': email,
      'img': img,
      'dateofbirth': dateofbirth?.toIso8601String(),
      'role': false,
    });
  }

  static Future<String?> fetchCustomerName(String? customerId) async {
    if (customerId == null) return null;
    final response = await client
        .from('Customer')
        .select('lastname')
        .eq('id', customerId)
        .maybeSingle();
    return response?['lastname'] as String?;
  }

  static Future<String?> fetchCustomerAvatarUrl(String? customerId) async {
    if (customerId == null) return null;
    final response = await client
        .from('Customer')
        .select('img')
        .eq('id', customerId)
        .maybeSingle();
    return response?['img'] as String?;
  }
}