import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Soporte y Ayuda',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildSupportHeader(),
          const SizedBox(height: 32),
          _buildSectionTitle('Contacta con Nosotros'),
          const SizedBox(height: 16),
          
          _buildContactOption(
            icon: HugeIcons.strokeRoundedMail01,
            title: 'Enviar un Correo',
            subtitle: 'Recibe respuesta en aproximadamente 24 horas',
            color: const Color(0xFF2979FF),
            onTap: () {},
          ),
          
          const SizedBox(height: 32),
          _buildSectionTitle('Preguntas Frecuentes'),
          const SizedBox(height: 16),
          _buildFaqItem(
            question: '¿Cómo solicito una nueva cita?',
            answer:
                'Ve a la pantalla principal, toca el botón "Solicitar Cita", elige la especialidad, el hospital y describe tu motivo. Recibirás una notificación cuando tu cita sea asignada.',
          ),
          _buildFaqItem(
            question: '¿Puedo ver los resultados de mis exámenes?',
            answer:
                'Sí. En la sección "Mi Historial Clínico", podrás ver un resumen de tus resultados. Si hay documentos adjuntos, tendrás la opción de descargarlos en formato PDF.',
          ),
          _buildFaqItem(
            question: '¿Cómo cancelo una cita?',
            answer:
                'En la pestaña "Próximas" de la sección "Mis Citas", encontrarás un ícono de bote de basura en la esquina de la tarjeta de la cita. Tócalo para iniciar el proceso de cancelación.',
          ),
          _buildFaqItem(
            question: '¿Cómo agrego a un familiar?',
            answer:
                'Ve a la sección "Mis Familiares" y toca el botón "+". Completa la información requerida y podrás gestionar su perfil médico.',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textColor,
      ),
    );
  }

  // Widget para la cabecera de la pantalla de soporte
  Widget _buildSupportHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withAlpha(40),
            AppColors.primaryColor.withAlpha(30),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryColor.withAlpha(15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withAlpha(150),
                ],
              ),
            ),
            child: Icon(
              HugeIcons.strokeRoundedCustomerService01,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Necesitas ayuda?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Estamos aquí para asistirte con cualquier duda o problema que tengas.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLightColor,
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

  // Widget reutilizable para las opciones de contacto
  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withAlpha(25),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textLightColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textLightColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para los items de preguntas frecuentes (FAQ)
  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          trailing: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withAlpha(40),
            ),
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.primaryColor,
            ),
          ),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLightColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
