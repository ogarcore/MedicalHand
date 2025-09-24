// lib/view/screens/home/widgets/notification_icon_button.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view_model/notification_view_model.dart';
import 'package:provider/provider.dart';

class NotificationIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const NotificationIconButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Usamos un Consumer para que el botón se actualice automáticamente
    // cada vez que cambie el estado en el NotificationViewModel.
    return Consumer<NotificationViewModel>(
      builder: (context, viewModel, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onPressed,
                icon: Icon(
                  HugeIcons.strokeRoundedNotification03,
                  color: AppColors.textColor(context).withAlpha(204),
                  size: 25,
                ),
              ),
            ),
            // El punto rojo ahora depende del estado en el ViewModel,
            // que se actualiza en tiempo real.
            if (viewModel.hasUnreadNotifications)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.warningColor(context),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
