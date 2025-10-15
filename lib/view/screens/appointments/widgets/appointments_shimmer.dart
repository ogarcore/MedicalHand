// lib/view/screens/appointments/widgets/appointments_shimmer.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class AppointmentsShimmer extends StatelessWidget {
  const AppointmentsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(16.0.r),
        itemCount: 5,
        itemBuilder: (context, index) => const _ShimmerCard(),
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  Widget _buildPlaceholderLine({
    required double width,
    double height = 14,
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0.h),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(128),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Placeholder for Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(100),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildPlaceholderLine(width: 150.w, height: 16.h),
                ),
                SizedBox(width: 8.w),
                _buildPlaceholderLine(width: 80.w, height: 22.h, borderRadius: 10.r),
              ],
            ),
          ),
          // Placeholder for Content
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlaceholderLine(width: double.infinity, height: 18.h),
                SizedBox(height: 4.h),
                _buildPlaceholderLine(width: 180.w, height: 18.h),
                SizedBox(height: 12.h),
                Row(children: [
                  Container(width: 14.w, height: 14.w, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  SizedBox(width: 8.w),
                  _buildPlaceholderLine(width: 160.w),
                ]),
                SizedBox(height: 8.h),
                Row(children: [
                  Container(width: 14.w, height: 14.w, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  SizedBox(width: 8.w),
                  _buildPlaceholderLine(width: 120.w),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}