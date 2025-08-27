import 'package:flutter/material.dart';

class RequestAppointmentScreen extends StatelessWidget {
  const RequestAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Nueva Cita'),
      ),
      body: const Center(
        child: Text('Aquí irá el formulario para solicitar citas.'),
      ),
    );
  }
}