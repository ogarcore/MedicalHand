// lib/view/screens/family/widgets/personal_info_section.dart
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/screens/profile/widgets/info_card.dart';
import 'package:p_hn25/view/screens/profile/widgets/info_row.dart';
import 'package:p_hn25/view/screens/profile/widgets/profile_divider.dart';
import 'package:p_hn25/view/screens/profile/widgets/profile_section_header.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shimmer/shimmer.dart';

class PersonalInfoSection extends StatefulWidget {
  final UserModel member;
  final VoidCallback? onEditPressed;
  final Function(String, String) onImageUpdated;

  const PersonalInfoSection({
    super.key,
    required this.member,
    this.onEditPressed,
    required this.onImageUpdated,
  });

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  bool _isUploadingFront = false;
  bool _isUploadingBack = false;

  String _formatDateOfBirth() {
    try {
      return DateFormat(
        'd \'de\' MMMM, y',
        'es_ES',
      ).format(widget.member.dateOfBirth.toDate());
    } catch (e) {
      return 'Fecha no disponible';
    }
  }

  Future<void> _pickAndUploadImage(String imageType) async {
    final isFront = imageType == 'id_front';
    if ((isFront && _isUploadingFront) || (!isFront && _isUploadingBack)) {
      return;
    }

    if (!await Permission.photos.request().isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('se_necesita_permiso_para_acceder_a_la_galera'.tr()),
          ),
        );
      }
      return;
    }

    setState(
      () => isFront ? _isUploadingFront = true : _isUploadingBack = true,
    );

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return;

      final storageRef = FirebaseStorage.instance.ref(
        'user_identity_documents/${widget.member.uid}/$imageType.jpg',
      );
      final snapshot = await storageRef.putFile(File(pickedFile.path));
      final newUrl = await snapshot.ref.getDownloadURL();

      if (!mounted) return;

      final field = isFront
          ? 'verification.idFrontUrl'
          : 'verification.idBackUrl';
      final success = await context
          .read<UserViewModel>()
          .updateFamilyMemberProfile(widget.member.uid, {field: newUrl});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Imagen actualizada.' : 'Error al actualizar.',
            ),
          ),
        );
        if (success) {
          widget.onImageUpdated(isFront ? 'idFrontUrl' : 'idBackUrl', newUrl);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ocurrió un error.')));
      }
    } finally {
      if (mounted) {
        setState(
          () => isFront ? _isUploadingFront = false : _isUploadingBack = false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final idFrontUrl = widget.member.verification?['idFrontUrl'];
    final idBackUrl = widget.member.verification?['idBackUrl'];

    return Column(
      children: [
        ProfileSectionHeader(
          title: 'informacin_personal'.tr(),
          icon: HugeIcons.strokeRoundedUserCircle02,
          onEditPressed: widget.onEditPressed,
        ),
        InfoCard(
          children: [
            InfoRow(
              label: 'nombre_completo'.tr(),
              value: '${widget.member.firstName} ${widget.member.lastName}',
              isFirst: true,
            ),
            const ProfileDivider(),
            InfoRow(
              label: 'fecha_de_nacimiento'.tr(),
              value: _formatDateOfBirth(),
            ),
            const ProfileDivider(),
            InfoRow(
              label: 'cdula_de_identidad'.tr(),
              value: widget.member.idNumber,
            ),
            if (idFrontUrl != null || idBackUrl != null)
              _IdImageViewer(
                frontUrl: idFrontUrl,
                backUrl: idBackUrl,
                isUploadingFront: _isUploadingFront,
                isUploadingBack: _isUploadingBack,
                onUpload: _pickAndUploadImage,
              ),
            const SizedBox(height: 10),
            const ProfileDivider(),
            InfoRow(label: 'telfono'.tr(), value: widget.member.phoneNumber),
            const ProfileDivider(),
            InfoRow(
              label: 'direccin'.tr(),
              value: widget.member.address,
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }
}

// Internal widget to handle image viewing and uploading UI
class _IdImageViewer extends StatelessWidget {
  final String? frontUrl;
  final String? backUrl;
  final bool isUploadingFront;
  final bool isUploadingBack;
  final Function(String) onUpload;

  const _IdImageViewer({
    this.frontUrl,
    this.backUrl,
    required this.isUploadingFront,
    required this.isUploadingBack,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (frontUrl != null)
            Expanded(
              child: _ImageContainer(
                'frente_de_la_cdula'.tr(),
                frontUrl!,
                'id_front',
                isUploadingFront,
                onUpload,
              ),
            ),
          if (frontUrl != null && backUrl != null) SizedBox(width: 16.w),
          if (backUrl != null)
            Expanded(
              child: _ImageContainer(
                'reverso_de_la_cdula'.tr(),
                backUrl!,
                'id_back',
                isUploadingBack,
                onUpload,
              ),
            ),
        ],
      ),
    );
  }
}

// Internal widget for a single image container with actions
class _ImageContainer extends StatelessWidget {
  final String label, url, imageType;
  final bool isLoading;
  final Function(String) onUpload;

  const _ImageContainer(
    this.label,
    this.url,
    this.imageType,
    this.isLoading,
    this.onUpload,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 8.h),
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => _showImageDialog(context, url),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  height: 100.h,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Image.network(
                    url,
                    key: ValueKey(url),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          ),
                    errorBuilder: (context, _, __) => Icon(
                      Icons.error_outline,
                      color: AppColors.warningColor(context),
                      size: 40.sp,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4.h,
              right: 4.w,
              child: Material(
                color: Colors.black.withAlpha(128),
                borderRadius: BorderRadius.circular(20.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: isLoading ? null : () => onUpload(imageType),
                  child: Padding(
                    padding: EdgeInsets.all(4.0.r),
                    child: Icon(Icons.edit, color: Colors.white, size: 18.sp),
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                height: 100.h,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(153),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(10.r),
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
