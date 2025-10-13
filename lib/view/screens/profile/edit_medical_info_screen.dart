// lib/view/screens/profile/edit_medical_info_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class EditMedicalInfoScreen extends StatefulWidget {
  final UserModel user;
  const EditMedicalInfoScreen({super.key, required this.user});

  @override
  State<EditMedicalInfoScreen> createState() => _EditMedicalInfoScreenState();
}

class _EditMedicalInfoScreenState extends State<EditMedicalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bloodTypeController;
  late TextEditingController _allergiesController;
  // ✅ FIX: Se añaden controladores y estado para los padecimientos crónicos.
  late TextEditingController _chronicDiseaseController;
  late List<String> _chronicDiseases;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bloodTypeController = TextEditingController(
      text: widget.user.medicalInfo?['bloodType'] ?? '',
    );
    _allergiesController = TextEditingController(
      text: widget.user.medicalInfo?['knownAllergies'] ?? '',
    );
    
    // ✅ FIX: Se inicializa el controlador y la lista de padecimientos.
    _chronicDiseaseController = TextEditingController();
    // Se convierte la lista de 'dynamic' a 'String' de forma segura.
    final diseasesFromDB = widget.user.medicalInfo?['chronicDiseases'] as List?;
    _chronicDiseases = diseasesFromDB?.map((e) => e.toString()).toList() ?? [];
  }

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _chronicDiseaseController.dispose(); // ✅ FIX: Se dispone el nuevo controlador.
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedData = {
      'medicalInfo.bloodType': _bloodTypeController.text.trim(),
      'medicalInfo.knownAllergies': _allergiesController.text.trim(),
      'medicalInfo.chronicDiseases': _chronicDiseases,
    };

    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    final success = await viewModel.updateUserProfile(updatedData);

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                success
                    ? 'Información actualizada con éxito.'
                    : 'Error al actualizar.',
              ),
            ),
          ],
        ),
        backgroundColor: success
            ? AppColors.secondaryColor(context).withAlpha(220)
            : AppColors.warningColor(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
        duration: const Duration(seconds: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
    if (success) {
      Navigator.pop(context);
    }
  }
  
  // ✅ FIX: Función para añadir un nuevo padecimiento a la lista.
  void _addChronicDisease() {
    final newDisease = _chronicDiseaseController.text.trim();
    if (newDisease.isNotEmpty && !_chronicDiseases.contains(newDisease)) {
      setState(() {
        _chronicDiseases.add(newDisease);
        _chronicDiseaseController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        appBar: AppBar(
          title: const Text('Información Médica'),
          backgroundColor: AppColors.accentColor(context),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header con mejor diseño
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentColor(context).withOpacity(0.1),
                      AppColors.accentColor(context).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accentColor(context).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accentColor(context),
                            AppColors.accentColor(context).withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentColor(context).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        HugeIcons.strokeRoundedCovidInfo,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Editar Información Médica',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentColor(context),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Esta información es crucial en caso de emergencias médicas',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Formulario con mejor espaciado y diseño
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildTextFieldEnhanced(
                                controller: _bloodTypeController,
                                labelText: 'Tipo de Sangre',
                                hintText: 'Ej: O+, AB-, B+',
                                icon: Icons.bloodtype_outlined,
                                validator: AppValidators.validateOptionalBloodType,
                              ),
                              const SizedBox(height: 20),
                              _buildTextFieldEnhanced(
                                controller: _allergiesController,
                                labelText: 'Alergias Conocidas',
                                hintText: 'Ej: Penicilina, Maní, etc.',
                                icon: Icons.warning_amber_rounded,
                                maxLines: 3,
                                minLines: 1,
                              ),
                              const SizedBox(height: 20),
                              // ✅ FIX: Se añade la sección para padecimientos crónicos.
                              _buildChronicDiseasesSection(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Botón de guardar con mejor diseño
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: PrimaryButton(
                              text: 'Guardar Cambios',
                              onPressed: _handleSave,
                              isLoading: _isLoading,
                              backgroundColor: AppColors.accentColor(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // ✅ FIX: Nuevo widget para la sección de padecimientos crónicos.
  Widget _buildChronicDiseasesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo para añadir nuevo padecimiento
        _buildTextFieldEnhanced(
          controller: _chronicDiseaseController,
          labelText: 'Padecimientos Crónicos',
          hintText: 'Ej: Hipertensión, Diabetes...',
          icon: HugeIcons.strokeRoundedHealth,
          // Se usa un `suffixIcon` para el botón de añadir
          suffixIcon: IconButton(
            icon: Icon(Icons.add_circle, color: AppColors.accentColor(context)),
            onPressed: _addChronicDisease,
          ),
          onSubmitted: (_) => _addChronicDisease(),
        ),
        
        // Espacio si hay padecimientos en la lista
        if (_chronicDiseases.isNotEmpty) const SizedBox(height: 12),
        
        // Lista de padecimientos como "chips"
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _chronicDiseases.map((disease) {
            return Chip(
              label: Text(disease, style: const TextStyle(fontWeight: FontWeight.w500)),
              onDeleted: () {
                setState(() {
                  _chronicDiseases.remove(disease);
                });
              },
              deleteIcon: const Icon(Icons.close, size: 18),
              backgroundColor: AppColors.accentColor(context).withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppColors.accentColor(context).withOpacity(0.2)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextFieldEnhanced({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    int? minLines,
    int? maxLines = 1,
    Widget? suffixIcon, // Se añade para el botón de añadir
    Function(String)? onSubmitted, // Se añade para el enter del teclado
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onTap: onTap,
        minLines: minLines,
        maxLines: maxLines,
        onFieldSubmitted: onSubmitted,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          suffixIcon: suffixIcon,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          labelStyle: TextStyle(
            color: AppColors.accentColor(context),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentColor(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.accentColor(context),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.accentColor(context),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
        validator: validator,
      ),
    );
  }
}