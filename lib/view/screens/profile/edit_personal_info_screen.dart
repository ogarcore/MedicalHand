import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  final UserModel user;
  const EditPersonalInfoScreen({super.key, required this.user});

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Controladores para todos los campos editables ---
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _dobController; // Para mostrar la fecha como texto
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  DateTime? _selectedDate; // Para guardar el objeto DateTime real
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los datos del UserModel
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _idNumberController = TextEditingController(text: widget.user.idNumber);

    // El Timestamp de Firestore se convierte a DateTime para el DatePicker
    _selectedDate = widget.user.dateOfBirth.toDate();
    // Y se formatea como String para mostrarlo en el campo de texto
    _dobController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_selectedDate!),
    );

    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _addressController = TextEditingController(text: widget.user.address);
  }

  @override
  void dispose() {
    // Liberar todos los controladores
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idNumberController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- Método para mostrar el selector de fecha ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale(
        'es',
        'ES',
      ), // Para que el calendario salga en español
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // --- Lógica para guardar los datos actualizados ---
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Construye el mapa con la notación de puntos para actualizar campos anidados
    final Map<String, dynamic> updatedData = {
      'personalInfo.firstName': _firstNameController.text.trim(),
      'personalInfo.lastName': _lastNameController.text.trim(),
      'personalInfo.idNumber': _idNumberController.text.trim(),
      'contactInfo.phoneNumber': _phoneController.text.trim(),
      'contactInfo.address': _addressController.text.trim(),
    };

    // Solo añade la fecha si se seleccionó una, guardándola como Timestamp
    if (_selectedDate != null) {
      updatedData['personalInfo.dateOfBirth'] = Timestamp.fromDate(
        _selectedDate!,
      );
    }

    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    final success = await viewModel.updateUserProfile(updatedData);

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Información actualizada con éxito.'
              : 'Error al actualizar. Inténtalo de nuevo.',
        ),
        backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        appBar: AppBar(
          title: const Text('Información Personal'),
          backgroundColor: AppColors.accentColor(context),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildInfoCard(),
                const SizedBox(height: 32),

                // --- Campos del Formulario ---
                _buildTextField(
                  controller: _firstNameController,
                  labelText: 'Nombres',
                  hintText: 'Tus nombres',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _lastNameController,
                  labelText: 'Apellidos',
                  hintText: 'Tus apellidos',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _idNumberController,
                  labelText: 'Cédula de Identidad',
                  hintText: 'Tu número de cédula',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _dobController,
                  labelText: 'Fecha de Nacimiento',
                  hintText: 'Selecciona tu fecha',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _phoneController,
                  labelText: 'Teléfono',
                  hintText: 'Tu número de teléfono',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _addressController,
                  labelText: 'Dirección',
                  hintText: 'Tu dirección de domicilio',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  text: 'Guardar Cambios',
                  onPressed: _handleSave,
                  isLoading: _isLoading,
                  backgroundColor: AppColors.accentColor(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper para no repetir el estilo de la tarjeta de info
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentColor(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit_outlined,
              size: 40,
              color: AppColors.accentColor(context),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Editar Datos Personales',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Mantén tu información personal y de contacto actualizada.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // Widget helper para no repetir el estilo de los campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      icon: icon,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo no puede estar vacío.';
        }
        return null;
      },
    );
  }
}
