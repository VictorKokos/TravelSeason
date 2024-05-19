import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelzone/auth_service.dart';
import 'package:travelzone/db_service.dart';

class TourBookingScreen extends StatefulWidget {
  final String tourId;
  const TourBookingScreen({Key? key, required this.tourId}) : super(key: key);

  @override
  State<TourBookingScreen> createState() => _TourBookingScreenState();
}

class _TourBookingScreenState extends State<TourBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _dbService = DbService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  late Future<Map<String, dynamic>?> _tourDataFuture;

  @override
  void initState() {
    super.initState();
    _tourDataFuture = _dbService.getTourById(widget.tourId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Booking'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _tourDataFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final tourData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tourData['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Payment Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name on Card',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name on card';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your card number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryDateController,
                            decoration: const InputDecoration(
                              labelText: 'Expiry Date (MM/YY)',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter expiry date';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                            ),
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter CVV';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final user = await _authService.getCurrentUser();
                          if (user != null) {
                            // Create booking document
                            final bookingData = {
                              'tourId': widget.tourId,
                              'userId': user.uid,
                              'name': _nameController.text,
                              'email': _emailController.text,
                              'cardNumber': _cardNumberController.text,
                              'expiryDate': _expiryDateController.text,
                              'cvv': _cvvController.text,
                            };
                            await _dbService.addData('bookings', bookingData);
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Booking Confirmation'),
                                content: const Text(
                                    'Your booking has been confirmed. You will be contacted soon.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop(); // Go back to previous screen
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // User is not logged in, show login/registration prompt
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Login/Registration Required'),
                                content: const Text(
                                    'Please login or register to continue.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      // Navigate to login/registration screen
                                      // ...
                                    },
                                    child: const Text('Login/Register'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Confirm Booking'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}