// lib/view/screens/profile/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  String _getShortName(UserModel user) {
    final firstName = (user.firstName).split(' ').first;
    final lastName = (user.lastName).split(' ').first;
    return '$firstName $lastName'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor(context).withAlpha(30),
              border: Border.all(
                color: AppColors.primaryColor(context).withAlpha(100),
                width: 1.5,
              ),
            ),
            child: Icon(
              HugeIcons.strokeRoundedUser,
              size: 32,
              color: AppColors.primaryColor(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getShortName(user),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor(context),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.only(
                    left: 3,
                    right: 6,
                    top: 4,
                    bottom: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor(context).withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedCalendar04,
                        size: 14,
                        color: AppColors.primaryColor(context),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Miembro desde el\n${DateFormat.yMMMMd('es_ES').format(user.createdAt!.toDate())}',
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLightColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
