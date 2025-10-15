import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'question': '¿Cómo funciona la "Fila Virtual"?',
        'answer':
            'La Fila Virtual se activa automáticamente el día de tu cita. La aplicación te notificará cuando se acerque tu turno para que puedas dirigirte a la sala de espera. Ya no necesitas hacer un registro manual al llegar; el sistema te gestiona para minimizar tu tiempo en el hospital.',
      },
      {
        'question': '¿Cómo puedo reprogramar o cancelar una cita?',
        'answer':
            'Ve a la sección "Mis Citas" y busca la cita en la pestaña "Próximas". Toca el ícono de opciones (los tres puntos) en la tarjeta de la cita. Se desplegará un menú donde podrás seleccionar "Reprogramar" para solicitar un cambio de fecha, o "Cancelar" para anularla.',
      },
      {
        'question': '¿Cómo cambio para gestionar el perfil de un familiar?',
        'answer':
            'Dirígete a la sección "Familia" en la barra de navegación principal. Allí verás una lista con tu perfil y los de tus familiares. Simplemente toca sobre el nombre del familiar cuyo perfil deseas ver o gestionar y la aplicación cambiará a su vista.',
      },
      {
        'question': 'Mi cita aparece como "Pendiente", ¿qué significa?',
        'answer':
            'Significa que el hospital ha recibido tu solicitud y está en proceso de asignarte una fecha y hora. Recibirás una notificación tan pronto como tu cita sea confirmada. Si permanece así por más de 48 horas, te recomendamos contactar al hospital.',
      },
      {
        'question': '¿Están seguros mis datos médicos en la aplicación?',
        'answer':
            'Absolutamente. Tu seguridad es nuestra máxima prioridad. Toda tu información está encriptada y se almacena en servidores seguros, cumpliendo con los estándares de protección de datos de salud.',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'soporte_y_ayuda'.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          _buildSupportHeader(context),
          SizedBox(height: 32.h),
          _buildSectionTitle('Contacta con Nosotros', context),
          SizedBox(height: 16.h),
          _buildContactOption(
            context: context,
            icon: HugeIcons.strokeRoundedMail01,
            title: 'enviar_un_correo'.tr(),
            subtitle: 'recibe_respuesta_en_aproximadamente_24_horas'.tr(),
            color: const Color(0xFF2979FF),
            onTap: () {
              // Lógica para abrir el cliente de correo
            },
          ),
          SizedBox(height: 32.h),
          _buildSectionTitle('Preguntas Frecuentes', context),
          SizedBox(height: 16.h),
          ...faqs.map(
            (faq) =>
                FaqItem(question: faq['question']!, answer: faq['answer']!),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textColor(context),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildSupportHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor(context).withAlpha(20),
            AppColors.primaryColor(context).withAlpha(30),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primaryColor(context).withAlpha(30),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor(context).withAlpha(30),
            ),
            child: Icon(
              HugeIcons.strokeRoundedCustomerService01,
              size: 30.sp,
              color: AppColors.primaryColor(context),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Necesitas ayuda?',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor(context),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'estamos_aqu_para_asistirte_con_cualquier_duda_o_problema_que'
                      .tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textLightColor(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withAlpha(40), width: 1.w),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          splashColor: color.withAlpha(40),
          highlightColor: color.withAlpha(20),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withAlpha(30),
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor(context),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textLightColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: AppColors.textLightColor(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const FaqItem({super.key, required this.question, required this.answer});

  @override
  State<FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<FaqItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withAlpha(40), width: 1.w),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: AppColors.primaryColor(context).withAlpha(30),
          highlightColor: AppColors.primaryColor(context).withAlpha(15),
        ),
        child: ExpansionTile(
          title: Text(
            widget.question,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor(context),
            ),
          ),
          onExpansionChanged: (isExpanding) {
            if (isExpanding) {
              Future.delayed(const Duration(milliseconds: 200), () {
                if (!mounted) return;
                Scrollable.ensureVisible(
                  // ignore: use_build_context_synchronously
                  context,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  alignment: 0.3,
                );
              });
            }
          },
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          iconColor: AppColors.primaryColor(context),
          collapsedIconColor: AppColors.textLightColor(context),
          children: [
            Text(
              widget.answer,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textLightColor(context),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}