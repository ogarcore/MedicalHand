import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTS AÑADIDOS PARA LA NAVEGACIÓN ---
import 'edit_family_member_info_screen.dart';
import 'edit_family_member_medical_info_screen.dart';

// Widgets importados del perfil principal para reutilizar el diseño
import '../profile/widgets/info_card.dart';
import '../profile/widgets/info_row.dart';
import '../profile/widgets/profile_divider.dart';
import '../profile/widgets/profile_section_header.dart';

class FamilyMemberProfileScreen extends StatefulWidget {
  final UserModel member;
  const FamilyMemberProfileScreen({super.key, required this.member});

  @override
  State<FamilyMemberProfileScreen> createState() =>
      _FamilyMemberProfileScreenState();
}

class _FamilyMemberProfileScreenState extends State<FamilyMemberProfileScreen> {
  late UserModel _currentMember;
  
  bool _isUploadingFront = false;
  bool _isUploadingBack = false;

  @override
  void initState() {
    super.initState();
    _currentMember = widget.member;
  }

  // --- FUNCIÓN AÑADIDA PARA NAVEGAR Y ACTUALIZAR DATOS AL REGRESAR ---
  Future<void> _navigateToEditScreen(Widget screen) async {
    // Navega a la pantalla de edición y espera a que se cierre.
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    // Cuando regresa, si la pantalla sigue existiendo, busca los datos actualizados.
    if (mounted) {
      final doc = await FirebaseFirestore.instance.collection('usuarios_movil').doc(_currentMember.uid).get();
      if (doc.exists) {
        // Actualiza el estado con los nuevos datos para refrescar la UI.
        setState(() {
          _currentMember = UserModel.fromFirestore(doc);
        });
      }
    }
  }

  String _formatDateOfBirth(UserModel user) {
    initializeDateFormatting('es_ES', null);
    try {
      return DateFormat(
        'd \'de\' MMMM, y',
        'es_ES',
      ).format(user.dateOfBirth.toDate());
    } catch (e) {
      return 'Fecha no disponible';
    }
  }

  String _formatChronicDiseases(UserModel user) {
    final diseases = user.medicalInfo?['chronicDiseases'] as List?;
    if (diseases == null || diseases.isEmpty) {
      return 'ninguna_reportada'.tr();
    }
    return diseases.join(', ');
  }

