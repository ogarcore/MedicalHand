import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/input_formatters.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/screens/profile/edit_medical_info_screen.dart';
import 'package:p_hn25/view/screens/profile/edit_personal_info_screen.dart';
import 'package:p_hn25/view/screens/profile/settings/app_preferences_screen.dart';
import 'package:p_hn25/view/screens/profile/settings/notification_preferences_screen.dart';
import 'package:p_hn25/view/screens/profile/settings/account_security_screen.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Se mantienen los imports de los widgets locales
import 'info_row.dart';
import 'profile_header.dart';
import 'settings_row.dart';
import 'info_card.dart';
import 'profile_section_header.dart';
import 'profile_divider.dart';

class ProfileContentView extends StatefulWidget {
  final UserModel user;

  const ProfileContentView({super.key, required this.user});

  @override
  State<ProfileContentView> createState() => _ProfileContentViewState();
}

class _ProfileContentViewState extends State<ProfileContentView> {
  bool _isUploadingFront = false;
  bool _isUploadingBack = false;

  String _formatDateOfBirth() {
    initializeDateFormatting('es_ES', null);
    try {
      return DateFormat(
        'd \'de\' MMMM, y',
        'es_ES',
      ).format(widget.user.dateOfBirth.toDate());
    } catch (e) {
      return 'Fecha no disponible';
    }
  }

  String _formatChronicDiseases() {
    final diseases = widget.user.medicalInfo?['chronicDiseases'] as List?;
    return (diseases == null || diseases.isEmpty)
        ? 'Ninguna reportada'
        : diseases.join(', ');
  }

  // ✅ FIX: Corregido. El UserModel ya nos da el mapa del contacto directamente.
  // No hay necesidad de buscar 'emergencyContact' dentro de sí mismo.
  Map<String, dynamic> _getEmergencyContact() {
    final contact = widget.user.emergencyContact;
    return contact?.map((key, value) => MapEntry(key.toString(), value)) ?? {};
  }

