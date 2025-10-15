// lib/view/screens/family/widgets/chronic_diseases_section.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'edit_enhanced_text_field.dart';

class ChronicDiseasesSection extends StatefulWidget {
  final List<String> initialDiseases;
  final ValueChanged<List<String>> onDiseasesChanged;

  const ChronicDiseasesSection({
    super.key,
    required this.initialDiseases,
    required this.onDiseasesChanged,
  });

  @override
  State<ChronicDiseasesSection> createState() => _ChronicDiseasesSectionState();
}

class _ChronicDiseasesSectionState extends State<ChronicDiseasesSection> {
  late final TextEditingController _controller;
  late List<String> _diseases;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _diseases = List.from(widget.initialDiseases);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addDisease() {
    final newDisease = _controller.text.trim();
    if (newDisease.isNotEmpty && !_diseases.contains(newDisease)) {
      setState(() {
        _diseases.add(newDisease);
        _controller.clear();
        widget.onDiseasesChanged(_diseases); // Notify parent of the change
      });
    }
  }

  void _removeDisease(String disease) {
    setState(() {
      _diseases.remove(disease);
      widget.onDiseasesChanged(_diseases); // Notify parent of the change
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditEnhancedTextField(
          controller: _controller,
          labelText: 'padecimientos_crnicos'.tr(),
          hintText: 'ej_hipertensin_diabetes'.tr(),
          icon: HugeIcons.strokeRoundedHealth,
          suffixIcon: IconButton(
            icon: Icon(Icons.add_circle, color: AppColors.accentColor(context)),
            onPressed: _addDisease,
          ),
          onSubmitted: (_) => _addDisease(),
        ),
        if (_diseases.isNotEmpty) SizedBox(height: 12.h),
        Wrap(
          spacing: 8.0.w,
          runSpacing: 4.0.h,
          children: _diseases.map((disease) {
            return Chip(
              label: Text(disease, style: const TextStyle(fontWeight: FontWeight.w500)),
              onDeleted: () => _removeDisease(disease),
              deleteIcon: Icon(Icons.close, size: 18.sp),
              backgroundColor: AppColors.accentColor(context).withAlpha(26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
                side: BorderSide(
                    color: AppColors.accentColor(context).withAlpha(51)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}