  void _showDeleteConfirmation(
    BuildContext context,
    FamilyViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomModal(
          title: 'eliminar_perfil_familiar'.tr(),
          subtitle: 'esta_accin_no_se_puede_deshacer'.tr(),
          icon: HugeIcons.strokeRoundedDelete02,
          content: Text(
            '¿Estás seguro de que deseas eliminar a ${_currentMember.firstName} ${_currentMember.lastName} de tu lista de familiares?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          actions: [
            ModalButton(
              text: 'cancelar'.tr(),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ModalButton(
              text: 'eliminar'.tr(),
              isWarning: true,
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success =
                    await viewModel.deleteFamilyMember(_currentMember.uid);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '${_currentMember.firstName} eliminado.'
                            : 'Error al eliminar.',
                      ),
                      backgroundColor: success
                          ? AppColors.successColor(context)
                          : AppColors.warningColor(context),
                    ),
                  );
                  if (success) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        );
      },
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
                  color: Colors.black.withOpacity(0.5),
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
        'user_identity_documents/${_currentMember.uid}/$imageType.jpg',
      );

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String newDownloadUrl = await snapshot.ref.getDownloadURL();

      String firestoreField =
          isFront ? 'verification.idFrontUrl' : 'verification.idBackUrl';

      final success = await Provider.of<UserViewModel>(
        context,
        listen: false,
      ).updateFamilyMemberProfile(_currentMember.uid, {firestoreField: newDownloadUrl});

      if (success && mounted) {
        setState(() {
          if (isFront) {
            _currentMember.verification?['idFrontUrl'] = newDownloadUrl;
          } else {
            _currentMember.verification?['idBackUrl'] = newDownloadUrl;
          }
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Imagen actualizada con éxito.'
                  : 'Error al actualizar la imagen.',
            ),
            backgroundColor:
                success ? Colors.green.shade700 : Colors.red.shade700,
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
    final familyViewModel = Provider.of<FamilyViewModel>(
      context,
      listen: false,
    );

    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final currentUser = userViewModel.currentUser;
    final activeProfile = userViewModel.activeProfile;

    final bool isTutorViewing = currentUser?.uid == activeProfile?.uid;

    final String? idFrontUrl = _currentMember.verification?['idFrontUrl'];
    final String? idBackUrl = _currentMember.verification?['idBackUrl'];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Perfil de ${_currentMember.firstName}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          children: [
            ProfileSectionHeader(
              title: 'informacin_personal'.tr(),
              icon: HugeIcons.strokeRoundedUserCircle02,
              // --- CAMBIO: Se añade la navegación al botón de editar ---
              onEditPressed: isTutorViewing
                  ? () => _navigateToEditScreen(
                        EditFamilyMemberInfoScreen(member: _currentMember),
                      )
                  : null,
            ),
            InfoCard(
              children: [
                InfoRow(
                  label: 'nombre_completo'.tr(),
                  value: '${_currentMember.firstName} ${_currentMember.lastName}',
                  isFirst: true,
                ),
                const ProfileDivider(),
                InfoRow(
                  label: 'fecha_de_nacimiento'.tr(),
                  value: _formatDateOfBirth(_currentMember),
                ),
                const ProfileDivider(),
                Column(
                  children: [
                    InfoRow(
                        label: 'cdula_de_identidad'.tr(),
                        value: _currentMember.idNumber),
                    if (idFrontUrl != null || idBackUrl != null)
                      _buildIdImageViewer(context, idFrontUrl, idBackUrl),
                  ],
                ),
                const SizedBox(height: 10),
                const ProfileDivider(),
                InfoRow(
                  label: 'telfono'.tr(),
                  value: _currentMember.phoneNumber,
                ),
                const ProfileDivider(),
                InfoRow(
                  label: 'direccin'.tr(),
                  value: _currentMember.address,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ProfileSectionHeader(
              title: 'informacin_mdica'.tr(),
              icon: HugeIcons.strokeRoundedHealth,
              // --- CAMBIO: Se añade la navegación al botón de editar ---
              onEditPressed: isTutorViewing
                  ? () => _navigateToEditScreen(
                        EditFamilyMemberMedicalInfoScreen(member: _currentMember),
                      )
                  : null,
            ),
            InfoCard(
              children: [
                InfoRow(
                  label: 'tipo_de_sangre'.tr(),
                  value:
                      _currentMember.medicalInfo?['bloodType'] ?? 'No especificado',
                  isFirst: true,
                ),
                const ProfileDivider(),
                InfoRow(
                  label: 'alergias_conocidas'.tr(),
                  value: _currentMember.medicalInfo?['knownAllergies'] ??
                      'ninguna_reportada'.tr(),
                ),
                const ProfileDivider(),
                InfoRow(
                  label: 'padecimientos_crnicos'.tr(),
                  value: _formatChronicDiseases(_currentMember),
                  isLast: true,
                ),
              ],
            ),
            if (isTutorViewing) ...[
              const SizedBox(height: 16),
              ProfileSectionHeader(
                title: 'configuracin_de_cuenta'.tr(),
                icon: HugeIcons.strokeRoundedSettings02,
              ),
              InfoCard(
                children: [
                  _buildDeleteActionRow(context, familyViewModel),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteActionRow(
      BuildContext context, FamilyViewModel viewModel) {
    final color = AppColors.warningColor(context);
    return InkWell(
      onTap: () => _showDeleteConfirmation(context, viewModel),
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(HugeIcons.strokeRoundedDelete02, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'eliminar_perfil_familiar'.tr(),
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
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
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: isLoading ? null : () => _pickAndUploadImage(imageType),
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
                  color: Colors.black.withOpacity(0.6),
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