  void _showEditEmergencyContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => EmergencyContactDialog(user: widget.user),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black45,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Material(
                  color: Colors.black.withAlpha(128),
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(String imageType) async {
    final isFront = imageType == 'id_front';
    if ((isFront && _isUploadingFront) || (!isFront && _isUploadingBack)) {
      return;
    }

    var status = await Permission.photos.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('se_necesita_permiso_para_acceder_a_la_galera'.tr()),
            backgroundColor: Colors.orange,
          ),
        );
      }
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
      return;
    }

    setState(() {
      if (isFront) {
        _isUploadingFront = true;
      } else {
        _isUploadingBack = true;
      }
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        setState(() {
          if (isFront) {
            _isUploadingFront = false;
          } else {
            _isUploadingBack = false;
          }
        });
        return;
      }

      File imageFile = File(pickedFile.path);

      final storageRef = FirebaseStorage.instance.ref(
        'user_identity_documents/${widget.user.uid}/$imageType.jpg',
      );

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String newDownloadUrl = await snapshot.ref.getDownloadURL();

      String firestoreField = isFront
          ? 'verification.idFrontUrl'
          : 'verification.idBackUrl';
      if (!mounted) return;
      final success = await Provider.of<UserViewModel>(
        context,
        listen: false,
      ).updateUserProfile({firestoreField: newDownloadUrl});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Imagen actualizada con éxito.'
                  : 'Error al actualizar la imagen.',
            ),
            backgroundColor: success
                ? Colors.green.shade700
                : Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ocurrió un error. Inténtalo de nuevo.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (isFront) {
            _isUploadingFront = false;
          } else {
            _isUploadingBack = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // La UI ahora leerá correctamente la información del contacto
    final emergencyContact = _getEmergencyContact();
    final hasEmergencyContact =
        emergencyContact.isNotEmpty &&
        emergencyContact['name'] != null &&
        (emergencyContact['name'] as String).isNotEmpty;

    final String? idFrontUrl = widget.user.verification?['idFrontUrl'];
    final String? idBackUrl = widget.user.verification?['idBackUrl'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: ProfileHeader(user: widget.user),
          ),
          ProfileSectionHeader(
            title: 'informacin_personal'.tr(),
            icon: HugeIcons.strokeRoundedUserCircle02,
            onEditPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPersonalInfoScreen(user: widget.user),
                ),
              );
            },
          ),
          InfoCard(
            children: [
              InfoRow(
                label: 'nombre_completo'.tr(),
                value: '${widget.user.firstName} ${widget.user.lastName}',
                isFirst: true,
              ),
              const ProfileDivider(),
              InfoRow(
                label: 'fecha_de_nacimiento'.tr(),
                value: _formatDateOfBirth(),
              ),
              const ProfileDivider(),
              Column(
                children: [
                  InfoRow(
                    label: 'cdula_de_identidad'.tr(),
                    value: widget.user.idNumber,
                  ),
                  if (idFrontUrl != null || idBackUrl != null)
                    _buildIdImageViewer(context, idFrontUrl, idBackUrl),
                ],
              ),
              const SizedBox(height: 10),
              const ProfileDivider(),
              InfoRow(label: 'telfono'.tr(), value: widget.user.phoneNumber),
              const ProfileDivider(),
              InfoRow(
                label: 'direccin'.tr(),
                value: widget.user.address,
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProfileSectionHeader(
            title: 'informacin_mdica'.tr(),
            icon: HugeIcons.strokeRoundedHealth,
            onEditPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditMedicalInfoScreen(user: widget.user),
                ),
              );
            },
          ),
          InfoCard(
            children: [
              InfoRow(
                label: 'tipo_de_sangre'.tr(),
                value:
                    widget.user.medicalInfo?['bloodType'] ?? 'No especificado',
                isFirst: true,
              ),
              const ProfileDivider(),
              InfoRow(
                label: 'alergias_conocidas'.tr(),
                value:
                    widget.user.medicalInfo?['knownAllergies'] ??
                    'ninguna_reportada'.tr(),
              ),
              const ProfileDivider(),
              InfoRow(
                label: 'padecimientos_crnicos'.tr(),
                value: _formatChronicDiseases(),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProfileSectionHeader(
            title: 'contacto_de_emergencia'.tr(),
            icon: HugeIcons.strokeRoundedContact02,
          ),
          InfoCard(
            children: [
              hasEmergencyContact
                  ? _buildExistingContact(emergencyContact)
                  : _buildAddContactPrompt(context),
            ],
          ),
          const SizedBox(height: 16),
          ProfileSectionHeader(
            title: 'ajustes_y_preferencias'.tr(),
            icon: HugeIcons.strokeRoundedSettings02,
          ),
          InfoCard(
            children: [
              SettingsRow(
                title: 'preferencias_de_la_aplicacin'.tr(),
                icon: HugeIcons.strokeRoundedPhoneArrowDown,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppPreferencesScreen(),
                  ),
                ),
                isFirst: true,
              ),
              const ProfileDivider(),
              SettingsRow(
                title: 'preferencias_de_notificaciones'.tr(),
                icon: HugeIcons.strokeRoundedNotification01,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationPreferencesScreen(),
                  ),
                ),
              ),
              const ProfileDivider(),
              SettingsRow(
                title: 'gestin_de_la_cuenta_y_seguridad'.tr(),
                icon: HugeIcons.strokeRoundedShield01,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccountSecurityScreen(),
                  ),
                ),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'tu_informacin_est_segura_con_nosotros'.tr(),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingContact(Map<String, dynamic> contact) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentColor(context).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              HugeIcons.strokeRoundedContact02,
              color: AppColors.accentColor(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact['phone'] ?? 'N/A',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.accentColor(context),
              size: 20,
            ),
            onPressed: () => _showEditEmergencyContactDialog(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddContactPrompt(BuildContext context) {
    return InkWell(
      onTap: () => _showEditEmergencyContactDialog(context),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warningColor(context).withAlpha(26),
              ),
              child: Icon(
                HugeIcons.strokeRoundedAddCircle,
                color: AppColors.warningColor(context),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'aadir_contacto'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'agrega_a_alguien_para_notificar_en_caso_de_emergencia'
                        .tr(),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdImageViewer(
    BuildContext context,
    String? frontUrl,
    String? backUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (frontUrl != null)
            Expanded(
              child: _buildImageContainer(
                'frente_de_la_cdula'.tr(),
                frontUrl,
                context,
                'id_front',
                _isUploadingFront,
              ),
            ),
          if (frontUrl != null && backUrl != null) const SizedBox(width: 16),
          if (backUrl != null)
            Expanded(
              child: _buildImageContainer(
                'reverso_de_la_cdula'.tr(),
                backUrl,
                context,
                'id_back',
                _isUploadingBack,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(
    String label,
    String url,
    BuildContext context,
    String imageType,
    bool isLoading,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => _showImageDialog(context, url),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Image.network(
                    url,
                    key: ValueKey(url),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: 100,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.error_outline,
                        color: AppColors.warningColor(context),
                        size: 40,
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.black.withAlpha(128),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: isLoading
                      ? null
                      : () => _pickAndUploadImage(imageType),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(153),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class EmergencyContactDialog extends StatefulWidget {
  final UserModel user;
  const EmergencyContactDialog({super.key, required this.user});

  @override
  State<EmergencyContactDialog> createState() => _EmergencyContactDialogState();
}

class _EmergencyContactDialogState extends State<EmergencyContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ✅ FIX: Corregido. Se leen los datos directamente del mapa que provee el UserModel.
    final contact = widget.user.emergencyContact;
    _nameController = TextEditingController(text: contact?['name'] ?? '');
    final rawPhone = contact?['phone'] ?? '';
    _phoneController = TextEditingController(
      text: _formatPhoneNumber(rawPhone),
    );
  }

  String _formatPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 8) {
      return '${digits.substring(0, 4)}-${digits.substring(4)}';
    }
    return phone; // si no tiene 8 dígitos, lo deja igual
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final contactData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    // La clave 'contactInfo.emergencyContact' actualiza correctamente el objeto anidado en Firestore.
    final updatedData = {'contactInfo.emergencyContact': contactData};

    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    final success = await viewModel.updateUserProfile(updatedData);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('contacto_de_emergencia_actualizado'.tr()),
          backgroundColor: AppColors.secondaryColor(context),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el contacto.'),
          backgroundColor: AppColors.warningColor(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentColor(context).withAlpha(26),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        HugeIcons.strokeRoundedContact02,
                        color: AppColors.accentColor(context),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'contacto_de_emergencia'.tr(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentColor(context),
                            ),
                          ),
                          Text(
                            'persona_a_notificar_en_emergencias'.tr(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextFieldEnhanced(
                  controller: _nameController,
                  labelText: 'nombre_completo'.tr(),
                  hintText: 'nombre_del_contacto'.tr(),
                  icon: HugeIcons.strokeRoundedUser,
                  validator: (value) =>
                      AppValidators.validateGenericEmpty(value, 'El nombre'),
                ),
                const SizedBox(height: 16),
                _buildTextFieldEnhanced(
                  controller: _phoneController,
                  labelText: 'telfono'.tr(),
                  hintText: '0000-0000',
                  icon: HugeIcons.strokeRoundedFlipPhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [PhoneInputFormatter()],
                  validator: AppValidators.validatePhone,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'cancelar'.tr(),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: Center(
                            child: PrimaryButton(
                              text: 'guardar'.tr(),
                              onPressed: _handleSave,
                              isLoading: _isLoading,
                              backgroundColor: AppColors.accentColor(context),
                              height: 48,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldEnhanced({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              prefixIcon: Icon(
                icon,
                size: 20,
                color: AppColors.accentColor(context),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.accentColor(context),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
